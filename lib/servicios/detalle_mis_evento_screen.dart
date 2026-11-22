import 'package:flutter/material.dart';

import '../wallet/payment_screen.dart';
import 'detalle_evento_screen.dart';
import 'evento_card.dart';
import 'inscripciones_estado.dart';
import 'calendario_servicio.dart';
import '../base_datos/inscripcion_dao.dart';

/// Detalle de un evento inscrito (diseño "Detalle mis eventos" del Figma):
/// estado "Inscrito", botón naranja "Agregar al calendario" y
/// botón rojo "Eliminar inscripción".
class DetalleMisEventoScreen extends StatefulWidget {
  final Inscripcion inscripcion;

  const DetalleMisEventoScreen({super.key, required this.inscripcion});

  @override
  State<DetalleMisEventoScreen> createState() => _DetalleMisEventoScreenState();
}

class _DetalleMisEventoScreenState extends State<DetalleMisEventoScreen> {
  Inscripcion get inscripcion => widget.inscripcion;
  bool _ocupado = false;
  bool get _pendientePago => inscripcion.estado == 'Pendiente de pago';

  @override
  Widget build(BuildContext context) {
    final e = inscripcion.evento;

    return Scaffold(
      backgroundColor: colorFondo,
      body: Stack(
        children: [
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Opacity(
              opacity: 0.85,
              child: PortadaEvento(evento: e, tamanoIcono: 90),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
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
                ),
              ),
            ),
          ),
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
                  ...contenidoDetalleEvento(e, estado: inscripcion.estado),
                  const SizedBox(height: 18),
                  _entrada(context),
                  const SizedBox(height: 18),
                  if (_pendientePago)
                    BotonEvento(
                      texto: 'Completar pago',
                      icono: Icons.payment_rounded,
                      color: colorNaranja,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(evento: e),
                        ),
                      ),
                    )
                  else
                    BotonEvento(
                      texto: 'Agregar al calendario',
                      icono: Icons.edit_calendar_rounded,
                      color: colorNaranja,
                      onPressed: _ocupado
                          ? null
                          : () => _abrirCalendario(context),
                    ),
                  const SizedBox(height: 12),
                  BotonEvento(
                    texto: 'Eliminar inscripción',
                    icono: Icons.delete_outline_rounded,
                    color: colorRojo,
                    onPressed: _ocupado
                        ? null
                        : () => _confirmarEliminar(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Datos del participante que se capturaron en el formulario.
  Widget _entrada(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorLavanda,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              size: 38,
              color: colorTexto,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mi entrada',
                  style: TextStyle(fontSize: 12, color: colorTextoSuave),
                ),
                Text(
                  inscripcion.nombre.isEmpty
                      ? inscripcion.evento.nombre
                      : inscripcion.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorTexto,
                  ),
                ),
                Text(
                  inscripcion.documento.isEmpty
                      ? inscripcion.estado
                      : 'Documento ${inscripcion.documento}',
                  style: const TextStyle(fontSize: 13, color: colorTexto),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context) async {
    if (_ocupado) return;
    setState(() => _ocupado = true);
    try {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: const Icon(
            Icons.warning_amber_rounded,
            size: 42,
            color: colorRojo,
          ),
          title: const Text('¿Eliminar inscripción?'),
          content: Text(
            'Vas a eliminar tu inscripción a "${inscripcion.evento.nombre}".',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorRojo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sí, eliminar'),
            ),
          ],
        ),
      );

      if (confirmar != true) return;
      try {
        await cancelarInscripcion(inscripcion.evento);
      } on ErrorInscripcion catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.mensaje)));
        }
        return;
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo cancelar la inscripción')),
          );
        }
        return;
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Eliminaste la inscripción a ${inscripcion.evento.nombre}',
          ),
        ),
      );
      Navigator.pop(context); // vuelve a la lista de Mis eventos
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _abrirCalendario(BuildContext context) async {
    if (_ocupado) return;
    setState(() => _ocupado = true);
    try {
      final id = inscripcion.evento.idEvento;
      if (id == null) {
        throw const ErrorInscripcion('El evento no está guardado');
      }
      final abierto = await CalendarioServicio.abrir(id);
      if (!abierto && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se completó la acción. Verifica que tengas una app de calendario',
            ),
          ),
        );
      }
    } on ErrorInscripcion catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.mensaje)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el calendario')),
        );
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }
}
