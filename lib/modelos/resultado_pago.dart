import 'billetera.dart';
import 'inscripcion.dart';

class ResultadoPago {
  final Billetera billetera;
  final Inscripcion inscripcion;
  const ResultadoPago({required this.billetera, required this.inscripcion});
}
