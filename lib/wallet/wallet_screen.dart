import 'package:flutter/material.dart';

import '../barra_navegacion.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

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
                      margin: const EdgeInsets.only(top: 0), // Ajusta el margen superior según sea necesario
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF757FFB),
                        border: Border.all(
                          color: const Color(0x66FFFFFF),
                          width: 2,
                        ),
                      ),
                      child: const Column(
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
                          Text(
                            '\$100.000',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
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
                      onPressed: () {
                        Navigator.pushNamed(context, '/recharge');
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

                  // Pago de evento
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 66),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD7D8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pago de evento',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '8 de octubre, 2026',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '-\$20.000',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFFF383C),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Recarga de saldo
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 66),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFFBE8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recarga de saldo',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '10 de octubre, 2026',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '+\$25.000',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF20C65A),
                          ),
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
    );
  }
}
