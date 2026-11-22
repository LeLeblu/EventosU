import 'dart:convert';
import 'dart:io';

import 'package:eventos_app/servicios/evento.dart';
import 'package:eventos_app/servicios/eventos_mock.dart';
import 'package:eventos_app/servicios/complemento_eventos.dart';
import 'package:eventos_app/servicios/filtro_eventos.dart';

void comprobar(bool condicion, String mensaje) {
  if (!condicion) throw StateError(mensaje);
}

void main(List<String> argumentos) {
  final categorias = eventosMock.map((e) => e.categoria).toSet().toList();
  final filas = [
    for (var i = 0; i < eventosMock.length; i++)
      {
        'idEvento': i + 1,
        'idCategoria': categorias.indexOf(eventosMock[i].categoria) + 1,
        'categoria': eventosMock[i].categoria,
        'titulo': eventosMock[i].nombre,
        'descripcion': eventosMock[i].descripcion,
        'fecha': eventosMock[i].fecha,
        'hora': eventosMock[i].hora,
        'ubicacion': eventosMock[i].ubicacion,
        'precio': eventosMock[i].precioPesos,
        'cuposDisponibles': eventosMock[i].cupos,
        'imagen': File(
          'assets/eventos/${Uri.parse(eventosMock[i].imagen).pathSegments[1]}.jpg',
        ).readAsBytesSync(),
      },
  ];
  if (argumentos.contains('--exportar')) {
    stdout.writeln(jsonEncode(filas));
    return;
  }
  final eventos = filas.map((fila) {
    final complemento = complementoEvento(fila);
    return Evento.desdeMapa(
      fila,
      organizador: complemento.organizador,
      subcategoria: complemento.subcategoria,
    );
  }).toList();
  comprobar(
    eventos.length == 11 && categorias.length == 3,
    'El catalogo debe conservar sus 11 eventos y 3 categorias.',
  );
  comprobar(
    eventos.every((e) => e.imagenBytes!.isNotEmpty && e.fechaHora != null),
    'Cada evento inicial debe tener fotografia y fecha legible.',
  );
  comprobar(
    eventos[1].precioPesos == 15000 && eventos.first.esGratis,
    'Los precios deben conservar el monto entero y los eventos gratuitos.',
  );
  comprobar(eventos[6].agotado, 'Cero cupos debe mostrar Agotado.');
  comprobar(
    filtrarEventos(
          eventos,
          categoria: 'Tecnología',
          filtro: 'Talleres',
          busqueda: '  FLUTTER ',
        ).single.idEvento ==
        2,
    'La busqueda debe combinarse con categoria y subcategoria.',
  );
  comprobar(
    filtrarEventos(eventos, filtro: 'Deportes').length == 3,
    'El filtro general debe seleccionar la categoria.',
  );
  comprobar(
    filtrarEventos(eventos, busqueda: 'Coliseo').single.idEvento == 7,
    'Debe buscar por ubicacion.',
  );
  comprobar(
    filtrarEventos(eventos, busqueda: 'sin coincidencias').isEmpty,
    'Debe admitir resultados vacios.',
  );
  final modificado = {...filas.first, 'precio': 23000, 'cuposDisponibles': 0};
  final complemento = complementoEvento(modificado);
  final actualizado = Evento.desdeMapa(
    modificado,
    organizador: complemento.organizador,
    subcategoria: complemento.subcategoria,
  );
  comprobar(
    actualizado.precioPesos == 23000 && actualizado.agotado,
    'El complemento no debe reemplazar los precios y cupos de SQLite.',
  );
  final desconocido = {...filas.first, 'titulo': 'Otro evento'};
  comprobar(
    complementoEvento(desconocido).subcategoria.isEmpty,
    'No debe asignar metadatos del catalogo a eventos ajenos.',
  );
  comprobar(
    Evento.desdeMapa({...filas.first, 'hora': '12:00 a.m.'}).fechaHora!.hour ==
        0,
    'Debe interpretar medianoche.',
  );
  comprobar(
    Evento.desdeMapa({...filas.first, 'hora': '12:00 p.m.'}).fechaHora!.hour ==
        12,
    'Debe interpretar mediodia.',
  );
  comprobar(
    Evento.desdeMapa({...filas.first, 'fecha': '31 de febrero de 2026'})
            .fechaHora ==
        null,
    'No debe normalizar una fecha inexistente.',
  );
  stdout.writeln(
    'Correcto: catalogo, BLOB, precios, cupos, fechas y filtros combinados.',
  );
}
