import 'package:nica_balance/core/database/objectbox_store.dart';
import 'package:nica_balance/objectbox.g.dart';
import '../models/income.dart';

class IncomeRepository {
  final Box<Income> _incomeBox;

  IncomeRepository(ObjectBoxStore database) : _incomeBox = database.store.box<Income>();

  /// Registra un nuevo ingreso en el almacenamiento local
  int insertIncome(Income income) {
    return _incomeBox.put(income);
  }

  /// Obtiene todos los ingresos ordenados del más reciente al más antiguo
  List<Income> getAllIncomes() {
    final query = _incomeBox.query().order(Income_.date, flags: Order.descending).build();
    final results = query.find();
    query.close();
    return results;
  }

  /// Elimina un ingreso específico por su ID
  bool deleteIncome(int id) {
    return _incomeBox.remove(id);
  }
}