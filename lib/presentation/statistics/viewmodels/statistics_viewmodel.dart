import 'package:flutter/material.dart';
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

  StatisticsViewModel({required this.dashboardViewModel});

  void changePeriod(int index) {
    _selectedPeriodIndex = index;
    notifyListeners();
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

    for (final exp in expenses) {
      final String categoryKey = exp.category.displayName;
      
      // Si la categoría ya existe, sumamos el monto
      if (grouped.containsKey(categoryKey)) {
        grouped[categoryKey]!.amount += exp.amount;
      } else {
        // Si es nueva, tomamos su colorHex base o uno por defecto de la lista
        final int hex = exp.colorHex != 0 ? exp.colorHex : defaultColors[colorIndex % defaultColors.length].value;
        grouped[categoryKey] = _CategoryTempData(amount: exp.amount, colorHex: hex, icon: exp.category.icon);
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

    for (final inc in incomes) {
      final String categoryKey = inc.category.displayName.toUpperCase();
      
      // Si la categoría ya existe, sumamos el monto
      if (grouped.containsKey(categoryKey)) {
        grouped[categoryKey]!.amount += inc.amount;
      } else {
        // Si es nueva, tomamos su colorHex base o uno por defecto de la lista
        final int hex = inc.colorHex != 0 ? inc.colorHex : defaultColors[colorIndex % defaultColors.length].value;
        grouped[categoryKey] = _CategoryTempData(amount: inc.amount, colorHex: hex, icon: inc.category.icon);
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
}

class _CategoryTempData {
  double amount;
  final int colorHex;
  final IconData icon;
  _CategoryTempData({required this.amount, required this.colorHex, required this.icon});
}