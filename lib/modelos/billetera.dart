class Movimiento {
  final int idMovimiento;
  final String tipo;
  final int monto;
  final String descripcion;
  final DateTime fecha;

  Movimiento.desdeMapa(Map<String, Object?> fila)
    : idMovimiento = fila['idMovimiento'] as int,
      tipo = fila['tipo'] as String,
      monto = fila['monto'] as int,
      descripcion = fila['descripcion'] as String? ?? '',
      fecha = DateTime.parse(fila['fechaMovimiento'] as String).toLocal();
}

class Billetera {
  final int idBilletera;
  final int idUsuario;
  final int saldo;
  final List<Movimiento> movimientos;

  const Billetera({
    required this.idBilletera,
    required this.idUsuario,
    required this.saldo,
    required this.movimientos,
  });
}
