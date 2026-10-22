import 'package:flutter/material.dart';

import '../wallet/payment_screen.dart';
import 'evento.dart';
import 'evento_card.dart';
import 'formulario_inscripcion_screen.dart';
import 'inscripciones_estado.dart';

/// Detalle del evento (diseño "Detalle evento" del Figma):
/// imagen superior, hoja blanca redondeada con los datos, recuadro de precio
/// y botón naranja "Inscribirse".
class DetalleEventoScreen extends StatelessWidget {
  final Evento evento;

  const DetalleEventoScreen({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      body: Stack(
        children: [
          // Imagen superior (393 x 210 en el diseño) con opacidad del 70 %.
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Opacity(
              opacity: 0.85,
              child: PortadaEvento(evento: evento, tamanoIcono: 90),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _botonCerrar(context),
              ),
            ),
          ),
          // Hoja blanca con el contenido.
          Padding(
            padding: const EdgeInsets.only(top: 220),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                children: [
                  ...contenidoDetalleEvento(evento),
                  const SizedBox(height: 22),
                  _recuadroPrecio(evento),
                  const SizedBox(height: 14),
                  _botonInscribirse(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonCerrar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorPrimario,
        shape: BoxShape.circle,
        boxShadow: sombraColor(colorPrimario),
      ),
      child: IconButton(
        tooltip: 'Cerrar',
        icon: const Icon(Icons.close_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// Recuadro de precio (325 x 62): morado claro si es pago, verde si es gratis.
  Widget _recuadroPrecio(Evento e) {
    final fondo = e.esGratis ? colorVerde : colorLavanda;
    final acento = e.esGratis ? const Color(0xFF15803D) : colorPrimario;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.confirmation_number_outlined, color: acento, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Precio',
                  style: TextStyle(fontSize: 14, color: colorTexto),
                ),
                Text(
                  e.esGratis ? 'Gratis' : '${e.precio} COP',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorTexto,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Cupos',
                style: TextStyle(fontSize: 12, color: colorTextoSuave),
              ),
              Text(
                '${e.cupos}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: acento,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botonInscribirse(BuildContext context) {
    // Escucha las inscripciones: si cambian, el botón se actualiza solo.
    return ValueListenableBuilder<List<Inscripcion>>(
      valueListenable: inscripciones,
      builder: (context, lista, _) {
        final mia = lista.where((i) => i.evento.nombre == evento.nombre);
        if (mia.isNotEmpty && mia.first.estado == 'Pendiente de pago') {
          return BotonEvento(
            texto: 'Completar pago',
            icono: Icons.payment_rounded,
            color: colorNaranja,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PaymentScreen(evento: evento)),
            ),
          );
        }
        if (mia.isNotEmpty) {
          return const BotonEvento(
            texto: 'Ya estás inscrito',
            icono: Icons.check_circle_rounded,
            color: colorExito,
          );
        }
        if (evento.agotado) {
          return const BotonEvento(
            texto: 'Evento agotado',
            icono: Icons.block_rounded,
            color: colorRojo,
          );
        }
        return BotonEvento(
          texto: evento.esGratis ? 'Inscribirse' : 'Inscribirse y pagar',
          color: colorNaranja,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormularioInscripcionScreen(evento: evento),
            ),
          ),
        );
      },
    );
  }
}

/// Título, organizador, fecha, hora, lugar, estado y descripción.
/// Se reutiliza en el detalle de "Mis eventos".
List<Widget> contenidoDetalleEvento(Evento e, {String? estado}) {
  final textoEstado = estado ?? e.disponibilidad;
  final colorEstado = estado == null
      ? colorDisponibilidad(textoEstado)
      : (estado == 'Inscrito' ? colorExito : colorNaranja);
  final iconoEstado = estado == null
      ? iconoDisponibilidad(textoEstado)
      : (estado == 'Inscrito'
          ? Icons.check_circle_rounded
          : Icons.schedule_rounded);

  return [
    Text(
      e.nombre,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: colorTexto,
      ),
    ),
    const SizedBox(height: 4),
    Text(
      'Creado por ${e.organizador}',
      style: const TextStyle(fontSize: 14, color: colorTextoSuave),
    ),
    const SizedBox(height: 14),
    Row(
      children: [
        Expanded(child: filaInfo(Icons.calendar_month_outlined, e.fecha)),
        const SizedBox(width: 8),
        SizedBox(
          width: 118,
          child: filaInfo(Icons.access_time_rounded, e.hora),
        ),
      ],
    ),
    Row(
      children: [
        Expanded(child: filaInfo(Icons.location_on_outlined, e.ubicacion)),
        const SizedBox(width: 8),
        SizedBox(
          width: 118,
          child: filaInfo(
            iconoEstado,
            textoEstado,
            color: colorEstado,
            negrita: true,
          ),
        ),
      ],
    ),
    const SizedBox(height: 16),
    const Divider(color: Color(0xFFE2E2E8), thickness: 1),
    const SizedBox(height: 12),
    const Text(
      'Descripción del evento',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorTexto,
      ),
    ),
    const SizedBox(height: 10),
    Text(
      e.descripcion,
      style: const TextStyle(fontSize: 14, color: colorTexto, height: 1.45),
    ),
  ];
}
