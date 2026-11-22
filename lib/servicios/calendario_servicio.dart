import 'package:add_2_calendar/add_2_calendar.dart';

import '../base_datos/inscripcion_dao.dart';
import 'sesion_usuario.dart';

class CalendarioServicio {
  static Future<bool> abrir(int idEvento) async {
    final idUsuario = SesionUsuario.idUsuario;
    final dao = await InscripcionDao.abrir();
    final evento = await dao.eventoParaCalendario(idUsuario, idEvento);
    if (SesionUsuario.usuarioActual?.idUsuarios != idUsuario) return false;
    final inicio = evento.fechaHora;
    if (inicio == null) {
      throw const ErrorInscripcion('La fecha u hora del evento no es válida');
    }
    // Agregar el evento al calendario del dispositivo
    return Add2Calendar.addEvent2Cal(
      Event(
        title: evento.nombre,
        description: evento.descripcion,
        location: evento.ubicacion,
        startDate: inicio,
        endDate: inicio.add(const Duration(hours: 1)),
      ),
    );
  }
}
