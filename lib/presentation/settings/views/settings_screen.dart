import 'package:flutter/material.dart';
import 'package:nica_balance/core/services/export_service.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/presentation/debts/views/debt_strategy_screen.dart';
import 'package:nica_balance/presentation/home/viewmodels/dashboard_viewmodel.dart';
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
          Text(
            'Aspecto e Interfaz',
            style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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

          Text(
            'Preferencias Financieras',
            style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
                color: AppTheme.getBackgroundColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<AppCurrency>(
                  value: prefsVM.selectedCurrency,
                  dropdownColor: AppTheme.getSurfaceColor(context),
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.getTextSecondary(context)),
                  style: TextStyle(color: AppTheme.getTextPrimary(context), fontWeight: FontWeight.bold, fontSize: 14),
                  onChanged: (AppCurrency? newValue) {
                    if (newValue != null) prefsVM.updateCurrency(newValue);
                  },
                  items: AppCurrency.values.map((AppCurrency currency) {
                    return DropdownMenuItem<AppCurrency>(
                      value: currency,
                      child: Text('${currency.code} ( ${currency.symbol} )'),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          
          _buildSettingsTile(
            context,
            icon: Icons.analytics_rounded, // O el icono financiero de tu preferencia
            iconColor: Colors.purple,
            title: 'Estrategias de Pago',
            subtitle: 'Simula el método Bola de Nieve o Avalancha',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebtStrategyScreen()),
              );
            },
          ),

          const SizedBox(height: 24),
          const Text(
            'Seguridad y Privacidad',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),

          // Ocultar Saldos
          _buildSettingsTile(
            context,
            icon: prefsVM.hideBalances ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Ocultar saldos',
            subtitle: 'Muestra asteriscos en los balances globales',
            trailing: Switch.adaptive(
              value: prefsVM.hideBalances,
              activeThumbColor: AppTheme.primaryColor,
              onChanged: (value) => prefsVM.toggleHideBalances(value),
            ),
          ),
          const SizedBox(height: 12),

          // Autenticación Biométrica
          _buildSettingsTile(
            context,
            icon: Icons.fingerprint_rounded,
            iconColor: const Color(0xFFEF4444),
            title: 'Bloqueo biométrico',
            subtitle: 'Solicitar Face ID o Huella al abrir la app',
            trailing: Switch.adaptive(
              value: prefsVM.biometricAuth,
              activeThumbColor: AppTheme.primaryColor,
              onChanged: (bool newValue) async {
                
                await prefsVM.toggleBiometricAuth(newValue);
                
                if (newValue && context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ),

          // ─── SECCIÓN: NOTIFICACIONES ───
          const SizedBox(height: 24),
          const Text(
            'Notificaciones',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_active_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'Recordatorio diario',
            subtitle: 'Recordar registrar transacciones al final del día',
            trailing: Switch.adaptive(
              value: prefsVM.dailyReminder,
              activeThumbColor: AppTheme.primaryColor,
              onChanged: (bool newValue) async {
                await prefsVM.toggleDailyReminder(newValue);
              },
            ),
          ),

          // Si está encendido, mostramos la opción para cambiar la hora de forma dinámica
          if (prefsVM.dailyReminder)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              child: InkWell(
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: prefsVM.reminderHour, minute: prefsVM.reminderMinute),
                  );
                  if (pickedTime != null) {
                    await prefsVM.updateReminderTime(pickedTime.hour, pickedTime.minute);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceColor(context).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.getBorderColor(context).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hora del aviso',
                        style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 13),
                      ),
                      Row(
                        children: [
                          Text(
                            prefsVM.formattedReminderTime,
                            style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.access_time_rounded, size: 16, color: AppTheme.primaryColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ─── SECCIÓN: Gestor de datos ───
          const SizedBox(height: 24),
          const Text(
            'Datos y Almacenamiento',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            icon: Icons.file_download_rounded,
            iconColor: Colors.blue,
            title: 'Exportar datos',
            subtitle: 'Descarga tus transacciones en formato CSV para Excel',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () async {
              final dashboardVM = context.read<DashboardViewModel>();

              // ─── VALIDACIÓN PREVENTIVA DE REGISTROS ───
              if (dashboardVM.expensesList.isEmpty && dashboardVM.incomesList.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.white),
                          SizedBox(width: 10),
                          Text('No hay transacciones registradas para exportar.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),  
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
                return;
              }

              // Mostramos un aviso temporal de que el proceso inició si pasa la validación
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Generando reporte CSV...',
                        style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),  
                      ),
                    ],
                  ),
                  backgroundColor: Colors.indigo,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );

              final bool success = await ExportService.exportTransactionsToCSV(
                expenses: dashboardVM.expensesList,
                incomes: dashboardVM.incomesList,
              );

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Archivo guardado en el dispositivo con éxito',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),  
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
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
    VoidCallback? onTap,
  }) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child:
          Container(
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
          ),
    );
  }
}