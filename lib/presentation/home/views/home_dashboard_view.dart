import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/presentation/debts/viewmodels/debt_viewmodel.dart';
import 'package:nica_balance/presentation/debts/views/debt_form_screen.dart';
import 'package:nica_balance/presentation/debts/views/debts_list_screen.dart';
import 'package:nica_balance/presentation/expenses/views/expense_detail_screen.dart';
import 'package:nica_balance/presentation/expenses/views/expense_list_screen.dart';
import 'package:nica_balance/presentation/home/viewmodels/dashboard_viewmodel.dart';
import 'package:nica_balance/presentation/home/widgets/balance_hero_card.dart';
import 'package:nica_balance/presentation/home/widgets/dashboard_header.dart';
import 'package:nica_balance/presentation/home/widgets/quick_actions_section.dart';
import 'package:nica_balance/presentation/income/views/income_detail_screen.dart';
import 'package:nica_balance/presentation/income/views/income_list_screen.dart';
import 'package:provider/provider.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/income.dart';
import '../../../data/models/expense_enums.dart';

class HomeDashboardView extends StatelessWidget {
  const HomeDashboardView({super.key});

  @override
Widget build(BuildContext context) {
  final dashboardVM = context.watch<DashboardViewModel>();

  return Scaffold(
    body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            top: -100,
            left: -70,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
            ),
          ),
    
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                DashboardHeader(),

                const SizedBox(height: 20),

                BalanceHeroCard(
                  balance: dashboardVM.netBalanceUsd,
                  incomes: dashboardVM.totalIncomesUsd,
                  expenses: dashboardVM.totalExpensesUsd,
                ),

                const SizedBox(height: 16),

                QuickActionsSection(),

                const SizedBox(height: 16),

                Consumer<DebtViewModel>(
                  builder: (context, debtVM, child) {
                    final totalRemaining = debtVM.totalDebtsRemainingUsd;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.getSurfaceColor(context).withValues(alpha: 0.6), //withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: totalRemaining > 0 
                              ? const Color(0xFFEF4444).withValues(alpha: 0.6) // Borde rojo sutil si debe dinero
                              : AppTheme.getBorderColor(context).withValues(alpha: 0.6),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // Redirige al listado completo de deudas al pulsar la tarjeta
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DebtsListScreen()),
                          );
                        },
                        child:  Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.12),
                              radius: 20,
                              child: const Icon(Icons.gavel_rounded, color: Color(0xFFEF4444), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pasivos / Deudas Totales',
                                    style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$ ${totalRemaining.toStringAsFixed(2)}',
                                    style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            // Botón de acción directo para agregar deuda
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const DebtFormScreen()),
                                );
                              },
                              icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryColor, size: 26),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                //         // SECCIÓN: Últimos Gastos
                _buildSectionHeader(
                  context,
                  title: 'Gastos Recientes', 
                  icon: Icons.shopping_bag_rounded,
                  showButton: dashboardVM.recentExpenses.length >= 3, // Validamos el total real de la lista completa
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExpenseListScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                if (dashboardVM.recentExpenses.isEmpty)
                  _buildEmptyPlaceholder(context,message: 'No hay gastos registrados todavía.', icon: Icons.shopping_bag_rounded,)
                else
                  ...dashboardVM.recentExpenses.map((expense) => _buildRecentExpenseRow(context, dashboardVM, expense)),

                const SizedBox(height: 16),

                // SECCIÓN: Últimos Ingresos
                _buildSectionHeader(
                  context,
                  title: 'Ingresos Recientes', 
                  icon: Icons.payments_rounded,
                  showButton: dashboardVM.recentIncomes.length >= 3, // Validamos el total real de la lista completa
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const IncomeListScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                if (dashboardVM.recentIncomes.isEmpty)
                  _buildEmptyPlaceholder(context, message: 'No hay ingresos registrados todavía.', icon: Icons.payments_rounded)
                else
                  ...dashboardVM.recentIncomes.map((income) => _buildRecentIncomeRow(context, dashboardVM, income)),
              
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSectionHeader(BuildContext context,{
  required String title,
  required IconData icon,
  required bool showButton,
  required VoidCallback onTap,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.getTextSecondary(context)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: -0.2),
          ),
        ],
      ),
      if (showButton)
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: AppTheme.primaryColor,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ver todos',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 10),
            ],
          ),
        ),
    ],
  );
}

  Widget _buildRecentExpenseRow(BuildContext context, DashboardViewModel vm, Expense expense) {
    final cat = expense.category;
    final isNio = expense.currency == Currency.nio;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExpenseDetailScreen(expense: expense),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.getBorderColor(context).withValues(alpha: 0.8)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(expense.colorHex).withValues(alpha: 0.15),
              radius: 18,
              child: Icon(cat.icon, color: Color(expense.colorHex), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                expense.name,
                style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 14, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '- ${isNio ? 'C\$' : '\$'} ${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFFF87171), fontSize: 14, fontWeight: FontWeight.w700),
                ),
                if (isNio)
                  Text(
                    '≈ \$ ${vm.convertToUsd(expense.amount, expense.currency).toStringAsFixed(2)}',
                    style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 11, fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentIncomeRow(BuildContext context, DashboardViewModel vm, Income income) {
    final cat = income.category;
    final isNio = income.currency == Currency.nio;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IncomeDetailScreen(income: income),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.getBorderColor(context).withValues(alpha: 0.8)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(income.colorHex).withValues(alpha: 0.15),
              radius: 18,
              child: Icon(cat.icon, color: Color(income.colorHex), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                income.name,
                style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 14, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+ ${isNio ? 'C\$' : '\$'} ${income.amount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFF34D399), fontSize: 14, fontWeight: FontWeight.w700),
                ),
                if (isNio)
                  Text(
                    '≈ \$ ${vm.convertToUsd(income.amount, income.currency).toStringAsFixed(2)}',
                    style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 11, fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder(BuildContext context,{required String message, required IconData icon,}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(context).withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.getTextSecondary(context).withValues(alpha: 0.12),
                child: Icon(icon, size: 32, color: AppTheme.getTextSecondary(context).withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12, fontStyle: FontStyle.normal),
              ),
            ],
          ),
        
        
      ),
    );
  }
}