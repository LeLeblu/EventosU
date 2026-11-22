import '../modelos/usuario.dart';

/// Sesion en memoria: al cerrar la app se solicita iniciar sesion otra vez.
class SesionUsuario {
  static Usuario? _usuario;

  static Usuario? get usuarioActual => _usuario;
  static bool get estaAutenticado => _usuario != null;
  static int get idUsuario {
    final usuario = _usuario;
    if (usuario == null) throw StateError('Debes iniciar sesion.');
    return usuario.idUsuarios;
  }

  static void iniciar(Usuario usuario) => _usuario = usuario;
  static void cerrar() => _usuario = null;
}
