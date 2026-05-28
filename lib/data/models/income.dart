import 'package:objectbox/objectbox.dart';
import 'income_enums.dart';
import 'expense_enums.dart'; // Reutilizamos el enum de Currency (USD, NIO) de forma consistente

@Entity()
class Income {
  @Id()
  int id;

  String name;
  double amount;
  DateTime date;
  String? notes;
  
  // Guardamos el hexadecimal del color seleccionado de forma explícita
  int colorHex; 

  // Atributos de persistencia para Enums (ObjectBox almacena String/Int nativamente)
  String dbCategory;
  String dbCurrency;
  String dbRecurrence;

  Income({
    this.id = 0,
    required this.name,
    required this.amount,
    required this.date,
    required this.colorHex,
    required this.dbCategory,
    required this.dbCurrency,
    required this.dbRecurrence,
    this.notes,
  });

  // --- Getters Dinámicos para transformar la persistencia en Enums Seguros ---

  /// Retorna el enum de [IncomeCategory] correspondiente
  IncomeCategory get category {
    try {
      return IncomeCategory.values.byName(dbCategory);
    } catch (_) {
      return IncomeCategory.other;
    }
  }

  /// Retorna el enum de [Currency] reutilizado de gastos
  Currency get currency {
    try {
      return Currency.values.byName(dbCurrency);
    } catch (_) {
      return Currency.nio;
    }
  }

  /// Retorna el enum de [RecurrenceFrequency] correspondiente
  RecurrenceFrequency get recurrence {
    try {
      return RecurrenceFrequency.values.byName(dbRecurrence);
    } catch (_) {
      return RecurrenceFrequency.none;
    }
  }
}