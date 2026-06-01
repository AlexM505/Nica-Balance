import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/presentation/home/widgets/hero_metric.dart';

class BalanceHeroCard extends StatelessWidget {
  final double balance;
  final double incomes;
  final double expenses;

  const BalanceHeroCard({
    super.key,
    required this.balance,
    required this.incomes,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0A4FB3),
            Color(0xFF1D7BE8),
            Color(0xFF45B649),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Balance Total Disponible (USD)',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 4),

          Text(
            '\$ ${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.4
            ),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              Expanded(
                child: Metric(
                  title: "Ingresos",
                  value: incomes,
                  icon: Icons.trending_up,
                ),
              ),
              Expanded(
                child: Metric(
                  title: "Gastos",
                  value: expenses,
                  icon: Icons.trending_down,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}