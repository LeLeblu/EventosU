import 'package:flutter/material.dart';

import 'evento.dart';
import 'eventos_mock.dart';
import 'detalle_evento_screen.dart';
import 'evento_card.dart';

/// Lista de eventos por categoría (diseño "Categorías" del Figma):
/// encabezado del color de la categoría, botones de subcategoría y tarjetas.
/// Es StatefulWidget porque la búsqueda y el filtro cambian la lista.
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
  String _filtro = 'Todos';

  bool get _todas => widget.categoria == 'Todos los eventos';

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

  /// Opciones de los botones superiores: subcategorías (o categorías).
  List<String> _opcionesFiltro() {
    final opciones = <String>['Todos'];
    for (final e in eventosMock) {
      final valor = _todas ? e.categoria : e.subcategoria;
      final pertenece = _todas || e.categoria == widget.categoria;
      if (pertenece && valor.isNotEmpty && !opciones.contains(valor)) {
        opciones.add(valor);
      }
    }
    return opciones;
  }

  /// Eventos que cumplen la categoría, el botón elegido y la búsqueda.
  List<Evento> _eventosFiltrados() {
    final texto = _busqueda.trim().toLowerCase();
    return [
      for (final e in eventosMock)
        if ((_todas || e.categoria == widget.categoria) &&
            (_filtro == 'Todos' ||
                (_todas ? e.categoria : e.subcategoria) == _filtro) &&
            (texto.isEmpty ||
                e.nombre.toLowerCase().contains(texto) ||
                e.ubicacion.toLowerCase().contains(texto) ||
                e.descripcion.toLowerCase().contains(texto)))
          e,
    ];
  }

  void _abrirDetalle(Evento evento) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalleEventoScreen(evento: evento)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = temaCategoria(widget.categoria);
    final eventos = _eventosFiltrados();

    return Scaffold(
      backgroundColor: colorFondo,
      body: Column(
        children: [
          _encabezado(context, tema),
          const SizedBox(height: 14),
          _botonesFiltro(tema),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
            child: Row(
              children: [
                const Text(
                  'Eventos disponibles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorTexto,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                  decoration: BoxDecoration(
                    color: tema.tarjeta,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${eventos.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: tema.fuerte,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: eventos.isEmpty
                ? _sinResultados()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
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

  Widget _encabezado(BuildContext context, TemaCategoria tema) {
    final arriba = MediaQuery.of(context).padding.top;
    final titulo = _todas ? 'Todos los eventos' : widget.categoria;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(8, arriba + 8, 20, 22),
      decoration: BoxDecoration(
        color: tema.encabezado,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Volver',
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: tema.textoEncabezado,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: tema.textoEncabezado,
                  ),
                ),
              ),
              Icon(
                _todas ? Icons.event_rounded : iconoCategoria(widget.categoria),
                color: tema.textoEncabezado.withAlpha(160),
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: sombraSuave(),
              ),
              child: TextField(
                controller: _busquedaCtrl,
                textInputAction: TextInputAction.search,
                // setState vuelve a dibujar la lista con cada letra.
                onChanged: (texto) => setState(() => _busqueda = texto),
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o lugar',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: colorTextoSuave,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: colorTexto),
                  suffixIcon: _busqueda.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpiar búsqueda',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _busquedaCtrl.clear();
                            setState(() => _busqueda = '');
                          },
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Botones superiores (120 x 35 en el diseño).
  Widget _botonesFiltro(TemaCategoria tema) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final opcion in _opcionesFiltro())
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _botonFiltro(opcion, tema),
            ),
        ],
      ),
    );
  }

  Widget _botonFiltro(String opcion, TemaCategoria tema) {
    final seleccionado = _filtro == opcion;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      constraints: const BoxConstraints(minWidth: 96),
      decoration: BoxDecoration(
        color: seleccionado ? tema.fuerte : tema.tarjeta,
        borderRadius: BorderRadius.circular(20),
        boxShadow: seleccionado ? sombraColor(tema.fuerte) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _filtro = opcion),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Center(
              widthFactor: 1,
              child: Text(
                opcion,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w500,
                  color: seleccionado ? Colors.white : colorTexto,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sinResultados() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: colorLavandaFuerte),
            SizedBox(height: 10),
            Text(
              'No se encontraron eventos',
              style: TextStyle(fontSize: 16, color: colorTextoSuave),
            ),
          ],
        ),
      ),
    );
  }
}
