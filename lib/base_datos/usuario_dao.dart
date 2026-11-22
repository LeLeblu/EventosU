import 'dart:typed_data';

import 'database_helper.dart';
import 'password_helper.dart';
import '../modelos/usuario.dart';

class CorreoRegistradoException implements Exception {
  const CorreoRegistradoException();
}

class UsuarioDao {
  static const _columnasPerfil = [
    'idUsuarios',
    'nombre',
    'correo',
    'programa',
    'rol',
    'fotoPerfil',
  ];

  static Future<Usuario> obtenerPorId(int idUsuario) async {
    final db = await DatabaseHelper.iniciarDB();
    final filas = await db.query(
      'usuario',
      columns: _columnasPerfil,
      where: 'idUsuarios = ?',
      whereArgs: [idUsuario],
      limit: 1,
    );
    if (filas.isEmpty) throw StateError('El usuario no existe.');
    return Usuario.desdeMapa(filas.single);
  }

  static Future<Usuario> actualizarPerfil({
    required int idUsuario,
    required String nombre,
    required String correo,
    required String programa,
  }) async {
    final correoNormalizado = correo.trim().toLowerCase();
    if (nombre.trim().isEmpty ||
        programa.trim().isEmpty ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(correoNormalizado)) {
      throw const FormatException(
        'Completa los campos e ingresa un correo válido',
      );
    }
    final db = await DatabaseHelper.iniciarDB();
    return db.transaction((txn) async {
      final duplicados = await txn.query(
        'usuario',
        columns: ['idUsuarios'],
        where: 'LOWER(TRIM(correo)) = ? AND idUsuarios <> ?',
        whereArgs: [correoNormalizado, idUsuario],
        limit: 1,
      );
      if (duplicados.isNotEmpty) throw const CorreoRegistradoException();
      final cantidad = await txn.update(
        'usuario',
        {
          'nombre': nombre.trim(),
          'correo': correoNormalizado,
          'programa': programa.trim(),
        },
        where: 'idUsuarios = ?',
        whereArgs: [idUsuario],
      );
      if (cantidad != 1) throw StateError('El usuario no existe.');
      final filas = await txn.query(
        'usuario',
        columns: _columnasPerfil,
        where: 'idUsuarios = ?',
        whereArgs: [idUsuario],
      );
      return Usuario.desdeMapa(filas.single);
    });
  }

  static Future<Usuario> actualizarFoto(int idUsuario, Uint8List foto) async {
    if (foto.isEmpty) throw const FormatException('La imagen está vacía');
    final db = await DatabaseHelper.iniciarDB();
    return db.transaction((txn) async {
      final cantidad = await txn.update(
        'usuario',
        {'fotoPerfil': foto},
        where: 'idUsuarios = ?',
        whereArgs: [idUsuario],
      );
      if (cantidad != 1) throw StateError('El usuario no existe.');
      final filas = await txn.query(
        'usuario',
        columns: _columnasPerfil,
        where: 'idUsuarios = ?',
        whereArgs: [idUsuario],
      );
      return Usuario.desdeMapa(filas.single);
    });
  }

  static Future<Usuario?> autenticar(String correo, String password) async {
    final db = await DatabaseHelper.iniciarDB();
    final filas = await db.query(
      'usuario',
      columns: [
        'idUsuarios',
        'nombre',
        'correo',
        'programa',
        'rol',
        'contrasenaHash',
        'fotoPerfil',
      ],
      where: 'LOWER(TRIM(correo)) = ?',
      whereArgs: [correo.trim().toLowerCase()],
      limit: 1,
    );
    if (filas.isEmpty) return null;
    final datos = filas.first;
    final valido = await PasswordHelper.verificarPassword(
      password,
      datos['contrasenaHash'] as String,
    );
    return valido ? Usuario.desdeMapa(datos) : null;
  }

  static Future<int> registrarUsuario({
    required String nombre,
    required String correo,
    required String programa,
    required String password,
  }) async {
    final db = await DatabaseHelper.iniciarDB();
    final correoNormalizado = correo.trim().toLowerCase();

    // Evita calcular el hash si el correo ya pertenece a otra cuenta.
    final existentes = await db.query(
      'usuario',
      columns: ['idUsuarios'],
      where: 'LOWER(TRIM(correo)) = ?',
      whereArgs: [correoNormalizado],
      limit: 1,
    );
    if (existentes.isNotEmpty) throw const CorreoRegistradoException();

    final hash = await PasswordHelper.generarHash(password);
    final fecha = DateTime.now().toUtc().toIso8601String();

    return await db.transaction((txn) async {
      // Revalidar dentro de la transaccion evita registros simultaneos.
      final existentes = await txn.query(
        'usuario',
        columns: ['idUsuarios'],
        where: 'LOWER(TRIM(correo)) = ?',
        whereArgs: [correoNormalizado],
        limit: 1,
      );
      if (existentes.isNotEmpty) throw const CorreoRegistradoException();

      // 1. Guardar el usuario
      final idUsuario = await txn.insert('usuario', {
        'nombre': nombre.trim(),
        'correo': correoNormalizado,
        'programa': programa.trim(),
        'contrasenaHash': hash,
        'fechaRegistro': fecha,
        'rol': 'usuario',
      });

      // 2. Crear su billetera con saldo cero
      await txn.insert('billetera', {
        'idUsuario': idUsuario,
        'saldo': 0,
        'fechaActualizacion': fecha,
      });

      return idUsuario;
    });
  }
}
