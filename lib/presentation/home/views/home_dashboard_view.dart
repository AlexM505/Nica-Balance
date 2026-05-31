import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/presentation/analytics/views/analytics_screen.dart';
import 'package:nica_balance/presentation/debts/viewmodels/debt_viewmodel.dart';
import 'package:nica_balance/presentation/debts/views/debt_form_screen.dart';
import 'package:nica_balance/presentation/debts/views/debts_list_screen.dart';
import 'package:nica_balance/presentation/expenses/views/expense_detail_screen.dart';
import 'package:nica_balance/presentation/expenses/views/expense_list_screen.dart';
import 'package:nica_balance/presentation/home/viewmodels/dashboard_viewmodel.dart';
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
    // Escuchamos únicamente al DashboardViewModel
    final dashboardVM = context.watch<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 6, left: 8, right: 0),
          child: Image.asset('assets/images/nbicon.png', fit: BoxFit.cover,),
        ),
        title: const Text('Nica Balance',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_rounded, color: AppTheme.textSecondary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
        children: [
          // CONTENEDOR HERO: Saldo Neto Global
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, const Color(0xFF234ACC), const Color(0xFF032287)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Balance Total Disponible (USD)',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Icon(Icons.insights_rounded, color: Colors.white.withOpacity(0.8), size: 22),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '\$ ${dashboardVM.netBalanceUsd.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  dashboardVM.netBalanceUsd >= 0 ? 'Cuenta en estado saludable' : 'Balance neto negativo',
                  style: TextStyle(
                    color: dashboardVM.netBalanceUsd >= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // FILA: Tarjetas Bifurcadas en USD
          Row(
            children: [
              Expanded(
                child: _buildMiniBalanceCard(
                  title: 'Ingresos Totales',
                  amount: dashboardVM.totalIncomesUsd,
                  color: AppTheme.accentColor,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMiniBalanceCard(
                  title: 'Gastos Totales',
                  amount: dashboardVM.totalExpensesUsd,
                  color: const Color(0xFFEF4444),
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Colocar debajo del contenedor de Ingresos/Gastos en el ListView principal:
          Consumer<DebtViewModel>(
            builder: (context, debtVM, child) {
              final totalRemaining = debtVM.totalDebtAmount;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: totalRemaining > 0 
                        ? const Color(0xFFEF4444).withOpacity(0.4) // Borde rojo sutil si debe dinero
                        : AppTheme.borderColor,
                  ),
                ),
                child: InkWell(
                borderRadius: BorderRadius.circular(20),
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
                      backgroundColor: const Color(0xFFEF4444).withOpacity(0.12),
                      radius: 20,
                      child: const Icon(Icons.gavel_rounded, color: Color(0xFFEF4444), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pasivos / Deudas Totales',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$ ${totalRemaining.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
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

          const SizedBox(height: 24),

          // SECCIÓN: Últimos Gastos
          _buildSectionHeader(
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
            _buildEmptyPlaceholder(message: 'No hay gastos registrados todavía.', icon: Icons.shopping_bag_rounded,)
          else
            ...dashboardVM.recentExpenses.map((expense) => _buildRecentExpenseRow(context, dashboardVM, expense)),

          const SizedBox(height: 16),

          // SECCIÓN: Últimos Ingresos
          _buildSectionHeader(
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
            _buildEmptyPlaceholder(message: 'No hay ingresos registrados todavía.', icon: Icons.payments_rounded)
          else
            ...dashboardVM.recentIncomes.map((income) => _buildRecentIncomeRow(context, dashboardVM, income)),
        ],
      ),
    );
  }

  Widget _buildMiniBalanceCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                radius: 14,
                child: Icon(icon, color: color, size: 15),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$ ${amount.toStringAsFixed(2)}',
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
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
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: -0.2),
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
          color: AppTheme.surfaceColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor.withOpacity(0.8)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(expense.colorHex).withOpacity(0.15),
              radius: 18,
              child: Icon(cat.icon, color: Color(expense.colorHex), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                expense.name,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
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
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
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
          color: AppTheme.surfaceColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor.withOpacity(0.8)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(income.colorHex).withOpacity(0.15),
              radius: 18,
              child: Icon(cat.icon, color: Color(income.colorHex), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                income.name,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
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
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder({required String message, required IconData icon,}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppTheme.textSecondary.withOpacity(0.6)),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontStyle: FontStyle.normal),
              ),
            ],
          ),
        
        
      ),
    );
  }
}