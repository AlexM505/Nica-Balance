import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/presentation/debts/views/debt_detail_screen.dart';
import 'package:provider/provider.dart';
import '../viewmodels/debt_viewmodel.dart';
import 'debt_form_screen.dart';
class DebtsListScreen extends StatelessWidget {
  const DebtsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final debtVM = context.watch<DebtViewModel>();
    final debts = debtVM.debts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pasivos y Deudas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DebtFormScreen()),
            ),
          )
        ],
      ),
      body: debts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gavel_rounded, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('¡Felicidades, estás libre de deudas!', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: debts.length,
              itemBuilder: (context, index) {
                final debt = debts[index];
                final type = debt.type;
                final color = Color(type.colorHex);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DebtDetailScreen(debt: debt)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabecera de la Tarjeta
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: color.withOpacity(0.1),
                                radius: 18,
                                child: Icon(type.icon, color: color, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      debt.title,
                                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Acreedor: ${debt.creditor}',
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              if (debt.isPaidOff)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: AppTheme.accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                                  child: const Text('PAGADO', style: TextStyle(color: AppTheme.accentColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Valores de Saldo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Saldo Restante', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                  Text('\$ ${debt.remainingAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Tasa / Interés', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                  Text('${debt.interestRate}% Anual', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Barra de Progreso de Amortización
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: debt.paidPercentage,
                              backgroundColor: AppTheme.borderColor,
                              valueColor: AlwaysStoppedAnimation<Color>(debt.isPaidOff ? AppTheme.accentColor : AppTheme.primaryColor),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}