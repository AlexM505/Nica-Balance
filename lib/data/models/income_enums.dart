import 'package:flutter/material.dart';

/// Categorías específicas para clasificar los flujos de entrada de dinero
enum IncomeCategory {
  salary('Salario', Icons.account_balance_wallet_rounded, 0xFF10B981),    // Verde Esmeralda
  investment('Inversión', Icons.trending_up_rounded, 0xFF3B82F6),        // Azul Eléctrico
  business('Negocio / Emprendimiento', Icons.storefront_rounded, 0xFF8B5CF6), // Violeta Real
  gifts('Regalos / Premios', Icons.card_giftcard_rounded, 0xFFEC4899),    // Rosa Intenso
  other('Otros Ingresos', Icons.add_card_rounded, 0xFF64748B);           // Slate Grey

  final String displayName;
  final IconData icon;
  final int colorHex;

  const IncomeCategory(this.displayName, this.icon, this.colorHex);
}

/// Frecuencias de recurrencia para ingresos fijos o periódicos
enum RecurrenceFrequency {
  none('No se repite'),
  weekly('Cada semana'),
  biweekly('Cada 15 días'),
  monthly('Cada mes');

  final String displayName;
  const RecurrenceFrequency(this.displayName);
}