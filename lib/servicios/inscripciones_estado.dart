import 'package:flutter/foundation.dart';

import 'evento.dart';
import 'sesion_usuario.dart';
import '../base_datos/inscripcion_dao.dart';
import '../base_datos/evento_dao.dart';
import '../modelos/inscripcion.dart';
export '../modelos/inscripcion.dart';

/// Estado compartido de las inscripciones.
///
/// Cache de SQLite para redibujar las pantallas; no mezcla usuarios.
final ValueNotifier<List<Inscripcion>> inscripciones =
    ValueNotifier<List<Inscripcion>>([]);

int? _usuarioCache;
int _revision = 0;

void limpiarInscripciones() {
  _usuarioCache = null;
  _revision++;
  inscripciones.value = [];
}

void _prepararUsuario(int idUsuario) {
  if (_usuarioCache != idUsuario) {
    limpiarInscripciones();
    _usuarioCache = idUsuario;
  }
}

bool mismoEvento(Evento a, Evento b) => a.idEvento != null && b.idEvento != null
    ? a.idEvento == b.idEvento
    : a.nombre == b.nombre;

Future<void> cargarInscripciones() async {
  final idUsuario = SesionUsuario.idUsuario;
  _prepararUsuario(idUsuario);
  final revision = ++_revision;
  final dao = await InscripcionDao.abrir();
  final guardadas = await dao.listar(idUsuario);
  if (SesionUsuario.usuarioActual?.idUsuarios != idUsuario ||
      revision != _revision) {
    return;
  }
  inscripciones.value = guardadas;
}

/// Revisa si ya existe una inscripción para ese evento.
bool estaInscrito(Evento evento) {
  return inscripciones.value.any((i) => mismoEvento(i.evento, evento));
}

/// Agrega una inscripción nueva.
final _registrosEnCurso = <String>{};

Future<bool> agregarInscripcion(Inscripcion nueva) async {
  final idUsuario = SesionUsuario.idUsuario;
  _prepararUsuario(idUsuario);
  final clave = '$idUsuario:${nueva.evento.idEvento ?? nueva.evento.nombre}';
  if (estaInscrito(nueva.evento) || !_registrosEnCurso.add(clave)) return false;
  try {
    ++_revision;
    final idEvento = nueva.evento.idEvento;
    if (idEvento == null) {
      throw const ErrorInscripcion('El evento no está guardado');
    }
    final actual = await EventoDao.obtenerPorId(idEvento);
    if (actual == null) throw const ErrorInscripcion('El evento ya no existe');
    if (actual.agotado) {
      throw const ErrorInscripcion('No quedan cupos disponibles');
    }
    final dao = await InscripcionDao.abrir();
    final registrada = await dao.registrarGratis(idUsuario, idEvento);
    if (SesionUsuario.usuarioActual?.idUsuarios == idUsuario) {
      ++_revision;
      inscripciones.value = [
        ...inscripciones.value.where(
          (i) => !mismoEvento(i.evento, registrada.evento),
        ),
        registrada,
      ];
      return true;
    }
    return false;
  } finally {
    _registrosEnCurso.remove(clave);
  }
}

/// Quita la inscripción del evento indicado.
Future<void> cancelarInscripcion(Evento evento) async {
  final idUsuario = SesionUsuario.idUsuario;
  ++_revision;
  final idEvento = evento.idEvento;
  if (idEvento != null) {
    final dao = await InscripcionDao.abrir();
    await dao.cancelar(idUsuario, idEvento);
  }
  if (SesionUsuario.usuarioActual?.idUsuarios != idUsuario) return;
  ++_revision;
  inscripciones.value = inscripciones.value
      .where((i) => !mismoEvento(i.evento, evento))
      .toList();
}

/// Publicar solo resultados que ya se confirmaron en SQLite.
void publicarInscripcionConfirmada(Inscripcion registrada) {
  _prepararUsuario(SesionUsuario.idUsuario);
  ++_revision;
  inscripciones.value = [
    ...inscripciones.value.where(
      (i) => !mismoEvento(i.evento, registrada.evento),
    ),
    registrada,
  ];
}
