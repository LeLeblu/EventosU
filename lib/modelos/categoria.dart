class Categoria {
  final int idCategoria;
  final String nombre;
  final String? descripcion;

  const Categoria({
    required this.idCategoria,
    required this.nombre,
    this.descripcion,
  });

  factory Categoria.desdeMapa(Map<String, Object?> datos) => Categoria(
    idCategoria: datos['idCategoria'] as int,
    nombre: datos['nombre'] as String,
    descripcion: datos['descripcion'] as String?,
  );
}
