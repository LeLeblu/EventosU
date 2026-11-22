import 'package:sqflite/sqflite.dart';

import '../modelos/billetera.dart';
import 'database_helper.dart';
import 'notificacion_dao.dart';

class ErrorBilletera implements Exception {
  final String mensaje;
  const ErrorBilletera(this.mensaje);
}

class BilleteraDao {
  final Database db;
  BilleteraDao(this.db);
  static const maximoSaldo = 9223372036854775807;

  static Future<BilleteraDao> abrir() async =>
      BilleteraDao(await DatabaseHelper.iniciarDB());

  Future<Billetera> consultarEn(
    DatabaseExecutor conexion,
    int idUsuario,
  ) async {
    final filas = await conexion.query(
      'billetera',
      where: 'idUsuario = ?',
      whereArgs: [idUsuario],
    );
    if (filas.isEmpty) {
      throw const ErrorBilletera('No se encontró la billetera de esta cuenta');
    }
    final fila = filas.single;
    final movimientos = await conexion.query(
      'movimiento',
      where: 'idBilletera = ?',
      whereArgs: [fila['idBilletera']],
      orderBy: 'fechaMovimiento DESC, idMovimiento DESC',
    );
    return Billetera(
      idBilletera: fila['idBilletera'] as int,
      idUsuario: idUsuario,
      saldo: fila['saldo'] as int,
      movimientos: movimientos.map(Movimiento.desdeMapa).toList(),
    );
  }

  Future<Billetera> obtener(int idUsuario) =>
      db.transaction((txn) => consultarEn(txn, idUsuario));

  Future<Billetera> recargar(int idUsuario, int monto) async {
    if (monto <= 0) {
      throw const ErrorBilletera('Ingresa un monto mayor que cero');
    }
    return db.transaction((txn) async {
      final filas = await txn.query(
        'billetera',
        where: 'idUsuario = ?',
        whereArgs: [idUsuario],
      );
      if (filas.isEmpty) {
        throw const ErrorBilletera(
          'No se encontró la billetera de esta cuenta',
        );
      }
      final billetera = filas.single;
      final saldo = billetera['saldo'] as int;
      // Comprobar antes de sumar evita exceder el INTEGER de SQLite.
      if (saldo < 0 || saldo > maximoSaldo - monto) {
        throw const ErrorBilletera('El monto supera el saldo máximo permitido');
      }
      final fecha = DateTime.now().toUtc().toIso8601String();
      await txn.rawUpdate(
        '''UPDATE billetera
        SET saldo = saldo + ?, fechaActualizacion = ? WHERE idUsuario = ?''',
        [monto, fecha, idUsuario],
      );
      await txn.insert('movimiento', {
        'idBilletera': billetera['idBilletera'],
        'tipo': 'recarga',
        'monto': monto,
        'descripcion': 'Recarga de saldo',
        'fechaMovimiento': fecha,
      });
      await NotificacionDao(db).crear(
        idUsuario: idUsuario,
        titulo: 'Recarga exitosa',
        mensaje: 'Se agregaron $monto COP a tu billetera.',
        conexion: txn,
      );
      return consultarEn(txn, idUsuario);
    });
  }
}
