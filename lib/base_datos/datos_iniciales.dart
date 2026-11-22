import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../servicios/eventos_mock.dart';
import 'database_helper.dart';

class DatosIniciales {
  static Future<void>? _carga;

  /// Comparte una carga entre pantallas y permite reintentar si falla.
  static Future<void> asegurarCatalogo() => _carga ??= _cargarConReintento();

  static Future<void> _cargarConReintento() async {
    try {
      await _cargar();
    } catch (_) {
      _carga = null;
      rethrow;
    }
  }

  static Future<void> _cargar() async {
    final imagenes = <String, Uint8List>{};
    // Los archivos se leen antes de abrir la transaccion; no requiere internet.
    for (final evento in eventosMock) {
      final numeroFoto = Uri.parse(evento.imagen).pathSegments[1];
      final datos = await rootBundle.load('assets/eventos/$numeroFoto.jpg');
      imagenes[evento.imagen] = datos.buffer.asUint8List(
        datos.offsetInBytes,
        datos.lengthInBytes,
      );
    }
    final db = await DatabaseHelper.iniciarDB();
    await db.transaction((txn) async {
      for (final evento in eventosMock) {
        await txn.insert('categoria', {
          'nombre': evento.categoria,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        final categorias = await txn.query(
          'categoria',
          columns: ['idCategoria'],
          where: 'nombre = ?',
          whereArgs: [evento.categoria],
        );
        final idCategoria = categorias.single['idCategoria'] as int;
        // No usar REPLACE: borraria registros referenciados o restableceria cupos.
        final existentes = await txn.query(
          'evento',
          columns: ['idEvento'],
          where: 'titulo = ? AND fecha = ? AND hora = ? AND ubicacion = ? AND idCategoria = ?',
          whereArgs: [
            evento.nombre,
            evento.fecha,
            evento.hora,
            evento.ubicacion,
            idCategoria,
          ],
          limit: 1,
        );
        if (existentes.isNotEmpty) continue;
        await txn.insert('evento', {
          'titulo': evento.nombre,
          'descripcion': evento.descripcion,
          'fecha': evento.fecha,
          'hora': evento.hora,
          'ubicacion': evento.ubicacion,
          'precio': evento.precioPesos,
          'cuposDisponibles': evento.cupos,
          'imagen': imagenes[evento.imagen],
          'idCategoria': idCategoria,
        });
      }
    });
  }
}
