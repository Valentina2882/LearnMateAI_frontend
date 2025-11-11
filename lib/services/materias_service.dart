import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/materia.dart';

class MateriasService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener todas las materias del usuario
  Future<List<Materia>> getMaterias() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await _supabase
          .from('materias')
          .select()
          .eq('usuario_id', user.id)
          .order('fechacreacion', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((json) => Materia.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener materias: ${e.toString()}');
    }
  }

  // Crear una nueva materia
  Future<Materia> createMateria({
    required String nombre,
    required String codigo,
    required int creditos,
    String? descripcion,
    String? profesor,
    String? aula,
    String? horario,
    String? color,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      final materiaData = <String, dynamic>{
        'nombre': nombre,
        'codigo': codigo,
        'creditos': creditos,
        'usuario_id': user.id,
        if (descripcion != null) 'descripcion': descripcion,
        if (profesor != null) 'profesor': profesor,
        if (aula != null) 'aula': aula,
        if (horario != null) 'horario': horario,
        'color': color ?? '#2196F3',
      };

      final response = await _supabase
          .from('materias')
          .insert(materiaData)
          .select()
          .single();

      return Materia.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Error al crear la materia: ${e.toString()}');
    }
  }

  // Actualizar una materia
  Future<Materia> updateMateria(
    String materiaId, {
    String? nombre,
    String? codigo,
    int? creditos,
    String? descripcion,
    String? profesor,
    String? aula,
    String? horario,
    String? color,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      final updateData = <String, dynamic>{
        'fechaactualizacion': DateTime.now().toIso8601String(),
      };

      if (nombre != null) updateData['nombre'] = nombre;
      if (codigo != null) updateData['codigo'] = codigo;
      if (creditos != null) updateData['creditos'] = creditos;
      if (descripcion != null) updateData['descripcion'] = descripcion;
      if (profesor != null) updateData['profesor'] = profesor;
      if (aula != null) updateData['aula'] = aula;
      if (horario != null) updateData['horario'] = horario;
      if (color != null) updateData['color'] = color;

      final response = await _supabase
          .from('materias')
          .update(updateData)
          .eq('id', materiaId)
          .eq('usuario_id', user.id) // Asegurar que solo actualiza sus propias materias
          .select()
          .single();

      return Materia.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Error al actualizar la materia: ${e.toString()}');
    }
  }

  // Eliminar una materia
  Future<void> deleteMateria(String materiaId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      await _supabase
          .from('materias')
          .delete()
          .eq('id', materiaId)
          .eq('usuario_id', user.id); // Asegurar que solo elimina sus propias materias
    } catch (e) {
      throw Exception('Error al eliminar la materia: ${e.toString()}');
    }
  }

}
