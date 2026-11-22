import 'package:eventos_app/base_datos/billetera_dao.dart';
import 'package:eventos_app/base_datos/database_helper.dart';
import 'package:eventos_app/base_datos/inscripcion_dao.dart';
import 'package:eventos_app/base_datos/notificacion_dao.dart';
import 'package:eventos_app/base_datos/pago_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late sqflite.Database db;
  late int usuarioUno;
  late int usuarioDos;
  late int eventoGratis;
  late int eventoPago;

  setUpAll(() {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await DatabaseHelper.iniciarDB(rutaAlternativa: inMemoryDatabasePath);
    final fecha = DateTime.now().toUtc().toIso8601String();
    usuarioUno = await db.insert('usuario', {
      'nombre': 'Ana',
      'correo': 'ana@example.com',
      'contrasenaHash': 'hash',
      'fechaRegistro': fecha,
    });
    usuarioDos = await db.insert('usuario', {
      'nombre': 'Luis',
      'correo': 'luis@example.com',
      'contrasenaHash': 'hash',
      'fechaRegistro': fecha,
    });
    final categoria = await db.insert('categoria', {'nombre': 'Pruebas'});
    eventoGratis = await db.insert('evento', {
      'titulo': 'Evento gratuito',
      'fecha': '2026-12-01',
      'hora': '10:00',
      'ubicacion': 'Campus',
      'precio': 0,
      'cuposDisponibles': 1,
      'idCategoria': categoria,
    });
    eventoPago = await db.insert('evento', {
      'titulo': 'Evento pago',
      'fecha': '2026-12-02',
      'hora': '11:00',
      'ubicacion': 'Campus',
      'precio': 500,
      'cuposDisponibles': 2,
      'idCategoria': categoria,
    });
    for (final idUsuario in [usuarioUno, usuarioDos]) {
      await db.insert('billetera', {
        'idUsuario': idUsuario,
        'saldo': idUsuario == usuarioUno ? 1000 : 0,
        'fechaActualizacion': fecha,
      });
    }
  });

  tearDown(() => db.close());

  test('inscripción gratuita persiste y notifica solo a su usuario', () async {
    final dao = InscripcionDao(db);

    await dao.registrarGratis(usuarioUno, eventoGratis);

    expect(await _count('inscripcion', db), 1);
    expect(await _cupos(db, eventoGratis), 0);
    final notificaciones = NotificacionDao(db);
    final avisoUno = await notificaciones.listar(usuarioUno);
    expect(avisoUno, hasLength(1));
    expect(avisoUno.single['titulo'], 'Inscripción confirmada');
    expect(await notificaciones.listar(usuarioDos), isEmpty);
    expect(
      await notificaciones.marcarLeida(
        usuarioDos,
        avisoUno.single['idNotificacion'] as int,
      ),
      0,
    );
    expect(
      await notificaciones.marcarLeida(
        usuarioUno,
        avisoUno.single['idNotificacion'] as int,
      ),
      1,
    );
    expect((await notificaciones.listar(usuarioUno)).single['leida'], 1);
  });

  test(
    'lista por fecha descendente y no permite leer avisos de otro usuario',
    () async {
      final idAntigua = await db.insert('notificacion', {
        'idUsuario': usuarioUno,
        'titulo': 'Antigua',
        'mensaje': 'Aviso antiguo',
        'fecha': '2026-01-01T10:00:00.000Z',
      });
      final idNueva = await db.insert('notificacion', {
        'idUsuario': usuarioUno,
        'titulo': 'Nueva',
        'mensaje': 'Aviso nuevo',
        'fecha': '2026-02-01T10:00:00.000Z',
      });
      final notificaciones = NotificacionDao(db);

      final avisos = await notificaciones.listar(usuarioUno);

      expect(avisos.map((aviso) => aviso['idNotificacion']), [
        idNueva,
        idAntigua,
      ]);
      expect(await notificaciones.listar(usuarioDos), isEmpty);
      expect(await notificaciones.marcarLeida(usuarioDos, idNueva), 0);
      expect(await notificaciones.marcarLeida(usuarioUno, idNueva), 1);
      expect((await notificaciones.listar(usuarioUno)).first['leida'], 1);
    },
  );

  test(
    'una inscripción duplicada falla sin consumir otro cupo ni avisar',
    () async {
      final dao = InscripcionDao(db);
      await dao.registrarGratis(usuarioUno, eventoGratis);

      await expectLater(
        dao.registrarGratis(usuarioUno, eventoGratis),
        throwsA(isA<ErrorInscripcion>()),
      );

      expect(await _cupos(db, eventoGratis), 0);
      expect(await _count('inscripcion', db), 1);
      expect(await _count('notificacion', db), 1);
    },
  );

  test(
    'pago exitoso persiste inscripción, saldo, pago, movimiento y avisos',
    () async {
      await PagoDao(db).pagar(usuarioUno, eventoPago, precioConfirmado: 500);

      expect(await _count('inscripcion', db), 1);
      expect(await _count('pago', db), 1);
      expect(await _count('movimiento', db), 1);
      expect(await _saldo(db, usuarioUno), 500);
      expect(await _cupos(db, eventoPago), 1);
      final avisos = await NotificacionDao(db).listar(usuarioUno);
      expect(avisos.map((aviso) => aviso['titulo']).toSet(), {
        'Inscripción confirmada',
        'Pago realizado',
      });
      expect(await NotificacionDao(db).listar(usuarioDos), isEmpty);
    },
  );

  test(
    'duplicar pago no cambia saldo, cupos, pagos ni notificaciones',
    () async {
      final dao = PagoDao(db);
      await dao.pagar(usuarioUno, eventoPago, precioConfirmado: 500);
      final avisosAntes = await _count('notificacion', db);

      await expectLater(
        dao.pagar(usuarioUno, eventoPago, precioConfirmado: 500),
        throwsA(isA<ErrorPago>()),
      );

      expect(await _saldo(db, usuarioUno), 500);
      expect(await _cupos(db, eventoPago), 1);
      expect(await _count('pago', db), 1);
      expect(await _count('movimiento', db), 1);
      expect(await _count('notificacion', db), avisosAntes);
    },
  );

  test('saldo insuficiente no modifica ninguna tabla operativa', () async {
    await expectLater(
      PagoDao(db).pagar(usuarioDos, eventoPago, precioConfirmado: 500),
      throwsA(isA<ErrorPago>()),
    );

    expect(await _saldo(db, usuarioDos), 0);
    expect(await _cupos(db, eventoPago), 2);
    expect(await _count('inscripcion', db), 0);
    expect(await _count('pago', db), 0);
    expect(await _count('movimiento', db), 0);
    expect(await _count('notificacion', db), 0);
  });

  test('sin cupos no descuenta saldo ni deja registros parciales', () async {
    await db.update(
      'evento',
      {'cuposDisponibles': 0},
      where: 'idEvento = ?',
      whereArgs: [eventoPago],
    );

    await expectLater(
      PagoDao(db).pagar(usuarioUno, eventoPago, precioConfirmado: 500),
      throwsA(isA<ErrorPago>()),
    );

    expect(await _saldo(db, usuarioUno), 1000);
    expect(await _count('inscripcion', db), 0);
    expect(await _count('pago', db), 0);
    expect(await _count('movimiento', db), 0);
    expect(await _count('notificacion', db), 0);
  });

  test('un fallo al crear el aviso revierte por completo el pago', () async {
    await db.execute('''
      CREATE TRIGGER fallar_aviso_pago
      BEFORE INSERT ON notificacion
      WHEN NEW.titulo = 'Pago realizado'
      BEGIN
        SELECT RAISE(ABORT, 'fallo provocado por la prueba');
      END
    ''');

    await expectLater(
      PagoDao(db).pagar(usuarioUno, eventoPago, precioConfirmado: 500),
      throwsA(anything),
    );

    expect(await _saldo(db, usuarioUno), 1000);
    expect(await _cupos(db, eventoPago), 2);
    expect(await _count('inscripcion', db), 0);
    expect(await _count('pago', db), 0);
    expect(await _count('movimiento', db), 0);
    expect(await _count('notificacion', db), 0);
  });

  test('recarga exitosa registra movimiento y notificación', () async {
    final billetera = await BilleteraDao(db).recargar(usuarioDos, 250);

    expect(billetera.saldo, 250);
    expect(await _count('movimiento', db), 1);
    expect(
      (await NotificacionDao(db).listar(usuarioDos)).single['titulo'],
      'Recarga exitosa',
    );
    expect(await NotificacionDao(db).listar(usuarioUno), isEmpty);
  });

  test(
    'cancelar inscripción devuelve cupo y genera una notificación',
    () async {
      final dao = InscripcionDao(db);
      await dao.registrarGratis(usuarioUno, eventoGratis);

      await dao.cancelar(usuarioUno, eventoGratis);

      expect(await _cupos(db, eventoGratis), 1);
      final avisos = await NotificacionDao(db).listar(usuarioUno);
      expect(avisos.map((aviso) => aviso['titulo']), [
        'Inscripción cancelada',
        'Inscripción confirmada',
      ]);
    },
  );
}

Future<int> _count(String tabla, sqflite.Database db) async {
  final filas = await db.rawQuery('SELECT COUNT(*) AS cantidad FROM $tabla');
  return filas.single['cantidad'] as int;
}

Future<int> _saldo(sqflite.Database db, int idUsuario) async {
  final filas = await db.query(
    'billetera',
    columns: ['saldo'],
    where: 'idUsuario = ?',
    whereArgs: [idUsuario],
  );
  return filas.single['saldo'] as int;
}

Future<int> _cupos(sqflite.Database db, int idEvento) async {
  final filas = await db.query(
    'evento',
    columns: ['cuposDisponibles'],
    where: 'idEvento = ?',
    whereArgs: [idEvento],
  );
  return filas.single['cuposDisponibles'] as int;
}
