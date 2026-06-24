import 'package:objectbox/objectbox.dart';
import 'debt.dart';

@Entity()
class Payment {
  @Id()
  int id;

  double amountPaid;    // El monto abonado a la deuda
  DateTime paymentDate; // Fecha en que se realizó el pago
  String? notes;        // Notas opcionales (ej: "Pago con aguinaldo")

  final ToOne<Debt> debt = ToOne<Debt>();

  Payment({
    this.id = 0,
    required this.amountPaid,
    required this.paymentDate,
    this.notes,
  });
}