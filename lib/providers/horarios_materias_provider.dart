import 'package:flutter/material.dart';
import '../services/horarios_materias_service.dart';

class HorariosMaterialsProvider with ChangeNotifier {
  final HorariosMaterialsService _service = HorariosMaterialsService();
  
  List<Map<String, dynamic>> _materias = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get materias => _materias;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMateriasByHorario(String horarioId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _materias = await _service.getMateriasByHorario(horarioId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _materias = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMateriaEnHorario({
    required String horarioId,
    required String materiaId,
    required String dia,
    required String horaInicio,
    required String horaFin,
    String? aula,
    String? notas,
  }) async {
    try {
      await _service.createMateriaEnHorario(
        horarioId: horarioId,
        materiaId: materiaId,
        dia: dia,
        horaInicio: horaInicio,
        horaFin: horaFin,
        aula: aula,
        notas: notas,
      );
      
      // Recargar las materias
      await loadMateriasByHorario(horarioId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMateriaDeHorario(String horarioId, String materiaHorarioId) async {
    try {
      await _service.deleteMateriaDeHorario(horarioId, materiaHorarioId);
      
      // Recargar las materias
      await loadMateriasByHorario(horarioId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMateriaEnHorario({
    required String horarioId,
    required String materiaHorarioId,
    String? dia,
    String? horaInicio,
    String? horaFin,
    String? aula,
    String? notas,
  }) async {
    try {
      await _service.updateMateriaEnHorario(
        horarioId: horarioId,
        materiaHorarioId: materiaHorarioId,
        dia: dia,
        horaInicio: horaInicio,
        horaFin: horaFin,
        aula: aula,
        notas: notas,
      );
      
      // Recargar las materias
      await loadMateriasByHorario(horarioId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

