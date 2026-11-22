// flutter run -t tool/verificar_billetera.dart
// Prueba el DAO real en una base temporal, sin abrir eventosu.db.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:eventos_app/base_datos/database_helper.dart';
import 'package:eventos_app/base_datos/billetera_dao.dart';

void comprobar(bool condicion, String mensaje) {
  if (!condicion) throw StateError(mensaje);
}

Future<void> rechaza(Future<Object?> Function() accion) async {
  try {
    await accion();
  } on ErrorBilletera {
    return;
  }
  throw StateError('Debio rechazar la operacion');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directorio = await Directory.systemTemp.createTemp('eventosu_fase6_');
  final ruta = join(directorio.path, 'prueba.db');
  Database? db;
  String resultado;
  try {
    db = await DatabaseHelper.iniciarDB(rutaAlternativa: ruta);
    var dao = BilleteraDao(db);
    for (var i = 1; i <= 2; i++) {
      await db.insert('usuario', {
        'nombre': 'Prueba',
        'correo': '$i@example.com',
        'contrasenaHash': 'dato-de-prueba',
        'fechaRegistro': '2026-11-21',
      });
      await db.insert('billetera', {
        'idUsuario': i,
        'saldo': 0,
        'fechaActualizacion': '2026-11-21',
      });
    }
    comprobar((await dao.obtener(1)).saldo == 0, 'Saldo inicial cero');
    await rechaza(() => dao.recargar(1, 0));
    await rechaza(() => dao.recargar(1, -1));
    await rechaza(() => dao.recargar(99, 500));
    final recargada = await dao.recargar(1, 5000);
    comprobar(
      recargada.saldo == 5000 && recargada.movimientos.single.monto == 5000,
      'Debe guardar saldo e historial',
    );
    comprobar(recargada.movimientos.single.tipo == 'recarga', 'Tipo correcto');
    comprobar(
      (await dao.obtener(2)).saldo == 0 &&
          (await dao.obtener(2)).movimientos.isEmpty,
      'No debe modificar otra cuenta',
    );
    comprobar(
      (await db.query('notificacion')).single['idUsuario'] == 1,
      'Debe notificar al propietario',
    );
    await Future.wait([dao.recargar(1, 100), dao.recargar(1, 200)]);
    final acumulada = await dao.obtener(1);
    comprobar(
      acumulada.saldo == 5300 && acumulada.movimientos.length == 3,
      'Las recargas concurrentes no deben perder actualizaciones',
    );
    comprobar(
      acumulada.movimientos.first.idMovimiento >
          acumulada.movimientos.last.idMovimiento,
      'Historial mas reciente primero',
    );

    for (final tabla in ['movimiento', 'notificacion']) {
      await db.execute('''CREATE TRIGGER fallo_recarga BEFORE INSERT ON $tabla
        BEGIN SELECT RAISE(ABORT, 'fallo de recarga'); END''');
      var falloEsperado = false;
      try {
        await dao.recargar(1, 700);
      } on DatabaseException catch (error) {
        falloEsperado = error.toString().contains('fallo de recarga');
      }
      comprobar(falloEsperado, 'Debe detectar el fallo forzado');
      comprobar((await dao.obtener(1)).saldo == 5300, 'Debe revertir el saldo');
      comprobar(
        (await db.query('movimiento')).length == 3,
        'No debe dejar movimientos parciales',
      );
      comprobar(
        (await db.query('notificacion')).length == 3,
        'No debe dejar avisos parciales',
      );
      await db.execute('DROP TRIGGER fallo_recarga');
    }
    await db.update(
      'billetera',
      {'saldo': BilleteraDao.maximoSaldo},
      where: 'idUsuario = ?',
      whereArgs: [2],
    );
    await rechaza(() => dao.recargar(2, 1));
    comprobar(
      (await dao.obtener(2)).saldo == BilleteraDao.maximoSaldo,
      'No debe desbordar el entero',
    );
    var negativoRechazado = false;
    try {
      await db.update(
        'billetera',
        {'saldo': -1},
        where: 'idUsuario = ?',
        whereArgs: [1],
      );
    } on DatabaseException {
      negativoRechazado = true;
    }
    comprobar(negativoRechazado, 'SQLite debe impedir saldos negativos');
    await db.close();
    db = await DatabaseHelper.iniciarDB(rutaAlternativa: ruta);
    dao = BilleteraDao(db);
    final persistida = await dao.obtener(1);
    comprobar(
      persistida.saldo == 5300 && persistida.movimientos.length == 3,
      'Saldo e historial deben persistir al reabrir',
    );
    comprobar(
      (await db.rawQuery('PRAGMA foreign_key_check')).isEmpty,
      'Integridad referencial',
    );
    resultado = 'FASE6_OK: saldo, historial, notificaciones, usuarios, concurrencia, limites y rollback.';
  } catch (error, stack) {
    resultado = 'FASE6_ERROR: $error';
    debugPrintStack(stackTrace: stack);
  } finally {
    await db?.close();
    await deleteDatabase(ruta);
    await directorio.delete();
  }
  debugPrint(resultado);
  runApp(
    MaterialApp(
      home: Scaffold(body: Center(child: Text(resultado))),
    ),
  );
}
