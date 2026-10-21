import 'package:flutter/material.dart';

import 'evento.dart';
import 'eventos_mock.dart';
import 'detalle_evento_screen.dart';
import 'evento_card.dart';

/// Lista de eventos de una categoría con buscador.
/// Es StatefulWidget porque el texto de búsqueda cambia lo que se muestra.
class EventosCategoriaScreen extends StatefulWidget {
  final String categoria;
  final String busquedaInicial;

  const EventosCategoriaScreen({
    super.key,
    this.categoria = 'Todos los eventos',
    this.busquedaInicial = '',
  });

  @override
  State<EventosCategoriaScreen> createState() => _EventosCategoriaScreenState();
}

class _EventosCategoriaScreenState extends State<EventosCategoriaScreen> {
  late final TextEditingController _busquedaCtrl;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _busqueda = widget.busquedaInicial;
    _busquedaCtrl = TextEditingController(text: widget.busquedaInicial);
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _abrirDetalle(Evento evento) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalleEventoScreen(evento: evento)),
    );
  }

  /// Eventos de la categoría que además coinciden con lo escrito.
  List<Evento> _eventosFiltrados() {
    final texto = _busqueda.trim().toLowerCase();
    final List<Evento> resultado = [];

    for (final evento in eventosMock) {
      final esDeLaCategoria = widget.categoria == 'Todos los eventos' ||
          evento.categoria == widget.categoria;
      final coincide = texto.isEmpty ||
          evento.nombre.toLowerCase().contains(texto) ||
          evento.ubicacion.toLowerCase().contains(texto) ||
          evento.descripcion.toLowerCase().contains(texto);

      if (esDeLaCategoria && coincide) resultado.add(evento);
    }
    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    final eventos = _eventosFiltrados();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F8),
      appBar: AppBar(
        title: Text(widget.categoria),
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Encuentra eventos para ti',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _busquedaCtrl,
                  textInputAction: TextInputAction.search,
                  // setState vuelve a dibujar la lista con cada letra.
                  onChanged: (texto) => setState(() => _busqueda = texto),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o lugar...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _busqueda.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _busquedaCtrl.clear();
                              setState(() => _busqueda = '');
                            },
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Eventos disponibles (${eventos.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: eventos.isEmpty
                ? const Center(child: Text('No se encontraron eventos'))
                : ListView.builder(
                    itemCount: eventos.length,
                    itemBuilder: (context, i) => EventoCard(
                      evento: eventos[i],
                      onTap: () => _abrirDetalle(eventos[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
