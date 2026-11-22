// flutter run -t tool/verificar_pagos.dart
// Ejecuta los DAO reales en una base temporal, sin abrir eventosu.db.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:eventos_app/base_datos/database_helper.dart';
import 'package:eventos_app/base_datos/pago_dao.dart';
import 'package:eventos_app/base_datos/billetera_dao.dart';
import 'package:eventos_app/base_datos/inscripcion_dao.dart';

void comprobar(bool condicion, String mensaje) {
  if (!condicion) throw StateError(mensaje);
}

Future<void> rechaza(Future<Object?> Function() accion) async {
  try {
    await accion();
  } on ErrorPago {
    return;
  }
  throw StateError('Debio rechazar el pago');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directorio = await Directory.systemTemp.createTemp('eventosu_fase7_');
  final ruta = join(directorio.path, 'prueba.db');
  Database? db;
  String resultado;
  try {
    db = await DatabaseHelper.iniciarDB(rutaAlternativa: ruta);
    var dao = PagoDao(db);
    for (var i = 1; i <= 4; i++) {
      await db.insert('usuario', {
        'nombre': 'Prueba',
        'correo': '$i@example.com',
        'contrasenaHash': 'dato-de-prueba',
        'fechaRegistro': '2026-11-21',
      });
      await db.insert('billetera', {
        'idUsuario': i,
        'saldo': i == 2 ? 0 : 30000,
        'fechaActualizacion': '2026-11-21',
      });
    }
    await db.insert('categoria', {'nombre': 'Prueba'});
    final precios = [10000, 0, 30000, 1000, 5000, 20000, 20000, 1000];
    for (var i = 0; i < precios.length; i++) {
      await db.insert('evento', {
        'titulo': 'Evento',
        'fecha': '2026-12-01',
        'hora': '10:00',
        'ubicacion': 'Campus',
        'idCategoria': 1,
        'precio': precios[i],
        'cuposDisponibles': i == 0 ? 2 : 1,
      });
    }
    final pagado = await dao.pagar(1, 1, precioConfirmado: 10000);
    comprobar(
      pagado.billetera.saldo == 20000,
      'Debe descontar el precio de SQLite',
    );
    comprobar(pagado.inscripcion.evento.cupos == 1, 'Debe descontar un cupo');
    comprobar(
      pagado.inscripcion.idInscripcion != null,
      'Debe persistir la inscripcion',
    );
    comprobar(
      pagado.billetera.movimientos.single.tipo == 'pago',
      'Debe registrar movimiento',
    );
    comprobar(
      (await db.query('pago')).single['monto'] == 10000,
      'Monto del pago correcto',
    );
    comprobar(
      (await db.query('notificacion')).length == 2,
      'Debe notificar pago e inscripcion',
    );
    await rechaza(() => dao.pagar(1, 1, precioConfirmado: 10000));
    await rechaza(() => dao.pagar(2, 1, precioConfirmado: 10000));
    await rechaza(() => dao.pagar(1, 2, precioConfirmado: 0));
    await rechaza(() => dao.pagar(1, 3, precioConfirmado: 12345));
    await rechaza(() => dao.pagar(99, 1, precioConfirmado: 10000));
    comprobar(
      (await db.query('pago')).length == 1,
      'Los rechazos no crean pagos',
    );
    comprobar(
      (await BilleteraDao(db).obtener(1)).saldo == 20000,
      'Los rechazos no cobran',
    );

    // Falla cada etapa y verifica que no quede ninguna escritura parcial.
    for (final tabla in [
      'evento',
      'billetera',
      'inscripcion',
      'pago',
      'movimiento',
      'notificacion',
    ]) {
      final accion = ['evento', 'billetera'].contains(tabla)
          ? 'UPDATE'
          : 'INSERT';
      final condicion = tabla == 'notificacion'
          ? "WHEN NEW.titulo = 'Pago realizado'"
          : '';
      await db.execute('''CREATE TRIGGER fallo_pago BEFORE $accion ON $tabla
        $condicion BEGIN SELECT RAISE(ABORT, 'fallo de pago'); END''');
      var revertido = false;
      try {
        await dao.pagar(1, 4, precioConfirmado: 1000);
      } on DatabaseException catch (error) {
        revertido = error.toString().contains('fallo de pago');
      }
      comprobar(revertido, 'Debe fallar en $tabla');
      comprobar(
        (await BilleteraDao(db).obtener(1)).saldo == 20000,
        'Debe restaurar saldo: $tabla',
      );
      comprobar(
        (await db.query(
              'evento',
              where: 'idEvento = ?',
              whereArgs: [4],
            )).single['cuposDisponibles'] ==
            1,
        'Debe restaurar cupo: $tabla',
      );
      for (final nombre in ['inscripcion', 'pago', 'movimiento']) {
        comprobar(
          (await db.query(nombre)).length == 1,
          'No debe dejar filas en $nombre tras fallo en $tabla',
        );
      }
      comprobar(
        (await db.query('notificacion')).length == 2,
        'Debe restaurar notificaciones',
      );
      await db.execute('DROP TRIGGER fallo_pago');
    }
    final ultimoCupo = await Future.wait(
      [1, 3].map((usuario) async {
        try {
          await dao.pagar(usuario, 5, precioConfirmado: 5000);
          return true;
        } on ErrorPago {
          return false;
        }
      }),
    );
    comprobar(
      ultimoCupo.where((ok) => ok).length == 1,
      'Solo un pago obtiene el ultimo cupo',
    );
    final saldoLimitado = await Future.wait(
      [6, 7].map((evento) async {
        try {
          await dao.pagar(4, evento, precioConfirmado: 20000);
          return true;
        } on ErrorPago {
          return false;
        }
      }),
    );
    comprobar(
      saldoLimitado.where((ok) => ok).length == 1,
      'No debe gastar dos veces el saldo',
    );
    comprobar(
      (await BilleteraDao(db).obtener(4)).saldo == 10000,
      'Saldo final sin sobregiro',
    );
    final cancelada = await db.insert('inscripcion', {
      'idUsuario': 1,
      'idEvento': 8,
      'fechaInscripcion': '2026-11-21',
      'estado': 'cancelada',
    });
    final reactivada = await dao.pagar(1, 8, precioConfirmado: 1000);
    comprobar(
      reactivada.inscripcion.idInscripcion == cancelada,
      'Debe reutilizar una cancelada sin pago',
    );
    await rechaza(() => dao.pagar(1, 8, precioConfirmado: 1000));
    comprobar(
      (await InscripcionDao(db).eventoParaCalendario(1, 8)).idEvento == 8,
      'Una inscripcion pagada permite calendario',
    );
    var cancelacionRechazada = false;
    try {
      await InscripcionDao(db).cancelar(1, 8);
    } on ErrorInscripcion {
      cancelacionRechazada = true;
    }
    comprobar(cancelacionRechazada, 'No debe borrar pagos al cancelar');
    final saldoFinal = (await BilleteraDao(db).obtener(1)).saldo;
    await db.close();
    db = await DatabaseHelper.iniciarDB(rutaAlternativa: ruta);
    dao = PagoDao(db);
    comprobar(
      (await BilleteraDao(db).obtener(1)).saldo == saldoFinal,
      'Debe persistir el saldo',
    );
    await rechaza(() => dao.pagar(1, 8, precioConfirmado: 1000));
    comprobar(
      (await db.rawQuery('PRAGMA foreign_key_check')).isEmpty,
      'Integridad referencial',
    );
    comprobar(
      (await db.query('pago')).length == 4,
      'Un pago por inscripcion exitosa',
    );
    comprobar(
      (await db.query('movimiento')).length == 4,
      'Un movimiento por pago',
    );
    resultado = 'FASE7_OK: cobro, inscripcion, cupos, saldo, duplicados, concurrencia, precio, persistencia y rollback.';
  } catch (error, stack) {
    resultado = 'FASE7_ERROR: $error';
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
