// lib/presentation/analytics/widgets/budget_distribution_chart.dart
import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';

class BudgetDistributionChart extends StatelessWidget {
  final double incomes;
  final double expenses;

  const BudgetDistributionChart({super.key, required this.incomes, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final total = incomes + expenses;
    final incomeWidthFactor = total > 0 ? incomes / total : 0.5;
    final expenseWidthFactor = total > 0 ? expenses / total : 0.5;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución de Flujos (Proporcional)',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          // Gráfico de barra partida simétrica
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  if (incomes > 0) Expanded(flex: (incomeWidthFactor * 100).toInt(), child: Container(color: AppTheme.accentColor)),
                  if (expenses > 0) Expanded(flex: (expenseWidthFactor * 100).toInt(), child: Container(color: const Color(0xFFEF4444))),
                  if (incomes == 0 && expenses == 0) Expanded(child: Container(color: AppTheme.borderColor)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Leyenda Informativa
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem('Ingresos', incomes, AppTheme.accentColor, total),
              _buildLegendItem('Gastos', expenses, const Color(0xFFEF4444), total),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, double amount, Color color, double total) {
    final percentage = total > 0 ? (amount / total) * 100 : 0.0;
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            Text(
              '\$ ${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        )
      ],
    );
  }
}