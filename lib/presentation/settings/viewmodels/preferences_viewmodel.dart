import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppCurrency { NIO, USD }

class PreferencesViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // Por defecto tu tema oscuro premium
  AppCurrency _selectedCurrency = AppCurrency.USD;

  ThemeMode get themeMode => _themeMode;
  AppCurrency get selectedCurrency => _selectedCurrency;

  // Helpers para obtener strings o símbolos limpios en tus vistas
  String get currencySymbol => _selectedCurrency == AppCurrency.USD ? '\$' : 'C\$';
  String get currencyCode => _selectedCurrency.name;

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
    // final currencyIndex = prefs.getInt('selected_currency_index') ?? AppCurrency.USD.index;
    // _selectedCurrency = AppCurrency.values[currencyIndex];
    
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
}