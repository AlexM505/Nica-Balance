import 'package:flutter/material.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/income.dart';
import '../../../data/models/expense_enums.dart';
import '../../expenses/viewmodels/expense_viewmodel.dart';
import '../../income/viewmodels/income_viewmodel.dart';

class DashboardViewModel extends ChangeNotifier {
  final ExpenseViewModel _expenseViewModel;
  final IncomeViewModel _incomeViewModel;

  static const double _exchangeRate = 36.0;

  DashboardViewModel({
    required this._expenseViewModel,
    required this._incomeViewModel,
  }) {
    // Escuchamos los cambios de ambos ViewModels subyacentes para replicar reactividad
    _expenseViewModel.addListener(notifyListeners);
    _incomeViewModel.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _expenseViewModel.removeListener(notifyListeners);
    _incomeViewModel.removeListener(notifyListeners);
    super.dispose();
  }

  // Lógica de conversión encapsulada en el dominio del ViewModel
  double convertToUsd(double amount, Currency currency) {
    if (currency == Currency.nio) {
      return amount / _exchangeRate;
    }
    return amount;
  }

  // --- GETTERS DIRECTOS Y ENCAPSULADOS ---

  double get totalIncomesUsd {
    return _incomeViewModel.incomes.fold(0.0, (sum, item) {
      return sum + convertToUsd(item.amount, item.currency);
    });
  }

  double get totalExpensesUsd {
    return _expenseViewModel.expenses.fold(0.0, (sum, item) {
      return sum + convertToUsd(item.amount, item.currency);
    });
  }

  double get netBalanceUsd => totalIncomesUsd - totalExpensesUsd;

  List<Expense> get recentExpenses => _expenseViewModel.expenses.take(3).toList();
  
  List<Income> get recentIncomes => _incomeViewModel.incomes.take(3).toList();
}