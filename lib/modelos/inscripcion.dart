import '../servicios/evento.dart';

/// Inscripción al evento, con datos opcionales del participante.
class Inscripcion {
  final int? idInscripcion;
  final Evento evento;
  final String nombre;
  final String documento;
  final String correo;
  final String celular;
  final String estado; // 'Inscrito' o 'Pendiente de pago'

  const Inscripcion({
    this.idInscripcion,
    required this.evento,
    this.nombre = '',
    this.documento = '',
    this.correo = '',
    this.celular = '',
    required this.estado,
  });
}
