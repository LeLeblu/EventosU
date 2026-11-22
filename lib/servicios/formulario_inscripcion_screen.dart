import 'package:flutter/material.dart';

import 'evento.dart';
import 'evento_card.dart';

/// Ventana flotante para confirmar la inscripción al evento.
class FormularioInscripcionScreen extends StatelessWidget {
  final Evento evento;

  const FormularioInscripcionScreen({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      scrollable: true,
      title: Text(
        evento.nombre,
        style: const TextStyle(fontWeight: FontWeight.w700, color: colorTexto),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dato(
              Icons.person_outline_rounded,
              'Creado por',
              evento.organizador,
            ),
            _dato(Icons.calendar_month_outlined, 'Fecha', evento.fecha),
            _dato(Icons.access_time_rounded, 'Hora', evento.hora),
            _dato(Icons.location_on_outlined, 'Lugar', evento.ubicacion),
            _dato(
              Icons.confirmation_number_outlined,
              'Costo',
              evento.esGratis ? 'Gratis' : '${evento.precio} COP',
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colorNaranja),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar inscripción'),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar inscripción'),
          ),
        ),
      ],
    );
  }

  Widget _dato(IconData icono, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: colorPrimario, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta, style: const TextStyle(color: colorTextoSuave)),
                Text(
                  valor,
                  style: const TextStyle(
                    color: colorTexto,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
