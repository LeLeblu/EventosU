
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color colorRegistro = Color(0xFF5263FA);

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController programaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmarPasswordController =
      TextEditingController();

  bool ocultarPassword = true;
  bool ocultarConfirmarPassword = true;

  void registrarUsuario() {
    final nombre = nombreController.text.trim();
    final correo = correoController.text.trim();
    final programa = programaController.text.trim();
    final password = passwordController.text;
    final confirmarPassword = confirmarPasswordController.text;

    if (nombre.isEmpty ||
        correo.isEmpty ||
        programa.isEmpty ||
        password.isEmpty ||
        confirmarPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
        ),
      );
      return;
    }

    if (!correo.contains('@') || !correo.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un correo electrónico válido'),
        ),
      );
      return;
    }

    if (password != confirmarPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Registro de demostración. Ahora puedes iniciar sesión.',
        ),
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    programaController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();
    super.dispose();
  }

  Widget campoTexto({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool ocultar = false,
    Widget? sufijo,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: ocultar,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        suffixIcon: sufijo,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
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
            color: colorRegistro,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget circulo(double diametro, Color color) {
    return Container(
      width: diametro,
      height: diametro,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final altoPantalla = MediaQuery.of(context).size.height;

    // Espacios adaptados a la altura disponible.
    final espacioSuperior = (altoPantalla * 0.10).clamp(48.0, 78.0);
    final espacioFormulario = (altoPantalla * 0.035).clamp(16.0, 26.0);
    final espacioInferior = (altoPantalla * 0.025).clamp(12.0, 22.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Decoración superior
                Positioned(
                  top: -48,
                  right: 10,
                  child: circulo(116, const Color(0xFF858BFA)),
                ),
                Positioned(
                  top: 20,
                  right: 150,
                  child: circulo(20, colorRegistro),
                ),
                Positioned(
                  top: 59,
                  right: 17,
                  child: circulo(9, colorRegistro),
                ),

                // Decoración inferior
                Positioned(
                  bottom: 67,
                  left: -43,
                  child: circulo(86, const Color(0xFF858BFA)),
                ),
                Positioned(
                  bottom: -36,
                  left: 150,
                  child: circulo(95, const Color(0xFF858BFA)),
                ),
                Positioned(
                  bottom: 8,
                  left: 25,
                  child: circulo(20, colorRegistro),
                ),

                // Formulario adaptable
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
                          'Crea tu cuenta',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          'Únete para explorar todos los eventos',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: espacioFormulario),

                        campoTexto(
                          controller: nombreController,
                          hint: 'Nombre completo',
                        ),

                        const SizedBox(height: 10),

                        campoTexto(
                          controller: correoController,
                          hint: 'Correo electrónico',
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 10),

                        campoTexto(
                          controller: programaController,
                          hint: 'Programa al que pertenece',
                        ),

                        const SizedBox(height: 10),

                        campoTexto(
                          controller: passwordController,
                          hint: 'Contraseña',
                          ocultar: ocultarPassword,
                          sufijo: IconButton(
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
                        ),

                        const SizedBox(height: 10),

                        campoTexto(
                          controller: confirmarPasswordController,
                          hint: 'Confirmar contraseña',
                          ocultar: ocultarConfirmarPassword,
                          sufijo: IconButton(
                            onPressed: () {
                              setState(() {
                                ocultarConfirmarPassword =
                                    !ocultarConfirmarPassword;
                              });
                            },
                            icon: Icon(
                              ocultarConfirmarPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton(
                            onPressed: registrarUsuario,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorRegistro,
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
                              'Crear cuenta',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text(
                                '¿Ya tienes una cuenta? ',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/login',
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  'Inicia sesión',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: colorRegistro,
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
}
