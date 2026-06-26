import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import '../../../data/models/budget.dart';

class BudgetTrackerCard extends StatelessWidget {
  final Budget budget;
  final double spentAmount;
  final double dailyRecommended;

  const BudgetTrackerCard({
    super.key,
    required this.budget,
    required this.spentAmount,
    required this.dailyRecommended,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (spentAmount / budget.limitAmount).clamp(0.0, 1.0);
    final progressPercent = (spentAmount / budget.limitAmount * 100).toStringAsFixed(0);
    
    final Color stateColor = spentAmount > budget.limitAmount 
        ? const Color(0xFFEF4444)
        : progress >= 0.8 ? const Color(0xFFF97316) : const Color(0xFF10B981);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(context).withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABECERA: Categoría y Porcentaje consumido
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budget.dbCategory,
                style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$progressPercent%',
                  style: TextStyle(color: stateColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // BARRA DE PROGRESO PREMIUM LINEAL
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.getBorderColor(context).withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(stateColor),
            ),
          ),
          const SizedBox(height: 14),

          // CIFRAS COMPARATIVAS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gastado: \$${spentAmount.toStringAsFixed(2)}',
                style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12),
              ),
              Text(
                'Límite: \$${budget.limitAmount.toStringAsFixed(2)}',
                style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          
          const Divider(height: 24, thickness: 0.5),

          // RECOMENDACIÓN DIARIA EN TIEMPO REAL
          Row(
            children: [
              Icon(Icons.tips_and_updates_rounded, size: 16, color: stateColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  spentAmount >= budget.limitAmount
                      ? '⚠️ Has agotado este presupuesto. Intenta mitigar gastos.'
                      : 'Gasto diario sugerido: \$${dailyRecommended.toStringAsFixed(2)} / día',
                  style: TextStyle(
                    color: spentAmount >= budget.limitAmount ? const Color(0xFFEF4444) : AppTheme.getTextPrimary(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}