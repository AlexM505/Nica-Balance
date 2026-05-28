import 'package:nica_balance/core/database/objectbox_store.dart';

import '../../objectbox.g.dart';
import '../models/goal.dart';

class GoalRepository {
  final Box<Goal> _goalBox;

  GoalRepository(ObjectBoxStore database) : _goalBox = database.store.box<Goal>();


  // Obtener todas las metas guardadas en la base de datos
  List<Goal> getAllGoals() {
    return _goalBox.getAll();
  }

  // Guardar o actualizar una meta (ObjectBox usa la misma función put)
  int saveGoal(Goal goal) {
    return _goalBox.put(goal);
  }

  // Eliminar una meta por su ID
  bool deleteGoal(int id) {
    return _goalBox.remove(id);
  }
}