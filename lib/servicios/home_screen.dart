import 'package:flutter/material.dart';

import '../barra_navegacion.dart';
import 'evento.dart';
import 'eventos_mock.dart';
import 'detalle_evento_screen.dart';
import 'evento_card.dart';
import 'eventos_categoria_screen.dart';
import 'inscripciones_estado.dart';

// Burbujas: los mismos tonos del login y el registro.
const Color _burbuja = Color(0xFF858BFA);

/// Pantalla principal: encabezado con burbujas, buscador flotante,
/// categorías, evento destacado y próximos eventos.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _abrirCategoria(
    BuildContext context,
    String categoria, {
    String busqueda = '',
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventosCategoriaScreen(
          categoria: categoria,
          busquedaInicial: busqueda,
        ),
      ),
    );
  }

  void _abrirDetalle(BuildContext context, Evento evento) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalleEventoScreen(evento: evento)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorFondo,
      bottomNavigationBar: const BarraNavegacion(indiceActual: 0),
      body: Stack(
        children: [
          // Burbujas decorativas de fondo (quedan quietas al desplazar).
          Positioned(
            top: 430,
            left: -40,
            child: circulo(90, _burbuja.withAlpha(60)),
          ),
          Positioned(top: 520, left: 34, child: circulo(12, colorPrimario.withAlpha(110))),
          Positioned(
            bottom: 40,
            right: -36,
            child: circulo(110, _burbuja.withAlpha(55)),
          ),
          Positioned(bottom: 160, right: 46, child: circulo(14, colorPrimario.withAlpha(110))),

          ListView(
            padding: EdgeInsets.zero,
            children: [
              _encabezado(context, ancho),
              const SizedBox(height: 22),
              _seccion('Categorías', null),
              _categorias(context),
              const SizedBox(height: 22),
              _seccion('Destacado de la semana', null),
              _destacado(context, talentosMock),
              const SizedBox(height: 18),
              _seccion(
                'Próximos eventos',
                TextButton(
                  onPressed: () =>
                      _abrirCategoria(context, 'Todos los eventos'),
                  child: const Text(
                    'Ver todos',
                    style: TextStyle(
                      color: colorPrimario,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              for (final evento in proximosEventosMock)
                EventoCard(
                  evento: evento,
                  compacta: true,
                  onTap: () => _abrirDetalle(context, evento),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _seccion(String titulo, Widget? accion) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, accion == null ? 20 : 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorTexto,
              ),
            ),
          ),
          if (accion != null) accion,
        ],
      ),
    );
  }

  // ------------------------------------------------------------ encabezado
  Widget _encabezado(BuildContext context, double ancho) {
    final arriba = MediaQuery.of(context).padding.top;

    // El buscador "flota" sobre el borde inferior del encabezado.
    // El Padding inferior deja espacio para que todo el buscador sea tocable.
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(36),
            bottomRight: Radius.circular(36),
          ),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6673FF), colorPrimario, Color(0xFF4351E8)],
              ),
            ),
            child: Stack(
              children: [
                // Burbujas del encabezado.
                Positioned(
                  top: -60,
                  right: -40,
                  child: circulo(170, _burbuja.withAlpha(150)),
                ),
                Positioned(
                  top: arriba + 70,
                  right: 120,
                  child: circulo(12, Colors.white.withAlpha(170)),
                ),
                Positioned(
                  top: arriba + 8,
                  left: ancho * 0.45,
                  child: circulo(8, Colors.white.withAlpha(140)),
                ),
                Positioned(
                  bottom: -50,
                  left: -30,
                  child: circulo(120, _burbuja.withAlpha(120)),
                ),
                Positioned(
                  bottom: 40,
                  left: 92,
                  child: circulo(16, _burbuja),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(22, arriba + 22, 22, 62),
                  child: _saludo(context),
                ),
              ],
            ),
          ),
          ),
        ),
        // Buscador flotante.
        Positioned(
          left: 22,
          right: 22,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: colorPrimario.withAlpha(60),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              textInputAction: TextInputAction.search,
              // Al presionar buscar, abre todos los eventos ya filtrados.
              onSubmitted: (texto) => _abrirCategoria(
                context,
                'Todos los eventos',
                busqueda: texto,
              ),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar eventos para esta semana',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: colorTextoSuave,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: colorPrimario,
                  size: 26,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Material(
                    color: colorPrimario,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Ver todos los eventos',
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () =>
                          _abrirCategoria(context, 'Todos los eventos'),
                    ),
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _saludo(BuildContext context) {
    return ValueListenableBuilder<List<Inscripcion>>(
      valueListenable: inscripciones,
      builder: (context, lista, _) {
        // El nombre sale del último formulario de inscripción.
        final nombre =
            lista.isEmpty ? 'Estudiante' : lista.last.nombre.split(' ').first;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar con la inicial.
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(45),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                nombre.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text.rich toma la letra del tema (Poppins).
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Hola, '),
                        TextSpan(
                          text: nombre,
                          style: const TextStyle(color: colorNaranja),
                        ),
                        const TextSpan(text: ' 👋'),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '¿Qué evento deseas descubrir hoy?',
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Campana con punto naranja de aviso.
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: sombraSuave(),
                  ),
                  child: IconButton(
                    tooltip: 'Notificaciones',
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: colorPrimario,
                    ),
                    onPressed: () => mostrarDemo(
                      context,
                      'Notificaciones',
                      'No tienes notificaciones nuevas.',
                    ),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorNaranja,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------ categorías
  Widget _categorias(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final categoria in ['Tecnología', 'Deportes', 'Música'])
            Expanded(child: _itemCategoria(context, categoria)),
        ],
      ),
    );
  }

  Widget _itemCategoria(BuildContext context, String categoria) {
    final tema = temaCategoria(categoria);
    final fondo = categoria == 'Tecnología' ? colorLavanda : tema.tarjeta;
    final burbuja =
        categoria == 'Tecnología' ? colorLavandaFuerte : tema.encabezado;
    final colorIcono = categoria == 'Tecnología' ? colorPrimario : tema.fuerte;
    final cantidad = eventosMock.where((e) => e.categoria == categoria).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Material(
        color: fondo,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _abrirCategoria(context, categoria),
          child: Stack(
            children: [
              // Burbuja dentro de la tarjeta.
              Positioned(top: -22, right: -22, child: circulo(70, burbuja)),
              Positioned(bottom: 10, left: 8, child: circulo(8, burbuja)),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: sombraSuave(),
                      ),
                      child: Icon(
                        iconoCategoria(categoria),
                        color: colorIcono,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      categoria,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorTexto,
                      ),
                    ),
                    Text(
                      '$cantidad eventos',
                      style: const TextStyle(
                        fontSize: 11,
                        color: colorTextoSuave,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- destacado
  Widget _destacado(BuildContext context, Evento evento) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        borderRadius: BorderRadius.circular(26),
        clipBehavior: Clip.antiAlias,
        color: colorPrimario,
        child: InkWell(
          onTap: () => _abrirDetalle(context, evento),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorPrimario, Color(0xFF7B5CFA)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(top: -40, right: -30, child: circulo(140, _burbuja.withAlpha(140))),
                Positioned(bottom: -30, right: 70, child: circulo(70, _burbuja.withAlpha(110))),
                Positioned(top: 18, right: 110, child: circulo(10, Colors.white.withAlpha(150))),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: Icon(
                    iconoCategoria(evento.categoria),
                    size: 74,
                    color: Colors.white.withAlpha(70),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorNaranja,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '¡Últimos cupos!',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        evento.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${evento.fecha.replaceAll(' de 2026', '')} · ${evento.hora}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              evento.ubicacion,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ver evento',
                              style: TextStyle(
                                color: colorPrimario,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: colorPrimario,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
