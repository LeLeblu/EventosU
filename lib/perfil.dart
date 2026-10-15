
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'barra_navegacion.dart';

const Color colorPerfil = Color(0xFF5263FA);
const Color colorTextoPerfil = Color(0xFF222222);

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final TextEditingController nombreController =
      TextEditingController(text: 'Yoly Mancera');

  final TextEditingController correoController =
      TextEditingController(text: 'Yoly@correo.com');

  final TextEditingController programaController =
      TextEditingController(text: 'Desarrollo de software');

  final ImagePicker picker = ImagePicker();

  File? fotoPerfil;

  // Identifica cuál campo se está editando.
  String? campoEditando;

  // Guarda el valor anterior para poder cancelar.
  String? valorAnterior;

  Future<void> cambiarFoto() async {
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (imagen != null && mounted) {
      setState(() {
        fotoPerfil = File(imagen.path);
      });
    }
  }

  void iniciarEdicion(String campo) {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      campoEditando = campo;

      switch (campo) {
        case 'Nombre':
          valorAnterior = nombreController.text;
          break;
        case 'Correo':
          valorAnterior = correoController.text;
          break;
        case 'Programa':
          valorAnterior = programaController.text;
          break;
      }
    });
  }

  void cancelarEdicion() {
    setState(() {
      switch (campoEditando) {
        case 'Nombre':
          nombreController.text = valorAnterior ?? '';
          break;
        case 'Correo':
          correoController.text = valorAnterior ?? '';
          break;
        case 'Programa':
          programaController.text = valorAnterior ?? '';
          break;
      }

      campoEditando = null;
      valorAnterior = null;
    });
  }

  void guardarPerfil() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      campoEditando = null;
      valorAnterior = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Información actualizada en esta demostración',
        ),
      ),
    );
  }

  Widget textoPerfil(String texto, {bool negrita = false}) {
    return Text(
      texto,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: colorTextoPerfil,
        fontWeight:
            negrita ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget campoTexto({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      autofocus: true,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: colorTextoPerfil,
      ),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget filaPerfil({
    required IconData icono,
    required String titulo,
    required Widget contenido,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 9,
          horizontal: 15,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icono,
              color: colorPerfil,
              size: 23,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textoPerfil(titulo, negrita: true),
                  const SizedBox(height: 2),
                  contenido,
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade700,
                size: 23,
              ),
          ],
        ),
      ),
    );
  }

  Widget botonesEdicion() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: cancelarEdicion,
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: guardarPerfil,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPerfil,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    programaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar:
          const BarraNavegacion(indiceActual: 3),

      body: Stack(
        children: [
          // Encabezado azul morado.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 235,
            child: Container(
              decoration: const BoxDecoration(
                color: colorPerfil,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                18,
                8,
                18,
                20,
              ),
              child: Column(
                children: [
                  // Título y notificaciones.
                  Row(
                    children: [
                      Text(
                        'Mi perfil',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          tooltip: 'Notificaciones',
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No tienes notificaciones nuevas',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.notifications_active_outlined,
                            color: colorPerfil,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Foto de perfil.
                  Center(
                    child: SizedBox(
                      width: 112,
                      height: 112,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 56,
                            backgroundColor: Colors.black,
                            backgroundImage: fotoPerfil != null
                                ? FileImage(fotoPerfil!)
                                : null,
                            child: fotoPerfil == null
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white70,
                                    size: 62,
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              child: IconButton(
                                tooltip: 'Cambiar foto',
                                onPressed: cambiarFoto,
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.black87,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tarjeta de información.
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.18,
                          ),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Eventos asistidos.
                        filaPerfil(
                          icono: Icons.calendar_month,
                          titulo: 'Eventos Asistidos',
                          contenido: textoPerfil('12'),
                        ),

                        // Nombre.
                        filaPerfil(
                          icono: Icons.person,
                          titulo: 'Nombre',
                          onTap: campoEditando == null
                              ? () => iniciarEdicion('Nombre')
                              : null,
                          contenido: campoEditando == 'Nombre'
                              ? campoTexto(
                                  controller: nombreController,
                                )
                              : textoPerfil(
                                  nombreController.text,
                                ),
                        ),

                        // Correo.
                        filaPerfil(
                          icono: Icons.alternate_email,
                          titulo: 'Correo',
                          onTap: campoEditando == null
                              ? () => iniciarEdicion('Correo')
                              : null,
                          contenido: campoEditando == 'Correo'
                              ? campoTexto(
                                  controller: correoController,
                                  keyboardType:
                                      TextInputType.emailAddress,
                                )
                              : textoPerfil(
                                  correoController.text,
                                ),
                        ),

                        // Programa.
                        filaPerfil(
                          icono: Icons.school_outlined,
                          titulo: 'Programa',
                          onTap: campoEditando == null
                              ? () => iniciarEdicion('Programa')
                              : null,
                          contenido: campoEditando == 'Programa'
                              ? campoTexto(
                                  controller: programaController,
                                )
                              : textoPerfil(
                                  programaController.text,
                                ),
                        ),
                      ],
                    ),
                  ),

                  // Botones exclusivos del campo seleccionado.
                  if (campoEditando != null)
                    botonesEdicion(),

                  const SizedBox(height: 22),

                  // Cerrar sesión cuando no se está editando.
                  if (campoEditando == null)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Color(0xFFDC2626),
                        size: 17,
                      ),
                      label: Text(
                        'Cerrar sesión',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFFDC2626),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
