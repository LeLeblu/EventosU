import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../wallet/payment_screen.dart';
import 'evento.dart';
import 'evento_card.dart';
import 'inscripciones_estado.dart';

/// Formulario para inscribirse a un evento, con validación de campos.
class FormularioInscripcionScreen extends StatefulWidget {
  final Evento evento;

  const FormularioInscripcionScreen({super.key, required this.evento});

  @override
  State<FormularioInscripcionScreen> createState() =>
      _FormularioInscripcionScreenState();
}

class _FormularioInscripcionScreenState
    extends State<FormularioInscripcionScreen> {
  // La llave permite validar todos los campos del formulario a la vez.
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _documentoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _celularCtrl = TextEditingController();

  String? _tipoParticipante;
  bool _aceptaCondiciones = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _documentoCtrl.dispose();
    _correoCtrl.dispose();
    _celularCtrl.dispose();
    super.dispose();
  }

  // ---------------- Validaciones ----------------

  String? _validarNombre(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe tu nombre completo';
    if (texto.length < 3) return 'El nombre es muy corto';
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$").hasMatch(texto)) {
      return 'El nombre solo puede tener letras';
    }
    return null;
  }

  String? _validarDocumento(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe tu número de documento';
    if (texto.length < 6) return 'Debe tener entre 6 y 10 números';
    return null;
  }

  String? _validarCorreo(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe tu correo';
    if (!RegExp(r'^[\w.\-]+@[\w\-]+\.[\w.\-]+$').hasMatch(texto)) {
      return 'Escribe un correo válido, por ejemplo nombre@correo.com';
    }
    return null;
  }

  String? _validarCelular(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe tu número de celular';
    if (texto.length != 10 || !texto.startsWith('3')) {
      return 'El celular debe tener 10 números y empezar por 3';
    }
    return null;
  }

  // ---------------- Envío del formulario ----------------

  void _enviar() {
    final camposValidos = _formKey.currentState!.validate();

    if (!_aceptaCondiciones) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar las condiciones del evento')),
      );
      return;
    }
    if (!camposValidos) return;

    final evento = widget.evento;
    final esGratis = evento.precio == 'Gratis';

    agregarInscripcion(
      Inscripcion(
        evento: evento,
        nombre: _nombreCtrl.text.trim(),
        documento: _documentoCtrl.text.trim(),
        correo: _correoCtrl.text.trim(),
        celular: _celularCtrl.text.trim(),
        estado: esGratis ? 'Inscrito' : 'Pendiente de pago',
      ),
    );

    if (esGratis) {
      _mostrarExito();
    } else {
      // Evento con costo: se continúa en la pantalla de pago de la billetera.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PaymentScreen(evento: evento)),
      );
    }
  }

  void _mostrarExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('✅ Inscripción exitosa'),
        content: Text(
          'Quedaste inscrito en "${widget.evento.nombre}".\n'
          'Te esperamos el ${widget.evento.fecha} a las ${widget.evento.hora}.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // cierra el diálogo
              Navigator.pop(context); // vuelve al detalle del evento
            },
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/mis-eventos',
                (route) => false,
              );
            },
            child: const Text('Ver mis eventos'),
          ),
        ],
      ),
    );
  }

  // ---------------- Interfaz ----------------

  InputDecoration _decoracion(String etiqueta, IconData icono) {
    return InputDecoration(
      labelText: etiqueta,
      prefixIcon: Icon(icono),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final evento = widget.evento;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F8),
      appBar: AppBar(
        title: const Text('Inscripción'),
        backgroundColor: colorPrimario,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          // En pantallas grandes (tablet) el formulario no se estira de más.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _resumenEvento(evento),
                  const SizedBox(height: 20),
                  const Text(
                    'Tus datos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nombreCtrl,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _decoracion('Nombre completo', Icons.person),
                    validator: _validarNombre,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _documentoCtrl,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _decoracion('Número de documento', Icons.badge),
                    validator: _validarDocumento,
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: _decoracion('Correo electrónico', Icons.email),
                    validator: _validarCorreo,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _celularCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _decoracion('Celular', Icons.phone_android),
                    validator: _validarCelular,
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _tipoParticipante,
                    decoration: _decoracion('Tipo de participante', Icons.school),
                    items: const [
                      DropdownMenuItem(value: 'Estudiante', child: Text('Estudiante')),
                      DropdownMenuItem(value: 'Docente', child: Text('Docente')),
                      DropdownMenuItem(value: 'Egresado', child: Text('Egresado')),
                      DropdownMenuItem(value: 'Invitado', child: Text('Invitado')),
                    ],
                    onChanged: (valor) => setState(() => _tipoParticipante = valor),
                    validator: (valor) =>
                        valor == null ? 'Selecciona una opción' : null,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _aceptaCondiciones,
                    onChanged: (valor) =>
                        setState(() => _aceptaCondiciones = valor ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Acepto las condiciones del evento y el tratamiento de mis datos',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimario,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _enviar,
                      child: Text(
                        evento.precio == 'Gratis'
                            ? 'CONFIRMAR INSCRIPCIÓN'
                            : 'CONTINUAR AL PAGO',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _resumenEvento(Evento e) {
    final color = colorCategoria(e.categoria);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withAlpha(40),
              child: Icon(iconoCategoria(e.categoria), color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  filaInfo(Icons.calendar_today, '${e.fecha} · ${e.hora}'),
                  filaInfo(Icons.sell, e.precio),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
