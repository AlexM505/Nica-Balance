import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../viewmodels/preferences_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefsVM = context.watch<PreferencesViewModel>();
    final isDark = prefsVM.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          const Text(
            'Aspecto e Interfaz',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),

          // Sección: Selector de Tema
          _buildSettingsTile(
            context,
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B),
            title: 'Tema Oscuro',
            subtitle: 'Reduce el cansancio visual',
            trailing: Switch.adaptive(
              value: isDark,
              activeThumbColor: AppTheme.primaryColor,
              onChanged: (value) => prefsVM.toggleTheme(value),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Preferencias Financieras',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),

          // Sección: Selector de Moneda Principal
          _buildSettingsTile(
            context,
            icon: Icons.payments_rounded,
            iconColor: AppTheme.accentColor,
            title: 'Moneda Principal',
            subtitle: 'Divisa base para tus balances globales',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<AppCurrency>(
                  value: prefsVM.selectedCurrency,
                  dropdownColor: AppTheme.surfaceColor,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  onChanged: (AppCurrency? newValue) {
                    if (newValue != null) prefsVM.updateCurrency(newValue);
                  },
                  items: AppCurrency.values.map((AppCurrency currency) {
                    return DropdownMenuItem<AppCurrency>(
                      value: currency,
                      child: Text(currency.name),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Contenedor base para mantener la consistencia visual de tus listas de opciones
  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}