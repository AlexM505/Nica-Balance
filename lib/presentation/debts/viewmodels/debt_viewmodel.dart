import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nica_balance/data/models/expense_enums.dart';
import '../../../data/models/debt.dart';
import '../../../data/repositories/debt_repository.dart';

class DebtViewModel extends ChangeNotifier {
  final DebtRepository _debtRepository;
  List<Debt> _debts = [];
  StreamSubscription? _subscription;

  DebtViewModel({required this._debtRepository}) {
    _listenToDebts();
  }

  List<Debt> get debts => List.unmodifiable(_debts);

  // Totales acumulados globales para el Dashboard de deudas
  double get totalDebtAmount => _debts.fold(0.0, (sum, item) => sum + item.remainingAmount);

  void _listenToDebts() {
    _subscription = _debtRepository.listenToDebts().listen((debtsList) {
      _debts = debtsList;
      notifyListeners();
    });
  }

  void addDebt(Debt debt) => _debtRepository.saveDebt(debt);

  void updateDebt(Debt debt) => _debtRepository.saveDebt(debt);

  void deleteDebt(int id) => _debtRepository.deleteDebt(id);

  // Registrar un abono directo que reduce la deuda
  void payAmount(int id, double amount) {
    final index = _debts.indexWhere((d) => d.id == id);
    if (index != -1) {
      final debt = _debts[index];
      debt.remainingAmount -= amount;
      if (debt.remainingAmount < 0) debt.remainingAmount = 0;
      
      _debtRepository.saveDebt(debt);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  static const double _exchangeRate = 36.0;

   // Lógica de conversión encapsulada en el dominio del ViewModel
  double convertToUsd(double amount, Currency currency) {
    if (currency == Currency.nio) {
      return amount / _exchangeRate;
    }
    return amount;
  }

  double get totalDebtsRemainingUsd {
    return _debts.fold(0.0, (sum, item) {
      return sum + convertToUsd(item.remainingAmount, item.currency);
    });
  }

}