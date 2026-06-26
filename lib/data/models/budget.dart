import 'package:objectbox/objectbox.dart';

@Entity()
class Budget {
  @Id()
  int id = 0;

  // Monto límite que el usuario planea gastar
  double limitAmount;

  // Guardamos la categoría como String para compatibilidad con ObjectBox
  String dbCategory;

  // Mes y año al que corresponde este presupuesto (Formato: DateTime(2026, 6, 1))
  @Property(type: PropertyType.date)
  DateTime targetMonth;

  // Banderas para evitar disparar la misma notificación múltiples veces
  bool notified80 = false;
  bool notified100 = false;

  Budget({
    this.id = 0,
    required this.limitAmount,
    required this.dbCategory,
    required this.targetMonth,
    this.notified80 = false,
    this.notified100 = false,
  });
}