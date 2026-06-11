import 'package:flutter/material.dart';
import 'package:nica_balance/data/models/expense_enums.dart';
import 'package:objectbox/objectbox.dart';

enum DebtType {
  loan(displayName: 'Préstamo Personal', icon: Icons.person_rounded, colorHex: 0xFFF59E0B),
  creditCard(displayName: 'Tarjeta de Crédito', icon: Icons.credit_card_rounded, colorHex: 0xFFEF4444),
  mortgage(displayName: 'Hipoteca / Vivienda', icon: Icons.home_work_rounded, colorHex: 0xFF10B981),
  other(displayName: 'Otra Deuda', icon: Icons.gavel_rounded, colorHex: 0xFF6B7280);

  final String displayName;
  final IconData icon;
  final int colorHex;

  const DebtType({
    required this.displayName,
    required this.icon,
    required this.colorHex,
  });
}

@Entity()
class Debt {
  @Id()
  int id;
  
  String title;          // Qué es (ej. "Visa Clásica", "Préstamo de Juan")
  String creditor;       // A quién se le debe (ej. "Banco BAC", "Mamá")
  double totalAmount;    // Monto inicial/total de la deuda
  double remainingAmount;// Cuánto se debe actualmente
  double interestRate;   // Porcentaje de interés (ej. 12.5 para 12.5%)
  
  int dueDateMilli;      // Próxima fecha límite de pago

  String dbCurrency;

  // Almacenamos el índice del enum para la persistencia
  int typeIndex;

  Debt({
    this.id = 0,
    required this.title,
    required this.creditor,
    required this.totalAmount,
    required this.remainingAmount,
    required this.interestRate,
    required this.dueDateMilli,
    required this.typeIndex,
    required this.dbCurrency,
  });

  // --- Getters de Utilidad ---

  DebtType get type => DebtType.values[typeIndex];

  DateTime get dueDate => DateTime.fromMillisecondsSinceEpoch(dueDateMilli);

  bool get isPaidOff => remainingAmount <= 0;

  // Calcula el dinero pagado hasta el momento
  double get totalPaid => totalAmount - remainingAmount;

  // Porcentaje de progreso de pago
  double get paidPercentage {
    if (totalAmount <= 0) return 1.0;
    final pct = totalPaid / totalAmount;
    return pct > 1.0 ? 1.0 : pct;
  }

  Currency get currency => Currency.values.firstWhere(
        (c) => c.name == dbCurrency,
        orElse: () => Currency.nio,
      );
}