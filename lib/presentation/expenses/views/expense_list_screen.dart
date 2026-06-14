import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/presentation/expenses/views/expense_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/expense_enums.dart';
import '../viewmodels/expense_viewmodel.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpenseViewModel>();

    // final expenses = viewModel.expenses;
    // Calcular el total histórico directo de la fuente para el encabezado de esta vista
    // final double totalExpense = expenses.fold(0.0, (sum, item) => sum + item.amount);


    return Scaffold(
      appBar: AppBar(title: const Text('Mis Gastos')),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.expenses.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_rounded, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text(
                          'Aún no has registrado ningún gasto',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(18),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Acumulado',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '\$ ${viewModel.totalExpensesUsd.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppTheme.accentColor, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: viewModel.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = viewModel.expenses[index];
                          return _ExpenseCard(expense: expense);
                        },
                      ),
                    ),
                  ]
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  const _ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ExpenseViewModel>();
    final category = expense.category;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExpenseDetailScreen(expense: expense),
          ),
        );
      },
      child: Card(
        color: AppTheme.surfaceColor,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderColor, width: 1), // Borde sutil para delimitar la tarjeta
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(category.colorHex).withValues(alpha: 0.15),
            child: Icon(
              category.icon,
              color: Color(category.colorHex),
            ),
          ),
          title: Text(expense.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          subtitle: Text('${category.displayName} • ${expense.date.day}/${expense.date.month}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${expense.currency == Currency.usd ? '\$' : 'C\$'}${expense.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: expense.isPaid ? const Color(0xFF34D399) : const Color(0xFFF87171),
                    ),
                  ),
                  if (expense.currency == Currency.nio)
                    Text(
                      '≈ \$ ${viewModel.convertToUsd(expense.amount, expense.currency).toStringAsFixed(2)}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                ],
              ),

              IconButton(
                icon: Icon(
                  expense.isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: expense.isPaid ? const Color(0xFF34D399) : AppTheme.textSecondary,
                  size: 24,              
                ),
                onPressed: () => viewModel.togglePaymentStatus(expense),
              ),
            ],
          ),
        ),
      ),
    );
  }
}