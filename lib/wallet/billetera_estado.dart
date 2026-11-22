import 'package:flutter/foundation.dart';

import '../base_datos/billetera_dao.dart';
import '../modelos/billetera.dart';
import '../servicios/sesion_usuario.dart';
import '../servicios/evento.dart';
import '../servicios/inscripciones_estado.dart';
import '../base_datos/pago_dao.dart';

final ValueNotifier<int> saldoBilletera = ValueNotifier<int>(0);
final ValueNotifier<List<Movimiento>> movimientosBilletera = ValueNotifier([]);
int? _usuarioCache;
int _revision = 0;
final _recargasEnCurso = <int>{};

void limpiarBilletera() {
  _usuarioCache = null;
  _revision++;
  saldoBilletera.value = 0;
  movimientosBilletera.value = [];
}

void _preparar(int idUsuario) {
  if (_usuarioCache != idUsuario) {
    limpiarBilletera();
    _usuarioCache = idUsuario;
  }
}

void _publicar(Billetera billetera) {
  saldoBilletera.value = billetera.saldo;
  movimientosBilletera.value = billetera.movimientos;
}

Future<void> cargarBilletera() async {
  final idUsuario = SesionUsuario.idUsuario;
  _preparar(idUsuario);
  final revision = ++_revision;
  final dao = await BilleteraDao.abrir();
  final billetera = await dao.obtener(idUsuario);
  if (SesionUsuario.usuarioActual?.idUsuarios == idUsuario &&
      revision == _revision) {
    _publicar(billetera);
  }
}

Future<void> recargarBilletera(int monto) async {
  final idUsuario = SesionUsuario.idUsuario;
  _preparar(idUsuario);
  if (!_recargasEnCurso.add(idUsuario)) {
    throw const ErrorBilletera('Ya hay una recarga en curso');
  }
  try {
    ++_revision;
    final dao = await BilleteraDao.abrir();
    final billetera = await dao.recargar(idUsuario, monto);
    if (SesionUsuario.usuarioActual?.idUsuarios == idUsuario) {
      ++_revision;
      _publicar(billetera);
    }
  } finally {
    _recargasEnCurso.remove(idUsuario);
  }
}

String formatearPesos(int valor) =>
    '\$${valor.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (match) => '${match[1]}.')}';

final _pagosEnCurso = <String>{};

Future<void> pagarEvento(Evento evento) async {
  final idUsuario = SesionUsuario.idUsuario;
  final idEvento = evento.idEvento;
  if (idEvento == null) throw const ErrorPago('El evento no está guardado');
  final clave = '$idUsuario:$idEvento';
  if (!_pagosEnCurso.add(clave)) {
    throw const ErrorPago('Ya se está procesando este pago');
  }
  _preparar(idUsuario);
  ++_revision;
  try {
    final dao = await PagoDao.abrir();
    final resultado = await dao.pagar(
      idUsuario,
      idEvento,
      precioConfirmado: evento.precioPesos,
    );
    if (SesionUsuario.usuarioActual?.idUsuarios == idUsuario) {
      ++_revision;
      _publicar(resultado.billetera);
      publicarInscripcionConfirmada(resultado.inscripcion);
    }
  } finally {
    _pagosEnCurso.remove(clave);
  }
}
