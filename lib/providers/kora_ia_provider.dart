import 'package:flutter/material.dart';
import '../models/kora_ia.dart';
import '../models/mensaje.dart';
import '../models/user.dart';
import '../services/chat_service.dart';

class KoraIAProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  // Mensajes del chat (usando MensajeKoraIA para la UI)
  List<MensajeKoraIA> _mensajesChat = [];
  
  // Estado de carga
  bool _isLoading = false;
  String? _error;
  
  // Tipo de IA (por defecto 'academica' para Kora Pro)
  String _tipoIA = 'academica';
  
  // ID del usuario actual
  String? _usuarioId;

  List<MensajeKoraIA> get mensajesChat => _mensajesChat;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get tipoIA => _tipoIA;

  /// Inicializar el provider con el usuario
  Future<void> inicializar(User? user) async {
    if (user == null) {
      _error = 'Usuario no autenticado';
      return;
    }

    _usuarioId = user.id;
    _tipoIA = 'academica'; // Kora Pro es académica

    // Cargar configuración del tipo de IA
    await _cargarConfiguracionIA();

    // Cargar mensajes desde Supabase
    await cargarMensajes();
  }

  /// Cargar configuración del tipo de IA desde Supabase
  Future<void> _cargarConfiguracionIA() async {
    try {
      final tipoIA = await _chatService.obtenerTipoIA(_tipoIA);
      if (tipoIA == null) {
        print('⚠️ [KoraIAProvider] Tipo de IA no encontrado: $_tipoIA');
      }
    } catch (e) {
      print('❌ [KoraIAProvider] Error al cargar configuración de IA: $e');
    }
  }

  /// Cargar mensajes desde Supabase
  Future<void> cargarMensajes() async {
    if (_usuarioId == null) {
      _error = 'Usuario no autenticado';
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // Obtener mensajes desde Supabase
      final mensajes = await _chatService.obtenerMensajes(
        usuarioId: _usuarioId!,
        tipoIA: _tipoIA,
      );

      // Convertir Mensaje (Supabase) a MensajeKoraIA (UI)
      _mensajesChat = mensajes.map((mensaje) => _convertirMensajeAKoraIA(mensaje)).toList();

      // Si no hay mensajes, cargar mensaje inicial
      if (_mensajesChat.isEmpty) {
        _cargarMensajeInicial();
      }

      notifyListeners();
    } catch (e) {
      _setError('Error al cargar mensajes: ${e.toString()}');
      print('❌ [KoraIAProvider] Error al cargar mensajes: $e');
      
      // Cargar mensaje inicial como fallback
      _cargarMensajeInicial();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar mensaje inicial del chat
  void _cargarMensajeInicial({bool profileCompleted = true}) {
    if (profileCompleted) {
      _mensajesChat = [
        MensajeKoraIA(
          id: 'msg_inicial',
          texto: '¡Hola! 👋 Soy Kora Pro, tu asistente de rendimiento académico ✨. Estoy aquí para ayudarte con hábitos de estudio 📚, productividad 💪, planificación 📅 y apoyo en tu carrera 🎓. ¿En qué puedo asistirte hoy? 😊',
          esUsuario: false,
          fecha: DateTime.now(),
          tipoMensaje: TipoMensaje.general,
        ),
      ];
    } else {
      _mensajesChat = [
        MensajeKoraIA(
          id: 'msg_inicial',
          texto: '¡Hola! 👋 Soy Kora Pro, tu asistente de rendimiento académico ✨.\n\nKora quiere conocerte un poquito más 💬 para hacer tu experiencia más personalizada y útil 🎯. ¿Te gustaría completar tu perfil? 😊',
          esUsuario: false,
          fecha: DateTime.now(),
          tipoMensaje: TipoMensaje.general,
        ),
      ];
    }
  }

  /// Recargar mensaje inicial basado en el estado del perfil
  void recargarMensajeInicial(bool profileCompleted) {
    // Si no hay mensajes en Supabase, mostrar mensaje inicial
    if (_mensajesChat.isEmpty) {
      _cargarMensajeInicial(profileCompleted: profileCompleted);
      notifyListeners();
    }
  }

  /// Enviar mensaje en el chat
  Future<void> enviarMensajeChat(String texto, {User? usuario}) async {
    if (texto.trim().isEmpty) return;
    if (_usuarioId == null) {
      _setError('Usuario no autenticado');
      return;
    }

    // Preparar información del usuario
    Map<String, dynamic>? informacionUsuario;
    if (usuario != null) {
      informacionUsuario = {
        'nombre': usuario.nombre,
        'apellido': usuario.apellido ?? '',
        'carrera': usuario.carrera ?? '',
        'semestre': usuario.semestre ?? 0,
      };
    }

    // Agregar mensaje del usuario a la UI inmediatamente
    final mensajeUsuarioUI = MensajeKoraIA(
      id: 'msg_temp_${DateTime.now().millisecondsSinceEpoch}',
      texto: texto,
      esUsuario: true,
      fecha: DateTime.now(),
    );
    _mensajesChat.add(mensajeUsuarioUI);
    _setLoading(true);
    notifyListeners();

    try {
      // Enviar mensaje usando ChatService (guarda en Supabase y obtiene respuesta de Gemini)
      final resultado = await _chatService.enviarMensaje(
        usuarioId: _usuarioId!,
        tipoIA: _tipoIA,
        mensajeUsuario: texto,
        informacionUsuario: informacionUsuario,
      );

      // Remover mensaje temporal del usuario
      _mensajesChat.removeLast();

      // Agregar mensaje del usuario desde Supabase
      final mensajeUsuario = _convertirMensajeAKoraIA(resultado['usuario']!);
      _mensajesChat.add(mensajeUsuario);

      // Agregar respuesta de la IA
      final mensajeIA = _convertirMensajeAKoraIA(resultado['ia']!);
      
      // Verificar que el mensaje no esté truncado
      print('📱 [KoraIAProvider] Mensaje de IA recibido: ${mensajeIA.texto.length} caracteres');
      if (mensajeIA.texto.length < 50) {
        print('⚠️ [KoraIAProvider] ADVERTENCIA: Mensaje muy corto, puede estar incompleto');
      }
      
      // Verificar truncamiento visual
      if (mensajeIA.texto.endsWith('...') || mensajeIA.texto.endsWith('…')) {
        print('⚠️ [KoraIAProvider] ADVERTENCIA: El mensaje termina con "...", puede estar truncado');
      }
      
      _mensajesChat.add(mensajeIA);

      _clearError();
    } catch (e) {
      // Remover mensaje temporal del usuario
      if (_mensajesChat.isNotEmpty && _mensajesChat.last.id.startsWith('msg_temp_')) {
        _mensajesChat.removeLast();
      }

      _setError('Error al enviar mensaje: ${e.toString()}');
      print('❌ [KoraIAProvider] Error al enviar mensaje: $e');

      // Mostrar mensaje de error
      final mensajeError = MensajeKoraIA(
        id: 'msg_error_${DateTime.now().millisecondsSinceEpoch}',
        texto: 'Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.',
        esUsuario: false,
        fecha: DateTime.now(),
        tipoMensaje: TipoMensaje.general,
      );
      _mensajesChat.add(mensajeError);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Convertir Mensaje (Supabase) a MensajeKoraIA (UI)
  MensajeKoraIA _convertirMensajeAKoraIA(Mensaje mensaje) {
    return MensajeKoraIA(
      id: mensaje.id,
      texto: mensaje.mensaje,
      esUsuario: mensaje.esUsuario,
      fecha: mensaje.createdAt,
      tipoMensaje: _detectarTipoMensaje(mensaje.mensaje),
    );
  }

  /// Detectar tipo de mensaje basado en el contenido
  TipoMensaje _detectarTipoMensaje(String mensaje) {
    final texto = mensaje.toLowerCase();
    
    if (texto.contains('estudiar') || texto.contains('examen') || texto.contains('materia') || 
        texto.contains('clase') || texto.contains('tarea') || texto.contains('proyecto') ||
        texto.contains('horario') || texto.contains('organizar')) {
      return TipoMensaje.academico;
    }
    
    if (texto.contains('motivación') || texto.contains('difícil') || texto.contains('desanimado') ||
        texto.contains('no puedo') || texto.contains('complicado') || texto.contains('estrés') ||
        texto.contains('ansiedad')) {
      return TipoMensaje.motivacional;
    }
    
    if (texto.contains('consejo') || texto.contains('recomendación') || texto.contains('sugerencia')) {
      return TipoMensaje.consejo;
    }
    
    if (texto.contains('información') || texto.contains('qué es') || texto.contains('cómo funciona')) {
      return TipoMensaje.informacion;
    }
    
    return TipoMensaje.general;
  }

  /// Limpiar mensajes del chat
  Future<void> limpiarChat() async {
    if (_usuarioId == null) {
      return;
    }

    _setLoading(true);
    try {
      // Eliminar mensajes de Supabase
      await _chatService.eliminarHistorial(
        usuarioId: _usuarioId!,
        tipoIA: _tipoIA,
      );

      // Limpiar mensajes locales
      _mensajesChat = [];
      _cargarMensajeInicial();

      _clearError();
    } catch (e) {
      _setError('Error al limpiar chat: ${e.toString()}');
      print('❌ [KoraIAProvider] Error al limpiar chat: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Métodos privados para manejar el estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
