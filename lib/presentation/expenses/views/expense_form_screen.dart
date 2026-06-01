import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/expense_enums.dart';
import '../viewmodels/expense_viewmodel.dart';

class ExpenseFormScreen extends StatefulWidget {

  final Expense? expenseToEdit; // Parámetro opcional para la edición

  const ExpenseFormScreen({super.key, this.expenseToEdit});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  // Opciones predefinidas de Iconos y Colores para personalización elegante
  final List<IconData> _availableIcons = [
    Icons.fastfood_rounded,
    Icons.directions_car_rounded,
    Icons.electric_bolt_rounded,
    Icons.movie_rounded,
    Icons.medical_services_rounded,
    Icons.shopping_bag_rounded,
    Icons.monetization_on_rounded,
  ];

  final List<int> _availableColors = [
    0xFF10B981, // Esmeralda
    0xFF3B82F6, // Azul Eléctrico
    0xFF8B5CF6, // Violeta Real
    0xFFEC4899, // Rosa Intenso
    0xFFF59E0B, // Ámbar Warm
    0xFFEF4444, // Coral Rojo
    0xFF64748B, // Slate Grey
  ];

  // Estados locales del formulario con valores iniciales estéticos
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  Currency _selectedCurrency = Currency.nio;
  late IconData _customIconCode;
  late int _customColorHex;
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    // Inicializar con los colores base de la categoría seleccionada
    _customIconCode = _selectedCategory.icon;
    _customColorHex = _selectedCategory.colorHex;

    if (widget.expenseToEdit != null) {
      final exp = widget.expenseToEdit!;
      _nameController.text = exp.name;
      _amountController.text = exp.amount.toString();
      _selectedCategory = exp.category;
      _selectedCurrency = exp.currency;
      // _selectedDate = exp.date;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Estilo base reutilizable para los inputs personalizados
  InputDecoration _buildCustomInputDecoration({
    required String label,
    required IconData prefixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF9CA3AF), size: 20),
      prefixText: prefixText,
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

    // Aquí sobreescribimos los valores por defecto de la categoría con la selección custom del usuario
    final newExpense = Expense(
      id: widget.expenseToEdit?.id ?? 0,
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text),
      isPaid: _isPaid,
      date: DateTime.now(),
      dbCategory: _selectedCategory.name,
      dbCurrency: _selectedCurrency.name,
      colorHex: _customColorHex,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    // Nota de escalabilidad: Como omitimos el dominio para simplificar, puedes extender tu modelo de ObjectBox 
    // si deseas guardar permanentemente las desviaciones exactas de iconos/colores por registro, 
    // o usar la lógica dinámica vinculada a los Enums modificables.

    final viewModel = context.read<ExpenseViewModel>();
    if (widget.expenseToEdit != null) {
      viewModel.updateExpense(newExpense);
    } else {
      viewModel.addExpense(newExpense);
    }
    // context.read<ExpenseViewModel>().addExpense(newExpense);
    Navigator.pop(context);

    if (widget.expenseToEdit != null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Gasto Premium'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            children: [
              // Sección de Previsualización en Tiempo Real (Toque de diseño UI/UX)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(_customColorHex), Color(_customColorHex).withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Color(_customColorHex).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      radius: 26,
                      child: Icon(
                        _customIconCode,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text.isEmpty ? 'Descripción del Gasto' : _nameController.text,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedCategory.displayName,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
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

              // INPUT: Descripción
              TextFormField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                decoration: _buildCustomInputDecoration(
                  label: '¿En qué gastaste? *',
                  prefixIcon: Icons.edit_note_rounded,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Por favor escribe un concepto' : null,
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
                        label: 'Monto Total *',
                        prefixIcon: Icons.payments_rounded,
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
                      initialValue: _selectedCurrency,
                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                      decoration: _buildCustomInputDecoration(label: 'Moneda', prefixIcon: Icons.shutter_speed_rounded),
                      items: Currency.values.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()));
                      }).toList(),
                      onChanged: (val) => setState(() {
                        _selectedCurrency = val!;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // CATEGORÍA BASE (Desplegable Estilizado)
              DropdownButtonFormField<ExpenseCategory>(
                initialValue: _selectedCategory,
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                decoration: _buildCustomInputDecoration(label: 'Categoría Base', prefixIcon: Icons.grid_view_rounded),
                items: ExpenseCategory.values.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat.displayName));
                }).toList(),
                onChanged: (val) => setState(() {
                  _selectedCategory = val!;
                  // Al cambiar la categoría, sincronizamos el preset visual por defecto
                  _customIconCode = _selectedCategory.icon;
                  _customColorHex = _selectedCategory.colorHex;
                }),
              ),
              const SizedBox(height: 28),

              // Selector Custom de Iconos (Horizontal & Atractivo)
              const Text('Personalizar Icono de Identificación', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
              const SizedBox(height: 10),
              SizedBox(
                height: 55,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final iconCode = _availableIcons[index];
                    final isSelected = _customIconCode == iconCode;
                    return GestureDetector(
                      onTap: () => setState(() => _customIconCode = iconCode),
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
                          iconCode, 
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Selector Custom de Colores de Acento (Paleta Elegante)
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
                          border: isSelected ? Border.all(color: const Color(0xFF1E3A8A), width: 3) : null,
                          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 3))] : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // INPUT: Notas de Soporte
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                style: TextStyle(color: AppTheme.textPrimary),
                decoration: _buildCustomInputDecoration(
                  label: 'Anotaciones u observaciones adicionales',
                  prefixIcon: Icons.description_rounded,
                ),
              ),
              const SizedBox(height: 20),

              Material(
                color: AppTheme.surfaceColor, // El fondo se define aquí en el contenedor Material
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias, // Asegura que el efecto splash no se salga de las esquinas redondeadas
                child: Container(
                  // Agregamos el borde usando un Container intermedio sin color de fondo
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor, width: 1.5),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      '¿Este gasto ya fue liquidado / pagado?', 
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    value: _isPaid,
                    activeThumbColor: Color(_customColorHex),
                    // IMPORTANTE: Quitamos 'tileColor' de aquí para que use el del widget Material padre
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    onChanged: (val) => setState(() => _isPaid = val),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // BOTÓN PRINCIPAL CUSTOM PREMIUM
              GestureDetector(
                onTap: _submit,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
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
                      'Confirmar y Guardar Gasto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}