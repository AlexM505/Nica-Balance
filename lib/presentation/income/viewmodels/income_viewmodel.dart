import 'package:flutter/material.dart';
import '../../../data/models/income.dart';
import '../../../data/repositories/income_repository.dart';

class IncomeViewModel extends ChangeNotifier {
  final IncomeRepository _incomeRepository;

  List<Income> _incomes = [];
  bool _isLoading = false;

  // Getters públicos para exponer el estado de forma segura (Inmutable desde fuera)
  List<Income> get incomes => _incomes;
  bool get isLoading => _isLoading;

  IncomeViewModel(this._incomeRepository) {
    // Cargamos los datos automáticamente al inicializar el ViewModel
    fetchIncomes();
  }

  /// Recupera la lista actualizada de ingresos desde ObjectBox
  void fetchIncomes() {
    _isLoading = true;
    notifyListeners();

    try {
      _incomes = _incomeRepository.getAllIncomes();
    } catch (e) {
      debugPrint('Error al recuperar los ingresos: $e');
      _incomes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registra un nuevo ingreso en el sistema y actualiza el estado reactivo
  void addIncome(Income income) {
    try {
      _incomeRepository.insertIncome(income);
      // Recargamos la lista local para reflejar el nuevo registro inmediatamente
      fetchIncomes(); 
    } catch (e) {
      debugPrint('Error al guardar el ingreso: $e');
    }
  }

  /// Elimina un registro de ingreso basándose en su ID único
  void removeIncome(int id) {
    try {
      final success = _incomeRepository.deleteIncome(id);
      if (success) {
        fetchIncomes();
      }
    } catch (e) {
      debugPrint('Error al eliminar el ingreso con ID $id: $e');
    }
  }

  // Editar/Actualizar un ingreso existente
  void updateIncome(Income updatedIncome) {
    _incomeRepository.insertIncome(updatedIncome); // Sobrescribe si el ID coincide
  }
}