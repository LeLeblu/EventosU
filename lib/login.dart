
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color colorLogin = Color(0xFF5263FA);

class Login extends StatefulWidget {
  const Login({super.key}); // Constructor de la clase Login

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool ocultarPassword = true; // Variable para controlar la visibilidad de la contraseña

<<<<<<< HEAD
  void iniciarSesion() { // Función para manejar el inicio de sesión
    String correo = correoController.text.trim();
    String password = passwordController.text;
=======
  void iniciarSesion() {
    final correo = correoController.text.trim();
    final password = passwordController.text;
>>>>>>> 93aa7a18ecd5b4acad9b93ef0678b19709ab566c

    if (correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
        ),
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final altoPantalla = MediaQuery.of(context).size.height;

    // Espacios adaptables al tamaño del dispositivo.
    final espacioSuperior = (altoPantalla * 0.13).clamp(65.0, 100.0);
    final espacioFormulario = (altoPantalla * 0.065).clamp(24.0, 48.0);
    final espacioInferior = (altoPantalla * 0.06).clamp(20.0, 45.0);

    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(title: const Text('Iniciar sesión'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            const Icon(Icons.event, size: 80, color: Colors.blue),

            const SizedBox(height: 20),

            const Text(
              'INICIAR SESIÓN',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),
             // Campo de texto para el correo electrónico
            TextField(
              controller: correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'ejemplo@correo.com',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),
             // Campo de texto para la contraseña con opción de mostrar/ocultar
            TextField(
              controller: passwordController,
              obscureText: ocultarPassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    ocultarPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {  // Cambia el estado de la visibilidad de la contraseña
                      ocultarPassword = !ocultarPassword;
                    });
                  },
=======
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Círculos decorativos superiores
                Positioned(
                  top: -48,
                  right: 10,
                  child: Container(
                    width: 116,
                    height: 116,
                    decoration: const BoxDecoration(
                      color: Color(0xFF858BFA),
                      shape: BoxShape.circle,
                    ),
                  ),
>>>>>>> 93aa7a18ecd5b4acad9b93ef0678b19709ab566c
                ),

                Positioned(
                  top: 20,
                  right: 92,
                  child: _circulo(9, colorLogin),
                ),

                Positioned(
                  top: 59,
                  right: 17,
                  child: _circulo(9, colorLogin),
                ),

                // Círculos decorativos inferiores
                Positioned(
                  bottom: 67,
                  left: -43,
                  child: _circulo(86, const Color(0xFF858BFA)),
                ),

                Positioned(
                  bottom: -36,
                  left: 76,
                  child: _circulo(83, const Color(0xFF858BFA)),
                ),

                Positioned(
                  bottom: 8,
                  left: 25,
                  child: _circulo(13, colorLogin),
                ),

                // Contenido adaptable y desplazable si hace falta
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: espacioSuperior),

                        Text(
                          '¡Hola de nuevo!',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          'Inicia sesión para continuar',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: espacioFormulario),

                        // Correo electrónico
                        TextField(
                          controller: correoController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Correo electrónico',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFD0D0D5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: colorLogin,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Contraseña
                        TextField(
                          controller: passwordController,
                          obscureText: ocultarPassword,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Contraseña',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  ocultarPassword = !ocultarPassword;
                                });
                              },
                              icon: Icon(
                                ocultarPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFD0D0D5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: colorLogin,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Botón de inicio de sesión
                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton(
                            onPressed: iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorLogin,
                              foregroundColor: Colors.white,
                              elevation: 1,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                                side: const BorderSide(
                                  color: Color(0xFF343434),
                                  width: 0.7,
                                ),
                              ),
                            ),
                            child: Text(
                              'Iniciar sesión',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Enlace al registro
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text(
                                '¿No tienes una cuenta? ',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/registro',
                                  );
                                },
                                child: Text(
                                  'Regístrate aquí',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: colorLogin,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: espacioInferior),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _circulo(double diametro, Color color) {
    return Container(
      width: diametro,
      height: diametro,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
