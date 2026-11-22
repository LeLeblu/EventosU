import 'dart:io';

import 'package:eventos_app/base_datos/password_helper.dart';

// Ejecutar con: dart run tool/verificar_password.dart
// No imprime contrasenas ni hashes y no accede a la base de datos.
Future<void> main() async {
  const clave = 'Clave de prueba 123!';
  final primero = await PasswordHelper.generarHash(clave);
  final segundo = await PasswordHelper.generarHash(clave);
  if (primero == segundo) {
    throw StateError('Dos registros deben usar sales diferentes.');
  }
  if (!await PasswordHelper.verificarPassword(clave, primero)) {
    throw StateError('La clave correcta debe ser aceptada.');
  }
  if (await PasswordHelper.verificarPassword('Otra clave 456!', primero)) {
    throw StateError('Una clave incorrecta debe ser rechazada.');
  }
  stdout.writeln('Correcto: sal aleatoria y verificacion de contrasenas.');
  for (final invalido in [
    'texto sin formato',
    'pbkdf2_sha256:600000:%%:%%',
    'pbkdf2_sha256:600000::',
  ]) {
    if (await PasswordHelper.verificarPassword(clave, invalido)) {
      throw StateError('Un hash invalido debe rechazarse.');
    }
  }
  stdout.writeln('Correcto: hashes malformados rechazados.');
}
