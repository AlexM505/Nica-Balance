import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/data/models/expense_enums.dart'; // Tu enum de categorías
import 'package:nica_balance/presentation/budgets/widgets/budget_tracker_card.dart';
import 'package:provider/provider.dart';
import '../../../data/models/budget.dart';
import '../../expenses/viewmodels/expense_viewmodel.dart';
import '../viewmodels/budget_viewmodel.dart';

class BudgetOverviewScreen extends StatelessWidget {
  const BudgetOverviewScreen({super.key});

  void _showAddBudgetBottomSheet(BuildContext context) {
    final budgetVM = context.read<BudgetViewModel>();
    final expenseVM = context.read<ExpenseViewModel>();
    
    final amountController = TextEditingController();
    // Tomamos la primera categoría disponible por defecto para el formulario
    ExpenseCategory selectedCategory = ExpenseCategory.values.first; 

    double autoSuggestion = budgetVM.getSuggestedBudget(selectedCategory.displayName, expenseVM.expenses);
    amountController.text = autoSuggestion > 100 ? autoSuggestion.toStringAsFixed(0) : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getSurfaceColor(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 12,
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: AppTheme.getBorderColor(context), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  Text('Planificar Presupuesto', style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Establece un límite mensual para guiar tus gastos.', style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 13)),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.getBackgroundColor(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.getBorderColor(context)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ExpenseCategory>(
                        value: selectedCategory,
                        dropdownColor: AppTheme.getSurfaceColor(context),
                        isExpanded: true,
                        items: ExpenseCategory.values.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                Icon(cat.icon, color: AppTheme.primaryColor, size: 20),
                                const SizedBox(width: 12),
                                Text(cat.displayName, style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 14)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (ExpenseCategory? value) {
                          if (value != null) {
                            setModalState(() {
                              selectedCategory = value;
                              // Recalcular sugerencia de forma reactiva al cambiar de categoría
                              autoSuggestion = budgetVM.getSuggestedBudget(selectedCategory.displayName, expenseVM.expenses);
                              amountController.text = autoSuggestion > 100 ? autoSuggestion.toStringAsFixed(0) : '';
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryColor, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sugerencia Inteligente: \$${autoSuggestion.toStringAsFixed(2)} basada en tu comportamiento del mes anterior.',
                            style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w500, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input de Monto Límite
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Monto Límite (\$)',
                      hintStyle: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 14),
                      prefixIcon: Icon(Icons.monetization_on_outlined, color: AppTheme.getTextSecondary(context), size: 20),
                      filled: true,
                      fillColor: AppTheme.getBackgroundColor(context),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppTheme.getBorderColor(context))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(bottomSheetContext),
                          child: Text('Cancelar', style: TextStyle(color: AppTheme.getTextSecondary(context), fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            final limit = double.tryParse(amountController.text) ?? 0.0;
                            if (limit > 0) {
                              final newBudget = Budget(
                                limitAmount: limit,
                                dbCategory: selectedCategory.displayName,
                                targetMonth: DateTime(DateTime.now().year, DateTime.now().month, 1),
                              );
                              budgetVM.saveBudget(newBudget);
                              Navigator.pop(bottomSheetContext);
                            }
                          },
                          child: const Text('Fijar Meta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetVM = context.watch<BudgetViewModel>();
    final expenseVM = context.watch<ExpenseViewModel>();

    final budgets = budgetVM.currentMonthBudgets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Límites y Presupuestos'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: budgets.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart_outline_rounded, size: 64, color: AppTheme.getTextPrimary(context).withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes presupuestos activos para este mes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Crea límites para que la app te guíe y evite que gastes de más.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.getTextSecondary(context).withValues(alpha: 0.7), fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                
                // Realizamos el cruce de datos en tiempo real con los gastos de ObjectBox
                final spent = budgetVM.getSpentForCategory(budget.dbCategory, expenseVM.expenses);
                final dailyRec = budgetVM.getRecommendedDailySpend(budget, spent);

                // Verificación de alertas en background (Dispara push instantáneo si aplica)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  budgetVM.verifyBudgetAlerts(budget, spent);
                });

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: BudgetTrackerCard(
                    budget: budget,
                    spentAmount: spent,
                    dailyRecommended: dailyRec,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _showAddBudgetBottomSheet(context),
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('Planificar Límite', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}