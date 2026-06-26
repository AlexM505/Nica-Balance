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

  @override
  Widget build(BuildContext context) {
    final calendarVM = context.watch<CalendarViewModel>();
    final expenseVM = context.watch<ExpenseViewModel>();
    final incomeVM = context.watch<IncomeViewModel>();
    final goalsVM = context.watch<GoalsViewModel>();

    final groupedTransactions = calendarVM.getGroupedTransactions(
      expenseVM: expenseVM,
      incomeVM: incomeVM,
      goalsVM: goalsVM,
    );

    final sortedDays = groupedTransactions.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Transacciones'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // ─── SELECTOR HORIZONTAL DE MESES CON AUTO-SCROLL ───
          _MonthSelector(
            selectedMonth: calendarVM.selectedMonth,
            onMonthChanged: (newMonth) => calendarVM.changeMonth(newMonth),
          ),

          // ─── LÍNEA DE TIEMPO / SECCIONES POR DÍA ───
          Expanded(
            child: groupedTransactions.isEmpty
                ? _buildEmptyState(context)
                : Stack(
                    children: [
                      Positioned(
                        left: 50,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          color: AppTheme.getBorderColor(context).withValues(alpha: 0.4),
                        ),
                      ),
                      ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 140),
                        itemCount: sortedDays.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final day = sortedDays[index];
                          final dayTransactions = groupedTransactions[day]!;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 54,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getSurfaceColor(context),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppTheme.getBorderColor(context)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        day.toString().padLeft(2, '0'),
                                        style: TextStyle(
                                          color: AppTheme.getTextPrimary(context),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _MonthSelector._monthsNames[calendarVM.selectedMonth.month - 1].toUpperCase(),
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    children: dayTransactions.map((tx) => _buildTransactionCard(context, tx)).toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, GlobalTransaction tx) {
    Color typeColor;
    String prefix;
    IconData fallbackIcon;
    final isNio = tx.dbCurrency == Currency.nio.name;

    switch (tx.type) {
      case TransactionType.income:
        typeColor = AppTheme.accentColor;
        prefix = '+';
        fallbackIcon = Icons.arrow_downward_rounded;
        break;
      case TransactionType.expense:
        typeColor = const Color(0xFFEF4444);
        prefix = '-';
        fallbackIcon = Icons.arrow_upward_rounded;
        break;
      case TransactionType.goal:
        typeColor = const Color(0xFF3B82F6);
        prefix = '';
        fallbackIcon = Icons.flag_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.getBorderColor(context).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(tx.colorHex).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              tx.category != null ? (tx.category.icon as IconData) : fallbackIcon, 
              color: Color(tx.colorHex), 
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.name,
                  style: TextStyle(
                    color: AppTheme.getTextPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  tx.type == TransactionType.goal ? 'Objetivo de Ahorro' : tx.category.displayName,
                  style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$prefix ${isNio ? 'C\$' : '\$'}${tx.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: typeColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 42),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.getBorderColor(context).withValues(alpha: 0.5)),
              ),
              child: Icon(
                Icons.calendar_today_rounded, 
                size: 44, 
                color: AppTheme.getTextPrimary(context).withValues(alpha: 0.25),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Mes sin movimientos',
              style: TextStyle(
                color: AppTheme.getTextPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No hay transacciones ni metas registradas en este periodo de tiempo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── COMPONENTE INTERNO CON CONTROL DE SCROLL AUTOMÁTICO ───
class _MonthSelector extends StatefulWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  static const List<String> _monthsNames = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];

  const _MonthSelector({
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  State<_MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<_MonthSelector> {
  late final ScrollController _scrollController;
  
  // Ancho estimado de cada pestaña + padding para calcular la distancia exacta del scroll
  final double _itemWidth = 94.0; 

  @override
  void initState() {
    super.initState();
    
    // Calculamos el índice base (0 para Ene, 5 para Jun, etc.)
    final initialIndex = widget.selectedMonth.month - 1;
    
    // Inicializamos el controlador posicionando el scroll directamente en el mes actual
    _scrollController = ScrollController(
      initialScrollOffset: initialIndex > 1 ? (initialIndex - 1) * _itemWidth : 0.0,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: 12,
        itemBuilder: (context, index) {
          final monthDate = DateTime(currentYear, index + 1);
          final isSelected = widget.selectedMonth.month == monthDate.month &&
                             widget.selectedMonth.year == monthDate.year;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                widget.onMonthChanged(monthDate);
                // Si el usuario toca un mes lejano, el scroll se acomoda suavemente
                if (index > 1) {
                  _scrollController.animateTo(
                    (index - 1) * _itemWidth,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _scrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 84, // Ancho fijo del botón interno
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [AppTheme.primaryColor, Colors.indigoAccent.shade700],
                        )
                      : null,
                  color: isSelected ? null : AppTheme.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? Colors.transparent 
                        : AppTheme.getBorderColor(context).withValues(alpha: 0.7),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${_MonthSelector._monthsNames[index]} ${currentYear.toString().substring(2)}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.getTextSecondary(context),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}