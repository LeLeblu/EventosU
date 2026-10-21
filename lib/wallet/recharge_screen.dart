import 'package:flutter/material.dart';

class RechargeScreen extends StatefulWidget { /// para introducir datos
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {

  final TextEditingController _valorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Recargar saldo', 
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFABADFF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const[
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ), 
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saldo actual',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('\$100.000',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Espacio entre la sección de saldo actual y la sección de recarga
            const SizedBox(height: 16),
             //Sección de saldo actual
            const Text('Ingrese valor a recargar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            // Campo de texto para ingresar el monto a recargar
            const SizedBox(height: 10),
            
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.number, 
              // para que solo se puedan ingresar números
          
              decoration: InputDecoration(
                hintText: 'Ej: 10000',
                filled: true,
                fillColor: Colors.white,
                
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                 // para redondear los bordes del TextField
                ),  
              ),
            ),

            const SizedBox(height: 20), // Espacio entre el TextField y el botón de recarga
            // Botón para recargar saldo
            SizedBox(
              width: double.infinity,
              
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C20),
                  foregroundColor: Colors.white, 
                  minimumSize: const Size(double.infinity, 48), // para que el botón ocupe todo el ancho disponible
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,

                ),
                ), 
                onPressed: () {
                  // Acción para recargar saldo 
                  final valor = _valorController.text.trim();

                  // Validar que el valor ingresado no esté vacío
                  if (valor.isEmpty) {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Monto inválido'),
                        content: const Text(
                          'Por favor, ingrese un monto válido.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Aceptar',
                            ),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  // Simulación de recarga exitosa
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Recarga exitosa'),
                      content: Text('La recarga de \$$valor fue exitosa.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                  },
                child: const Text('Recargar saldo'), // Texto del botón
              ),
            ),
          ],
      ),
    ),
    ),
  );
  } // Fin del método build
// Liberar recursos del controlador de texto
  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }
}