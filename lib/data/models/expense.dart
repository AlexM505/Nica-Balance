import 'package:objectbox/objectbox.dart';
import 'expense_enums.dart';

@Entity()
class Expense {
  @Id()
  int id;
  
  String name;
  double amount;
  bool isPaid;
  
  @Property(type: PropertyType.date)
  DateTime date;
  
  String? notes;
  int colorHex; 

  // Persistimos los enums como Strings internamente
  String dbCategory;
  String dbCurrency;

  Expense({
    this.id = 0,
    required this.name,
    required this.amount,
    required this.isPaid,
    required this.date,
    required this.dbCategory,
    required this.dbCurrency,
    this.notes,
    required this.colorHex,
  });

  // Getters prácticos para usar los Enums de forma limpia en la UI
  ExpenseCategory get category => ExpenseCategory.values.firstWhere(
        (e) => e.name == dbCategory,
        orElse: () => ExpenseCategory.other,
      );

  Currency get currency => Currency.values.firstWhere(
        (c) => c.name == dbCurrency,
        orElse: () => Currency.nio,
      );
}