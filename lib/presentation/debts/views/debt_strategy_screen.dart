import 'package:flutter/material.dart';
import 'package:nica_balance/core/services/debt_strategy_engine.dart';
import 'package:provider/provider.dart';
import '../viewmodels/debt_strategy_viewmodel.dart';
import '../viewmodels/debt_viewmodel.dart'; // Tu ViewModel general de deudas

class DebtStrategyScreen extends StatefulWidget {
  const DebtStrategyScreen({super.key});

  @override
  State<DebtStrategyScreen> createState() => _DebtStrategyScreenState();
}

class _DebtStrategyScreenState extends State<DebtStrategyScreen> {
  @override
  void initState() {
    super.initState();
    // Alimentamos el motor de estrategias con las deudas actuales del repositorio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final debts = context.read<DebtViewModel>().debts;
      context.read<DebtStrategyViewModel>().setDebts(debts);
    });
  }

  // ─── WIDGET TEMPORAL DE CARGA ───
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            'Analizando tus deudas...',
            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strategyVM = context.watch<DebtStrategyViewModel>();
    final projections = strategyVM.strategyProjections;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estrategias de Desendeudamiento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: strategyVM.isLoading
          ? _buildLoadingState() // 1. Si está calculando, muestra spinner
          : projections.isEmpty
            ? _buildEmptyState(context)
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ─── CARD EXPLICATIVO DE MÉTODOS ───
                  _buildStrategySelector(context, strategyVM),
                  const SizedBox(height: 24),

                  // ─── SLIDER DE DINERO EXTRA (EFECTO ACELERADOR) ───
                  _buildSnowballSlider(context, strategyVM),
                  const SizedBox(height: 28),

                  // ─── LISTADO DE ORDEN DE PAGO INTELIGENTE ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Orden de Pago Sugerido',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          strategyVM.selectedStrategy == DebtStrategy.snowball ? 'Psicológico' : 'Económico',
                          style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: projections.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = projections[index];
                      return _buildDebtStrategyCard(context, item, index + 1);
                    },
                  ),
                ],
              ),
    );
  }

  // ─── SELECTOR SEGMENTADO DE ESTRATEGIA ───
  Widget _buildStrategySelector(BuildContext context, DebtStrategyViewModel vm) {
    final isSnowball = vm.selectedStrategy == DebtStrategy.snowball;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Bola de Nieve')),
                  selected: isSnowball,
                  onSelected: (_) => vm.changeStrategy(DebtStrategy.snowball),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Avalancha')),
                  selected: !isSnowball,
                  onSelected: (_) => vm.changeStrategy(DebtStrategy.avalanche),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isSnowball
                ? 'Paga primero tus deudas más pequeñas. Esto genera victorias psicológicas rápidas que aumentan tu motivación.'
                : 'Paga primero las deudas con la tasa de interés más alta. Matemáticamente es el método que más dinero te ahorra.',
            style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── INTERFAZ DEL ACELERADOR DE DINERO ───
  Widget _buildSnowballSlider(BuildContext context, DebtStrategyViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inyección Mensual Extra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 2),
                  Text('Acelera el fin de tus deudas', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              Text(
                '\$${vm.extraBudget.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: vm.extraBudget,
            min: 0,
            max: 500,
            divisions: 50,
            activeColor: Colors.blue,
            inactiveColor: Colors.blue.withValues(alpha: 0.2),
            onChanged: (val) => vm.updateExtraBudget(val),
          ),
        ],
      ),
    );
  }

  // ─── CARDS DE PRIORIZACIÓN DE DEUDAS ───
  Widget _buildDebtStrategyCard(BuildContext context, StrategyReportItem item, int priorityIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Círculo indicador de posición / orden de pago
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: priorityIndex == 1 ? Colors.green : Colors.grey.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$priorityIndex',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: priorityIndex == 1 ? Colors.white : Colors.black87,
                    fontSize: 13
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Información financiera de la deuda
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.debt.creditor,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Saldo: \$${item.debt.remainingAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 12),
                      Text('Interés: ${item.debt.interestRate}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            // Proyección calculada por el motor
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.estimatedMonthsToPay == -1 ? 'Inalcanzable' : '${item.estimatedMonthsToPay} meses',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 13,
                    color: item.estimatedMonthsToPay == -1 ? Colors.red : Colors.black87
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '+ \$${item.totalInterestToPay.toStringAsFixed(0)} int.',
                  style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_rounded, size: 54, color: Colors.green),
            SizedBox(height: 16),
            Text('¡Felicidades, no tienes deudas activas!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            SizedBox(height: 4),
            Text('Tu saldo y tus finanzas se encuentran limpias.', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}