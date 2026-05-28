import 'package:flutter/material.dart';

enum Currency { usd, nio }

enum ExpenseCategory {
  food('Alimentos', Icons.fastfood_rounded, 0xFF4CAF50),
  transport('Transporte', Icons.directions_car_rounded, 0xFF2196F3),
  utilities('Servicios', Icons.electric_bolt_rounded, 0xFFFF9800),
  entertainment('Entretenimiento', Icons.movie_rounded, 0xFF9C27B0),
  health('Salud', Icons.medical_services_rounded, 0xFFE91E63),
  shopping('Compras', Icons.shopping_bag_rounded, 0xFF607D8B),
  other('Otros', Icons.monetization_on_rounded, 0xFF795548);

  final String displayName;
  final IconData icon;
  final int colorHex;

  const ExpenseCategory(this.displayName, this.icon, this.colorHex);
}