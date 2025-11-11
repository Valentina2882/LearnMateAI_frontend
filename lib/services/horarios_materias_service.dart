import 'package:supabase_flutter/supabase_flutter.dart';

class HorariosMaterialsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMateriasByHorario(String horarioId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No hay token de autenticación');

      // Verificar que el horario pertenece al usuario
      try {
        await _supabase
            .from('horarios')
            .select('id')
            .eq('id', horarioId)
            .eq('usuario_id', user.id)
            .single();
      } catch (e) {
        throw Exception('Horario no encontrado o no pertenece al usuario');
      }

      // Obtener materias del horario con información de la materia
      final response = await _supabase
          .from('horarios_materias')
          .select('''
            *,
            materias (*)
          ''')
          .eq('horario_id', horarioId)
          .order('dia', ascending: true)
          .order('hora_inicio', ascending: true);

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((json) => Map<String, dynamic>.from(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener materias: $e');
    }
  }

  Future<Map<String, dynamic>> createMateriaEnHorario({
    required String horarioId,
    required String materiaId,
    required String dia,
    required String horaInicio,
    required String horaFin,
    String? aula,
    String? notas,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No hay token de autenticación');

      // Verificar que el horario pertenece al usuario
      try {
        await _supabase
            .from('horarios')
            .select('id')
            .eq('id', horarioId)
            .eq('usuario_id', user.id)
            .single();
      } catch (e) {
        throw Exception('Horario no encontrado o no pertenece al usuario');
      }

      final materiaHorarioData = {
        'horario_id': horarioId,
        'materia_id': materiaId,
        'dia': dia,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
        if (aula != null) 'aula': aula,
        if (notas != null) 'notas': notas,
      };

      final response = await _supabase
          .from('horarios_materias')
          .insert(materiaHorarioData)
          .select('''
            *,
            materias (*)
          ''')
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Error al crear materia en horario: $e');
    }
  }

  Future<void> deleteMateriaDeHorario(String horarioId, String materiaHorarioId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No hay token de autenticación');

      // Verificar que el horario pertenece al usuario
      try {
        await _supabase
            .from('horarios')
            .select('id')
            .eq('id', horarioId)
            .eq('usuario_id', user.id)
            .single();
      } catch (e) {
        throw Exception('Horario no encontrado o no pertenece al usuario');
      }

      await _supabase
          .from('horarios_materias')
          .delete()
          .eq('id', materiaHorarioId)
          .eq('horario_id', horarioId);
    } catch (e) {
      print('DELETE Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateMateriaEnHorario({
    required String horarioId,
    required String materiaHorarioId,
    String? dia,
    String? horaInicio,
    String? horaFin,
    String? aula,
    String? notas,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No hay token de autenticación');

      // Verificar que el horario pertenece al usuario
      try {
        await _supabase
            .from('horarios')
            .select('id')
            .eq('id', horarioId)
            .eq('usuario_id', user.id)
            .single();
      } catch (e) {
        throw Exception('Horario no encontrado o no pertenece al usuario');
      }

      final updateData = <String, dynamic>{
        'fechaactualizacion': DateTime.now().toIso8601String(),
      };
      if (dia != null) updateData['dia'] = dia;
      if (horaInicio != null) updateData['hora_inicio'] = horaInicio;
      if (horaFin != null) updateData['hora_fin'] = horaFin;
      if (aula != null) updateData['aula'] = aula;
      if (notas != null) updateData['notas'] = notas;

      final response = await _supabase
          .from('horarios_materias')
          .update(updateData)
          .eq('id', materiaHorarioId)
          .eq('horario_id', horarioId)
          .select('''
            *,
            materias (*)
          ''')
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Error al actualizar materia: $e');
    }
  }
}
