import 'package:flutter/material.dart';

import '../base_datos/notificacion_dao.dart';
import '../servicios/sesion_usuario.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  late final int _idUsuario;
  List<Map<String, Object?>> _avisos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _idUsuario = SesionUsuario.idUsuario;
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      if (SesionUsuario.usuarioActual?.idUsuarios != _idUsuario) return;
      final dao = await NotificacionDao.abrir();
      final avisos = await dao.listar(_idUsuario);
      if (!mounted || SesionUsuario.usuarioActual?.idUsuarios != _idUsuario) {
        return;
      }
      setState(() {
        _avisos = avisos;
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudieron cargar las notificaciones');
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _leer(Map<String, Object?> aviso) async {
    try {
      if (SesionUsuario.usuarioActual?.idUsuarios != _idUsuario) return;
      final dao = await NotificacionDao.abrir();
      await dao.marcarLeida(_idUsuario, aviso['idNotificacion'] as int);
      if (mounted && SesionUsuario.usuarioActual?.idUsuarios == _idUsuario) {
        await _cargar();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo marcar como leída')),
        );
      }
    }
  }

  String _fecha(String valor) {
    final fecha = DateTime.tryParse(valor)?.toLocal();
    if (fecha == null) return valor;
    final ahora = DateTime.now();
    final hoy =
        fecha.year == ahora.year &&
        fecha.month == ahora.month &&
        fecha.day == ahora.day;
    final hora =
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    return hoy ? hora : '${fecha.day}/${fecha.month}/${fecha.year}\n$hora';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Encabezado morado
      appBar: AppBar(
        backgroundColor: const Color(0xFF5263FA),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 90,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),

      body: SesionUsuario.usuarioActual?.idUsuarios != _idUsuario
          ? const Center(child: Text('No tienes notificaciones'))
          : _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: TextButton(
                onPressed: _cargar,
                child: Text('$_error. Reintentar'),
              ),
            )
          : _avisos.isEmpty
          ? const Center(child: Text('No tienes notificaciones'))
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  for (final aviso in _avisos) ...[
                    Semantics(
                      label: aviso['leida'] == 1
                          ? 'Leída'
                          : 'Sin leer. Toca para marcar como leída',
                      button: true,
                      child: GestureDetector(
                        onTap: () => _leer(aviso),
                        child: tarjetaNotificacion(
                          titulo: aviso['titulo'] as String,
                          mensaje: aviso['mensaje'] as String,
                          hora: _fecha(aviso['fecha'] as String),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
    );
  }

  // Construye una tarjeta con los datos que le entregamos
  Widget tarjetaNotificacion({
    required String titulo,
    required String mensaje,
    required String hora,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD4D8FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(mensaje, style: const TextStyle(fontSize: 14)),
              ),

              const SizedBox(width: 12),

              Text(
                hora,
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
