import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/data/models/expense_enums.dart';
import 'package:provider/provider.dart';
import '../../../data/models/debt.dart';
import '../viewmodels/debt_viewmodel.dart';

class DebtDetailScreen extends StatefulWidget {
  final Debt debt;

  const DebtDetailScreen({super.key, required this.debt});

  @override
  State<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends State<DebtDetailScreen> {
  
  final _payController = TextEditingController();
  final _bottomSheetFormKey = GlobalKey<FormState>();

  void _showPaymentBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Permite que el teclado no tape el contenido
    backgroundColor: AppTheme.getSurfaceColor(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomSheetContext) {
      return Padding(
        // Ajusta el padding inferior dinámicamente cuando emerge el teclado virtual
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _bottomSheetFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tirador visual indicador de arrastre (Pill Superior)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.getBorderColor(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              Text(
                'Registrar Abono',
                style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Ingresa el monto para amortizar tu saldo pendiente.',
                style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Entrada de texto acoplada al estilo de tus inputs del formulario
              TextFormField(
                controller: _payController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 14),
                autofocus: true, // Abre el teclado automáticamente para agilizar la acción
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 14),
                  prefixIcon: Icon(Icons.monetization_on_outlined, color: AppTheme.getTextSecondary(context), size: 20),
                  filled: true,
                  fillColor: AppTheme.getBackgroundColor(context),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.getBorderColor(context), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16), 
                    borderSide: const BorderSide(color: Color(0xFFEF4444))
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16), 
                    borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa un monto';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Ingresa un número válido mayor a 0';
                  }
                  // Validación Clave: No permitir abonar más de lo que se debe
                  if (amount > widget.debt.remainingAmount) {
                    return 'El abono excede el saldo pendiente (\$${widget.debt.remainingAmount.toStringAsFixed(2)})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Fila de acciones (Cancelar y Confirmar)
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        _payController.clear();
                        Navigator.pop(bottomSheetContext);
                      },
                      child: Text('Cancelar', style: TextStyle(color: AppTheme.getTextSecondary(context), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // final amount = double.tryParse(_payController.text) ?? 0.0;
                        // if (amount > 0) {
                        //   // Inyectamos el abono reactivo en ObjectBox
                        //   context.read<DebtViewModel>().payAmount(widget.debt.id, amount);
                        //   _payController.clear();
                        //   Navigator.pop(bottomSheetContext); // Cierra BottomSheet
                        //   Navigator.pop(context); // Regresa al listado para refrescar el árbol
                        // }
                        // Validamos el estado del formulario antes de procesar el pago
                          if (_bottomSheetFormKey.currentState!.validate()) {
                            final amount = double.parse(_payController.text);
                            
                            // Ejecutar la amortización en la base de datos
                            context.read<DebtViewModel>().payAmount(widget.debt.id, amount);
                            _payController.clear();
                            
                            Navigator.pop(bottomSheetContext); // Cierra el Bottom Sheet
                            Navigator.pop(context); // Regresa a la vista de listado anterior

                            // Disparar la confirmación visual premium
                            _showSuccessSnackBar(context, amount, widget.debt.title);
                          }
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.tealAccent.shade700, const Color(0xFF059669)]
                          ),
                          // color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Aplicar Pago',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('¿Eliminar Registro?', style: TextStyle(color: AppTheme.getTextPrimary(context))),
        content: const Text('¿Estás seguro de que deseas borrar este pasivo? Esto la removerá del historial global.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context.read<DebtViewModel>().deleteDebt(widget.debt.id);
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, double amount, String debtTitle) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppTheme.getSurfaceColor(context),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      duration: const Duration(seconds: 4),
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppTheme.accentColor, // Tu color verde del tema
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Abono registrado con éxito!',
                  style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Se aplicaron \$${amount.toStringAsFixed(2)} a la deuda "$debtTitle".',
                  style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final debtVM = context.watch<DebtViewModel>();
    final type = widget.debt.type;
    final color = Color(type.colorHex);
    final daysLeft = widget.debt.dueDate.difference(DateTime.now()).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control del Pasivo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
            onPressed: () => _confirmDelete(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta Principal de Información Retenida
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(type.icon, color: Colors.white, size: 36),
                  const SizedBox(height: 12),
                  Text(widget.debt.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Acreedor: ${widget.debt.creditor}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                  const SizedBox(height: 24),
                  const Text('SALDO PENDIENTE', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text( '${widget.debt.currency == Currency.usd ? '\$' : 'C\$'}${widget.debt.remainingAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700)
                  ),
                  if (widget.debt.currency == Currency.nio)
                    Text(
                      '≈ \$ ${debtVM.convertToUsd(widget.debt.remainingAmount, widget.debt.currency).toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Metadatos de Amortización
            _buildDetailRow('Monto Inicial Registrado', '${widget.debt.currency == Currency.usd ? '\$' : 'C\$'}${widget.debt.totalAmount.toStringAsFixed(2)}'),
            _buildDetailRow('Total Abonado a la Fecha', '${widget.debt.currency == Currency.usd ? '\$' : 'C\$'}${widget.debt.totalPaid.toStringAsFixed(2)}'),
            _buildDetailRow('Tasa de Interés Ajustada', '${widget.debt.interestRate}% Anual'),
            _buildDetailRow('Próximo Vencimiento', '${widget.debt.dueDate.day}/${widget.debt.dueDate.month}/${widget.debt.dueDate.year} (${daysLeft < 0 ? 'Vencida' : 'en $daysLeft días'})'),
            
            const SizedBox(height: 40),

            // Botón para desplegar el Abono
            if (!widget.debt.isPaidOff)
              GestureDetector(
                onTap: () => _showPaymentBottomSheet(context),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, Colors.indigoAccent.shade700]
                    ),
                    // color: AppTheme.primaryColor, 
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: const Center(
                    child: Text('Registrar Abono / Pago', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(context).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 13)),
          Text(value, style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}