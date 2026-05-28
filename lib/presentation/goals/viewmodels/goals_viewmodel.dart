import 'package:flutter/material.dart';
import '../../../data/models/goal.dart';
import '../../../data/repositories/goal_repository.dart';

class GoalsViewModel extends ChangeNotifier {
  final GoalRepository _goalRepository;
  List<Goal> _goals = [];

  GoalsViewModel({required GoalRepository goalRepository}) 
      : _goalRepository = goalRepository {
    _loadGoals(); // Carga inicial reactiva al instanciar el módulo
  }

  List<Goal> get goals => List.unmodifiable(_goals);

  // Carga los datos desde ObjectBox a la memoria del flujo
  void _loadGoals() {
    _goals = _goalRepository.getAllGoals();
    notifyListeners();
  }

  // Registra una nueva meta y sincroniza con el almacenamiento local
  void addGoal(Goal goal) {
    _goalRepository.saveGoal(goal);
    _loadGoals(); // Recargamos para mantener consistencia absoluta
  }

  // Incrementa fondos a una meta y actualiza ObjectBox
  void addFundsToGoal(int id, double amount) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final goalToUpdate = _goals[index];
      goalToUpdate.currentAmount += amount;
      
      _goalRepository.saveGoal(goalToUpdate);
      _loadGoals();
    }
  }

  // Eliminar un objetivo de la persistencia NoSQL
  void removeGoal(int id) {
    _goalRepository.deleteGoal(id);
    _loadGoals();
  }
}