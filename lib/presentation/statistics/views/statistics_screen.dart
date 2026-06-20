import 'package:flutter/material.dart';
import 'package:nica_balance/data/models/expense_enums.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../debts/viewmodels/debt_viewmodel.dart';
import '../viewmodels/statistics_viewmodel.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() { _touchedIndex = -1; });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statisticsVM = context.watch<StatisticsViewModel>();
    final debtVM = context.watch<DebtViewModel>();

    final expenseData = statisticsVM.getExpenseCategoryData();
    final incomeData = statisticsVM.getIncomeCategoryData();
    final debtData = statisticsVM.getDebtData(debtVM.debts); 

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        title: const Text(
          'Estadísticas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.getBorderColor(context).withValues(alpha: 0.5)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab, 
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              labelColor: Colors.white,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.2),
              unselectedLabelColor: AppTheme.getTextSecondary(context),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              overlayColor: WidgetStateProperty.all(Colors.transparent), 
              tabs: const [
                Tab(height: 38, text: 'Gastos'),
                Tab(height: 38, text: 'Ingresos'),
                Tab(height: 38, text: 'Deudas'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsTab(context, expenseData, 'Gastos Totales'),
          _buildStatisticsTab(context, incomeData, 'Ingresos Totales'),
          _buildStatisticsTab(context, debtData, 'Deudas Totales'),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(BuildContext context, List<CategoryStatsData> data, String title) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.getTextSecondary(context).withValues(alpha: 0.12),
              child: Icon(Icons.pie_chart_outline_rounded, size: 50, color: AppTheme.getTextSecondary(context).withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            Text('No hay datos registrados en esta sección.', style: TextStyle(color: AppTheme.getTextSecondary(context))),
          ],
        ),
      );
    }

    final double totalAmount = data.fold(0, (sum, item) => sum + item.amount);
    final statisticsVM = context.read<StatisticsViewModel>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          height: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 4,
              centerSpaceRadius: 45,
              sections: _generateChartSections(data, totalAmount),
            ),
          ),
        ),
        const SizedBox(height: 28),

        Text(
          'Desglose por Categorías',
          style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = data[index];
            final percentage = (item.amount / totalAmount) * 100;

            // Filtramos la lista real de transacciones que pertenecen a ESTA categoría específica
            // desde las listas globales del DashboardViewModel
            final List transactionsOfCategory = _tabController.index == 0
                ? statisticsVM.dashboardViewModel.expensesList.where((e) => e.category.displayName.toLowerCase() == item.categoryName.toLowerCase()).toList()
                : _tabController.index == 1
                    ? statisticsVM.dashboardViewModel.incomesList.where((i) => i.category.displayName.toLowerCase() == item.categoryName.toLowerCase()).toList()
                    : []; // Si son deudas, enlazar debtVM.debtsList de igual forma si aplica

            return Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: 
                ExpansionTile(
                  clipBehavior: Clip.antiAlias,
                  collapsedBackgroundColor: AppTheme.getSurfaceColor(context),
                  backgroundColor: AppTheme.getSurfaceColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: AppTheme.getBorderColor(context)),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: AppTheme.getBorderColor(context)),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.getTextSecondary(context)),
                  title: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.categoryName,
                          style: TextStyle(
                            color: AppTheme.getTextPrimary(context), 
                            fontWeight: FontWeight.bold, 
                            fontSize: 14
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 26, top: 2),
                    child: Text(
                      'Representa el ${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 11),
                    ),
                  ),
                  leading: null, 
                  expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                  childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  
                  children: [
                    const SizedBox(height: 2),
                    
                    if (transactionsOfCategory.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No hay transacciones individuales',
                          style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      )
                    else
                      // Mapeamos los elementos reales que engloban la categoría
                      ...transactionsOfCategory.map((tx) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.getSurfaceColor(context).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.getBorderColor(context).withValues(alpha: 0.9)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(tx.colorHex).withValues(alpha: 0.15),
                                radius: 18,
                                child: Icon(tx.category.icon, color: Color(tx.colorHex), size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tx.name,
                                  style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 14, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${tx.currency == Currency.usd ? '\$' : 'C\$'}${tx.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Color(0xFFF87171), fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
            );
        }),
      ],
    );
  }

  List<PieChartSectionData> _generateChartSections(List<CategoryStatsData> data, double total) {
    return List.generate(data.length, (i) {
      final item = data[i];
      final isTouched = i == _touchedIndex;
      final double radius = isTouched ? 80.0 : 70.0;
      final percentage = (item.amount / total) * 100;
      final String sectionTitle = isTouched 
        ? '${item.categoryName}\n${percentage.toStringAsFixed(1)}%' 
        : item.categoryName;

      return PieChartSectionData(
        color: item.color,
        value: item.amount,
        title: sectionTitle,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 13 : 11, 
          fontWeight: FontWeight.bold, 
          color: Colors.white,
          shadows: const [
            Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 1))
          ],
        ),
        badgeWidget: _buildBadgeIcon(item, isTouched),
        titlePositionPercentageOffset: 0.35,
        badgePositionPercentageOffset: 0.95,
      );
    });
  }

  Widget _buildBadgeIcon(CategoryStatsData item, bool isTouched) {
    final double size = isTouched ? 42.0 : 36.0;
    
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: item.color,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 4,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          item.icon,
          size: isTouched ? 22.0 : 18.0,
          color: item.color,
        ),
      ),
    );
  }
}