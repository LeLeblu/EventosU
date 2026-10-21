
import 'package:flutter/material.dart';

class BarraNavegacion extends StatelessWidget {
  final int indiceActual;

  const BarraNavegacion({
    super.key,
    required this.indiceActual,
  });

  @override
  Widget build(BuildContext context) {
    const Color colorBarra = Color(0xFF5263FA);
    const Color colorCirculo = Colors.white;

    const rutas = [
      '/home',
      '/mis-eventos',
      '/wallet/wallet',
      '/perfil',
    ];

    const iconos = [
      Icons.home,
      Icons.celebration,
      Icons.account_balance_wallet,
      Icons.person,
    ];

    const etiquetas = [
      'Inicio',
      'Mis eventos',
      'Billetera',
      'Perfil',
    ];

    final altoDisponible = MediaQuery.of(context).size.height;
    final altoBarra = (altoDisponible * 0.09).clamp(65.0, 76.0);

    return Container(
      color: colorBarra,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: altoBarra,
          child: Row(
            children: List.generate(rutas.length, (indice) {
              final seleccionado = indice == indiceActual;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (seleccionado) return;

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      rutas[indice],
                      (route) => false,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // El círculo aparece únicamente en el icono seleccionado.
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: seleccionado
                              ? colorCirculo
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconos[indice],
                          size: 25,
                          color: seleccionado
                              ? colorBarra
                              : Colors.white,
                        ),
                      ),

                      const SizedBox(height: 1),

                      Text(
                        etiquetas[indice],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: seleccionado
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
