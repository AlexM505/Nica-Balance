import 'package:nica_balance/core/database/objectbox_store.dart';
import 'package:objectbox/objectbox.dart';
import '../models/debt.dart';

class DebtRepository {
  final Box<Debt> _debtBox;
  
  DebtRepository(ObjectBoxStore database) : _debtBox = database.store.box<Debt>();


  // Retorna un Stream reactivo para escuchar cambios en tiempo real
  Stream<List<Debt>> listenToDebts() {
    return _debtBox.query().watch(triggerImmediately: true).map((q) => q.find());
  }

  int saveDebt(Debt debt) => _debtBox.put(debt);

  bool deleteDebt(int id) => _debtBox.remove(id);
}