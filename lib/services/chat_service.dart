import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mensaje.dart';
import '../models/tipo_ia.dart';
import '../services/gemini_service.dart';
import '../config/api_config.dart';

/// Servicio para gestionar el chat con las IAs
/// Integra Supabase (almacenamiento) con Gemini (generación de respuestas)
class ChatService {
  final GeminiService _geminiService;

  ChatService() : _geminiService = GeminiService();

  /// Obtener el cliente de Supabase de forma lazy
  SupabaseClient get _supabase {
    try {
      // Verificar si Supabase está inicializado
      if (!Supabase.instance.isInitialized) {
        throw Exception('Supabase no está inicializado. Configura las credenciales en lib/config/api_config.dart y asegúrate de inicializar Supabase en main.dart');
      }
      return Supabase.instance.client;
    } catch (e) {
      throw Exception('Error al acceder a Supabase: ${e.toString()}');
    }
  }

  /// Obtener el historial de mensajes para un usuario y tipo de IA
  Future<List<Mensaje>> obtenerMensajes({
    required String usuarioId,
    required String tipoIA,
    int? limite,
  }) async {
    try {
      var query = _supabase
          .from('mensajes')
          .select()
          .eq('usuario_id', usuarioId)
          .eq('tipo_ia', tipoIA)
          .order('created_at', ascending: true);

      if (limite != null) {
        query = query.limit(limite);
      }

      final response = await query;

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((json) => Mensaje.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [ChatService] Error al obtener mensajes: $e');
      rethrow;
    }
  }

  /// Guardar un mensaje en la base de datos
  Future<Mensaje> guardarMensaje({
    required String usuarioId,
    required String tipoIA,
    required String role, // 'user' o 'ia'
    required String mensaje,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final mensajeData = {
        'usuario_id': usuarioId,
        'tipo_ia': tipoIA,
        'role': role,
        'mensaje': mensaje,
        'metadata': metadata ?? {},
      };

      final response = await _supabase
          .from('mensajes')
          .insert(mensajeData)
          .select()
          .single();

      return Mensaje.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      print('❌ [ChatService] Error al guardar mensaje: $e');
      rethrow;
    }
  }

  /// Enviar un mensaje del usuario y obtener la respuesta de la IA
  /// 
  /// Este método:
  /// 1. Guarda el mensaje del usuario en Supabase
  /// 2. Obtiene el historial de mensajes
  /// 3. Genera la respuesta usando Gemini
  /// 4. Guarda la respuesta de la IA en Supabase
  /// 5. Retorna ambos mensajes
  Future<Map<String, Mensaje>> enviarMensaje({
    required String usuarioId,
    required String tipoIA,
    required String mensajeUsuario,
    Map<String, dynamic>? informacionUsuario,
    Map<String, dynamic>? metadataUsuario,
  }) async {
    try {
      // 1. Guardar el mensaje del usuario
      final mensajeUsuarioGuardado = await guardarMensaje(
        usuarioId: usuarioId,
        tipoIA: tipoIA,
        role: 'user',
        mensaje: mensajeUsuario,
        metadata: metadataUsuario,
      );

      // 2. Obtener el historial de mensajes (últimos 20 mensajes para contexto)
      final historial = await obtenerMensajes(
        usuarioId: usuarioId,
        tipoIA: tipoIA,
        limite: 20,
      );

      // 3. Generar la respuesta usando Gemini
      String respuestaIA;
      try {
        print('📤 [ChatService] Generando respuesta de IA...');
        respuestaIA = await _geminiService.generarRespuesta(
          tipoIA: tipoIA,
          mensajes: historial,
          mensajeUsuario: mensajeUsuario,
          informacionUsuario: informacionUsuario,
        );
        
        // Verificar que la respuesta no esté vacía o truncada
        print('📥 [ChatService] Respuesta recibida: ${respuestaIA.length} caracteres');
        if (respuestaIA.isEmpty) {
          throw Exception('La respuesta de la IA está vacía');
        }
        
        // Logging adicional para debugging
        if (respuestaIA.length < 100) {
          print('⚠️ [ChatService] ADVERTENCIA: Respuesta muy corta (${respuestaIA.length} caracteres)');
        }
      } catch (e) {
        print('❌ [ChatService] Error al generar respuesta de IA: $e');
        
        // Manejar error 429 (límite de cuota) con mensaje específico
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('429') || 
            errorString.contains('resource exhausted') ||
            errorString.contains('límite de solicitudes') ||
            errorString.contains('cuota')) {
          respuestaIA = '⚠️ Lo siento, hemos alcanzado el límite de solicitudes a la API de Gemini. '
              'Esto suele ser temporal. Por favor, intenta de nuevo en unos minutos. ⏰\n\n'
              'Si el problema persiste, puede ser que se haya excedido la cuota diaria. '
              'Verifica tu cuenta de Google Cloud Console. 💙';
        } else {
          // Respuesta de fallback genérica para otros errores
          respuestaIA = 'Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo en unos momentos. 💙';
        }
      }

      // 4. Guardar la respuesta de la IA
      final metadataIA = {
        'modelo': ApiConfig.geminiModel,
        'timestamp': DateTime.now().toIso8601String(),
        'longitud': respuestaIA.length, // Guardar longitud para verificación
      };

      print('💾 [ChatService] Guardando respuesta de IA (${respuestaIA.length} caracteres)...');
      final mensajeIAGuardado = await guardarMensaje(
        usuarioId: usuarioId,
        tipoIA: tipoIA,
        role: 'ia',
        mensaje: respuestaIA,
        metadata: metadataIA,
      );
      
      // Verificar que el mensaje se guardó correctamente
      print('✅ [ChatService] Mensaje de IA guardado. ID: ${mensajeIAGuardado.id}');
      print('✅ [ChatService] Mensaje guardado longitud: ${mensajeIAGuardado.mensaje.length} caracteres');
      
      // Verificar que el mensaje guardado coincide con el enviado
      if (mensajeIAGuardado.mensaje.length != respuestaIA.length) {
        print('⚠️ [ChatService] ADVERTENCIA: La longitud del mensaje guardado no coincide con la respuesta original');
        print('⚠️ [ChatService] Original: ${respuestaIA.length}, Guardado: ${mensajeIAGuardado.mensaje.length}');
      }

      // 5. Retornar ambos mensajes
      return {
        'usuario': mensajeUsuarioGuardado,
        'ia': mensajeIAGuardado,
      };
    } catch (e) {
      print('❌ [ChatService] Error al enviar mensaje: $e');
      rethrow;
    }
  }

  /// Obtener la configuración de un tipo de IA
  Future<TipoIA?> obtenerTipoIA(String codigo) async {
    try {
      final response = await _supabase
          .from('tipos_ia')
          .select()
          .eq('codigo', codigo)
          .eq('activo', true)
          .single();

      final tipoIA = TipoIA.fromJson(Map<String, dynamic>.from(response));
      
      // Configurar el prompt base en GeminiService
      _geminiService.configurarPromptBase(tipoIA);

      return tipoIA;
    } catch (e) {
      // Si no se encuentra el tipo de IA, retornar null
      print('⚠️ [ChatService] Tipo de IA no encontrado: $codigo');
      return null;
    }
  }

  /// Obtener todos los tipos de IA activos
  Future<List<TipoIA>> obtenerTiposIA() async {
    try {
      final response = await _supabase
          .from('tipos_ia')
          .select()
          .eq('activo', true)
          .order('orden', ascending: true);

      if (response.isEmpty) {
        return [];
      }

      final tiposIA = (response as List<dynamic>)
          .map((json) => TipoIA.fromJson(json as Map<String, dynamic>))
          .toList();

      // Configurar los prompts base en GeminiService
      for (final tipoIA in tiposIA) {
        _geminiService.configurarPromptBase(tipoIA);
      }

      return tiposIA;
    } catch (e) {
      print('❌ [ChatService] Error al obtener tipos de IA: $e');
      return [];
    }
  }

  /// Eliminar un mensaje
  Future<bool> eliminarMensaje(String mensajeId) async {
    try {
      await _supabase.from('mensajes').delete().eq('id', mensajeId);
      return true;
    } catch (e) {
      print('❌ [ChatService] Error al eliminar mensaje: $e');
      return false;
    }
  }

  /// Eliminar todos los mensajes de un tipo de IA para un usuario
  Future<bool> eliminarHistorial({
    required String usuarioId,
    required String tipoIA,
  }) async {
    try {
      await _supabase
          .from('mensajes')
          .delete()
          .eq('usuario_id', usuarioId)
          .eq('tipo_ia', tipoIA);
      return true;
    } catch (e) {
      print('❌ [ChatService] Error al eliminar historial: $e');
      return false;
    }
  }
}

