import 'package:flutter/material.dart';

import '../barra_navegacion.dart';
import 'detalle_mis_evento_screen.dart';
import 'evento_card.dart';
import 'inscripciones_estado.dart';

/// Lista de eventos en los que la persona se inscribió.
/// Al tocar uno se abre su detalle con las opciones del diseño
/// ("Agregar al calendario" y "Eliminar inscripción").
class MisEventosScreen extends StatefulWidget {
  const MisEventosScreen({super.key});

  @override
  State<MisEventosScreen> createState() => _MisEventosScreenState();
}

class _MisEventosScreenState extends State<MisEventosScreen> {
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await cargarInscripciones();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudieron cargar tus inscripciones');
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      bottomNavigationBar: const BarraNavegacion(indiceActual: 1),
      appBar: barraSuperior('Mis eventos'),
      // ValueListenableBuilder redibuja la pantalla cuando cambia la lista.
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: TextButton(
                onPressed: _cargar,
                child: Text('$_error. Reintentar'),
              ),
            )
          : ValueListenableBuilder<List<Inscripcion>>(
              valueListenable: inscripciones,
              builder: (context, lista, _) {
                if (lista.isEmpty) return _sinInscripciones(context);

                // Lista de eventos inscritos, como en el diseño del grupo.
                return ListView(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  children: [
                    for (final ins in lista)
                      EventoCard(
                        evento: ins.evento,
                        estadoPersonalizado: ins.estado,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetalleMisEventoScreen(inscripcion: ins),
                            ),
                          );
                          if (mounted) await _cargar();
                        },
                      ),
                  ],
                );
              },
            ),
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
