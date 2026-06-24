import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/data/models/expense_enums.dart';
import 'package:provider/provider.dart';
import '../../../data/models/goal.dart';
import '../viewmodels/goals_viewmodel.dart';

class GoalFormScreen extends StatefulWidget {
  const GoalFormScreen({super.key});

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();

  Currency _selectedCurrency = Currency.nio;
  GoalCategory _selectedCategory = GoalCategory.travel;
  DateTime _startDate = DateTime.now();
  DateTime _deadline = DateTime.now().add(const Duration(days: 90)); // Por defecto 3 meses plazo

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _deadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              surface: AppTheme.surfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_deadline.isBefore(_startDate)) {
            _deadline = _startDate.add(const Duration(days: 1));
          }
        } else {
          _deadline = picked;
        }
      });
    }
  }

  InputDecoration _buildInputDecoration(BuildContext context,  label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 14),
      prefixIcon: Icon(icon, color: AppTheme.getTextSecondary(context), size: 20),
      filled: true,
      fillColor: AppTheme.getSurfaceColor(context),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppTheme.getBorderColor(context), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de cumplimiento debe ser posterior al inicio.')),
      );
      return;
    }


    final newGoal = Goal(
      name: _nameController.text.trim(),
      targetAmount: double.parse(_targetAmountController.text),
      currentAmount: _currentAmountController.text.isEmpty ? 0.0 : double.parse(_currentAmountController.text),
      startDateMilli: _startDate.millisecondsSinceEpoch,
      deadlineMilli: _deadline.millisecondsSinceEpoch,
      categoryIndex: _selectedCategory.index, // Guardamos la posición del enum
      dbCurrency: _selectedCurrency.name,
    );

    context.read<GoalsViewModel>().addGoal(newGoal);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Meta de Ahorro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TARJETA DE PREVISUALIZACIÓN EN TIEMPO REAL (Estilo Premium)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(_selectedCategory.colorHex), Color(_selectedCategory.colorHex).withValues(alpha: 0.65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Color(_selectedCategory.colorHex).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          radius: 22,
                          child: Icon(_selectedCategory.icon, color: Colors.white, size: 24),
                        ),
                        Text(
                          _selectedCategory.displayName,
                          style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _nameController.text.isEmpty ? 'Nombre del Objetivo' : _nameController.text,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meta: ${_selectedCurrency == Currency.usd ? '\$' : 'C\$'}${_targetAmountController.text.isEmpty ? '0.00' : _targetAmountController.text}',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Plazo: ${_deadline.day}/${_deadline.month}/${_deadline.year}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // INPUT: Nombre de la meta
              TextFormField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: AppTheme.getTextPrimary(context), fontWeight: FontWeight.w600),
                decoration: _buildInputDecoration(context, '¿Qué estás planeando cumplir? *', Icons.stars_rounded),
                validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa un nombre para tu objetivo' : null,
              ),
              const SizedBox(height: 20),

              // FILA: Monto Objetivo y Base Inicial
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _targetAmountController,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(color: AppTheme.getTextPrimary(context), fontWeight: FontWeight.bold),
                      decoration: _buildInputDecoration(context, 'Monto Requerido', Icons.track_changes_rounded),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || double.tryParse(v) == null || double.parse(v) <= 0 ? 'Monto requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<Currency>(
                      initialValue: _selectedCurrency,
                      style: TextStyle(color: AppTheme.getTextPrimary(context), fontWeight: FontWeight.bold),
                      decoration: _buildInputDecoration(context, 'Moneda', Icons.shutter_speed_rounded),
                      items: Currency.values.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()));
                      }).toList(),
                      onChanged: (val) => setState(() {
                        _selectedCurrency = val!;
                      }),
                    ),
                  ),
                  // Expanded(
                  //   child: TextFormField(
                  //     controller: _currentAmountController,
                  //     style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                  //     decoration: _buildInputDecoration('Ahorro Inicial (\$)', Icons.savings_rounded),
                  //     keyboardType: TextInputType.number,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _currentAmountController,
                style: TextStyle(color: AppTheme.getTextPrimary(context), fontWeight: FontWeight.bold),
                decoration: _buildInputDecoration(context, 'Ahorro Inicial', Icons.savings_rounded),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              // DROP DRAW: Categorías de metas
              DropdownButtonFormField<GoalCategory>(
                initialValue: _selectedCategory,
                dropdownColor: AppTheme.getSurfaceColor(context),
                style: TextStyle(color: AppTheme.getTextPrimary(context), fontWeight: FontWeight.w600),
                decoration: _buildInputDecoration(context, 'Categoría de Meta', Icons.folder_special_rounded),
                items: GoalCategory.values.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat.displayName));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 24),

              // SELECTORES DE FECHAS ESTILIZADOS
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.getBorderColor(context), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha de Inicio', style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 11)),
                            const SizedBox(height: 6),
                            Text(
                              '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                              style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.getBorderColor(context), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha Objetivo', style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 11)),
                            const SizedBox(height: 6),
                            Text(
                              '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                              style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 44),

              // BOTÓN GUARDAR METAS
              GestureDetector(
                onTap: _submit,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, Colors.indigo], // Gradiente de esmeralda a verde oscuro profundo
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Establecer Objetivo Financiero',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}