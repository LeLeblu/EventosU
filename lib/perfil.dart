
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
  String? campoEditando;
  String? valorAnterior;

  Future<void> cambiarFoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final XFile? imagen = await picker.pickImage(
      source: source,
      imageQuality: 85,
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

    FocusManager.instance.primaryFocus?.unfocus();
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
        fontSize: 13,
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
        fontSize: 13,
        color: colorTextoPerfil,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF5F6FF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFD8DCFF),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFD8DCFF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: colorPerfil,
            width: 1.5,
          ),
        ),
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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 23,
          horizontal: 17,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: colorPerfil.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icono,
                color: colorPerfil,
                size: 23,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textoPerfil(titulo, negrita: true),
                  const SizedBox(height: 5),
                  contenido,
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade600,
                size: 25,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget botonesEdicion() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: cancelarEdicion,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorPerfil,
                side: const BorderSide(color: colorPerfil),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
    final double altoPantalla = MediaQuery.sizeOf(context).height;

    // El fondo morado llega más abajo.
    final double altoEncabezado =
        (altoPantalla * 0.43).clamp(300.0, 350.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      resizeToAvoidBottomInset: true,
      bottomNavigationBar:
          const BarraNavegacion(indiceActual: 3),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: altoEncabezado,
            child: Container(
              decoration: const BoxDecoration(
                color: colorPerfil,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título y campana con fondo morado.
                  Row(
                    children: [
                      Text(
                        'Mi perfil',
                        style: GoogleFonts.poppins(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: colorPerfil,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
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
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  // Foto de perfil.
                  Center(
                    child: SizedBox(
                      width: 124,
                      height: 124,
                      child: Stack(
                        children: [
                          Container(
                            width: 116,
                            height: 116,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: const Color(0xFF30344D),
                              backgroundImage: fotoPerfil != null
                                  ? FileImage(fotoPerfil!)
                                  : null,
                              child: fotoPerfil == null
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white70,
                                      size: 64,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              elevation: 3,
                              child: IconButton(
                                tooltip: 'Cambiar foto',
                                onPressed: cambiarFoto,
                                icon: const Icon(
                                  Icons.edit,
                                  color: colorPerfil,
                                  size: 19,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Más separación para bajar la tarjeta.
                  const SizedBox(height: 38),

                  // Tarjeta de información.
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFEBEDFA),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorPerfil.withValues(alpha: 0.09),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        filaPerfil(
                          icono: Icons.calendar_month_rounded,
                          titulo: 'Eventos asistidos',
                          contenido: textoPerfil('12'),
                        ),
                        const Divider(
                          height: 1,
                          indent: 17,
                          endIndent: 17,
                          color: Color(0xFFEEEEF5),
                        ),
                        filaPerfil(
                          icono: Icons.person_outline_rounded,
                          titulo: 'Nombre',
                          onTap: campoEditando == null
                              ? () => iniciarEdicion('Nombre')
                              : null,
                          contenido: campoEditando == 'Nombre'
                              ? campoTexto(
                                  controller: nombreController,
                                )
                              : textoPerfil(nombreController.text),
                        ),
                        const Divider(
                          height: 1,
                          indent: 17,
                          endIndent: 17,
                          color: Color(0xFFEEEEF5),
                        ),
                        filaPerfil(
                          icono: Icons.alternate_email_rounded,
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
                              : textoPerfil(correoController.text),
                        ),
                        const Divider(
                          height: 1,
                          indent: 17,
                          endIndent: 17,
                          color: Color(0xFFEEEEF5),
                        ),
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
                              : textoPerfil(programaController.text),
                        ),
                        if (campoEditando != null) botonesEdicion(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (campoEditando == null)
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFDC2626),
                          size: 19,
                        ),
                        label: Text(
                          'Cerrar sesión',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.w500,
                          ),
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
