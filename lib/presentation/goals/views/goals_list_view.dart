import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/data/models/expense_enums.dart';
import 'package:nica_balance/data/models/goal.dart';
import 'package:provider/provider.dart';
import '../viewmodels/goals_viewmodel.dart';
import 'goal_form_screen.dart';

class GoalsListView extends StatelessWidget {
  const GoalsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final goalsViewModel = context.watch<GoalsViewModel>();
    final goals = goalsViewModel.goals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Objetivos de Vida'),
      ),
      // FLOATING ACTION BUTTON PARA LANZAR EL FORMULARIO
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90), // Para que flote por encima del dock principal
        child: FloatingActionButton(
          backgroundColor: AppTheme.primaryColor,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GoalFormScreen()),
            );
          },
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
      body: goals.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                          radius: 45,
                          backgroundColor: AppTheme.getTextSecondary(context).withValues(alpha: 0.12),
                          child: Icon(Icons.emoji_events_rounded, size: 64, color: AppTheme.getTextSecondary(context).withValues(alpha: 0.4)),
                        ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay metas activas',
                      style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Define tu próximo gran paso, ya sea un viaje, un auto o un fondo de emergencia. ¡Empieza hoy!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 160),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final cat = goal.category;
                final progress = goal.progressPercentage;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.getBorderColor(context)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    // Disparamos la hoja de registro inferior al dar tap
                    onTap: goal.isCompleted 
                        ? () => _showCelebrationDialog(context, goal)
                        : () => _showDepositBottomSheet(context, goal),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(cat.colorHex).withValues(alpha: 0.12),
                                radius: 18,
                                child: Icon(cat.icon, color: Color(cat.colorHex), size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  goal.name,
                                  style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 15, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (goal.isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.2), 
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: const Text('¡Cumplida!', style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${goal.currency == Currency.usd ? '\$' : 'C\$'} ${goal.currentAmount.toStringAsFixed(2)} recolectados',
                                style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 13),
                              ),
                              Text(
                                'Objetivo: ${goal.currency == Currency.usd ? '\$' : 'C\$'}${goal.targetAmount.toStringAsFixed(2)}',
                                style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: AppTheme.getBorderColor(context),
                              color: Color(cat.colorHex),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}% completado',
                                style: TextStyle(color: Color(cat.colorHex), fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Límite: ${goal.deadline.day}/${goal.deadline.month}/${goal.deadline.year}',
                                style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )

    );
  }

  void _showDepositBottomSheet(BuildContext context, Goal goal) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final remaining = goal.targetAmount - goal.currentAmount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getSurfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(color: AppTheme.getBorderColor(context), borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Abonar a: ${goal.name}',
                  style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Monto pendiente necesario: ${goal.currency == Currency.usd ? '\$' : 'C\$'} ${remaining.toStringAsFixed(2)}',
                  style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: amountController,
                  style: TextStyle(color: AppTheme.getTextPrimary(context), fontWeight: FontWeight.bold),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Monto a agregar (${goal.currency == Currency.usd ? '\$' : 'C\$'} )',
                    labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
                    prefixIcon: Icon(Icons.add_card_rounded, color: AppTheme.getTextSecondary(context)),
                    filled: true,
                    fillColor: AppTheme.getSurfaceColor(context).withValues(alpha: 0.5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Por favor ingresa un monto';
                    final parsedAmount = double.tryParse(v);
                    if (parsedAmount == null || parsedAmount <= 0) return 'Monto inválido';
                    
                    // Validación Clave: No dejar sobrepasar la meta establecida
                    if (parsedAmount > remaining) {
                      return 'El monto supera los \$ ${remaining.toStringAsFixed(2)} restantes';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    if (!formKey.currentState!.validate()) return;
                    
                    final depositValue = double.parse(amountController.text);
                    final viewModel = context.read<GoalsViewModel>();
                    
                    // Cerramos el BottomSheet primero
                    Navigator.pop(context);
                    
                    // Ejecutamos la adición de fondos (sincronizada con ObjectBox)
                    viewModel.addFundsToGoal(goal.id, depositValue);

                    // Verificamos si con este abono la meta se da por completada
                    final updatedGoal = viewModel.goals.firstWhere((g) => g.id == goal.id);
                    if (updatedGoal.isCompleted) {
                      // Esperamos un instante a que el árbol termine de actualizarse para pintar la alerta premium
                      Future.delayed(const Duration(milliseconds: 300), () {
                        // _showCelebrationDialog(context, updatedGoal);
                        if (context.mounted) {
                          _showCelebrationDialog(context, updatedGoal);
                        }
                      });
                    }
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        'Confirmar Depósito',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCelebrationDialog(BuildContext context, Goal goal) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Iconografía festiva e inspiradora
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFF34D399),
                    size: 56,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '¡Objetivo Logrado!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                ),
                const SizedBox(height: 10),
                Text(
                  'Felicidades, has reunido los \$ ${goal.targetAmount.toStringAsFixed(2)} requeridos para completar tu meta: "${goal.name}". Tu disciplina financiera está dando frutos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Excelente',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}