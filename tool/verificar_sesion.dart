import 'dart:io';

import 'package:eventos_app/modelos/usuario.dart';
import 'package:eventos_app/servicios/sesion_usuario.dart';

void comprobar(bool condicion, String mensaje) {
  if (!condicion) throw StateError(mensaje);
}

void main() {
  SesionUsuario.cerrar();
  comprobar(!SesionUsuario.estaAutenticado, 'La sesion debe comenzar vacia.');
  var accesoRechazado = false;
  try {
    SesionUsuario.idUsuario;
  } on StateError {
    accesoRechazado = true;
  }
  comprobar(accesoRechazado, 'No debe existir un identificador por defecto.');
  final usuario = Usuario.desdeMapa({
    'idUsuarios': 27,
    'nombre': 'Cuenta de prueba',
    'correo': 'prueba@example.com',
    'programa': null,
    'rol': 'usuario',
  });
  SesionUsuario.iniciar(usuario);
  comprobar(SesionUsuario.estaAutenticado, 'Debe existir una sesion activa.');
  comprobar(SesionUsuario.idUsuario == 27, 'Debe conservar el ID de SQLite.');
  SesionUsuario.cerrar();
  comprobar(
    SesionUsuario.usuarioActual == null,
    'Cerrar debe quitar la cuenta.',
  );
  stdout.writeln('Correcto: inicio, identificador real y cierre de sesion.');
}
