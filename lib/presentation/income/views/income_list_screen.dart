import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/presentation/income/views/income_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../../data/models/expense_enums.dart'; 
import '../viewmodels/income_viewmodel.dart';

class IncomeListScreen extends StatelessWidget {
  const IncomeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incomeViewModel = context.watch<IncomeViewModel>();
    final incomes = incomeViewModel.incomes;

    // Calcular el total histórico directo de la fuente para el encabezado de esta vista
    // final double totalIncomes = incomes.fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ingresos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: incomes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                          radius: 45,
                          backgroundColor: AppTheme.getTextSecondary(context).withValues(alpha: 0.12),
                          child: Icon(Icons.payments_rounded, size: 64, color: AppTheme.getTextSecondary(context).withValues(alpha: 0.4)),
                        ),
                    const SizedBox(height: 16),
                    Text(
                      'Aún no has registrado ningún ingreso',
                      style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Resumen rápido superior estilizado
                Container(
                  margin: const EdgeInsets.all(18),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.getBorderColor(context)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Acumulado',
                        style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '\$ ${incomeViewModel.totalIncomesUsd.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppTheme.accentColor, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Listado Deslizable
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: incomes.length,
                    itemBuilder: (context, index) {
                      final income = incomes[index];
                      final cat = income.category;

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
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.getSurfaceColor(context).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.getBorderColor(context).withValues(alpha: 0.7)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: Color(income.colorHex).withValues(alpha: 0.15),
                              radius: 20,
                              child: Icon(cat.icon, color: Color(income.colorHex), size: 20),
                            ),
                            title: Text(
                              income.name,
                              style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              cat.displayName,
                              style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12),
                            ),
                            trailing: 
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${income.currency == Currency.usd ? '\$' : 'C\$'}${income.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accentColor,
                                      fontSize: 15
                                    ),
                                  ),
                                  if (income.currency == Currency.nio)
                                    Text(
                                      '≈ \$ ${incomeViewModel.convertToUsd(income.amount, income.currency).toStringAsFixed(2)}',
                                      style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                ],
                              ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}