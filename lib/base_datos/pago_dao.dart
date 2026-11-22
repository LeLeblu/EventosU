import 'package:sqflite/sqflite.dart';

import '../modelos/resultado_pago.dart';
import 'database_helper.dart';
import 'billetera_dao.dart';
import 'inscripcion_dao.dart';
import 'notificacion_dao.dart';

class ErrorPago implements Exception {
  final String mensaje;
  const ErrorPago(this.mensaje);
}

class PagoDao {
  final Database db;
  PagoDao(this.db);
  static Future<PagoDao> abrir() async =>
      PagoDao(await DatabaseHelper.iniciarDB());

  Future<ResultadoPago> pagar(
    int idUsuario,
    int idEvento, {
    required int precioConfirmado,
  }) async {
    return db.transaction((txn) async {
      final eventos = await txn.query(
        'evento',
        where: 'idEvento = ?',
        whereArgs: [idEvento],
      );
      if (eventos.isEmpty) throw const ErrorPago('El evento ya no existe');
      final evento = eventos.single;
      final monto = evento['precio'] as int;
      if (monto <= 0) {
        throw const ErrorPago(
          'Este evento no requiere pago. Inscríbete desde su detalle',
        );
      }
      if (monto != precioConfirmado) {
        throw const ErrorPago(
          'El precio cambió. Revisa el importe actualizado antes de pagar',
        );
      }
      final anteriores = await txn.query(
        'inscripcion',
        where: 'idUsuario = ? AND idEvento = ?',
        whereArgs: [idUsuario, idEvento],
      );
      if (anteriores.isNotEmpty) {
        final anterior = anteriores.single;
        final pagos = await txn.query(
          'pago',
          columns: ['idPago'],
          where: 'idInscripcion = ?',
          whereArgs: [anterior['idInscripcion']],
        );
        if (pagos.isNotEmpty) {
          throw const ErrorPago('Esta inscripción ya tiene un pago registrado');
        }
        if (anterior['estado'] != 'cancelada') {
          throw const ErrorPago('Ya existe una inscripción para este evento');
        }
      }
      final billeteras = await txn.query(
        'billetera',
        where: 'idUsuario = ?',
        whereArgs: [idUsuario],
      );
      if (billeteras.isEmpty) {
        throw const ErrorPago('No se encontró tu billetera');
      }
      final billetera = billeteras.single;
      if ((billetera['saldo'] as int) < monto) {
        throw const ErrorPago(
          'Saldo insuficiente. Recarga tu billetera para continuar',
        );
      }
      final cupo = await txn.rawUpdate(
        '''UPDATE evento
        SET cuposDisponibles = cuposDisponibles - 1
        WHERE idEvento = ? AND cuposDisponibles > 0''',
        [idEvento],
      );
      if (cupo != 1) throw const ErrorPago('No quedan cupos disponibles');
      final fecha = DateTime.now().toUtc().toIso8601String();
      final descontada = await txn.rawUpdate(
        '''UPDATE billetera
        SET saldo = saldo - ?, fechaActualizacion = ?
        WHERE idUsuario = ? AND saldo >= ?''',
        [monto, fecha, idUsuario, monto],
      );
      if (descontada != 1) throw const ErrorPago('Saldo insuficiente');
      final int idInscripcion;
      if (anteriores.isEmpty) {
        idInscripcion = await txn.insert('inscripcion', {
          'idUsuario': idUsuario,
          'idEvento': idEvento,
          'fechaInscripcion': fecha,
          'estado': 'activa',
        });
      } else {
        idInscripcion = anteriores.single['idInscripcion'] as int;
        await txn.update(
          'inscripcion',
          {'estado': 'activa', 'fechaInscripcion': fecha},
          where: 'idInscripcion = ?',
          whereArgs: [idInscripcion],
        );
      }
      final idPago = await txn.insert('pago', {
        'idInscripcion': idInscripcion,
        'monto': monto,
        'fechaPago': fecha,
        'estado': 'exitoso',
      });
      await txn.insert('movimiento', {
        'idBilletera': billetera['idBilletera'],
        'idPago': idPago,
        'tipo': 'pago',
        'monto': monto,
        'descripcion': 'Pago de ${evento['titulo']}',
        'fechaMovimiento': fecha,
      });
      final notificaciones = NotificacionDao(db);
      await notificaciones.avisarInscripcion(
        idUsuario: idUsuario,
        evento: evento['titulo'] as String,
        requierePago: false,
        conexion: txn,
      );
      await notificaciones.crear(
        idUsuario: idUsuario,
        titulo: 'Pago realizado',
        mensaje: 'Pagaste $monto COP por "${evento['titulo']}".',
        conexion: txn,
      );
      return ResultadoPago(
        billetera: await BilleteraDao(db).consultarEn(txn, idUsuario),
        inscripcion: await InscripcionDao(db)
            .obtenerConfirmadaEn(txn, idUsuario, idEvento),
      );
    });
  }
}
