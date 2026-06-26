import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../data/models/income.dart';
import '../../../data/models/expense_enums.dart';
import '../viewmodels/income_viewmodel.dart';
import 'income_form_screen.dart'; // Importa tu formulario de ingresos

class IncomeDetailScreen extends StatelessWidget {
  final Income income;

  const IncomeDetailScreen({super.key, required this.income});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('¿Eliminar Ingreso?', style: TextStyle(color: AppTheme.getTextPrimary(context))),
        content: Text('¿Estás seguro de que deseas borrar "${income.name}"? Esta acción afectará tu balance global.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancelar', style: TextStyle(color: AppTheme.getTextSecondary(context))),
          ),
          TextButton(
            onPressed: () {
              context.read<IncomeViewModel>().removeIncome(income.id);
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
    final cat = income.category;
    final isNio = income.currency == Currency.nio;
    final categoryColor = Color(income.colorHex); // Color nativo de la categoría

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Ingreso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABECERA GRADIENTE PREMIUM
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [categoryColor, categoryColor.withValues(alpha: 0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    radius: 28,
                    child: Icon(cat.icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    income.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.displayName,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '+ ${isNio ? 'C\$' : '\$'} ${income.amount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  if (isNio) ...[
                    const SizedBox(height: 4),
                    Text(
                      '≈ \$ ${(income.amount / 36.0).toStringAsFixed(2)} USD',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text('Metadatos de la Transacción', style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            _buildInfoRow(context, Icons.calendar_month_rounded, 'Fecha de entrada', '${income.date.day}/${income.date.month}/${income.date.year}'),
            _buildInfoRow(context, Icons.currency_exchange_rounded, 'Moneda de origen', isNio ? 'Córdobas (NIO)' : 'Dólares (USD)'),
            _buildInfoRow(context, Icons.fingerprint_rounded, 'Identificador local', '#${income.id}'),
            
            const SizedBox(height: 48),

            // BOTÓN MODIFICAR
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IncomeFormScreen(incomeToEdit: income),
                  ),
                );
              },
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.getBorderColor(context), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_rounded, color: AppTheme.primaryColor, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Modificar Información',
                      style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(context).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.getTextSecondary(context), size: 20),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 13, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}