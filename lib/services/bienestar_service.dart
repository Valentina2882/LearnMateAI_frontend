import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bienestar.dart';

class BienestarService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener resultados de cuestionarios
  Future<List<ResultadoCuestionario>> obtenerResultadosCuestionarios({
    TipoCuestionario? tipo,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      dynamic query = _supabase
          .from('resultados_cuestionarios_bienestar')
          .select()
          .eq('usuario_id', user.id);

      if (tipo != null) {
        query = query.eq('tipo', tipo.name);
      }

      query = query.order('fecha_completado', ascending: false);

      final response = await query;

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((json) => ResultadoCuestionario.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener resultados: ${e.toString()}');
    }
  }

  // Guardar resultado de cuestionario
  Future<ResultadoCuestionario> guardarResultadoCuestionario(
    ResultadoCuestionario resultado,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      final cuestionarioData = {
        'usuario_id': user.id,
        'tipo': resultado.tipo.name,
        'puntuacion_total': resultado.puntuacionTotal,
        'fecha_completado': resultado.fechaCompletado.toIso8601String(),
        if (resultado.interpretacion != null) 'interpretacion': resultado.interpretacion,
        'respuestas': resultado.respuestas,
      };

      final response = await _supabase
          .from('resultados_cuestionarios_bienestar')
          .insert(cuestionarioData)
          .select()
          .single();

      return ResultadoCuestionario.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Error al guardar resultado: ${e.toString()}');
    }
  }

  // Obtener contactos de emergencia
  Future<List<ContactoEmergencia>> obtenerContactosEmergencia() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await _supabase
          .from('contactos_emergencia')
          .select()
          .eq('usuario_id', user.id)
          .order('nombre', ascending: true);

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((json) => ContactoEmergencia.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener contactos: ${e.toString()}');
    }
  }

  // Crear contacto de emergencia
  Future<ContactoEmergencia> crearContactoEmergencia({
    required String nombre,
    required String telefono,
    String? descripcion,
    bool esNacional = false,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      final contactoData = {
        'usuario_id': user.id,
        'nombre': nombre,
        'telefono': telefono,
        if (descripcion != null) 'descripcion': descripcion,
        'es_nacional': esNacional,
      };

      final response = await _supabase
          .from('contactos_emergencia')
          .insert(contactoData)
          .select()
          .single();

      return ContactoEmergencia.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Error al crear contacto: ${e.toString()}');
    }
  }

  // Eliminar contacto de emergencia
  Future<void> eliminarContactoEmergencia(String contactoId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      await _supabase
          .from('contactos_emergencia')
          .delete()
          .eq('id', contactoId)
          .eq('usuario_id', user.id);
    } catch (e) {
      throw Exception('Error al eliminar contacto: ${e.toString()}');
    }
  }

  // Obtener estadísticas
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }

      // Obtener todos los resultados del usuario
      final resultados = await obtenerResultadosCuestionarios();

      // Calcular estadísticas
      final estadisticas = <String, dynamic>{
        'total': resultados.length,
        'porTipo': <String, int>{},
        'promedioPuntuacion': 0.0,
        'ultimaFecha': null,
      };

      if (resultados.isEmpty) {
        return estadisticas;
      }

      // Calcular por tipo
      int sumaPuntuaciones = 0;
      DateTime? ultimaFecha;

      for (final resultado in resultados) {
        // Contar por tipo
        final tipoStr = resultado.tipo.name;
        estadisticas['porTipo'][tipoStr] = (estadisticas['porTipo'][tipoStr] as int? ?? 0) + 1;

        // Sumar puntuaciones
        sumaPuntuaciones += resultado.puntuacionTotal;

        // Encontrar última fecha
        if (ultimaFecha == null || resultado.fechaCompletado.isAfter(ultimaFecha)) {
          ultimaFecha = resultado.fechaCompletado;
        }
      }

      estadisticas['promedioPuntuacion'] = sumaPuntuaciones / resultados.length;
      estadisticas['ultimaFecha'] = ultimaFecha?.toIso8601String();

      return estadisticas;
    } catch (e) {
      throw Exception('Error al obtener estadísticas: ${e.toString()}');
    }
  }

}
