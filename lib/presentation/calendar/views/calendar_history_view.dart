import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/data/models/expense_enums.dart';
import 'package:provider/provider.dart';
import '../../../data/models/global_transaction.dart';
import '../../expenses/viewmodels/expense_viewmodel.dart';
import '../../income/viewmodels/income_viewmodel.dart';
import '../../goals/viewmodels/goals_viewmodel.dart';
import '../viewmodels/calendar_viewmodel.dart';

class CalendarHistoryView extends StatelessWidget {
  const CalendarHistoryView({super.key});

  // Lista de meses estática para renderizar el selector horizontal
  static const List<String> _monthsNames = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];

  @override
  Widget build(BuildContext context) {
    final calendarVM = context.watch<CalendarViewModel>();
    
    // Inyectamos los ViewModels que tienen los datos de ObjectBox
    final expenseVM = context.watch<ExpenseViewModel>();
    final incomeVM = context.watch<IncomeViewModel>();
    final goalsVM = context.watch<GoalsViewModel>();

    // Obtenemos los datos combinados y agrupados por día
    final groupedTransactions = calendarVM.getGroupedTransactions(
      expenseVM: expenseVM,
      incomeVM: incomeVM,
      goalsVM: goalsVM,
    );

    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario'),
      ),
      body: Column(
        children: [
          // ─── SELECTOR HORIZONTAL DE MESES ───
          Container(
            height: 64,
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthDate = DateTime(currentYear, index + 1);
                final isSelected = calendarVM.selectedMonth.month == monthDate.month &&
                                   calendarVM.selectedMonth.year == monthDate.year;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(
                      '${_monthsNames[index]} ${currentYear.toString().substring(2)}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.getTextSecondary(context),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryColor,
                    backgroundColor: AppTheme.getSurfaceColor(context),
                    checkmarkColor: Colors.white ,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: isSelected ? AppTheme.primaryColor : AppTheme.getBorderColor(context)),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        calendarVM.changeMonth(monthDate);
                      }
                    },
                  ),
                );
              },
            ),
          ),

          // ─── LISTADO SECCIONADO DE TRANSACCIONES POR DÍA ───
          Expanded(
            child: groupedTransactions.isEmpty
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month_rounded, size: 64, color: AppTheme.getTextPrimary(context).withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'No hay actividades registradas en este mes.',
                          style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ) : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 140),
                    itemCount: groupedTransactions.keys.length,
                    itemBuilder: (context, index) {
                      // Obtenemos los números de día ordenados descendentemente
                      final days = groupedTransactions.keys.toList();
                      final day = days[index];
                      final dayTransactions = groupedTransactions[day]!;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // COLUMNA IZQUIERDA: Indicador del día fijo
                            Container(
                              width: 52,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.getSurfaceColor(context),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.getBorderColor(context)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    day.toString().padLeft(2, '0'),
                                    style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 18, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    _monthsNames[calendarVM.selectedMonth.month - 1].toUpperCase(),
                                    style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 10, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // COLUMNA DERECHA: Lista interna de flujos ocurridos en ese día
                            Expanded(
                              child: Column(
                                children: dayTransactions.map((tx) {
                                  // Asignación de colores y signos según tipo de flujo
                                  Color typeColor;
                                  String prefix;
                                  IconData fallbackIcon;
                                  final isNio = tx.dbCurrency == Currency.nio.name;

                                  switch (tx.type) {
                                    case TransactionType.income:
                                      typeColor = AppTheme.accentColor; // Verde/Esmeralda de ingresos
                                      prefix = '+';
                                      fallbackIcon = Icons.arrow_downward_rounded;
                                      break;
                                    case TransactionType.expense:
                                      typeColor = const Color(0xFFEF4444); // Rojo para gastos
                                      prefix = '-';
                                      fallbackIcon = Icons.arrow_upward_rounded;
                                      break;
                                    case TransactionType.goal:
                                      typeColor = const Color(0xFF3B82F6); // Azul para inicio de metas
                                      prefix = '';
                                      fallbackIcon = Icons.flag_rounded;
                                      break;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppTheme.getSurfaceColor(context).withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppTheme.getBorderColor(context).withValues(alpha: 0.6)),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Color(tx.colorHex).withValues(alpha: 0.12),
                                          radius: 16,
                                          child: Icon(
                                            tx.category != null ? (tx.category.icon as IconData) : fallbackIcon, 
                                            color: Color(tx.colorHex), 
                                            size: 16
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tx.name,
                                                style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 13, fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                tx.type == TransactionType.goal 
                                                    ? 'Objetivo de Ahorro' 
                                                    : tx.category.displayName,
                                                style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '$prefix ${isNio ? 'C\$' : '\$'} ${tx.amount.toStringAsFixed(2)}',
                                          style: TextStyle(color: typeColor, fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
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