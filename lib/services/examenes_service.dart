import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/examen.dart';

class ExamenesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener todas las materias del usuario (helper method)
  Future<List<String>> _getMateriasIdsDelUsuario() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('materias')
        .select('id')
        .eq('usuario_id', user.id);

    if (response.isEmpty) return [];
    return (response as List<dynamic>)
        .map((json) => (json as Map<String, dynamic>)['id'] as String)
        .toList();
  }

  // Obtener todos los exámenes con filtros opcionales
  Future<List<Examen>> getExamenes({
    String? materiaId,
    String? estadoEval,
    String? tipoEval,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      // Obtener IDs de materias del usuario
      final materiasIds = await _getMateriasIdsDelUsuario();
      if (materiasIds.isEmpty) {
        return [];
      }

      // Construir query base - usar OR si hay múltiples materias, o eq si solo hay una
      dynamic queryBuilder = _supabase
          .from('examenes')
          .select('''
            *,
            materias (*)
          ''');

      // Aplicar filtro de materias
      if (materiasIds.length == 1) {
        queryBuilder = queryBuilder.eq('materiaid', materiasIds[0]);
      } else if (materiasIds.length > 1) {
        // Construir condición OR para múltiples materias
        final orCondition = materiasIds
            .map((id) => 'materiaid.eq.$id')
            .join(',');
        queryBuilder = queryBuilder.or(orCondition);
      } else {
        return [];
      }

      // Si se especifica una materia específica, usar esa en lugar de todas
      if (materiaId != null && materiaId.isNotEmpty && materiasIds.contains(materiaId)) {
        queryBuilder = queryBuilder.eq('materiaid', materiaId);
      }

      // Aplicar otros filtros
      if (tipoEval != null && tipoEval.isNotEmpty) {
        queryBuilder = queryBuilder.eq('tipoeval', tipoEval);
      }
      if (estadoEval != null && estadoEval.isNotEmpty) {
        queryBuilder = queryBuilder.eq('estadoeval', estadoEval);
      }
      if (fechaInicio != null && fechaInicio.isNotEmpty) {
        queryBuilder = queryBuilder.gte('fechaeval', fechaInicio);
      }
      if (fechaFin != null && fechaFin.isNotEmpty) {
        queryBuilder = queryBuilder.lte('fechaeval', fechaFin);
      }

      // Ordenar por fecha
      queryBuilder = queryBuilder.order('fechaeval', ascending: true);

      final response = await queryBuilder;

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((json) => _examenFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener exámenes: ${e.toString()}');
    }
  }

  // Obtener exámenes por materia
  Future<List<Examen>> getExamenesPorMateria(String materiaId) async {
    return getExamenes(materiaId: materiaId);
  }

  // Obtener exámenes por estado
  Future<List<Examen>> getExamenesPorEstado(String estadoEval) async {
    return getExamenes(estadoEval: estadoEval);
  }

  // Obtener un examen específico
  Future<Examen> getExamen(String examenId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      // Verificar que el examen pertenece a una materia del usuario
      final materiasIds = await _getMateriasIdsDelUsuario();
      if (materiasIds.isEmpty) {
        throw Exception('Examen no encontrado');
      }

      // Construir condición OR para verificar que pertenece a una de las materias del usuario
      final orCondition = materiasIds
          .map((id) => 'materiaid.eq.$id')
          .join(',');

      final response = await _supabase
          .from('examenes')
          .select('''
            *,
            materias (*)
          ''')
          .eq('id', examenId)
          .or(orCondition)
          .single();

      return _examenFromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Error al obtener el examen: ${e.toString()}');
    }
  }

  // Crear un nuevo examen
  Future<Examen> createExamen({
    required String materiaId,
    TipoEvaluacion? tipoEval,
    DateTime? fechaEval,
    double? notaEval,
    double? ponderacionEval,
    EstadoEvaluacion? estadoEval,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      // Verificar que la materia pertenece al usuario
      try {
        await _supabase
            .from('materias')
            .select('id')
            .eq('id', materiaId)
            .eq('usuario_id', user.id)
            .single();
      } catch (e) {
        throw Exception('Materia no encontrada o no pertenece al usuario');
      }

      final examenData = {
        'materiaid': materiaId,
        if (tipoEval != null) 'tipoeval': tipoEval.value,
        if (fechaEval != null) 'fechaeval': fechaEval.toIso8601String().split('T')[0],
        if (notaEval != null) 'notaeval': notaEval,
        if (ponderacionEval != null) 'ponderacioneval': ponderacionEval,
        if (estadoEval != null) 'estadoeval': estadoEval.value,
      };

      final response = await _supabase
          .from('examenes')
          .insert(examenData)
          .select('''
            *,
            materias (*)
          ''')
          .single();

      return _examenFromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Error al crear el examen: ${e.toString()}');
    }
  }

  // Actualizar un examen
  Future<Examen> updateExamen(
    String examenId, {
    TipoEvaluacion? tipoEval,
    DateTime? fechaEval,
    double? notaEval,
    double? ponderacionEval,
    EstadoEvaluacion? estadoEval,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      // Verificar que el examen pertenece a una materia del usuario
      final materiasIds = await _getMateriasIdsDelUsuario();
      if (materiasIds.isEmpty) {
        throw Exception('Examen no encontrado');
      }

      final updateData = <String, dynamic>{};
      if (tipoEval != null) updateData['tipoeval'] = tipoEval.value;
      if (fechaEval != null) updateData['fechaeval'] = fechaEval.toIso8601String().split('T')[0];
      if (notaEval != null) updateData['notaeval'] = notaEval;
      if (ponderacionEval != null) updateData['ponderacioneval'] = ponderacionEval;
      if (estadoEval != null) updateData['estadoeval'] = estadoEval.value;

      // Construir condición OR para verificar que pertenece a una de las materias del usuario
      final orCondition = materiasIds
          .map((id) => 'materiaid.eq.$id')
          .join(',');

      final response = await _supabase
          .from('examenes')
          .update(updateData)
          .eq('id', examenId)
          .or(orCondition)
          .select('''
            *,
            materias (*)
          ''')
          .single();

      return _examenFromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Error al actualizar el examen: ${e.toString()}');
    }
  }

  // Eliminar un examen
  Future<bool> deleteExamen(String examenId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      // Verificar que el examen pertenece a una materia del usuario
      final materiasIds = await _getMateriasIdsDelUsuario();
      if (materiasIds.isEmpty) {
        throw Exception('Examen no encontrado');
      }

      // Construir condición OR para verificar que pertenece a una de las materias del usuario
      final orCondition = materiasIds
          .map((id) => 'materiaid.eq.$id')
          .join(',');

      await _supabase
          .from('examenes')
          .delete()
          .eq('id', examenId)
          .or(orCondition);

      return true;
    } catch (e) {
      throw Exception('Error al eliminar el examen: ${e.toString()}');
    }
  }

  // Obtener estadísticas generales
  Future<EstadisticasExamenes> getEstadisticasGenerales() async {
    try {
      final examenes = await getExamenes();
      return _calcularEstadisticas(examenes);
    } catch (e) {
      throw Exception('Error al obtener estadísticas: ${e.toString()}');
    }
  }

  // Obtener estadísticas por materia
  Future<EstadisticasExamenes> getEstadisticasPorMateria(String materiaId) async {
    try {
      final examenes = await getExamenes(materiaId: materiaId);
      return _calcularEstadisticas(examenes);
    } catch (e) {
      throw Exception('Error al obtener estadísticas: ${e.toString()}');
    }
  }

  // Calcular estadísticas desde una lista de exámenes
  EstadisticasExamenes _calcularEstadisticas(List<Examen> examenes) {
    final total = examenes.length;
    final porEstado = <EstadoEvaluacion, int>{};
    final porTipo = <TipoEvaluacion, int>{};
    double sumaNotas = 0.0;
    int contarNotas = 0;
    double sumaPonderacion = 0.0;
    int contarPonderacion = 0;

    for (final examen in examenes) {
      // Contar por estado
      if (examen.estadoEval != null) {
        porEstado[examen.estadoEval!] = (porEstado[examen.estadoEval!] ?? 0) + 1;
      }

      // Contar por tipo
      if (examen.tipoEval != null) {
        porTipo[examen.tipoEval!] = (porTipo[examen.tipoEval!] ?? 0) + 1;
      }

      // Calcular promedios
      if (examen.notaEval != null) {
        sumaNotas += examen.notaEval!;
        contarNotas++;
      }

      if (examen.ponderacionEval != null) {
        sumaPonderacion += examen.ponderacionEval!;
        contarPonderacion++;
      }
    }

    return EstadisticasExamenes(
      total: total,
      porEstado: porEstado,
      porTipo: porTipo,
      promedioNotas: contarNotas > 0 ? sumaNotas / contarNotas : 0.0,
      promedioPonderacion: contarPonderacion > 0 ? sumaPonderacion / contarPonderacion : 0.0,
    );
  }

  // Mapear desde JSON de BD a modelo Examen
  // Usa Examen.fromJson que ya maneja correctamente los nombres de la BD
  Examen _examenFromJson(Map<String, dynamic> json) {
    return Examen.fromJson(json);
  }
}
