import 'eventos_mock.dart';

// Devuelve el organizador y subcategoría de un evento según la fila de la base de datos.
({String organizador, String subcategoria}) complementoEvento(
  Map<String, Object?> fila,
) {
  for (final original in eventosMock) {
    if (original.nombre == fila['titulo'] &&
        original.categoria == fila['categoria'] &&
        original.fecha == fila['fecha'] &&
        original.hora == fila['hora'] &&
        original.ubicacion == fila['ubicacion']) {
      return (
        organizador: original.organizador,
        subcategoria: original.subcategoria,
      );
    }
  }
  return (organizador: 'Organizador no especificado', subcategoria: '');
}
