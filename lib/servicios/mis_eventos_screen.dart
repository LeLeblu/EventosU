import 'package:flutter/material.dart';

import '../barra_navegacion.dart';
import 'detalle_mis_evento_screen.dart';
import 'evento_card.dart';
import 'inscripciones_estado.dart';

/// Lista de eventos en los que la persona se inscribió.
/// Al tocar uno se abre su detalle con las opciones del diseño
/// ("Agregar al calendario" y "Eliminar inscripción").
class MisEventosScreen extends StatelessWidget {
  const MisEventosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      bottomNavigationBar: const BarraNavegacion(indiceActual: 1),
      appBar: barraSuperior('Mis eventos'),
      // ValueListenableBuilder redibuja la pantalla cuando cambia la lista.
      body: ValueListenableBuilder<List<Inscripcion>>(
        valueListenable: inscripciones,
        builder: (context, lista, _) {
          if (lista.isEmpty) return _sinInscripciones(context);

          final pendientes =
              lista.where((i) => i.estado == 'Pendiente de pago').length;

          return ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              _resumen(lista.length - pendientes, pendientes),
              for (final ins in lista)
                EventoCard(
                  evento: ins.evento,
                  estadoPersonalizado: ins.estado,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalleMisEventoScreen(inscripcion: ins),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Tarjeta morada con el conteo, como el encabezado de la billetera.
  Widget _resumen(int inscritos, int pendientes) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: colorPrimario,
        borderRadius: BorderRadius.circular(22),
        boxShadow: sombraColor(colorPrimario),
      ),
      child: Row(
        children: [
          Expanded(
            child: _contador(Icons.check_circle_rounded, '$inscritos', 'Inscritos'),
          ),
          Container(width: 1, height: 40, color: Colors.white38),
          Expanded(
            child: _contador(
              Icons.schedule_rounded,
              '$pendientes',
              'Pendientes de pago',
            ),
          ),
        ],
      ),
    );
  }

  Widget _contador(IconData icono, String numero, String texto) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              numero,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Text(
          texto,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _sinInscripciones(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: colorLavanda,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                size: 56,
                color: colorPrimario,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Aún no te has inscrito a ningún evento',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorTexto,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Explora los eventos disponibles y reserva tu cupo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: colorTextoSuave),
            ),
            const SizedBox(height: 22),
            BotonEvento(
              texto: 'Explorar eventos',
              icono: Icons.search_rounded,
              color: colorPrimario,
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
}
