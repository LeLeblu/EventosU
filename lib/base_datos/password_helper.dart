import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class PasswordHelper {
  static final algoritmo = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 600000,
    bits: 256,
  );

  static Future<String> generarHash(String password) async {
    final random = Random.secure();

    final salt = List<int>.generate(16, (_) => random.nextInt(256));

    final resultado = await algoritmo.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );

    final hash = await resultado.extractBytes();

    return 'pbkdf2_sha256:600000:'
        '${base64Encode(salt)}:${base64Encode(hash)}';
  }

  static Future<bool> verificarPassword(
    String password,
    String hashGuardado,
  ) async {
    final partes = hashGuardado.split(':');

    if (partes.length != 4 || partes[0] != 'pbkdf2_sha256') {
      return false;
    }

    final iteraciones = int.tryParse(partes[1]);

    if (iteraciones == null || iteraciones <= 0) {
      return false;
    }

    late final List<int> salt;
    late final List<int> hashOriginal;
    try {
      salt = base64Decode(partes[2]);
      hashOriginal = base64Decode(partes[3]);
    } on FormatException {
      return false;
    }
    if (salt.length != 16 || hashOriginal.length != 32) return false;

    final algoritmoVerificacion = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iteraciones,
      bits: hashOriginal.length * 8,
    );

    final resultado = await algoritmoVerificacion.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );

    final hashCalculado = await resultado.extractBytes();

    if (hashCalculado.length != hashOriginal.length) {
      return false;
    }

    var diferencia = 0;

    for (var i = 0; i < hashCalculado.length; i++) {
      diferencia |= hashCalculado[i] ^ hashOriginal[i];
    }

    return diferencia == 0;
  }
}
