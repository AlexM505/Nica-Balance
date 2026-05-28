import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../data/models/income.dart';
import '../../../data/models/income_enums.dart';
import '../../../data/models/expense_enums.dart';
import '../viewmodels/income_viewmodel.dart';

class IncomeFormScreen extends StatefulWidget {

  final Income? incomeToEdit; // Parámetro opcional para inyectar edición

  const IncomeFormScreen({super.key, this.incomeToEdit});

  @override
  State<IncomeFormScreen> createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends State<IncomeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  final List<IconData> _availableIcons = [
    Icons.account_balance_wallet_rounded,
    Icons.trending_up_rounded,
    Icons.storefront_rounded,
    Icons.card_giftcard_rounded,
    Icons.add_card_rounded,
    Icons.work_rounded,
    Icons.payments_rounded,
    Icons.savings_rounded,
    Icons.person_4_rounded,
    Icons.volunteer_activism_rounded,
  ];

  final List<int> _availableColors = [
    0xFF10B981, // Esmeralda Premium
    0xFF3B82F6, // Azul Eléctrico
    0xFF06B6D4, // Cyan
    0xFF8B5CF6, // Violeta Real
    0xFFEC4899, // Rosa Intenso
    0xFFF59E0B, // Ámbar Warm
    0xFF14B8A6, // Menta / Teal
  ];

  IncomeCategory _selectedCategory = IncomeCategory.salary;
  Currency _selectedCurrency = Currency.nio;
  RecurrenceFrequency _selectedRecurrence = RecurrenceFrequency.none;
  
  late IconData _customIcon;
  late int _customColorHex;

  @override
  void initState() {
    super.initState();
    _customIcon = _selectedCategory.icon;
    _customColorHex = _selectedCategory.colorHex;

    if (widget.incomeToEdit != null) {
      final inc = widget.incomeToEdit!;
      _nameController.text = inc.name;
      _amountController.text = inc.amount.toString();
      _selectedCategory = inc.category;
      _selectedCurrency = inc.currency;
      _selectedRecurrence = inc.recurrence;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  InputDecoration _buildCustomInputDecoration({
    required String label,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
      prefixIcon: Icon(prefixIcon, color: AppTheme.textSecondary, size: 20),
      filled: true,
      fillColor: AppTheme.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final newIncome = Income(
      id: widget.incomeToEdit?.id ?? 0,
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text),
      date: DateTime.now(),
      colorHex: _customColorHex,
      dbCategory: _selectedCategory.name,
      dbCurrency: _selectedCurrency.name,
      dbRecurrence: _selectedRecurrence.name,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    // context.read<IncomeViewModel>().addIncome(newIncome);
    // Navigator.pop(context);

    final viewModel = context.read<IncomeViewModel>();
    
    if (widget.incomeToEdit != null) {
      viewModel.updateIncome(newIncome);
    } else {
      viewModel.addIncome(newIncome);
    }

    Navigator.pop(context); // Cierra el formulario
    
    if (widget.incomeToEdit != null) {
      Navigator.pop(context); // Cierra el detalle para refrescar la pila
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Ingreso Premium'),
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
            // TARJETA DE PREVISUALIZACIÓN EN TIEMPO REAL (Fusión de gradientes en modo oscuro)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(_customColorHex), Color(_customColorHex).withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Color(_customColorHex).withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.25),
                    radius: 26,
                    child: Icon(_customIcon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text.isEmpty ? 'Procedencia del Ingreso' : _nameController.text,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedCategory.displayName,
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_selectedCurrency == Currency.usd ? '\$' : 'C\$'}${_amountController.text.isEmpty ? '0.00' : _amountController.text}',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // INPUT: Origen / Concepto
            TextFormField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
              decoration: _buildCustomInputDecoration(
                label: '¿Cuál es el origen de este ingreso? *',
                prefixIcon: Icons.edit_document,
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Por favor detalla la procedencia' : null,
            ),
            const SizedBox(height: 20),

            // FILA: Monto y Moneda
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _amountController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                    decoration: _buildCustomInputDecoration(
                      label: 'Monto Recibido *',
                      prefixIcon: Icons.price_check_rounded,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obligatorio';
                      if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Monto inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<Currency>(
                    value: _selectedCurrency,
                    dropdownColor: AppTheme.surfaceColor,
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                    decoration: _buildCustomInputDecoration(label: 'Moneda', prefixIcon: Icons.currency_exchange_rounded),
                    items: Currency.values.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCurrency = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // SELECTOR: Categoría Base
            DropdownButtonFormField<IncomeCategory>(
              value: _selectedCategory,
              dropdownColor: AppTheme.surfaceColor,
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
              decoration: _buildCustomInputDecoration(label: 'Categoría de Ingreso', prefixIcon: Icons.dashboard_customize_rounded),
              items: IncomeCategory.values.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat.displayName));
              }).toList(),
              onChanged: (val) => setState(() {
                _selectedCategory = val!;
                _customIcon = _selectedCategory.icon;
                _customColorHex = _selectedCategory.colorHex;
              }),
            ),
            const SizedBox(height: 24),

            // SELECTOR: Frecuencia de Repetición (Nuevo Atributo)
            DropdownButtonFormField<RecurrenceFrequency>(
              value: _selectedRecurrence,
              dropdownColor: AppTheme.surfaceColor,
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
              decoration: _buildCustomInputDecoration(label: '¿Este ingreso es recurrente?', prefixIcon: Icons.autorenew_rounded),
              items: RecurrenceFrequency.values.map((freq) {
                return DropdownMenuItem(value: freq, child: Text(freq.displayName));
              }).toList(),
              onChanged: (val) => setState(() => _selectedRecurrence = val!),
            ),
            const SizedBox(height: 28),

            // SECTOR CUSTOM: Iconos de Personalización
            const Text('Personalizar Icono de Entrada', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 10),
            SizedBox(
              height: 55,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final iconData = _availableIcons[index];
                  final isSelected = _customIcon == iconData;
                  return GestureDetector(
                    onTap: () => setState(() => _customIcon = iconData),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      width: 55,
                      decoration: BoxDecoration(
                        color: isSelected ? Color(_customColorHex) : AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : AppTheme.borderColor,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        iconData,
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // SECTOR CUSTOM: Paleta de Colores Circulares
            const Text('Asignar Color Distintivo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                itemBuilder: (context, index) {
                  final colorHex = _availableColors[index];
                  final isSelected = _customColorHex == colorHex;
                  return GestureDetector(
                    onTap: () => setState(() => _customColorHex = colorHex),
                    child: Container(
                      margin: const EdgeInsets.only(right: 14),
                      width: 44,
                      decoration: BoxDecoration(
                        color: Color(colorHex),
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // INPUT: Notas / Comentarios
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: _buildCustomInputDecoration(
                label: 'Notas explicativas o detalles del depósito',
                prefixIcon: Icons.description_rounded,
              ),
            ),
            const SizedBox(height: 40),

            // BOTÓN DE ACCIÓN GRADIENTE PREMIUM (Inversión de colores: Esmeralda para ingresos)
            GestureDetector(
              onTap: _submit,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentColor, Color(0xFF059669)], // Gradiente de esmeralda a verde oscuro profundo
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Confirmar y Guardar Ingreso',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}