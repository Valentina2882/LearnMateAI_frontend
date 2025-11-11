import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/horario.dart';

class HorariosService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener todos los horarios del usuario
  Future<List<Horario>> getHorarios() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await _supabase
          .from('horarios')
          .select()
          .eq('usuario_id', user.id)
          .order('fechainiciosemestre', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((json) => Horario.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener horarios: ${e.toString()}');
    }
  }

  // Obtener un horario por ID
  Future<Horario> getHorarioById(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await _supabase
          .from('horarios')
          .select()
          .eq('id', id)
          .eq('usuario_id', user.id)
          .single();

      return Horario.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Error al obtener el horario: ${e.toString()}');
    }
  }

  // Crear un nuevo horario
  Future<Horario> createHorario({
    String? nombrehor,
    String? descripcionhor,
    String? fechainiciosemestre,
    String? fechafinsemestre,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      final horarioData = {
        'usuario_id': user.id,
        if (nombrehor != null) 'nombrehor': nombrehor,
        if (descripcionhor != null) 'descripcionhor': descripcionhor,
        if (fechainiciosemestre != null) 'fechainiciosemestre': fechainiciosemestre,
        if (fechafinsemestre != null) 'fechafinsemestre': fechafinsemestre,
      };

      final response = await _supabase
          .from('horarios')
          .insert(horarioData)
          .select()
          .single();

      return Horario.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Error al crear el horario: ${e.toString()}');
    }
  }

  // Actualizar un horario
  Future<Horario> updateHorario({
    required String id,
    String? nombrehor,
    String? descripcionhor,
    String? fechainiciosemestre,
    String? fechafinsemestre,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      final updateData = <String, dynamic>{};
      if (nombrehor != null) updateData['nombrehor'] = nombrehor;
      if (descripcionhor != null) updateData['descripcionhor'] = descripcionhor;
      if (fechainiciosemestre != null) updateData['fechainiciosemestre'] = fechainiciosemestre;
      if (fechafinsemestre != null) updateData['fechafinsemestre'] = fechafinsemestre;

      final response = await _supabase
          .from('horarios')
          .update(updateData)
          .eq('id', id)
          .eq('usuario_id', user.id)
          .select()
          .single();

      return Horario.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Error al actualizar el horario: ${e.toString()}');
    }
  }

  // Eliminar un horario
  Future<bool> deleteHorario(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      await _supabase
          .from('horarios')
          .delete()
          .eq('id', id)
          .eq('usuario_id', user.id);

      return true;
    } catch (e) {
      throw Exception('Error al eliminar el horario: ${e.toString()}');
    }
  }

}
