import 'package:flutter/material.dart';
import '../../../data/models/global_transaction.dart';
import '../../expenses/viewmodels/expense_viewmodel.dart';
import '../../income/viewmodels/income_viewmodel.dart';
import '../../goals/viewmodels/goals_viewmodel.dart';

class CalendarViewModel extends ChangeNotifier {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  
  DateTime get selectedMonth => _selectedMonth;

  // Actualiza el filtro de mes y año
  void changeMonth(DateTime newMonth) {
    _selectedMonth = DateTime(newMonth.year, newMonth.month);
    notifyListeners();
  }

  // Combina, filtra y estructura todas las transacciones por día del mes seleccionado
  Map<int, List<GlobalTransaction>> getGroupedTransactions({
    required ExpenseViewModel expenseVM,
    required IncomeViewModel incomeVM,
    required GoalsViewModel goalsVM,
  }) {
    final List<GlobalTransaction> allTransactions = [];

    // 1. Mapear Gastos
    for (var exp in expenseVM.expenses) {
      allTransactions.add(GlobalTransaction(
        id: 'exp_${exp.id}',
        name: exp.name,
        amount: exp.amount,
        date: exp.date, // Asumiendo que exp.date es DateTime
        type: TransactionType.expense,
        category: exp.category,
        dbCurrency: exp.dbCurrency,
        colorHex: exp.colorHex
      ));
    }

    // 2. Mapear Ingresos
    for (var inc in incomeVM.incomes) {
      allTransactions.add(GlobalTransaction(
        id: 'inc_${inc.id}',
        name: inc.name,
        amount: inc.amount,
        date: inc.date, // Asumiendo que inc.date es DateTime
        type: TransactionType.income,
        category: inc.category,
        dbCurrency: inc.dbCurrency,
        colorHex: inc.colorHex
      ));
    }

    // 3. Mapear Metas (Tomamos la fecha de creación/inicio como punto en el calendario)
    for (var goal in goalsVM.goals) {
      allTransactions.add(GlobalTransaction(
        id: 'goal_${goal.id}',
        name: 'Meta Creada: ${goal.name}',
        amount: goal.targetAmount,
        date: goal.startDate,
        type: TransactionType.goal,
        category: goal.category,
        dbCurrency: goal.dbCurrency,
        colorHex: goal.category.colorHex
      ));
    }

    // 4. Filtrar únicamente las que pertenecen al año y mes seleccionados
    final filtered = allTransactions.where((t) {
      return t.date.year == _selectedMonth.year && t.date.month == _selectedMonth.month;
    }).toList();

    // 5. Ordenar cronológicamente descendente (del día más reciente al más antiguo)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    // 6. Agrupar por el número de día del mes [Día -> Lista de transacciones]
    final Map<int, List<GlobalTransaction>> grouped = {};
    for (var tx in filtered) {
      final day = tx.date.day;
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(tx);
    }

    return grouped;
  }
}