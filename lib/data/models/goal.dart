import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

enum GoalCategory {
  travel(displayName: 'Viajes / Vacaciones', icon: Icons.flight_takeoff_rounded, colorHex: 0xFF3B82F6),
  vehicle(displayName: 'Vehículo / Auto', icon: Icons.directions_car_rounded, colorHex: 0xFFF59E0B),
  housing(displayName: 'Vivienda / Hogar', icon: Icons.home_rounded, colorHex: 0xFF10B981),
  electronics(displayName: 'Tecnología / Gadgets', icon: Icons.laptop_mac_rounded, colorHex: 0xFF8B5CF6),
  emergency(displayName: 'Fondo de Emergencia', icon: Icons.health_and_safety_rounded, colorHex: 0xFFEF4444),
  education(displayName: 'Educación / Cursos', icon: Icons.school_rounded, colorHex: 0xFF06B6D4),
  other(displayName: 'Otros Objetivos', icon: Icons.stars_rounded, colorHex: 0xFF6B7280);

  final String displayName;
  final IconData icon;
  final int colorHex;

  const GoalCategory({
    required this.displayName,
    required this.icon,
    required this.colorHex,
  });
}

@Entity()
class Goal {
  @Id()
  int id;
  
  String name;
  double targetAmount;
  double currentAmount;
  
  // ObjectBox gestiona mejor DateTime si lo guardamos o transformamos de forma segura
  int startDateMilli;
  int deadlineMilli;
  
  // Almacenamos el índice del enum para la persistencia NoSQL
  int categoryIndex;

  Goal({
    this.id = 0,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.startDateMilli,
    required this.deadlineMilli,
    required this.categoryIndex,
  });

  // --- Getters de Utilidad para las Vistas ---

  GoalCategory get category => GoalCategory.values[categoryIndex];

  DateTime get startDate => DateTime.fromMillisecondsSinceEpoch(startDateMilli);
  
  DateTime get deadline => DateTime.fromMillisecondsSinceEpoch(deadlineMilli);

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final pct = currentAmount / targetAmount;
    return pct > 1.0 ? 1.0 : pct;
  }

  bool get isCompleted => currentAmount >= targetAmount;
}