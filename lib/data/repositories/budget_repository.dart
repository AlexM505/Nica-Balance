import 'package:nica_balance/core/database/objectbox_store.dart';
import 'package:nica_balance/objectbox.g.dart';
import '../models/budget.dart';

class BudgetRepository {
  final Box<Budget> _budgetBox;

  BudgetRepository(ObjectBoxStore database) : _budgetBox = database.store.box<Budget>();

  // BudgetRepository({required Store store}) : _budgetBox = store.box<Budget>();

  /// Obtiene los presupuestos configurados para un mes específico
  List<Budget> getBudgetsForMonth(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    
    final query = _budgetBox.query(
      Budget_.targetMonth.equals(startOfMonth.millisecondsSinceEpoch)
    ).build();
    
    final results = query.find();
    query.close();
    return results;
  }

  /// Guarda o actualiza un presupuesto en la base de datos local
  void saveBudget(Budget budget) {
    _budgetBox.put(budget);
  }

  /// Elimina un presupuesto por su ID
  void deleteBudget(int id) {
    _budgetBox.remove(id);
  }
}