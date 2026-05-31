import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../data/models/debt.dart';
import '../viewmodels/debt_viewmodel.dart';

class DebtFormScreen extends StatefulWidget {
  final Debt? debtToEdit;

  const DebtFormScreen({super.key, this.debtToEdit});

  @override
  State<DebtFormScreen> createState() => _DebtFormScreenState();
}

class _DebtFormScreenState extends State<DebtFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _creditorController = TextEditingController();
  final _amountController = TextEditingController();
  final _interestController = TextEditingController();
  
  DebtType _selectedType = DebtType.loan;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    if (widget.debtToEdit != null) {
      final debt = widget.debtToEdit!;
      _titleController.text = debt.title;
      _creditorController.text = debt.creditor;
      _amountController.text = debt.remainingAmount.toString();
      _interestController.text = debt.interestRate.toString();
      _selectedType = debt.type;
      _selectedDate = debt.dueDate;
    }
  }

  void _presentDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final double parsedAmount = double.parse(_amountController.text);
    
    final debtData = Debt(
      id: widget.debtToEdit?.id ?? 0,
      title: _titleController.text.trim(),
      creditor: _creditorController.text.trim(),
      totalAmount: widget.debtToEdit?.totalAmount ?? parsedAmount,
      remainingAmount: parsedAmount,
      interestRate: double.tryParse(_interestController.text) ?? 0.0,
      dueDateMilli: _selectedDate.millisecondsSinceEpoch,
      typeIndex: _selectedType.index,
    );

    final viewModel = context.read<DebtViewModel>();
    if (widget.debtToEdit != null) {
      viewModel.updateDebt(debtData);
    } else {
      viewModel.addDebt(debtData);
    }
    
    Navigator.pop(context);
  }

  // Estilo de decoración de inputs compartido con tus formularios previos
  InputDecoration _buildInputDecoration({required String hintText, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: AppTheme.textSecondary, size: 20),
      filled: true,
      fillColor: AppTheme.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none, // Oculta la línea nativa fea
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.debtToEdit != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Deuda' : 'Nueva Deuda'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          children: [
            // Campo: Concepto
            const Text('Concepto de la Deuda', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: _buildInputDecoration(hintText: 'Ej. Visa Clásica, Préstamo vehicular', prefixIcon: Icons.bookmark_outline_rounded),
              validator: (v) => v!.isEmpty ? 'Por favor escribe el concepto' : null,
            ),
            const SizedBox(height: 20),
            
            // Campo: Acreedor
            const Text('Acreedor / Prestamista', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _creditorController,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: _buildInputDecoration(hintText: '¿A quién le debes? Ej. Banco BAC, Juan', prefixIcon: Icons.business_rounded),
              validator: (v) => v!.isEmpty ? 'Por favor ingresa el acreedor' : null,
            ),
            const SizedBox(height: 20),

            // Campos en paralelo: Monto e Interés
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monto Actual (\$)', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                        decoration: _buildInputDecoration(hintText: '0.00', prefixIcon: Icons.monetization_on_outlined),
                        validator: (v) => double.tryParse(v ?? '') == null ? 'Monto inválido' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Interés Anual (%)', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _interestController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                        decoration: _buildInputDecoration(hintText: '0.0', prefixIcon: Icons.percent_rounded),
                        validator: (v) => double.tryParse(v ?? '') == null ? 'Porcentaje inválido' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Selector Horizontal Tipo de Deuda (ChoiceChips Premium)
            const Text('Clasificación del Pasivo', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: DebtType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        type.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryColor,
                      backgroundColor: AppTheme.surfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor),
                      ),
                      onSelected: (_) => setState(() => _selectedType = type),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Disparador de Fecha de Próximo Pago estilo ListTile Premium
            const Text('Próxima Fecha de Pago', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _presentDatePicker,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: AppTheme.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textSecondary, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Botón de Confirmación Principal
            GestureDetector(
              onTap: _submit,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    isEdit ? 'Guardar Cambios' : 'Registrar Pasivo',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}