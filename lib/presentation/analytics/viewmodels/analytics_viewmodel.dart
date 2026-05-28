import 'package:flutter/material.dart';
import 'package:nica_balance/presentation/home/viewmodels/dashboard_viewmodel.dart';

enum FinancialHealthStatus { initial, excellent, stable, warning, critical }

class AnalyticsViewModel extends ChangeNotifier {
  final DashboardViewModel _dashboardVM;

  AnalyticsViewModel({required DashboardViewModel dashboardViewModel})
      : _dashboardVM = dashboardViewModel {
    _dashboardVM.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _dashboardVM.removeListener(notifyListeners);
    super.dispose();
  }

  // --- MÁSTRICA DE DATOS GENERALES (En USD) ---
  double get totalIncomes => _dashboardVM.totalIncomesUsd;
  double get totalExpenses => _dashboardVM.totalExpensesUsd;
  double get netSavings => _dashboardVM.netBalanceUsd;

  bool get hasNoData => totalIncomes == 0 && totalExpenses == 0;

  // Calcula qué porcentaje de los ingresos se está ahorrando
  double get savingsRate {
    if (totalIncomes <= 0) return 0.0;
    final rate = (netSavings / totalIncomes) * 100;
    return rate < 0 ? 0.0 : rate;
  }

  // --- DIAGNÓSTICO INTELIGENTE ---
  FinancialHealthStatus get financialHealth {
    if (hasNoData) return FinancialHealthStatus.initial;
    if (totalIncomes == 0 && totalExpenses > 0) return FinancialHealthStatus.critical;
    if (savingsRate >= 30) return FinancialHealthStatus.excellent;
    if (savingsRate >= 10) return FinancialHealthStatus.stable;
    if (savingsRate > 0 && savingsRate < 10) return FinancialHealthStatus.warning;
    return FinancialHealthStatus.critical;
  }

  // --- RECOMENDACIONES FINANCIERAS DINÁMICAS ---
  List<String> getActionPlan() {
    switch (financialHealth) {
      case FinancialHealthStatus.initial:
        return [
          '¡Bienvenido a tu panel de analíticas! Registra tu primer ingreso (como tu salario o proyectos) en la Consola para comenzar.',
          'Anota tus gastos diarios fijos y variables. Nuestro motor NoSQL calculará tu tasa de ahorro en tiempo real.',
          'Establece una Meta de Ahorro para que el algoritmo te guíe en la distribución óptima de tus finanzas.'
        ];
      case FinancialHealthStatus.excellent:
        return [
          'Tu tasa de ahorro supera el 30%. Es el momento ideal para mover capital hacia tus Metas de Ahorro activas.',
          'Considera diversificar: evalúa fondos de inversión o depósitos a plazo fijo para mitigar la inflación.',
          'Mantén optimizados tus gastos fijos para sostener este ritmo a largo plazo.'
        ];
      case FinancialHealthStatus.stable:
        return [
          'Tu situación es sólida, pero puedes optimizarla. Intenta recortar un 5% de gastos hormiga este mes.',
          'Asegúrate de estar fondeando activamente tu meta de "Fondo de Emergencia" hasta cubrir 3 meses de gastos fijos.',
          'Automatiza tus ahorros apenas percibas tus ingresos principales.'
        ];
      case FinancialHealthStatus.warning:
        return [
          'Alerta: Estás gastando más del 90% de lo que percibes. Tu margen de maniobra ante emergencias es bajo.',
          'Aplica la regla 50/30/20: Destina estrictamente el 50% a necesidades básicas y frena gastos de entretenimiento.',
          'Audita tus suscripciones activas y cancela los servicios que no hayas usado en los últimos 30 días.'
        ];
      case FinancialHealthStatus.critical:
        return [
          'Urgente: Tus gastos superan tus ingresos disponibles. Estás incurriendo en déficit o deudas.',
          'Congela de inmediato todo gasto variable o prescindible no esencial.',
          'Consolida tus deudas si presentan tasas altas y prioriza la creación de una base de ahorro mínima de contingencia.'
        ];
    }
  }
}