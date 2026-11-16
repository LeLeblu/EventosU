import 'package:flutter/foundation.dart';

import 'evento.dart';

/// Inscripción a un evento. Ya no pide datos personales: el usuario
/// solo confirma en una ventana flotante (sus datos son los de su cuenta).
class Inscripcion {
  final Evento evento;
  final String estado; // 'Inscrito' o 'Pendiente de pago'

  const Inscripcion({required this.evento, required this.estado});
}

/// Estado compartido de las inscripciones.
///
/// Es una lista guardada en memoria mientras la app está abierta (no hay base
/// de datos). Al ser un ValueNotifier, las pantallas que la escuchan con
/// ValueListenableBuilder se redibujan solas cuando la lista cambia.
final ValueNotifier<List<Inscripcion>> inscripciones =
    ValueNotifier<List<Inscripcion>>([]);

/// Revisa si ya existe una inscripción para ese evento.
bool estaInscrito(Evento evento) {
  return inscripciones.value.any((i) => i.evento.nombre == evento.nombre);
}

/// Agrega una inscripción nueva.
void agregarInscripcion(Inscripcion nueva) {
  inscripciones.value = [...inscripciones.value, nueva];
}

/// Quita la inscripción del evento indicado.
void cancelarInscripcion(Evento evento) {
  inscripciones.value = inscripciones.value
      .where((i) => i.evento.nombre != evento.nombre)
      .toList();
}

/// Cambia una inscripción "Pendiente de pago" a "Inscrito".
/// La puede llamar la pantalla de pago cuando el pago sale bien.
void confirmarPago(Evento evento) {
  inscripciones.value = [
    for (final i in inscripciones.value)
      i.evento.nombre == evento.nombre
          ? Inscripcion(evento: i.evento, estado: 'Inscrito')
          : i,
  ];
}
