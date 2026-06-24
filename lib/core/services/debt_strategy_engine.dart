import '../../data/models/debt.dart';

enum DebtStrategy { snowball, avalanche }

class StrategyReportItem {
  final Debt debt;
  final int estimatedMonthsToPay;
  final double totalInterestToPay;

  StrategyReportItem({
    required this.debt,
    required this.estimatedMonthsToPay,
    required this.totalInterestToPay,
  });
}

class DebtStrategyEngine {
  /// Ordena las deudas según la estrategia seleccionada
  static List<Debt> sortDebts({
    required List<Debt> debts,
    required DebtStrategy strategy,
  }) {
    final List<Debt> sortedList = List.from(debts);

    if (strategy == DebtStrategy.snowball) {
      // Bola de Nieve: De menor saldo restante a mayor saldo restante
      sortedList.sort((a, b) => a.remainingAmount.compareTo(b.remainingAmount));
    } else {
      // Avalancha: De mayor tasa de interés a menor tasa de interés
      sortedList.sort((a, b) => b.interestRate.compareTo(a.interestRate));
    }

    return sortedList;
  }

  /// Procesa una simulación de pagos mensuales proyectando meses e intereses
  static List<StrategyReportItem> calculateProjections({
    required List<Debt> debts,
    required DebtStrategy strategy,
    required double extraSnowballAmount,
  }) {
    // 1. Ordenamos las deudas según la prioridad de la estrategia
    final List<Debt> orderedDebts = sortDebts(debts: debts, strategy: strategy);
    final List<StrategyReportItem> report = [];

    double availableExtraMoney = extraSnowballAmount;

    for (int i = 0; i < orderedDebts.length; i++) {
      final currentDebt = orderedDebts[i];
      
      // Cálculo simplificado de amortización local
      double balance = currentDebt.remainingAmount;
      double monthlyInterestRate = (currentDebt.interestRate / 100) / 12;
      
      // Al primer elemento de la lista (el prioritario) le sumamos el dinero extra
      double allocationForThisDebt = currentDebt.minimumPayment + (i == 0 ? availableExtraMoney : 0);
      
      int months = 0;
      double totalInterestPaid = 0;

      while (balance > 0) {
        months++;
        double interestThisMonth = balance * monthlyInterestRate;
        totalInterestPaid += interestThisMonth;
        
        double principalPaid = allocationForThisDebt - interestThisMonth;
        if (principalPaid <= 0) {
          // Evita bucle infinito si el pago no cubre ni el interés
          months = 999; 
          break;
        }
        
        balance -= principalPaid;
        if (months > 120) break; // Límite de 10 años para la simulación
      }

      // Una vez que esta deuda se "paga" idealmente, su pago mínimo se libera
      // y se acumula ("efecto bola de nieve") para la siguiente deuda del ciclo
      availableExtraMoney += currentDebt.minimumPayment;

      report.add(StrategyReportItem(
        debt: currentDebt,
        estimatedMonthsToPay: months == 999 ? -1 : months,
        totalInterestToPay: totalInterestPaid,
      ));
    }

    return report;
  }
}