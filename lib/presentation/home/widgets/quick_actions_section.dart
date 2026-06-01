import 'package:flutter/material.dart';
import 'package:nica_balance/presentation/debts/views/debts_list_screen.dart';
import 'package:nica_balance/presentation/expenses/views/expense_list_screen.dart';
import 'package:nica_balance/presentation/goals/views/goal_form_screen.dart';
import 'package:nica_balance/presentation/home/widgets/action_button.dart';
import 'package:nica_balance/presentation/income/views/income_list_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ActionButton(
            icon: Icons.arrow_downward_rounded,
            label: 'Gastos',
            color: Color(0xFFEF4444),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpenseListScreen()),
              );
            },
          ),
          ActionButton(
            icon: Icons.arrow_upward_rounded,
            label: 'Ingresos',
            color: Color(0xFF34D399),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IncomeListScreen()),
              );
            },
          ),
          ActionButton(
            icon: Icons.flag_outlined,
            label: 'Meta',
            color: Color(0xFFF59E0B),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GoalFormScreen()),
              );
            },
          ),
          ActionButton(
            icon: Icons.account_balance_outlined,
            label: 'Deudas',
            color: Color(0xFF0A4FB3),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DebtsListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}