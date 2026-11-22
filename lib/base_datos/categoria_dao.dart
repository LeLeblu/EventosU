import '../modelos/categoria.dart';
import 'database_helper.dart';

class CategoriaDao {
  static Future<List<Categoria>> listar() async {
    final db = await DatabaseHelper.iniciarDB();
    final filas = await db.query('categoria', orderBy: 'idCategoria');
    return filas.map(Categoria.desdeMapa).toList();
  }
}
