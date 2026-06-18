import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/presentation/home/widgets/hero_metric.dart';
import 'package:nica_balance/presentation/settings/viewmodels/preferences_viewmodel.dart';
import 'package:provider/provider.dart';

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
    final prefsVM = context.watch<PreferencesViewModel>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF08284D),
            Colors.blue,
            Colors.indigo,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
            prefsVM.hideBalances 
            ? '\$ •••••••••' 
            : '\$ ${balance.toStringAsFixed(2)}',
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