import 'package:flutter/material.dart';

import '../wallet/payment_screen.dart';
import 'detalle_evento_screen.dart';
import 'evento_card.dart';
import 'inscripciones_estado.dart';

/// Detalle de un evento inscrito (diseño "Detalle mis eventos" del Figma):
/// estado "Inscrito", botón naranja "Agregar al calendario" y
/// botón rojo "Eliminar inscripción".
class DetalleMisEventoScreen extends StatelessWidget {
  final Inscripcion inscripcion;

  const DetalleMisEventoScreen({super.key, required this.inscripcion});

  bool get _pendientePago => inscripcion.estado == 'Pendiente de pago';

  @override
  Widget build(BuildContext context) {
    final e = inscripcion.evento;

    return Scaffold(
      backgroundColor: colorFondo,
      body: Stack(
        children: [
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Opacity(
              opacity: 0.85,
              child: PortadaEvento(evento: e, tamanoIcono: 90),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorPrimario,
                    shape: BoxShape.circle,
                    boxShadow: sombraColor(colorPrimario),
                  ),
                  child: IconButton(
                    tooltip: 'Cerrar',
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 220),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                children: [
                  ...contenidoDetalleEvento(e, estado: inscripcion.estado),
                  const SizedBox(height: 24),
                  if (_pendientePago)
                    BotonEvento(
                      texto: 'Completar pago',
                      icono: Icons.payment_rounded,
                      color: colorNaranja,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(evento: e),
                        ),
                      ),
                    )
                  else
                    BotonEvento(
                      texto: 'Agregar al calendario',
                      icono: Icons.edit_calendar_rounded,
                      color: colorNaranja,
                      onPressed: () => mostrarCalendarioDemo(context, e),
                    ),
                  const SizedBox(height: 12),
                  BotonEvento(
                    texto: 'Eliminar inscripción',
                    icono: Icons.delete_outline_rounded,
                    color: colorRojo,
                    onPressed: () => _confirmarEliminar(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(
          Icons.warning_amber_rounded,
          size: 42,
          color: colorRojo,
        ),
        title: const Text('¿Eliminar inscripción?'),
        content: Text(
          'Vas a eliminar tu inscripción a "${inscripcion.evento.nombre}".',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorRojo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    cancelarInscripcion(inscripcion.evento);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Eliminaste la inscripción a ${inscripcion.evento.nombre}',
        ),
      ),
    );
    Navigator.pop(context); // vuelve a la lista de Mis eventos
  }
}
