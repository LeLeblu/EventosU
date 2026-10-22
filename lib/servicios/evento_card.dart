import 'package:flutter/material.dart';

import 'evento.dart';

/// Estilo y widgets compartidos por las pantallas de eventos.
/// Colores y medidas tomados del diseño en Figma del grupo:
/// morado #5263FA, verde #AFF4C6 (Deportes), amarillo #FFF1C2 (Música),
/// naranja #FF8D28 (Inscribirse) y rojo #FF383C (Eliminar).

// ---------------------------------------------------------------- colores
const Color colorPrimario = Color(0xFF5263FA); // morado del grupo
const Color colorLavanda = Color(0xFFDFE2FE); // tarjetas de Tecnología
const Color colorLavandaFuerte = Color(0xFFC9CEFD); // recuadro de categorías
const Color colorVerde = Color(0xFFAFF4C6); // Deportes
const Color colorAmarillo = Color(0xFFFFF1C2); // Música
const Color colorNaranja = Color(0xFFFF8D28); // botón Inscribirse
const Color colorRojo = Color(0xFFFF383C); // botón Eliminar / agotado
const Color colorExito = Color(0xFF22C55E); // Disponible / Inscrito
const Color colorFondo = Color(0xFFFFFFFF);
const Color colorTexto = Color(0xFF1F2033);
const Color colorTextoSuave = Color(0xFF6B6F80);
const Color colorBordeCampo = Color(0xFFD0D0D5);

/// Colores de cada categoría según el diseño.
class TemaCategoria {
  final Color fuerte; // chips seleccionados y acentos
  final Color encabezado; // fondo del encabezado de la categoría
  final Color tarjeta; // fondo de las tarjetas
  final Color textoEncabezado;

  const TemaCategoria({
    required this.fuerte,
    required this.encabezado,
    required this.tarjeta,
    required this.textoEncabezado,
  });
}

TemaCategoria temaCategoria(String categoria) {
  if (categoria == 'Deportes') {
    return const TemaCategoria(
      fuerte: Color(0xFF22B45A),
      encabezado: colorVerde,
      tarjeta: Color(0xFFE6FBEE),
      textoEncabezado: colorTexto,
    );
  }
  if (categoria == 'Música') {
    return const TemaCategoria(
      fuerte: Color(0xFFE9B425),
      encabezado: colorAmarillo,
      tarjeta: Color(0xFFFFF8E1),
      textoEncabezado: colorTexto,
    );
  }
  // Tecnología y "Todos los eventos"
  return const TemaCategoria(
    fuerte: colorPrimario,
    encabezado: colorPrimario,
    tarjeta: colorLavanda,
    textoEncabezado: Colors.white,
  );
}

IconData iconoCategoria(String categoria) {
  if (categoria == 'Tecnología') return Icons.computer_rounded;
  if (categoria == 'Deportes') return Icons.sports_soccer_rounded;
  return Icons.music_note_rounded;
}

/// Mantiene compatibilidad con código que pide un color por categoría.
Color colorCategoria(String categoria) => temaCategoria(categoria).fuerte;

Color colorDisponibilidad(String disponibilidad) {
  if (disponibilidad == 'Disponible') return colorExito;
  return colorRojo; // A punto de cerrar / Agotado
}

IconData iconoDisponibilidad(String disponibilidad) {
  if (disponibilidad == 'Agotado') return Icons.cancel_rounded;
  if (disponibilidad == 'A punto de cerrar') {
    return Icons.local_fire_department_rounded;
  }
  return Icons.check_circle_rounded;
}

// --------------------------------------------------------------- utilidades
List<BoxShadow> sombraSuave() => [
      BoxShadow(
        color: Colors.black.withAlpha(20),
        blurRadius: 14,
        offset: const Offset(0, 5),
      ),
    ];

List<BoxShadow> sombraColor(Color color) => [
      BoxShadow(
        color: color.withAlpha(90),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ];

/// Decoración de los campos de texto (igual a login y registro).
InputDecoration decoracionCampo(String etiqueta, IconData icono) {
  return InputDecoration(
    labelText: etiqueta,
    prefixIcon: Icon(icono, color: colorPrimario),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: colorBordeCampo),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: colorBordeCampo),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: colorPrimario, width: 2),
    ),
  );
}

/// Barra superior blanca con título centrado (estilo del tema del grupo).
AppBar barraSuperior(String titulo) {
  return AppBar(
    title: Text(
      titulo,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colorTexto,
      ),
    ),
    centerTitle: true,
    backgroundColor: colorFondo,
    surfaceTintColor: Colors.transparent,
    foregroundColor: colorTexto,
    elevation: 0,
  );
}

Widget circulo(double tamano, Color color) => Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

/// Fila con ícono y texto, como en las tarjetas del diseño.
Widget filaInfo(
  IconData icono,
  String texto, {
  Color? color,
  bool negrita = false,
  double tamano = 13,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Icon(icono, size: 18, color: color ?? colorTexto),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: tamano,
              color: color ?? colorTexto,
              fontWeight: negrita ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Botón grande con sombra (325 x 41 en el diseño, esquinas de 20).
class BotonEvento extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final Color color;
  final VoidCallback? onPressed;

  const BotonEvento({
    super.key,
    required this.texto,
    required this.color,
    this.icono,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final activo = onPressed != null;
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: activo ? sombraColor(color) : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE4E4EA),
          disabledForegroundColor: colorTextoSuave,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icono != null) ...[Icon(icono, size: 20), const SizedBox(width: 8)],
            Flexible(child: Text(texto, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

/// "Imagen" del evento: ilustración con degradado del color de la categoría.
class PortadaEvento extends StatelessWidget {
  final Evento evento;
  final double tamanoIcono;
  final BorderRadius borderRadius;

  const PortadaEvento({
    super.key,
    required this.evento,
    this.tamanoIcono = 46,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    final tema = temaCategoria(evento.categoria);
    final base = evento.categoria == 'Tecnología' ? colorPrimario : tema.fuerte;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [base, Color.lerp(base, Colors.black, 0.25)!],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final ancho = c.maxWidth;
            return Stack(
              children: [
                Positioned(
                  top: -ancho * 0.25,
                  right: -ancho * 0.25,
                  child: circulo(ancho * 0.8, Colors.white.withAlpha(30)),
                ),
                Positioned(
                  bottom: -ancho * 0.2,
                  left: -ancho * 0.2,
                  child: circulo(ancho * 0.6, Colors.white.withAlpha(22)),
                ),
                Center(
                  child: Icon(
                    iconoCategoria(evento.categoria),
                    size: tamanoIcono,
                    color: Colors.white,
                  ),
                ),
                // Foto del evento. Mientras carga, o si no hay internet,
                // se ve la ilustración de la categoría que está debajo.
                if (evento.imagen.isNotEmpty)
                  Positioned.fill(
                    child: Image.network(
                      evento.imagen,
                      fit: BoxFit.cover,
                      frameBuilder: (context, child, frame, sincrono) =>
                          AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: child,
                      ),
                      errorBuilder: (context, error, stack) =>
                          const SizedBox.shrink(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ tarjeta lista
/// Tarjeta de evento (369 x 194 en el diseño): imagen a la izquierda,
/// datos a la derecha y botón circular para ver el detalle.
class EventoCard extends StatelessWidget {
  final Evento evento;
  final VoidCallback onTap;
  final bool compacta; // versión del inicio (sin precio)
  final String? estadoPersonalizado; // ej. "Inscrito" en Mis eventos

  const EventoCard({
    super.key,
    required this.evento,
    required this.onTap,
    this.compacta = false,
    this.estadoPersonalizado,
  });

  @override
  Widget build(BuildContext context) {
    final tema = temaCategoria(evento.categoria);
    final estado = estadoPersonalizado ?? evento.disponibilidad;
    final colorEstado = estadoPersonalizado == null
        ? colorDisponibilidad(estado)
        : (estado == 'Inscrito' ? colorExito : colorNaranja);
    final iconoEstado = estadoPersonalizado == null
        ? Icons.check_circle_outline_rounded
        : (estado == 'Inscrito'
            ? Icons.check_circle_outline_rounded
            : Icons.schedule_rounded);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: tema.tarjeta,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            // Altura suficiente para la letra Poppins (evita el desborde).
            height: compacta ? 160 : 176,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: compacta ? 100 : 112,
                  child: PortadaEvento(evento: evento, tamanoIcono: 40),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evento.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colorTexto,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (estadoPersonalizado != null) ...[
                          // Mis eventos (como el diseño): fecha, lugar y hora.
                          filaInfo(
                            Icons.calendar_month_outlined,
                            evento.fecha.replaceAll(' de 2026', ''),
                          ),
                          filaInfo(Icons.location_on_outlined, evento.ubicacion),
                          filaInfo(Icons.access_time_rounded, evento.hora),
                        ] else ...[
                          filaInfo(
                            Icons.calendar_month_outlined,
                            '${evento.fecha.replaceAll(' de 2026', '')} · ${evento.hora}',
                          ),
                          filaInfo(Icons.location_on_outlined, evento.ubicacion),
                          filaInfo(
                            iconoEstado,
                            estado,
                            color: colorEstado,
                            negrita: true,
                          ),
                        ],
                        const Spacer(),
                        Row(
                          children: [
                            if (!compacta) ...[
                              const Icon(
                                Icons.attach_money_rounded,
                                size: 20,
                                color: colorTexto,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                evento.esGratis
                                    ? 'Gratis'
                                    : evento.precio.replaceAll('\$', ''),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: colorTexto,
                                ),
                              ),
                            ],
                            const Spacer(),
                            // Botón circular morado del diseño.
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: colorPrimario,
                                shape: BoxShape.circle,
                                boxShadow: sombraColor(colorPrimario),
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

// ------------------------------------------------------------- diálogos
void mostrarDemo(BuildContext context, String titulo, String mensaje) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

void mostrarCalendarioDemo(BuildContext context, Evento evento) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: const Icon(
        Icons.event_available_rounded,
        size: 40,
        color: colorNaranja,
      ),
      title: const Text('Agregar al calendario'),
      content: Text(
        '${evento.nombre}\n${evento.fecha} · ${evento.hora}\n${evento.ubicacion}\n\n'
        'Vista de ejemplo: en esta fase no se conecta con el calendario del celular.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Listo'),
        ),
      ],
    ),
  );
}
