import '../base_datos/pago_dao.dart';
import '../base_datos/evento_dao.dart';
import '../servicios/sesion_usuario.dart';

import 'package:flutter/material.dart';

import '../servicios/evento.dart';
import 'billetera_estado.dart';

class PaymentScreen extends StatefulWidget {
  final Evento evento;

  const PaymentScreen({super.key, required this.evento});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Evento? _actual;
  Evento get evento => _actual ?? widget.evento;
  bool _pagando = false;
  late final int _idUsuario;
  bool _cargando = true;
  bool _error = false;
  @override
  void initState() {
    super.initState();
    _idUsuario = SesionUsuario.idUsuario;
    _cargarSaldo();
  }

  Future<void> _cargarSaldo() async {
    setState(() {
      _cargando = true;
      _error = false;
    });
    try {
      final id = widget.evento.idEvento;
      final actual = id == null ? null : await EventoDao.obtenerPorId(id);
      if (actual == null) throw const ErrorPago('El evento ya no existe');
      await cargarBilletera();
      if (!mounted || SesionUsuario.usuarioActual?.idUsuarios != _idUsuario) {
        return;
      }
      setState(() => _actual = actual);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _pagar() async {
    if (_pagando ||
        _cargando ||
        _error ||
        SesionUsuario.usuarioActual?.idUsuarios != _idUsuario) {
      return;
    }
    setState(() => _pagando = true);
    try {
      await pagarEvento(evento);
      if (!mounted || SesionUsuario.usuarioActual?.idUsuarios != _idUsuario) {
        return;
      }
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Evento pagado con éxito'),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/mis-eventos',
                    (route) => route.isFirst,
                  );
                },
                child: const Text('Ver mis eventos'),
              ),
            ],
          ),
        ),
      );
    } on ErrorPago catch (error) {
      if (mounted) {
        await _mostrarError(error.mensaje);
        if (mounted) await _cargarSaldo();
      }
    } catch (_) {
      if (mounted) {
        await _mostrarError(
          'No se pudo completar el pago. Consulta tu saldo y Mis Eventos antes de reintentar',
        );
      }
    } finally {
      if (mounted) setState(() => _pagando = false);
    }
  }

  Future<void> _mostrarError(String mensaje) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('No se pudo realizar el pago'),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Realizar pago')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalles del pago:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Fecha: ${evento.fecha}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Ubicación: ${evento.ubicacion}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(evento.hora, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Monto a pagar: ${evento.precio}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<int>(
              valueListenable: saldoBilletera,
              builder: (_, saldo, _) => Text(
                _cargando
                    ? 'Cargando saldo...'
                    : _error
                    ? 'No se pudieron consultar los datos del pago'
                    : 'Saldo disponible: ${formatearPesos(saldo)} COP',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (_error)
              TextButton(
                onPressed: _cargarSaldo,
                child: const Text('Reintentar consulta'),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _pagando || _cargando || _error ? null : _pagar,
              child: const Text('Pagar'),
            ),
          ],
        ),
      ),
    );
  }
}
