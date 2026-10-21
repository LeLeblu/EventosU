import 'package:flutter/material.dart';

import '../barra_navegacion.dart';
import '../wallet/payment_screen.dart';
import 'evento_card.dart';
import 'inscripciones_estado.dart';

/// Muestra las inscripciones que la persona hizo con el formulario.
/// La lista se actualiza sola al inscribirse o cancelar.
class MisEventosScreen extends StatelessWidget {
  const MisEventosScreen({super.key});

  void _verEntrada(BuildContext context, Inscripcion ins) {
    final e = ins.evento;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🎟️ Mi entrada', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2, size: 140),
            const Text('Entrada de ejemplo · sin validez de acceso'),
            const SizedBox(height: 12),
            Text(
              e.nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            filaInfo(Icons.person, ins.nombre),
            filaInfo(Icons.badge, 'Documento ${ins.documento}'),
            filaInfo(Icons.calendar_today, e.fecha),
            filaInfo(Icons.access_time, e.hora),
            filaInfo(Icons.location_on, e.ubicacion),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarCancelacion(
    BuildContext context,
    Inscripcion ins,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar inscripción?'),
        content: Text('Vas a cancelar tu inscripción a "${ins.evento.nombre}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sí, cancelar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    cancelarInscripcion(ins.evento);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancelaste la inscripción a ${ins.evento.nombre}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BarraNavegacion(indiceActual: 1),
      backgroundColor: const Color(0xFFF3F3F8),
      appBar: AppBar(
        title: const Text('Mis eventos'),
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
      ),
      // ValueListenableBuilder redibuja la pantalla cuando cambia la lista.
      body: ValueListenableBuilder<List<Inscripcion>>(
        valueListenable: inscripciones,
        builder: (context, lista, _) {
          if (lista.isEmpty) return _sinInscripciones(context);

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: lista.length,
            itemBuilder: (context, i) => _tarjeta(context, lista[i]),
          );
        },
      ),
    );
  }

  Widget _sinInscripciones(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy, size: 72, color: Colors.black38),
            const SizedBox(height: 12),
            const Text(
              'Aún no te has inscrito a ningún evento',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Explorar eventos'),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(BuildContext context, Inscripcion ins) {
    final e = ins.evento;
    final color = colorCategoria(e.categoria);
    final pendientePago = ins.estado == 'Pendiente de pago';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconoCategoria(e.categoria), color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            filaInfo(Icons.calendar_today, e.fecha),
            filaInfo(Icons.access_time, e.hora),
            filaInfo(Icons.location_on, e.ubicacion),
            const SizedBox(height: 8),
            Text(
              pendientePago ? 'Estado: PENDIENTE DE PAGO ⏳' : 'Estado: INSCRITO ✅',
              style: TextStyle(
                color: pendientePago ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: pendientePago
                      ? OutlinedButton.icon(
                          icon: const Icon(Icons.payment),
                          label: const Text('Pagar'),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(evento: e),
                            ),
                          ),
                        )
                      : OutlinedButton.icon(
                          icon: const Icon(Icons.confirmation_number),
                          label: const Text('Ver entrada'),
                          onPressed: () => _verEntrada(context, ins),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancelar'),
                    onPressed: () => _confirmarCancelacion(context, ins),
                  ),
                ),
              ],
            ),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: const Text('Agregar a mi calendario'),
                onPressed: () => mostrarCalendarioDemo(context, e),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
