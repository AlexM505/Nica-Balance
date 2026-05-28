import 'package:flutter/foundation.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/expense_repository.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository _repository;

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ExpenseViewModel(this._repository) {
    _listenToExpenses();
  }

  void _listenToExpenses() {
    _isLoading = true;
    _repository.watchExpenses().listen((updatedExpenses) {
      // Ordenamos de forma descendente por fecha
      _expenses = updatedExpenses..sort((a, b) => b.date.compareTo(a.date));
      _isLoading = false;
      notifyListeners();
    });
  }

  void addExpense(Expense expense) {
    _repository.saveExpense(expense);
  }

  void togglePaymentStatus(Expense expense) {
    expense.isPaid = !expense.isPaid;
    _repository.saveExpense(expense); // ObjectBox sobreescribe al detectar el mismo ID
  }

  // void removeExpense(int id) {
  //   _repository.deleteExpense(id);
  // }

  // Eliminar un gasto por ID
  void deleteExpense(int id) {
    _repository.deleteExpense(id); // Asumiendo que tu repositorio usa la caja de ObjectBox
  }

  // Editar/Actualizar un gasto existente
  void updateExpense(Expense updatedExpense) {
    _repository.saveExpense(updatedExpense); 
  }
}