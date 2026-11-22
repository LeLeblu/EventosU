import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class NotificacionDao {
  final Database db;

  NotificacionDao(this.db);

  static Future<NotificacionDao> abrir() async =>
      NotificacionDao(await DatabaseHelper.iniciarDB());

  Future<int> crear({
    required int idUsuario,
    required String titulo,
    required String mensaje,
    DatabaseExecutor? conexion,
  }) async {
    final executor = conexion ?? db;
    return executor.insert('notificacion', {
      'idUsuario': idUsuario,
      'titulo': titulo,
      'mensaje': mensaje,
      'fecha': DateTime.now().toUtc().toIso8601String(),
      'leida': 0,
    });
  }

  Future<int> avisarInscripcion({
    required int idUsuario,
    required String evento,
    required bool requierePago,
    DatabaseExecutor? conexion,
  }) => crear(
    idUsuario: idUsuario,
    titulo: requierePago
        ? 'Inscripción pendiente de pago'
        : 'Inscripción confirmada',
    mensaje: requierePago
        ? 'Completa el pago para confirmar tu inscripción a "$evento".'
        : 'Te has inscrito a "$evento".',
    conexion: conexion,
  );

  Future<List<Map<String, Object?>>> listar(int idUsuario) => db.query(
    'notificacion',
    where: 'idUsuario = ?',
    whereArgs: [idUsuario],
    orderBy: 'fecha DESC, idNotificacion DESC',
  );

  Future<int> marcarLeida(int idUsuario, int idNotificacion) => db.update(
    'notificacion',
    {'leida': 1},
    where: 'idUsuario = ? AND idNotificacion = ?',
    whereArgs: [idUsuario, idNotificacion],
  );
}
