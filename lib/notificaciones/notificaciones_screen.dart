import 'package:flutter/material.dart';

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Hoy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          tarjetaNotificacion(
            titulo: 'Inscripción confirmada',
            mensaje: 'Te has inscrito a "Música en vivo".',
            hora: '08:00 am',
          ),

          const SizedBox(height: 12),

          tarjetaNotificacion(
            titulo: 'Recarga exitosa',
            mensaje: 'Se agregaron \$25.000 a tu billetera.',
            hora: '07:00 am',
          ),

          const SizedBox(height: 12),

          tarjetaNotificacion(
            titulo: 'Pago realizado',
            mensaje: 'Pagaste \$25.000 por tu inscripción.',
            hora: '06:00 am',
          ),
        ],
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  mensaje,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              const SizedBox(width: 12),

              Text(
                hora,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}