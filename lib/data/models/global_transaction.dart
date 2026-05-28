enum TransactionType { expense, income, goal }

class GlobalTransaction {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final dynamic category; // Acepta GoalCategory o la categoría de gastos/ingresos
  final String dbCurrency;
  final int colorHex; 

  GlobalTransaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    required this.dbCurrency,
    required this.colorHex,
  });
}