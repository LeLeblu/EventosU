// Ejecutar en Android/iOS: flutter run -t tool/verificar_inscripciones.dart
// Usa exclusivamente una base temporal; nunca abre eventosu.db.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:eventos_app/base_datos/database_helper.dart';
import 'package:eventos_app/base_datos/inscripcion_dao.dart';

void comprobar(bool condicion, String mensaje) {
  if (!condicion) throw StateError(mensaje);
}

Future<void> rechaza(Future<Object?> Function() accion) async {
  try {
    await accion();
  } on ErrorInscripcion {
    return;
  }
  throw StateError('La operacion debio rechazarse');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directorio = await Directory.systemTemp.createTemp('eventosu_fase5_');
  final ruta = join(directorio.path, 'prueba.db');
  Database? db;
  String resultado;
  try {
    db = await DatabaseHelper.iniciarDB(rutaAlternativa: ruta);
    var dao = InscripcionDao(db);
    for (final correo in ['uno@example.com', 'dos@example.com']) {
      await db.insert('usuario', {
        'nombre': correo,
        'correo': correo,
        'contrasenaHash': 'dato-de-prueba',
        'fechaRegistro': '2026-11-21',
      });
    }
    await db.insert('categoria', {'nombre': 'Prueba'});
    for (var i = 1; i <= 4; i++) {
      await db.insert('evento', {
        'titulo': 'Evento',
        'fecha': '2026-12-01',
        'hora': '10:00',
        'ubicacion': 'Campus',
        'idCategoria': 1,
        'precio': i == 3 ? 5000 : 0,
        'cuposDisponibles': 1,
      });
    }
    final primera = await dao.registrarGratis(1, 1);
    comprobar((await dao.listar(1)).length == 1, 'Debe listar la inscripcion');
    comprobar((await dao.listar(2)).isEmpty, 'Debe aislar usuarios');
    await rechaza(() => dao.registrarGratis(1, 1));
    await rechaza(() => dao.registrarGratis(2, 1));
    await rechaza(() => dao.registrarGratis(1, 3));
    await rechaza(() => dao.eventoParaCalendario(2, 1));
    comprobar(
      (await dao.eventoParaCalendario(1, 1)).idEvento == 1,
      'El calendario debe consultar una inscripcion confirmada',
    );
    await dao.cancelar(2, 1);
    comprobar(
      (await dao.listar(1)).length == 1,
      'No debe cancelar a otro usuario',
    );
    await dao.cancelar(1, 1);
    await dao.cancelar(1, 1);
    final cupos = await db.query(
      'evento',
      where: 'idEvento = ?',
      whereArgs: [1],
    );
    comprobar(
      cupos.single['cuposDisponibles'] == 1,
      'Debe devolver un solo cupo',
    );
    await rechaza(() => dao.eventoParaCalendario(1, 1));
    final segunda = await dao.registrarGratis(1, 1);
    comprobar(
      primera.idInscripcion == segunda.idInscripcion,
      'Debe reutilizar la fila cancelada',
    );

    // Un fallo real en la ultima escritura debe deshacer toda la transaccion.
    await db.execute(
      '''CREATE TRIGGER fallo_aviso BEFORE INSERT ON notificacion
      WHEN NEW.idUsuario = 2 BEGIN SELECT RAISE(ABORT, 'fallo de prueba'); END''',
    );
    var revertida = false;
    try {
      await dao.registrarGratis(2, 2);
    } on DatabaseException catch (error) {
      revertida = error.toString().contains('fallo de prueba');
    }
    comprobar(revertida, 'Debe propagar el fallo de notificacion');
    comprobar(
      (await db.query(
            'evento',
            where: 'idEvento = ?',
            whereArgs: [2],
          )).single['cuposDisponibles'] ==
          1,
      'Debe restaurar el cupo',
    );
    comprobar(
      (await dao.listar(2)).isEmpty,
      'No debe quedar inscripcion parcial',
    );
    await db.execute('DROP TRIGGER fallo_aviso');

    final intentos = await Future.wait(
      [1, 2].map((usuario) async {
        try {
          await dao.registrarGratis(usuario, 4);
          return true;
        } on ErrorInscripcion {
          return false;
        }
      }),
    );
    comprobar(
      intentos.where((exito) => exito).length == 1,
      'Solo uno puede tomar el ultimo cupo',
    );
    comprobar(
      (await db.query('pago')).isEmpty,
      'Los gratuitos no deben crear pagos',
    );
    comprobar(
      (await db.query('movimiento')).isEmpty,
      'Los gratuitos no deben mover saldo',
    );
    comprobar(
      (await db.query('notificacion')).length == 3,
      'Solo debe avisar operaciones exitosas',
    );

    final pagada = await db.insert('inscripcion', {
      'idUsuario': 1,
      'idEvento': 3,
      'fechaInscripcion': '2026-11-21',
      'estado': 'activa',
    });
    await db.insert('pago', {
      'idInscripcion': pagada,
      'monto': 5000,
      'fechaPago': '2026-11-21',
    });
    await rechaza(() => dao.cancelar(1, 3));
    comprobar((await db.query('pago')).length == 1, 'Debe conservar el pago');
    await db.close();
    db = await DatabaseHelper.iniciarDB(rutaAlternativa: ruta);
    dao = InscripcionDao(db);
    comprobar(
      (await dao.listar(1))
          .any((i) => i.idInscripcion == primera.idInscripcion),
      'Debe persistir al reabrir la base',
    );
    comprobar(
      (await db.rawQuery('PRAGMA foreign_key_check')).isEmpty,
      'Debe respetar las relaciones',
    );
    resultado = 'FASE5_OK: persistencia, duplicados, ultimo cupo, cancelacion, reingreso, rollback y calendario.';
  } catch (error, stack) {
    resultado = 'FASE5_ERROR: $error';
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
