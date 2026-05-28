import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/presentation/expenses/views/expense_form_screen.dart';
import 'package:provider/provider.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/expense_enums.dart';
import '../viewmodels/expense_viewmodel.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('¿Eliminar Gasto?', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('¿Estás seguro de que deseas borrar "${expense.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              // Eliminamos el registro de ObjectBox a través del ViewModel
              context.read<ExpenseViewModel>().deleteExpense(expense.id);
              
              // Cerramos el diálogo y regresamos al listado principal
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = expense.category;
    final isNio = expense.currency == Currency.nio;
    final categoryColor = Color(cat.colorHex);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Gasto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // BOTÓN DE ELIMINAR
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        children: [
          // CABECERA DESTACADA: Tarjeta con Identidad Visual de Categoría
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [categoryColor, categoryColor.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  radius: 28,
                  child: Icon(cat.icon, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  expense.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  cat.displayName,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Text(
                  '- ${isNio ? 'C\$' : '\$'} ${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                if (isNio) ...[
                  const SizedBox(height: 4),
                  Text(
                    '≈ \$ ${(expense.amount / 36.0).toStringAsFixed(2)} USD',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(height: 32),

          // BLOQUE DE INFORMACIÓN ESPECÍFICA
          const Text('Metadatos de la Transacción', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          _buildInfoRow(Icons.calendar_month_rounded, 'Fecha de registro', '${expense.date.day}/${expense.date.month}/${expense.date.year}'),
          _buildInfoRow(Icons.currency_exchange_rounded, 'Moneda original', isNio ? 'Córdobas (NIO)' : 'Dólares (USD)'),
          _buildInfoRow(Icons.fingerprint_rounded, 'Identificador local', '#${expense.id}'),
          
          const SizedBox(height: 48),

          // BOTÓN DE ACCIÓN: Editar Gasto
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Navega a tu formulario pasándole el gasto para editar
                  builder: (_) => ExpenseFormScreen(expenseToEdit: expense),
                ),
              );
            },
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor, width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_rounded, color: AppTheme.primaryColor, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Modificar Información',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}