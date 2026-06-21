import 'package:flutter/material.dart';
import 'package:nica_balance/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppCurrency { 
  USD(symbol: '\$', code: 'USD', name: 'Dólares Americanos'), 
  NIO(symbol: 'C\$', code: 'NIO', name: 'Córdobas Oro');

  final String symbol;
  final String code;
  final String name;

  const AppCurrency({required this.symbol, required this.code, required this.name});
}

class PreferencesViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // Por defecto tu tema oscuro premium
  AppCurrency _selectedCurrency = AppCurrency.USD;

  ThemeMode get themeMode => _themeMode;
  AppCurrency get selectedCurrency => _selectedCurrency;

  String get currencySymbol => _selectedCurrency.symbol;
  String get currencyCode => _selectedCurrency.code;

  bool _hideBalances = false;
  bool _biometricAuth = false;

  bool _isAuthenticating = false;

  bool get hideBalances => _hideBalances;
  bool get biometricAuth => _biometricAuth;
  bool get isAuthenticating => _isAuthenticating;

  PreferencesViewModel() {
    _loadPreferences();
  }

  // Carga inicial al instanciar el ViewModel en el arranque de la app
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cargar Tema
    final isDark = prefs.getBool('is_dark_mode') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    // Cargar Moneda por defecto
    final currencyIndex = prefs.getInt('selected_currency_index') ?? AppCurrency.USD.index;
    _selectedCurrency = AppCurrency.values[currencyIndex];

    // Cargar Configuraciones de Seguridad
    _hideBalances = prefs.getBool('security_hide_balances') ?? false;
    _biometricAuth = prefs.getBool('security_biometric_auth') ?? false;
    
    // 1. Carga los valores dentro de tu método existente _loadPreferences():
    _dailyReminder = prefs.getBool('security_daily_reminder') ?? false;
    _reminderHour = prefs.getInt('security_reminder_hour') ?? 20;
    _reminderMinute = prefs.getInt('security_reminder_minute') ?? 0;


    notifyListeners();
  }

  Future<void> toggleTheme(bool isDarkMode) async{
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDarkMode);
  }

  Future<void> updateCurrency(AppCurrency currency) async{
    _selectedCurrency = currency;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_currency_index', currency.index);
  }

  // Modificar estado de ocultar saldos
  Future<void> toggleHideBalances(bool value) async {
    _hideBalances = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('security_hide_balances', value);
  }

  // Modificar estado de autenticación biométrica
  Future<void> toggleBiometricAuth(bool value) async {
    _biometricAuth = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('security_biometric_auth', value);
  }

  void setIsAuthenticating(bool value) {
    _isAuthenticating = value;
    notifyListeners();
  }

  //Notification flow
  bool _dailyReminder = false;
  int _reminderHour = 20; // 8 PM por defecto
  int _reminderMinute = 0;

  bool get dailyReminder => _dailyReminder;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;

  String get formattedReminderTime {
    final String hourStr = _reminderHour.toString().padLeft(2, '0');
    final String minuteStr = _reminderMinute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  Future<void> toggleDailyReminder(bool value) async {
    _dailyReminder = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('security_daily_reminder', value);

    if (value) {
      await NotificationService.scheduleDailyReminder(hour: _reminderHour, minute: _reminderMinute);
    } else {
      await NotificationService.cancelDailyReminder();
    }
  }

  Future<void> updateReminderTime(int hour, int minute) async {
    _reminderHour = hour;
    _reminderMinute = minute;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('security_reminder_hour', hour);
    await prefs.setInt('security_reminder_minute', minute);

    if (_dailyReminder) {
      await NotificationService.scheduleDailyReminder(hour: hour, minute: minute);
    }
  }
}