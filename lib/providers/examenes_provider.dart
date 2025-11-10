import 'package:flutter/material.dart';
import '../models/examen.dart';
import '../services/examenes_service.dart';

class ExamenesProvider extends ChangeNotifier {
  final ExamenesService _examenesService = ExamenesService();
  List<Examen> _examenes = [];
  EstadisticasExamenes? _estadisticasGenerales;
  Map<String, EstadisticasExamenes> _estadisticasPorMateria = {};
  bool _isLoading = false;
  String? _error;

  List<Examen> get examenes => _examenes;
  EstadisticasExamenes? get estadisticasGenerales => _estadisticasGenerales;
  Map<String, EstadisticasExamenes> get estadisticasPorMateria => _estadisticasPorMateria;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ExamenesProvider() {
    print('🚀 [ExamenesProvider] Provider inicializado');
    fetchExamenes();
  }

  // Cargar todos los exámenes con filtros opcionales
  Future<void> fetchExamenes({
    String? materiaId,
    String? estadoEval,
    String? tipoEval,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    debugPrint('[ExamenesProvider] fetchExamenes llamado con filtros:');
    debugPrint('[ExamenesProvider] - materiaId: $materiaId');
    debugPrint('[ExamenesProvider] - estadoEval: $estadoEval');
    debugPrint('[ExamenesProvider] - tipoEval: $tipoEval');
    debugPrint('[ExamenesProvider] - fechaInicio: $fechaInicio');
    debugPrint('[ExamenesProvider] - fechaFin: $fechaFin');
    
    _setLoading(true);
    _clearError();
    try {
      _examenes = await _examenesService.getExamenes(
        materiaId: materiaId,
        estadoEval: estadoEval,
        tipoEval: tipoEval,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      print('[ExamenesProvider] Exámenes cargados exitosamente: ${_examenes.length} registros');
      notifyListeners();
    } catch (e, stackTrace) {
      print('[ExamenesProvider] ERROR en fetchExamenes: $e');
      print('[ExamenesProvider] Stack trace: $stackTrace');
      _setError('Error al cargar exámenes: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Crear un nuevo examen
  Future<bool> createExamen({
    required String materiaId,
    TipoEvaluacion? tipoEval,
    DateTime? fechaEval,
    double? notaEval,
    double? ponderacionEval,
    EstadoEvaluacion? estadoEval,
  }) async {
    debugPrint('[ExamenesProvider] createExamen llamado');
    _setLoading(true);
    _clearError();
    try {
      final examen = await _examenesService.createExamen(
        materiaId: materiaId,
        tipoEval: tipoEval,
        fechaEval: fechaEval,
        notaEval: notaEval,
        ponderacionEval: ponderacionEval,
        estadoEval: estadoEval,
      );
      _examenes.add(examen);
      print('[ExamenesProvider] Examen creado exitosamente: ${examen.id}');
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('[ExamenesProvider] ERROR en createExamen: $e');
      print('[ExamenesProvider] Stack trace: $stackTrace');
      _setError('Error al crear examen: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar un examen
  Future<bool> updateExamen(
    String examenId, {
    TipoEvaluacion? tipoEval,
    DateTime? fechaEval,
    double? notaEval,
    double? ponderacionEval,
    EstadoEvaluacion? estadoEval,
  }) async {
    debugPrint('[ExamenesProvider] updateExamen llamado para: $examenId');
    _setLoading(true);
    _clearError();
    try {
      final examen = await _examenesService.updateExamen(
        examenId,
        tipoEval: tipoEval,
        fechaEval: fechaEval,
        notaEval: notaEval,
        ponderacionEval: ponderacionEval,
        estadoEval: estadoEval,
      );
      
      final index = _examenes.indexWhere((e) => e.id == examenId);
      if (index != -1) {
        _examenes[index] = examen;
        print('[ExamenesProvider] Examen actualizado exitosamente: $examenId');
        notifyListeners();
      } else {
        print('[ExamenesProvider] WARNING: Examen no encontrado en lista local: $examenId');
      }
      return true;
    } catch (e, stackTrace) {
      print('[ExamenesProvider] ERROR en updateExamen: $e');
      print('[ExamenesProvider] Stack trace: $stackTrace');
      _setError('Error al actualizar examen: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar un examen
  Future<bool> deleteExamen(String examenId) async {
    debugPrint('[ExamenesProvider] deleteExamen llamado para: $examenId');
    _setLoading(true);
    _clearError();
    try {
      final success = await _examenesService.deleteExamen(examenId);
      if (success) {
        _examenes.removeWhere((e) => e.id == examenId);
        print('[ExamenesProvider] Examen eliminado exitosamente: $examenId');
        notifyListeners();
      } else {
        print('[ExamenesProvider] WARNING: No se pudo eliminar el examen: $examenId');
      }
      return success;
    } catch (e, stackTrace) {
      print('[ExamenesProvider] ERROR en deleteExamen: $e');
      print('[ExamenesProvider] Stack trace: $stackTrace');
      _setError('Error al eliminar examen: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Obtener estadísticas generales
  Future<void> fetchEstadisticasGenerales() async {
    debugPrint('[ExamenesProvider] fetchEstadisticasGenerales llamado');
    _setLoading(true);
    _clearError();
    try {
      _estadisticasGenerales = await _examenesService.getEstadisticasGenerales();
      print('[ExamenesProvider] Estadísticas generales cargadas exitosamente');
      print('[ExamenesProvider] Total: ${_estadisticasGenerales?.total ?? 0}');
      notifyListeners();
    } catch (e, stackTrace) {
      print('[ExamenesProvider] ERROR en fetchEstadisticasGenerales: $e');
      print('[ExamenesProvider] Stack trace: $stackTrace');
      _setError('Error al cargar estadísticas: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Obtener estadísticas por materia
  Future<void> fetchEstadisticasPorMateria(String materiaId) async {
    debugPrint('[ExamenesProvider] fetchEstadisticasPorMateria llamado para: $materiaId');
    _setLoading(true);
    _clearError();
    try {
      final estadisticas = await _examenesService.getEstadisticasPorMateria(materiaId);
      _estadisticasPorMateria[materiaId] = estadisticas;
      print('[ExamenesProvider] Estadísticas de materia cargadas exitosamente');
      print('[ExamenesProvider] Total: ${estadisticas.total}');
      notifyListeners();
    } catch (e, stackTrace) {
      print('[ExamenesProvider] ERROR en fetchEstadisticasPorMateria: $e');
      print('[ExamenesProvider] Stack trace: $stackTrace');
      _setError('Error al cargar estadísticas de la materia: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Obtener exámenes por materia
  List<Examen> getExamenesPorMateria(String materiaId) {
    return _examenes.where((e) => e.materiaId == materiaId).toList();
  }

  // Obtener exámenes por estado
  List<Examen> getExamenesPorEstado(EstadoEvaluacion estado) {
    return _examenes.where((e) => e.estadoEval == estado).toList();
  }

  // Obtener exámenes próximos (por estado)
  List<Examen> getExamenesProximos() {
    return _examenes.where((e) => e.estadoEval == EstadoEvaluacion.proximos).toList();
  }

  // Obtener exámenes vencidos
  List<Examen> getExamenesVencidos() {
    return _examenes.where((e) => e.estaVencido).toList();
  }

  // Obtener exámenes por tipo
  List<Examen> getExamenesPorTipo(TipoEvaluacion tipo) {
    return _examenes.where((e) => e.tipoEval == tipo).toList();
  }

  // Obtener exámenes pendientes a calificar (sin nota asignada)
  List<Examen> getExamenesPendientes() {
    return _examenes.where((e) => 
      e.estadoEval == EstadoEvaluacion.pendientesACalificar
    ).toList();
  }

  // Obtener exámenes calificados (con nota asignada)
  List<Examen> getExamenesCalificados() {
    return _examenes.where((e) => 
      e.estadoEval == EstadoEvaluacion.calificados
    ).toList();
  }

  // Obtener exámenes próximos
  List<Examen> getExamenesProximosEstado() {
    return _examenes.where((e) => 
      e.estadoEval == EstadoEvaluacion.proximos
    ).toList();
  }

  // Obtener promedio de notas
  double getPromedioNotas() {
    final examenesConNota = _examenes.where((e) => e.notaEval != null).toList();
    if (examenesConNota.isEmpty) return 0.0;
    
    final sumaNotas = examenesConNota.fold<double>(0.0, (sum, e) => sum + e.notaEval!);
    return sumaNotas / examenesConNota.length;
  }

  // Obtener promedio de notas por materia
  double getPromedioNotasPorMateria(String materiaId) {
    final examenesMateria = getExamenesPorMateria(materiaId);
    final examenesConNota = examenesMateria.where((e) => e.notaEval != null).toList();
    if (examenesConNota.isEmpty) return 0.0;
    
    final sumaNotas = examenesConNota.fold<double>(0.0, (sum, e) => sum + e.notaEval!);
    return sumaNotas / examenesConNota.length;
  }

  // Obtener estadísticas de rendimiento
  Map<String, dynamic> getEstadisticasRendimiento() {
    final totalExamenes = _examenes.length;
    final examenesCalificados = getExamenesCalificados().length;
    final promedioGeneral = getPromedioNotas();
    // Exámenes aprobados: aquellos calificados con nota >= 3.0 (sistema 5) o >= 6.0 (sistema 10)
    // Por defecto usamos 3.0 como criterio mínimo
    final examenesAprobados = _examenes.where((e) => 
      e.estadoEval == EstadoEvaluacion.calificados && 
      e.notaEval != null && 
      e.notaEval! >= 3.0
    ).length;
    
    return {
      'totalExamenes': totalExamenes,
      'examenesCalificados': examenesCalificados,
      'promedioGeneral': promedioGeneral,
      'examenesAprobados': examenesAprobados,
      'porcentajeAprobacion': totalExamenes > 0 ? (examenesAprobados / totalExamenes) * 100 : 0.0,
    };
  }

  // Buscar exámenes por texto
  List<Examen> buscarExamenes(String query) {
    if (query.isEmpty) return _examenes;
    
    final queryLower = query.toLowerCase();
    return _examenes.where((examen) {
      return examen.tipoEval?.value.toLowerCase().contains(queryLower) == true ||
             examen.materia?.nombre.toLowerCase().contains(queryLower) == true ||
             examen.materia?.codigo.toLowerCase().contains(queryLower) == true ||
             examen.estadoEval?.value.toLowerCase().contains(queryLower) == true;
    }).toList();
  }

  // Ordenar exámenes por fecha
  List<Examen> getExamenesOrdenadosPorFecha({bool ascendente = true}) {
    final examenesOrdenados = List<Examen>.from(_examenes);
    examenesOrdenados.sort((a, b) {
      if (a.fechaEval == null && b.fechaEval == null) return 0;
      if (a.fechaEval == null) return ascendente ? 1 : -1;
      if (b.fechaEval == null) return ascendente ? -1 : 1;
      return ascendente 
          ? a.fechaEval!.compareTo(b.fechaEval!)
          : b.fechaEval!.compareTo(a.fechaEval!);
    });
    return examenesOrdenados;
  }

  // Ordenar exámenes por nota
  List<Examen> getExamenesOrdenadosPorNota({bool ascendente = true}) {
    final examenesOrdenados = List<Examen>.from(_examenes);
    examenesOrdenados.sort((a, b) {
      if (a.notaEval == null && b.notaEval == null) return 0;
      if (a.notaEval == null) return ascendente ? 1 : -1;
      if (b.notaEval == null) return ascendente ? -1 : 1;
      return ascendente 
          ? a.notaEval!.compareTo(b.notaEval!)
          : b.notaEval!.compareTo(a.notaEval!);
    });
    return examenesOrdenados;
  }

  // Métodos privados
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

  // Método para limpiar datos
  void clearData() {
    _examenes.clear();
    _estadisticasGenerales = null;
    _estadisticasPorMateria.clear();
    _clearError();
    notifyListeners();
  }
}
