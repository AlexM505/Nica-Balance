import 'package:flutter/material.dart';
import 'package:nica_balance/data/models/expense_enums.dart';
import '../../home/viewmodels/dashboard_viewmodel.dart';

class CategoryStatsData {
  final String categoryName;
  final double amount;
  final Color color;
  final IconData icon;

  CategoryStatsData({
    required this.categoryName,
    required this.amount,
    required this.color,
    required this.icon,
  });
}

class StatisticsViewModel extends ChangeNotifier {
  final DashboardViewModel dashboardViewModel;
  
  int _selectedPeriodIndex = 0; 
  int get selectedPeriodIndex => _selectedPeriodIndex;

  static const double _exchangeRate = 36.0;

  StatisticsViewModel({required this.dashboardViewModel});

  void changePeriod(int index) {
    _selectedPeriodIndex = index;
    notifyListeners();
  }

  /// Helper interno para filtrar listas según el período seleccionado (_selectedPeriodIndex)
  bool _filterByPeriod(DateTime itemDate) {
    final now = DateTime.now();
    switch (_selectedPeriodIndex) {
      case 0: // 7 Días
        final oneWeekAgo = now.subtract(const Duration(days: 7));
        return itemDate.isAfter(oneWeekAgo);
      case 1: // Este Mes
        return itemDate.year == now.year && itemDate.month == now.month;
      case 2: // Este Año
        return itemDate.year == now.year;
      default:
        return true;
    }
  }

  /// Obtiene los datos procesados de Gastos agrupados por Categoría
  List<CategoryStatsData> getExpenseCategoryData() {
    final expenses = dashboardViewModel.expensesList; 
    final Map<String, _CategoryTempData> grouped = {};

    final defaultColors = [
      const Color(0xFFEF4444), 
      const Color(0xFFF59E0B), 
      const Color(0xFF3B82F6), 
      const Color(0xFF10B981), 
      const Color(0xFF8B5CF6), 
    ];

    int colorIndex = 0;
    // APLICACIÓN DEL FILTRO: Solo procesamos los gastos que cumplen la condición de tiempo
    final filteredExpenses = expenses.where((exp) => _filterByPeriod(exp.date));

    for (final exp in filteredExpenses) { //expenses
      final String categoryKey = exp.category.displayName;

      final double usdAmount = convertToUsd(exp.amount, exp.currency);
      
      if (grouped.containsKey(categoryKey)) {
        grouped[categoryKey]!.amount += usdAmount;//exp.amount;
      } else {
        final int hex = exp.colorHex != 0 ? exp.colorHex : defaultColors[colorIndex % defaultColors.length].value;
        grouped[categoryKey] = _CategoryTempData(amount: usdAmount, colorHex: hex, icon: exp.category.icon);
        colorIndex++;
      }
    }

    return grouped.entries.map((entry) {
      
      final String displayName = entry.key[0].toUpperCase() + entry.key.substring(1).toLowerCase();

      return CategoryStatsData(
        categoryName: displayName,
        amount: entry.value.amount,
        color: Color(entry.value.colorHex),
        icon: entry.value.icon,
      );
    }).toList();
  }

  /// Obtiene los datos procesados de Ingresos agrupados por Categoría
  List<CategoryStatsData> getIncomeCategoryData() {
    final incomes = dashboardViewModel.incomesList;
    final Map<String, _CategoryTempData> grouped = {};

    final defaultColors = [
      const Color(0xFF10B981), 
      const Color(0xFF06B6D4), 
      const Color(0xFF3B82F6), 
    ];

    int colorIndex = 0;
    // APLICACIÓN DEL FILTRO: Solo procesamos los ingresos que cumplen la condición de tiempo
    final filteredIncomes = incomes.where((inc) => _filterByPeriod(inc.date));

    for (final inc in filteredIncomes) { //incomes
      final String categoryKey = inc.category.displayName.toUpperCase();
      final double usdAmount = convertToUsd(inc.amount, inc.currency);
      
      if (grouped.containsKey(categoryKey)) {
        grouped[categoryKey]!.amount += usdAmount;//inc.amount;
      } else {
        final int hex = inc.colorHex != 0 ? inc.colorHex : defaultColors[colorIndex % defaultColors.length].value;
        grouped[categoryKey] = _CategoryTempData(amount: usdAmount, colorHex: hex, icon: inc.category.icon);
        colorIndex++;
      }
    }
    return grouped.entries.map((entry) {
      final String displayName = entry.key[0].toUpperCase() + entry.key.substring(1).toLowerCase();

      return CategoryStatsData(
        categoryName: displayName,
        amount: entry.value.amount,
        color: Color(entry.value.colorHex),
        icon: entry.value.icon,
      );
    }).toList();
  }

  /// Obtiene las Deudas agrupadas por acreedor
  List<CategoryStatsData> getDebtData(List debtsFromRepository) {
    final Map<String, double> grouped = {};
    
    for (final debt in debtsFromRepository) {
      grouped[debt.creditor] = (grouped[debt.creditor] ?? 0) + debt.remainingAmount;
    }

    final colors = [
      const Color(0xFFA855F7), 
      const Color(0xFFEC4899), 
      const Color(0xFF64748B), 
    ];

    int colorIndex = 0;
    return grouped.entries.map((entry) {
      return CategoryStatsData(
        categoryName: entry.key,
        amount: entry.value,
        color: colors[colorIndex % colors.length],
        icon: Icons.account_balance_outlined,
      );
    }).toList();
  }

  // Lógica de conversión encapsulada en el dominio del ViewModel
  double convertToUsd(double amount, Currency currency) {
    if (currency == Currency.nio) {
      return amount / _exchangeRate;
    }
    return amount;
  }

  /// Calcula el monto total sumado del período actual (Útil para centrar en el PieChart)
  double getTotalAmountForCurrentPeriod() {
    return getExpenseCategoryData().fold(0, (sum, item) => sum + item.amount);
  }
}

class _CategoryTempData {
  double amount;
  final int colorHex;
  final IconData icon;
  _CategoryTempData({required this.amount, required this.colorHex, required this.icon});
}