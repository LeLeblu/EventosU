import 'dart:typed_data';

/// Datos compartidos de la cuenta. Nunca contiene la contrasena ni su hash.
class Usuario {
  final int idUsuarios;
  final String nombre;
  final String correo;
  final String? programa;
  final String rol;
  final Uint8List? fotoPerfil;

  const Usuario({
    required this.idUsuarios,
    required this.nombre,
    required this.correo,
    this.programa,
    this.fotoPerfil,
    required this.rol,
  });

  factory Usuario.desdeMapa(Map<String, Object?> datos) => Usuario(
    idUsuarios: datos['idUsuarios'] as int,
    nombre: datos['nombre'] as String,
    correo: datos['correo'] as String,
    programa: datos['programa'] as String?,
    rol: datos['rol'] as String,
    fotoPerfil: datos['fotoPerfil'] == null
        ? null
        : Uint8List.fromList(datos['fotoPerfil'] as List<int>),
  );
}
