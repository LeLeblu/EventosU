import 'evento.dart';

/// Filtra los registros recuperados de SQLite. No contiene datos de ejemplo.
List<Evento> filtrarEventos(
  List<Evento> eventos, {
  String categoria = 'Todos los eventos',
  String filtro = 'Todos',
  String busqueda = '',
}) {
  final todas = categoria == 'Todos los eventos';
  final texto = busqueda.trim().toLowerCase();
  return eventos
      .where(
        (e) =>
            (todas || e.categoria == categoria) &&
            (filtro == 'Todos' ||
                (todas ? e.categoria : e.subcategoria) == filtro) &&
            (texto.isEmpty ||
                e.nombre.toLowerCase().contains(texto) ||
                e.ubicacion.toLowerCase().contains(texto) ||
                e.descripcion.toLowerCase().contains(texto)),
      )
      .toList();
}
