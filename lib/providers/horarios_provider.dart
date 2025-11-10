import 'package:flutter/material.dart';
import '../models/horario.dart';
import '../services/horarios_service.dart';

class HorariosProvider extends ChangeNotifier {
  final HorariosService _horariosService = HorariosService();
  List<Horario> _horarios = [];
  bool _isLoading = false;
  String? _error;

  List<Horario> get horarios => _horarios;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HorariosProvider() {
    fetchHorarios();
  }

  Future<void> fetchHorarios() async {
    _setLoading(true);
    _clearError();
    try {
      _horarios = await _horariosService.getHorarios();
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar horarios: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createHorario({
    String? nombrehor,
    String? descripcionhor,
    String? fechainiciosemestre,
    String? fechafinsemestre,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final horario = await _horariosService.createHorario(
        nombrehor: nombrehor,
        descripcionhor: descripcionhor,
        fechainiciosemestre: fechainiciosemestre,
        fechafinsemestre: fechafinsemestre,
      );
      _horarios.add(horario);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al crear horario: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateHorario({
    required String id,
    String? nombrehor,
    String? descripcionhor,
    String? fechainiciosemestre,
    String? fechafinsemestre,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final horario = await _horariosService.updateHorario(
        id: id,
        nombrehor: nombrehor,
        descripcionhor: descripcionhor,
        fechainiciosemestre: fechainiciosemestre,
        fechafinsemestre: fechafinsemestre,
      );
      
      final index = _horarios.indexWhere((h) => h.id == id);
      if (index != -1) {
        _horarios[index] = horario;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Error al actualizar horario: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteHorario(String id) async {
    _setLoading(true);
    _clearError();
    try {
      final success = await _horariosService.deleteHorario(id);
      if (success) {
        _horarios.removeWhere((h) => h.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Error al eliminar horario: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Obtener horarios por nombre
  List<Horario> getHorariosPorNombre(String nombre) {
    return _horarios.where((h) => h.nombrehor == nombre).toList();
  }

  // Obtener horarios por semestre
  List<Horario> getHorariosPorSemestre(String fechainiciosemestre) {
    return _horarios.where((h) => h.fechainiciosemestre == fechainiciosemestre).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
