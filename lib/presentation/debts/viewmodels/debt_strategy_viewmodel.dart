import 'package:flutter/material.dart';
import 'package:nica_balance/core/services/debt_strategy_engine.dart';
import '../../../data/models/debt.dart';

class DebtStrategyViewModel extends ChangeNotifier {
  DebtStrategy _selectedStrategy = DebtStrategy.snowball;
  double _extraBudget = 0.0;
  List<Debt> _allDebts = []; // Esta lista se alimentará desde el repositorio o DebtViewModel principal

  DebtStrategy get selectedStrategy => _selectedStrategy;
  double get extraBudget => _extraBudget;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  void setDebts(List<Debt> debts) {
    _isLoading = true;

    _allDebts = debts.where((d) => d.remainingAmount > 0).toList();

    _isLoading = false;
    notifyListeners();
  }

  void changeStrategy(DebtStrategy strategy) {
    _selectedStrategy = strategy;
    notifyListeners();
  }

  void updateExtraBudget(double amount) {
    _extraBudget = amount;
    notifyListeners();
  }

  /// Obtiene la lista ordenada para la UI
  List<Debt> get prioritizedDebts {
    return DebtStrategyEngine.sortDebts(debts: _allDebts, strategy: _selectedStrategy);
  }

  /// Obtiene las proyecciones detalladas de meses e intereses acumulados
  List<StrategyReportItem> get strategyProjections {
    return DebtStrategyEngine.calculateProjections(
      debts: _allDebts,
      strategy: _selectedStrategy,
      extraSnowballAmount: _extraBudget,
    );
  }
}