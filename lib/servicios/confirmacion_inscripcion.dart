import 'package:flutter/material.dart';

import '../wallet/payment_screen.dart';
import 'evento.dart';
import 'evento_card.dart';
import 'inscripciones_estado.dart';

/// Ventana flotante para confirmar la inscripción a un evento
/// (reemplaza el formulario: los datos del usuario son los de su cuenta).
///
/// Muestra la foto, el nombre, quién lo organiza, fecha, hora, lugar y precio,
/// con el botón verde "Confirmar inscripción" y el rojo "Cancelar inscripción".
Future<void> mostrarConfirmacionInscripcion(
  BuildContext context,
  Evento evento,
) async {
  final confirmo = await showDialog<bool>(
    context: context,
    builder: (ctx) => _VentanaConfirmacion(evento: evento),
  );
  if (confirmo != true || !context.mounted) return;

  // Se guarda la inscripción. Si el evento tiene costo queda pendiente de pago.
  agregarInscripcion(
    Inscripcion(
      evento: evento,
      estado: evento.esGratis ? 'Inscrito' : 'Pendiente de pago',
    ),
  );

  if (evento.esGratis) {
    _mostrarExito(context, evento);
  } else {
    // Evento con costo: continúa en la pantalla de pago de la billetera.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentScreen(evento: evento)),
    );
  }
}

void _mostrarExito(BuildContext context, Evento evento) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: const CircleAvatar(
        radius: 30,
        backgroundColor: colorVerde,
        child: Icon(Icons.check_rounded, size: 36, color: Color(0xFF15803D)),
      ),
      title: const Text(
        'Inscripción exitosa',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: Text(
        'Quedaste inscrito en "${evento.nombre}".\n'
        'Te esperamos el ${evento.fecha} a las ${evento.hora}',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cerrar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colorPrimario,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/mis-eventos',
              (route) => false,
            );
          },
          child: const Text('Ver mis eventos'),
        ),
      ],
    ),
  );
}

class _VentanaConfirmacion extends StatelessWidget {
  final Evento evento;

  const _VentanaConfirmacion({required this.evento});

  @override
  Widget build(BuildContext context) {
    final e = evento;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      backgroundColor: const Color(0xFFF2F2F7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Foto del evento con la X para cerrar.
            SizedBox(
              height: 170,
              child: Stack(
                children: [
                  Positioned.fill(child: PortadaEvento(evento: e, tamanoIcono: 60)),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorPrimario,
                        shape: BoxShape.circle,
                        boxShadow: sombraColor(colorPrimario),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: 'Cerrar',
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colorTexto,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Creado por ${e.organizador}',
                    style: const TextStyle(fontSize: 12, color: colorTextoSuave),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: filaInfo(Icons.calendar_month_outlined, e.fecha),
                      ),
                      SizedBox(
                        width: 108,
                        child: filaInfo(Icons.access_time_rounded, e.hora),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: filaInfo(Icons.location_on_outlined, e.ubicacion),
                      ),
                      SizedBox(
                        width: 108,
                        child: filaInfo(
                          Icons.attach_money_rounded,
                          e.esGratis ? 'Gratis' : e.precio,
                          color: e.esGratis ? colorExito : colorTexto,
                          negrita: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFD9D9DE), thickness: 1),
                  const SizedBox(height: 12),
                  const Text(
                    '¿Seguro que deseas inscribirte a este evento?',
                    style: TextStyle(fontSize: 14, color: colorTexto),
                  ),
                  const SizedBox(height: 16),
                  BotonEvento(
                    texto: 'Confirmar inscripción',
                    color: colorExito,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                  const SizedBox(height: 12),
                  BotonEvento(
                    texto: 'Cancelar inscripción',
                    color: colorRojo,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
