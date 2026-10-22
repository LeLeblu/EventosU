// Los datos ya tienen el formato en que aparecen en la pantalla.
class Evento {
  final String nombre;
  final String descripcion;
  final String categoria; // Tecnología, Deportes o Música
  final String subcategoria; // Conferencias, Fútbol, Conciertos...
  final String organizador; // "Creado por ..."
  final String fecha;
  final String hora;
  final String ubicacion;
  final String precio; // "Gratis" o "$20.000"
  final int cupos;
  final String disponibilidad; // Disponible, A punto de cerrar o Agotado
  final String imagen; // foto del evento (enlace de internet)

  const Evento({
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    this.subcategoria = '',
    this.organizador = 'Bienestar Universitario',
    required this.fecha,
    required this.hora,
    required this.ubicacion,
    required this.precio,
    required this.cupos,
    this.disponibilidad = 'Disponible',
    this.imagen = '',
  });

  bool get esGratis => precio == 'Gratis';
  bool get agotado => disponibilidad == 'Agotado' || cupos <= 0;
}
