import 'dart:typed_data';

// Conserva el formato de la interfaz y los identificadores reales de SQLite.
class Evento {
  final int? idEvento;
  final int? idCategoria;
  final Uint8List? imagenBytes;
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
  final String imagen; // URL de origen, solo usada por la carga inicial.

  const Evento({
    this.idEvento,
    this.idCategoria,
    this.imagenBytes,
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

  /// Admite las fechas originales del proyecto y fechas ISO de otros registros.
  DateTime? get fechaHora {
    final iso = DateTime.tryParse(fecha);
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final partes = RegExp(r'^(\d{1,2}) de (\w+) de (\d{4})$').firstMatch(fecha);
    DateTime? dia = iso;
    if (dia == null && partes != null) {
      final mes = meses.indexOf(partes[2]!.toLowerCase()) + 1;
      if (mes == 0) return null;
      dia = DateTime(int.parse(partes[3]!), mes, int.parse(partes[1]!));
      if (dia.month != mes || dia.day != int.parse(partes[1]!)) return null;
    }
    if (dia == null) return null;
    final tiempo = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(hora);
    if (tiempo == null) return null;
    var horas = int.parse(tiempo[1]!);
    final minutos = int.parse(tiempo[2]!);
    final normalizada = hora
        .toLowerCase()
        .replaceAll('.', '')
        .replaceAll(' ', '');
    if (normalizada.endsWith('am') || normalizada.endsWith('pm')) {
      if (horas < 1 || horas > 12) return null;
      horas = horas % 12 + (normalizada.endsWith('pm') ? 12 : 0);
    }
    if (horas > 23 || minutos > 59) return null;
    return DateTime(dia.year, dia.month, dia.day, horas, minutos);
  }

  int get precioPesos =>
      esGratis ? 0 : int.parse(precio.replaceAll(RegExp(r'[^0-9]'), ''));

  factory Evento.desdeMapa(
    Map<String, Object?> datos, {
    String organizador = 'Organizador no especificado',
    String subcategoria = '',
  }) {
    final precio = datos['precio'] as int;
    final cupos = datos['cuposDisponibles'] as int;
    if (precio < 0 || cupos < 0) {
      throw const FormatException(
        'El precio y los cupos no pueden ser negativos',
      );
    }
    return Evento(
      idEvento: datos['idEvento'] as int,
      idCategoria: datos['idCategoria'] as int,
      nombre: datos['titulo'] as String,
      descripcion: datos['descripcion'] as String? ?? '',
      categoria: datos['categoria'] as String,
      organizador: organizador,
      subcategoria: subcategoria,
      fecha: datos['fecha'] as String,
      hora: datos['hora'] as String,
      ubicacion: datos['ubicacion'] as String,
      precio: precio == 0
          ? 'Gratis'
          : '\$${precio.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}',
      cupos: cupos,
      disponibilidad: cupos <= 0
          ? 'Agotado'
          : cupos <= 10
          ? 'A punto de cerrar'
          : 'Disponible',
      imagenBytes: datos['imagen'] == null
          ? null
          : Uint8List.fromList(datos['imagen'] as List<int>),
    );
  }
}
