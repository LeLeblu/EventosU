import 'package:sqflite/sqflite.dart';

import '../modelos/inscripcion.dart';
import '../servicios/evento.dart';
import '../servicios/complemento_eventos.dart';
import 'database_helper.dart';
import 'notificacion_dao.dart';

class ErrorInscripcion implements Exception {
  final String mensaje;
  const ErrorInscripcion(this.mensaje);
}

/// Recibe la conexion para poder probar las transacciones en una base aislada.
class InscripcionDao {
  final Database db;
  InscripcionDao(this.db);
  static Future<InscripcionDao> abrir() async =>
      InscripcionDao(await DatabaseHelper.iniciarDB());

  static const _consulta = '''
    SELECT i.idInscripcion, i.estado AS estadoInscripcion,
      u.nombre AS nombreUsuario, u.correo AS correoUsuario,
      e.*, c.nombre AS categoria
    FROM inscripcion i
    JOIN usuario u ON u.idUsuarios = i.idUsuario
    JOIN evento e ON e.idEvento = i.idEvento
    JOIN categoria c ON c.idCategoria = e.idCategoria
  ''';

  static Inscripcion _convertir(Map<String, Object?> fila) {
    final complemento = complementoEvento(fila);
    return Inscripcion(
      idInscripcion: fila['idInscripcion'] as int,
      evento: Evento.desdeMapa(
        fila,
        organizador: complemento.organizador,
        subcategoria: complemento.subcategoria,
      ),
      nombre: fila['nombreUsuario'] as String,
      correo: fila['correoUsuario'] as String,
      estado: fila['estadoInscripcion'] == 'activa'
          ? 'Inscrito'
          : 'Pendiente de pago',
    );
  }

  Future<List<Inscripcion>> listar(int idUsuario) async {
    final filas = await db.rawQuery(
      '''$_consulta
      WHERE i.idUsuario = ? AND i.estado = 'activa'
      ORDER BY i.fechaInscripcion DESC, i.idInscripcion DESC
    ''',
      [idUsuario],
    );
    return filas.map(_convertir).toList();
  }

  Future<Inscripcion> obtenerConfirmadaEn(
    DatabaseExecutor conexion,
    int idUsuario,
    int idEvento,
  ) async {
    final filas = await conexion.rawQuery(
      "$_consulta WHERE i.idUsuario = ? AND i.idEvento = ? AND i.estado = 'activa'",
      [idUsuario, idEvento],
    );
    if (filas.isEmpty) {
      throw const ErrorInscripcion('No se encontró la inscripción');
    }
    return _convertir(filas.single);
  }

  Future<Inscripcion> registrarGratis(int idUsuario, int idEvento) async {
    return db.transaction((txn) async {
      final eventos = await txn.query(
        'evento',
        where: 'idEvento = ?',
        whereArgs: [idEvento],
      );
      if (eventos.isEmpty) {
        throw const ErrorInscripcion('El evento ya no existe');
      }
      final evento = eventos.single;
      if (evento['precio'] != 0) {
        throw const ErrorInscripcion(
          'Este evento requiere pago. Actualiza el detalle',
        );
      }
      final anteriores = await txn.query(
        'inscripcion',
        where: 'idUsuario = ? AND idEvento = ?',
        whereArgs: [idUsuario, idEvento],
      );
      if (anteriores.isNotEmpty && anteriores.single['estado'] != 'cancelada') {
        throw const ErrorInscripcion('Ya estás inscrito en este evento');
      }
      if (anteriores.isNotEmpty) {
        final pagos = await txn.query(
          'pago',
          columns: ['idPago'],
          where: 'idInscripcion = ?',
          whereArgs: [anteriores.single['idInscripcion']],
        );
        if (pagos.isNotEmpty) {
          throw const ErrorInscripcion('La inscripción tiene un pago asociado');
        }
      }
      final actualizados = await txn.rawUpdate(
        '''
        UPDATE evento SET cuposDisponibles = cuposDisponibles - 1
        WHERE idEvento = ? AND cuposDisponibles > 0 AND precio = 0
      ''',
        [idEvento],
      );
      if (actualizados != 1) {
        throw const ErrorInscripcion('No quedan cupos disponibles');
      }
      final fecha = DateTime.now().toUtc().toIso8601String();
      if (anteriores.isEmpty) {
        await txn.insert('inscripcion', {
          'idUsuario': idUsuario,
          'idEvento': idEvento,
          'fechaInscripcion': fecha,
          'estado': 'activa',
        });
      } else {
        // Reutilizar la fila cancelada respeta UNIQUE(idUsuario, idEvento).
        await txn.update(
          'inscripcion',
          {'estado': 'activa', 'fechaInscripcion': fecha},
          where: 'idInscripcion = ?',
          whereArgs: [anteriores.single['idInscripcion']],
        );
      }
      await NotificacionDao(db).avisarInscripcion(
        idUsuario: idUsuario,
        evento: evento['titulo'] as String,
        requierePago: false,
        conexion: txn,
      );
      final filas = await txn.rawQuery(
        '$_consulta WHERE i.idUsuario = ? AND i.idEvento = ?',
        [idUsuario, idEvento],
      );
      return _convertir(filas.single);
    });
  }

  Future<void> cancelar(int idUsuario, int idEvento) async {
    await db.transaction((txn) async {
      final filas = await txn.query(
        'inscripcion',
        where: "idUsuario = ? AND idEvento = ? AND estado = 'activa'",
        whereArgs: [idUsuario, idEvento],
      );
      if (filas.isEmpty) {
        return; // Repetir la cancelacion no devuelve otro cupo.
      }
      final id = filas.single['idInscripcion'];
      final pagos = await txn.query(
        'pago',
        columns: ['idPago'],
        where: 'idInscripcion = ?',
        whereArgs: [id],
      );
      if (pagos.isNotEmpty) {
        throw const ErrorInscripcion(
          'No se puede cancelar una inscripción con pago desde esta opción',
        );
      }
      await txn.update(
        'inscripcion',
        {'estado': 'cancelada'},
        where: 'idInscripcion = ?',
        whereArgs: [id],
      );
      await txn.rawUpdate(
        'UPDATE evento SET cuposDisponibles = cuposDisponibles + 1 WHERE idEvento = ?',
        [idEvento],
      );
      final eventos = await txn.query(
        'evento',
        columns: ['titulo'],
        where: 'idEvento = ?',
        whereArgs: [idEvento],
      );
      await NotificacionDao(db).crear(
        idUsuario: idUsuario,
        titulo: 'Inscripción cancelada',
        mensaje: 'Cancelaste tu inscripción a "${eventos.single['titulo']}".',
        conexion: txn,
      );
    });
  }

  Future<Evento> eventoParaCalendario(int idUsuario, int idEvento) async {
    final filas = await db.rawQuery(
      '''$_consulta
      WHERE i.idUsuario = ? AND i.idEvento = ? AND i.estado = 'activa'
        AND (e.precio = 0 OR EXISTS (
          SELECT 1 FROM pago p WHERE p.idInscripcion = i.idInscripcion
          AND p.estado = 'exitoso'))
    ''',
      [idUsuario, idEvento],
    );
    if (filas.isEmpty) {
      throw const ErrorInscripcion('Primero debes confirmar tu inscripción');
    }
    return _convertir(filas.single).evento;
  }
}
