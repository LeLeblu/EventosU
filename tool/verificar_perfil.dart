import 'dart:io';
import 'dart:typed_data';

import 'package:eventos_app/modelos/usuario.dart';

void main() {
  final datos = <String, Object?>{
    'idUsuarios': 7,
    'nombre': 'Perfil de prueba',
    'correo': 'perfil@example.com',
    'programa': null,
    'rol': 'usuario',
    'fotoPerfil': null,
  };
  if (Usuario.desdeMapa(datos).fotoPerfil != null) {
    throw StateError('La foto debe ser opcional.');
  }
  final blob = Uint8List.fromList([137, 80, 78, 71]);
  datos['fotoPerfil'] = blob;
  final usuario = Usuario.desdeMapa(datos);
  blob[0] = 0;
  if (usuario.fotoPerfil!.length != 4 || usuario.fotoPerfil!.first != 137) {
    throw StateError('Debe conservar una copia de los bytes recuperados.');
  }
  if (usuario.idUsuarios != 7 || usuario.programa != null) {
    throw StateError('Debe respetar el identificador y los campos opcionales.');
  }
  stdout.writeln('Correcto: perfil sin foto y conversion de BLOB.');
}
