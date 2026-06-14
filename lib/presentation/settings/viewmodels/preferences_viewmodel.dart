import 'package:flutter/material.dart';

enum AppCurrency { NIO, USD }

class PreferencesViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // Por defecto tu tema oscuro premium
  AppCurrency _selectedCurrency = AppCurrency.USD;

  ThemeMode get themeMode => _themeMode;
  AppCurrency get selectedCurrency => _selectedCurrency;

  // Helpers para obtener strings o símbolos limpios en tus vistas
  String get currencySymbol => _selectedCurrency == AppCurrency.USD ? '\$' : 'C\$';
  String get currencyCode => _selectedCurrency.name;

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void updateCurrency(AppCurrency currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }
}