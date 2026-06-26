import 'package:flutter/material.dart';
import 'package:nica_balance/core/services/notification_service.dart';
import 'package:nica_balance/data/models/expense.dart';
import 'package:nica_balance/data/models/expense_enums.dart';
import '../../../data/models/budget.dart';
import '../../../data/models/global_transaction.dart';
import '../../../data/repositories/budget_repository.dart'; 

class BudgetViewModel extends ChangeNotifier {
  final BudgetRepository _budgetRepository;

  List<Budget> _currentMonthBudgets = [];
  List<Budget> get currentMonthBudgets => _currentMonthBudgets;

  BudgetViewModel(this._budgetRepository){
    loadBudgetsForMonth(DateTime.now());
  }

  /// Carga los presupuestos delegando la lectura al repositorio
  void loadBudgetsForMonth(DateTime month) {
    _currentMonthBudgets = _budgetRepository.getBudgetsForMonth(month);
    notifyListeners();
  }

  /// Guarda un presupuesto y actualiza el estado local
  void saveBudget(Budget budget) {
    _budgetRepository.saveBudget(budget);
    loadBudgetsForMonth(budget.targetMonth);
  }

  /// Elimina un presupuesto
  void deleteBudget(int id, DateTime targetMonth) {
    _budgetRepository.deleteBudget(id);
    loadBudgetsForMonth(targetMonth);
  }

  // ─── LÓGICA DE PROYECCIONES FINANCIERAS (Permanecen intactas y puras) ───

  double getSpentForCategory(String categoryName, List<Expense> expenses) {

    final List<GlobalTransaction> allTransactions = [];

    // 1. Mapear Gastos
    for (var exp in expenses) {
      double usdAmount = 0.0;
      if (exp.currency == Currency.nio){
        usdAmount = convertToUsd(exp.amount, exp.currency);
      }else{
        usdAmount = exp.amount;
      }
      allTransactions.add(GlobalTransaction(
        id: 'exp_${exp.id}',
        name: exp.name,
        amount: usdAmount,
        date: exp.date, // Asumiendo que exp.date es DateTime
        type: TransactionType.expense,
        category: exp.category,
        dbCurrency: exp.dbCurrency,
        colorHex: exp.colorHex
      ));
    }

    return allTransactions
        .where((tx) => tx.type == TransactionType.expense && tx.category.displayName == categoryName)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  Color getBudgetColor(double progress) {
    if (progress < 0.50) return const Color(0xFF10B981); // Verde
    if (progress < 0.80) return const Color(0xFFA855F7); // Púrpura
    if (progress < 1.00) return const Color(0xFFF97316); // Naranja
    return const Color(0xFFEF4444); // Rojo
  }

  double getRecommendedDailySpend(Budget budget, double spentAmount) {
    final now = DateTime.now();
    final totalDaysInMonth = DateUtils.getDaysInMonth(budget.targetMonth.year, budget.targetMonth.month);
    final remainingDays = totalDaysInMonth - now.day + 1;

    if (remainingDays <= 0) return 0.0;
    
    final remainingBudget = budget.limitAmount - spentAmount;
    return remainingBudget > 0 ? remainingBudget / remainingDays : 0.0;
  }

  double getSuggestedBudget(String categoryName, List<Expense> allExpenses) {
    final lastMonthDate = DateTime(DateTime.now().year, DateTime.now().month - 1, 1);

    final List<GlobalTransaction> allTransactions = [];

    // 1. Mapear Gastos
    for (var exp in allExpenses) {
      double usdAmount = 0.0;
      if (exp.currency == Currency.nio){
        usdAmount = convertToUsd(exp.amount, exp.currency);
      }else{
        usdAmount = exp.amount;
      }

      allTransactions.add(GlobalTransaction(
        id: 'exp_${exp.id}',
        name: exp.name,
        amount: usdAmount,
        date: exp.date, // Asumiendo que exp.date es DateTime
        type: TransactionType.expense,
        category: exp.category,
        dbCurrency: exp.dbCurrency,
        colorHex: exp.colorHex
      ));
    }
    
    final lastMonthSpent = allTransactions.where((tx) {
      return tx.type == TransactionType.expense && 
             tx.category == categoryName &&
             tx.date.year == lastMonthDate.year &&
             tx.date.month == lastMonthDate.month;
    }).fold(0.0, (sum, tx) => sum + tx.amount);

    return lastMonthSpent > 0 ? (lastMonthSpent * 1.05).roundToDouble() : 100.0;
  }

  void verifyBudgetAlerts(Budget budget, double spentAmount) {
    final progress = spentAmount / budget.limitAmount;

    if (progress >= 1.0 && !budget.notified100) {
      budget.notified100 = true;
      _budgetRepository.saveBudget(budget); // Persistencia a través del repositorio
      NotificationService.showInstantNotification(
        id: budget.id + 2000,
        title: '🚨 Presupuesto Agotado',
        body: 'Has excedido el límite fijado para la categoría ${budget.dbCategory}.',
      );
    } else if (progress >= 0.80 && progress < 1.0 && !budget.notified80) {
      budget.notified80 = true;
      _budgetRepository.saveBudget(budget); // Persistencia a través del repositorio
      NotificationService.showInstantNotification(
        id: budget.id + 1000,
        title: '⚠️ Alerta de Gasto (80%)',
        body: 'Consumiste el 80% de tus fondos destinados a ${budget.dbCategory}.',
      );
    }
  }

  static const double _exchangeRate = 36.0;
   // Lógica de conversión encapsulada en el dominio del ViewModel
  double convertToUsd(double amount, Currency currency) {
    if (currency == Currency.nio) {
      return amount / _exchangeRate;
    }
    return amount;
  }
}