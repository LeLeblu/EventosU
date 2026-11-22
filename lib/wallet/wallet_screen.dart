import '../modelos/billetera.dart';

import 'package:flutter/material.dart';

import 'billetera_estado.dart';

import '../barra_navegacion.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await cargarBilletera();
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo cargar la billetera');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Widget _movimiento(Movimiento movimiento) {
    final recarga = movimiento.tipo == 'recarga';
    final fecha = movimiento.fecha;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 66),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: recarga ? const Color(0xFFDFFBE8) : const Color(0xFFFFD7D8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movimiento.descripcion.isNotEmpty
                      ? movimiento.descripcion
                      : recarga
                      ? 'Recarga de saldo'
                      : 'Pago de evento',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              '${recarga ? '+' : '-'}${formatearPesos(movimiento.monto)}',
              style: TextStyle(
                fontSize: 16,
                color: recarga
                    ? const Color(0xFF20C65A)
                    : const Color(0xFFFF383C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BarraNavegacion(indiceActual: 2),

      appBar: AppBar(
        backgroundColor: const Color(0xFF5263FA),
        foregroundColor: Colors.white,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Mi billetera',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con el botón superpuesto
            SizedBox(
              height: 240,
              child: Stack(
                children: [
                  // Fondo morado
                  Container(
                    width: double.infinity,
                    height: 210,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5263FA),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                  ),

                  // Círculo del saldo
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 180,
                      height: 180,
                      margin: const EdgeInsets.only(
                        top: 0,
                      ), // Ajusta el margen superior según sea necesario
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF757FFB),
                        border: Border.all(
                          color: const Color(0x66FFFFFF),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Saldo disponible',
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          ValueListenableBuilder<int>(
                            valueListenable: saldoBilletera,
                            builder: (_, saldo, _) => Text(
                              _cargando
                                  ? '...'
                                  : _error != null
                                  ? '--'
                                  : formatearPesos(saldo),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Espacio entre el círculo y el botón // Espacio entre el círculo y el botón
                  // Botón: mitad sobre morado y mitad sobre blanco
                  Positioned(
                    left: 70,
                    right: 70,
                    bottom: 0,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _cargando || _error != null
                          ? null
                          : () async {
                              await Navigator.pushNamed(context, '/recharge');
                              if (mounted) await _cargar();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C20),
                        foregroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 26),
                      label: const Text(
                        'Recargar saldo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Margen de la sección de movimientos
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Últimos movimientos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 20),

                  if (_cargando)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    TextButton(
                      onPressed: _cargar,
                      child: Text('$_error. Reintentar'),
                    )
                  else
                    ValueListenableBuilder<List<Movimiento>>(
                      valueListenable: movimientosBilletera,
                      builder: (context, movimientos, _) => Column(
                        children: movimientos.isEmpty
                            ? [const Text('Aún no tienes movimientos')]
                            : [
                                for (final movimiento in movimientos) ...[
                                  _movimiento(movimiento),
                                  const SizedBox(height: 12),
                                ],
                              ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
