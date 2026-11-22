import '../servicios/evento.dart';
import '../servicios/complemento_eventos.dart';
import 'database_helper.dart';

class EventoDao {
  static const _consulta = '''
    SELECT e.*, c.nombre AS categoria
    FROM evento e JOIN categoria c ON c.idCategoria = e.idCategoria
  ''';

  static Evento _convertir(Map<String, Object?> fila) {
    final complemento = complementoEvento(fila);
    return Evento.desdeMapa(
      fila,
      organizador: complemento.organizador,
      subcategoria: complemento.subcategoria,
    );
  }

  static Future<List<Evento>> listar() async {
    final db = await DatabaseHelper.iniciarDB();
    final filas = await db.rawQuery('$_consulta ORDER BY e.idEvento');
    final eventos = filas.map(_convertir).toList();
    eventos.sort((a, b) {
      final comparacion = (a.fechaHora ?? DateTime(9999)).compareTo(
        b.fechaHora ?? DateTime(9999),
      );
      return comparacion != 0
          ? comparacion
          : a.idEvento!.compareTo(b.idEvento!);
    });
    return eventos;
  }

  static Future<Evento?> obtenerPorId(int idEvento) async {
    final db = await DatabaseHelper.iniciarDB();
    final filas = await db.rawQuery('$_consulta WHERE e.idEvento = ?', [
      idEvento,
    ]);
    return filas.isEmpty ? null : _convertir(filas.single);
  }
}
