import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../viewmodels/analytics_viewmodel.dart';
import '../widgets/budget_distribution_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analyticsVM = context.watch<AnalyticsViewModel>();

    // Determinar parámetros estéticos según el diagnóstico de salud financiera
    Color healthColor;
    String healthTitle;
    IconData healthIcon;
    String subtitleText;

    // Evaluamos el estado incluyendo la nueva validación inicial limpia
    switch (analyticsVM.financialHealth) {
      case FinancialHealthStatus.initial:
        healthColor = AppTheme.primaryColor; // Color gris neutro elegante
        healthTitle = 'Sin Datos Suficientes';
        healthIcon = Icons.bar_chart_rounded;
        subtitleText = 'Comienza a registrar tus flujos para generar un diagnóstico.';
        break;
      case FinancialHealthStatus.excellent:
        healthColor = AppTheme.accentColor;
        healthTitle = 'Salud Financiera Excelente';
        healthIcon = Icons.gavel_rounded;
        subtitleText = 'Tu tasa de ahorro mensual actual es del ${analyticsVM.savingsRate.toStringAsFixed(1)}%.';
        break;
      case FinancialHealthStatus.stable:
        healthColor = const Color(0xFF3B82F6);
        healthTitle = 'Estado Estable / Controlado';
        healthIcon = Icons.verified_user_rounded;
        subtitleText = 'Tu tasa de ahorro mensual actual es del ${analyticsVM.savingsRate.toStringAsFixed(1)}%.';
        break;
      case FinancialHealthStatus.warning:
        healthColor = const Color(0xFFF59E0B);
        healthTitle = 'Alerta de Consumo';
        healthIcon = Icons.warning_amber_rounded;
        subtitleText = 'Tu tasa de ahorro mensual actual es del ${analyticsVM.savingsRate.toStringAsFixed(1)}%.';
        break;
      case FinancialHealthStatus.critical:
        healthColor = const Color(0xFFEF4444);
        healthTitle = 'Déficit Financiero Crítico';
        healthIcon = Icons.gpp_bad_rounded;
        subtitleText = 'Tus gastos superan tus ingresos percibidos en el sistema.';
        break;
    }

    // switch (analyticsVM.financialHealth) {
    //   case FinancialHealthStatus.excellent:
    //     healthColor = AppTheme.accentColor;
    //     healthTitle = 'Salud Financiera Excelente';
    //     healthIcon = Icons.gavel_rounded;
    //     break;
    //   case FinancialHealthStatus.stable:
    //     healthColor = const Color(0xFF3B82F6);
    //     healthTitle = 'Estado Estable / Controlado';
    //     healthIcon = Icons.verified_user_rounded;
    //     break;
    //   case FinancialHealthStatus.warning:
    //     healthColor = const Color(0xFFF59E0B);
    //     healthTitle = 'Alerta de Consumo';
    //     healthIcon = Icons.warning_amber_rounded;
    //     break;
    //   case FinancialHealthStatus.critical:
    //     healthColor = const Color(0xFFEF4444);
    //     healthTitle = 'Déficit Financiero Crítico';
    //     healthIcon = Icons.gpp_bad_rounded;
    //     break;
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico Financiero'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        children: [
          // ─── TARJETA DE STATUS DIAGNÓSTICO ───
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: healthColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: healthColor.withOpacity(0.4), width: 1.5),
            ),
            child: Row(
              children: [
                Icon(healthIcon, color: healthColor, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        healthTitle,
                        style: TextStyle(color: healthColor, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // 'Tu tasa de ahorro mensual actual es del ${analyticsVM.savingsRate.toStringAsFixed(1)}%.',
                        subtitleText,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── DIAGRAMA PROPORCIONAL DE FLUJOS ───
          // Si no hay datos, ocultamos el gráfico proporcional para evitar barras vacías confusas
          if (!analyticsVM.hasNoData) ...[
            BudgetDistributionChart(
              incomes: analyticsVM.totalIncomes,
              expenses: analyticsVM.totalExpenses,
            ),
            const SizedBox(height: 32),
          ],
          // BudgetDistributionChart(
          //   incomes: analyticsVM.totalIncomes,
          //   expenses: analyticsVM.totalExpenses,
          // ),
          // const SizedBox(height: 32),

          // ─── INDICACIONES Y PLANIFICACIÓN FUTURA ───
          Row(
            children: [
              // Icon(Icons.escalator_warning, size: 18, color: AppTheme.textSecondary), // Fallback seguro a iconos directos
              Icon(Icons.assignment_turned_in_rounded, size: 18, color: AppTheme.textSecondary),
              SizedBox(width: 8),
              Text(
                analyticsVM.hasNoData ? '¿Cómo empezar?' :'Plan de Acción Sugerido',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Renderizar dinámicamente las indicaciones del ViewModel
          ...analyticsVM.getActionPlan().map((indication) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: healthColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        indication,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.3, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}