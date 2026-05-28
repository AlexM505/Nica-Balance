import '../../core/database/objectbox_store.dart';
import '../models/expense.dart';
import '../../objectbox.g.dart'; // Generado por build_runner

class ExpenseRepository {
  final Box<Expense> _box;

  ExpenseRepository(ObjectBoxStore database) : _box = database.store.box<Expense>();

  List<Expense> getAllExpenses() => _box.getAll();

  int saveExpense(Expense expense) => _box.put(expense);

  bool deleteExpense(int id) => _box.remove(id);

  // Stream directo de la base de datos para reactividad Offline-First
  Stream<List<Expense>> watchExpenses() {
    return _box
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
}