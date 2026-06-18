import 'package:flutter/material.dart';
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.getTextPrimary(context),
          unselectedLabelColor: AppTheme.getTextSecondary(context),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Gastos'),
            Tab(text: 'Ingresos'),
            Tab(text: 'Deudas'),
          ],
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
            Icon(Icons.pie_chart_outline_rounded, size: 48, color: AppTheme.getTextSecondary(context).withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No hay datos registrados en esta sección.', style: TextStyle(color: AppTheme.getTextSecondary(context))),
          ],
        ),
      );
    }

    final double totalAmount = data.fold(0, (sum, item) => sum + item.amount);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Gráfico Circular de Dona
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

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: Row(
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
                      style: TextStyle(color: AppTheme.getTextPrimary(context), fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${item.amount.toStringAsFixed(2)}',
                        style: TextStyle(color: AppTheme.getTextPrimary(context), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 11),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
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
    final double size = isTouched ? 36.0 : 30.0;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          item.icon,
          size: isTouched ? 18.0 : 15.0,
          color: item.color,
        ),
      ),
    );
  }
}