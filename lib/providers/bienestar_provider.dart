import 'package:flutter/material.dart';
import '../models/bienestar.dart';
import '../models/user.dart';
import '../services/bienestar_service.dart';
import '../services/chat_service.dart';

class BienestarProvider extends ChangeNotifier {
  final BienestarService _bienestarService = BienestarService();
  final ChatService _chatService = ChatService();
  
  // Lista de contactos de emergencia
  List<ContactoEmergencia> _contactosEmergencia = [];
  
  // Lista de resultados de cuestionarios
  List<ResultadoCuestionario> _resultadosCuestionarios = [];
  
  // Estadísticas
  Map<String, dynamic>? _estadisticas;
  
  // Emoción seleccionada hoy (ahora será un valor numérico de 0-10)
  double _emocionActual = 5.0; // Valor por defecto: neutral (5.0)
  
  // Mensajes del chat
  List<MensajeChat> _mensajesChat = [];
  
  // Estado de carga
  bool _isLoading = false;
  String? _error;
  
  // ID del usuario actual
  String? _usuarioId;
  
  // Tipo de IA para bienestar emocional
  final String _tipoIA = 'emocional';

  /// Getter que siempre incluye contactos nacionales por defecto
  List<ContactoEmergencia> get contactosEmergencia {
    // Obtener contactos nacionales por defecto
    final contactosNacionales = _obtenerContactosNacionalesPorDefecto();
    final contactosNacionalesIds = contactosNacionales.map((c) => c.id).toSet();
    final contactosNacionalesTelefonos = contactosNacionales.map((c) => c.telefono).toSet();
    
    // Filtrar contactos actuales para evitar duplicados
    final contactosSinDuplicados = _contactosEmergencia.where((c) {
      if (c.esNacional) {
        // Si es nacional, solo incluir si no está en los por defecto
        return !contactosNacionalesIds.contains(c.id) && 
               !contactosNacionalesTelefonos.contains(c.telefono);
      }
      return true; // Siempre incluir contactos no nacionales
    }).toList();
    
    // Combinar: contactos nacionales por defecto (siempre primero) + contactos sin duplicados
    return [
      ...contactosNacionales,
      ...contactosSinDuplicados,
    ];
  }
  List<ResultadoCuestionario> get resultadosCuestionarios => _resultadosCuestionarios;
  Map<String, dynamic>? get estadisticas => _estadisticas;
  double get emocionActual {
    // Asegurar que siempre retornemos un valor válido (0-10)
    // Si por alguna razón es null (aunque no debería ser), retornamos el valor por defecto
    final valor = _emocionActual;
    if (valor.isNaN || valor.isInfinite) {
      return 5.0;
    }
    return valor.clamp(0.0, 10.0);
  }
  List<MensajeChat> get mensajesChat => _mensajesChat;
  bool get isLoading => _isLoading;
  String? get error => _error;

  BienestarProvider() {
    // Inicializar con contactos nacionales por defecto (siempre disponibles)
    _contactosEmergencia = _obtenerContactosNacionalesPorDefecto();
    _cargarMensajeInicialChat();
  }
  
  /// Inicializar el provider con el usuario
  Future<void> inicializar(User? user) async {
    if (user == null) {
      _error = 'Usuario no autenticado';
      return;
    }

    _usuarioId = user.id;

    // Cargar configuración del tipo de IA
    await _cargarConfiguracionIA();
    
    // Cargar mensajes desde Supabase
    await cargarMensajesChat();
  }
  
  /// Cargar configuración del tipo de IA desde Supabase
  Future<void> _cargarConfiguracionIA() async {
    try {
      final tipoIA = await _chatService.obtenerTipoIA(_tipoIA);
      if (tipoIA == null) {
        print('⚠️ [BienestarProvider] Tipo de IA no encontrado: $_tipoIA');
      }
    } catch (e) {
      print('❌ [BienestarProvider] Error al cargar configuración de IA: $e');
    }
  }
  
  /// Cargar mensajes desde Supabase
  Future<void> cargarMensajesChat() async {
    if (_usuarioId == null) {
      _error = 'Usuario no autenticado';
      return;
    }

    _setLoading(true);
    _clearError();
    try {
      final mensajes = await _chatService.obtenerMensajes(
        usuarioId: _usuarioId!,
        tipoIA: _tipoIA,
      );

      // Convertir Mensaje (Supabase) a MensajeChat (UI)
      _mensajesChat = mensajes.map((mensaje) => _convertirMensajeAMensajeChat(mensaje)).toList();

      // Si no hay mensajes, cargar mensaje inicial
      if (_mensajesChat.isEmpty) {
        _cargarMensajeInicialChat();
      }

      notifyListeners();
    } catch (e) {
      _setError('Error al cargar mensajes: ${e.toString()}');
      print('❌ [BienestarProvider] Error al cargar mensajes: $e');
      
      // Cargar mensaje inicial como fallback
      _cargarMensajeInicialChat();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Convertir Mensaje (Supabase) a MensajeChat (UI)
  MensajeChat _convertirMensajeAMensajeChat(dynamic mensaje) {
    return MensajeChat(
      id: mensaje.id ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
      texto: mensaje.mensaje ?? '',
      esUsuario: mensaje.role == 'user',
      fecha: mensaje.createdAt ?? DateTime.now(),
    );
  }

  // Cargar datos desde el backend
  Future<void> cargarDatos() async {
    // Asegurar que los contactos nacionales estén siempre inicializados
    if (_contactosEmergencia.isEmpty || 
        !_contactosEmergencia.any((c) => c.esNacional)) {
      _contactosEmergencia = _obtenerContactosNacionalesPorDefecto();
      notifyListeners();
    }
    
    await Future.wait([
      cargarContactosEmergencia(),
      cargarResultadosCuestionarios(),
      cargarEstadisticas(),
    ]);
  }

  // Cargar contactos de emergencia desde el backend
  Future<void> cargarContactosEmergencia() async {
    _setLoading(true);
    _clearError();
    try {
      final contactosBackend = await _bienestarService.obtenerContactosEmergencia();
      
      // Obtener contactos nacionales por defecto
      final contactosNacionales = _obtenerContactosNacionalesPorDefecto();
      
      // Filtrar contactos nacionales que ya vienen del backend (para evitar duplicados)
      final contactosNacionalesIds = contactosNacionales.map((c) => c.id).toSet();
      final contactosNacionalesTelefonos = contactosNacionales.map((c) => c.telefono).toSet();
      
      // Combinar: contactos nacionales por defecto + contactos del backend
      // Los contactos nacionales por defecto siempre tienen prioridad
      _contactosEmergencia = [
        // Primero los contactos nacionales por defecto (siempre deben estar)
        ...contactosNacionales,
        // Luego los contactos del backend que:
        // 1. No sean nacionales, O
        // 2. Sean nacionales pero no estén en los por defecto (por ID o teléfono)
        ...contactosBackend.where((c) {
          if (!c.esNacional) return true; // Siempre incluir contactos no nacionales
          // Si es nacional, solo incluir si no está en los por defecto
          return !contactosNacionalesIds.contains(c.id) && 
                 !contactosNacionalesTelefonos.contains(c.telefono);
        }),
      ];
      
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar contactos: ${e.toString()}');
      // Si falla, usar solo contactos nacionales por defecto
      _contactosEmergencia = _obtenerContactosNacionalesPorDefecto();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Cargar resultados de cuestionarios desde el backend
  Future<void> cargarResultadosCuestionarios() async {
    _setLoading(true);
    _clearError();
    try {
      _resultadosCuestionarios = await _bienestarService.obtenerResultadosCuestionarios();
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar resultados: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Cargar estadísticas desde el backend
  Future<void> cargarEstadisticas() async {
    try {
      _estadisticas = await _bienestarService.obtenerEstadisticas();
      notifyListeners();
    } catch (e) {
      print('Error al cargar estadísticas: ${e.toString()}');
    }
  }

  // Verificar si el usuario ha completado los cuestionarios este mes
  Map<TipoCuestionario, bool> getCuestionariosCompletadosEsteMes() {
    if (_estadisticas == null) {
      return {
        TipoCuestionario.phq9: false,
        TipoCuestionario.gad7: false,
        TipoCuestionario.isi: false,
      };
    }

    final completadosEsteMes = _estadisticas!['completadosEsteMes'] as Map<String, dynamic>?;
    if (completadosEsteMes == null) {
      return {
        TipoCuestionario.phq9: false,
        TipoCuestionario.gad7: false,
        TipoCuestionario.isi: false,
      };
    }

    return {
      TipoCuestionario.phq9: completadosEsteMes['phq9'] == true,
      TipoCuestionario.gad7: completadosEsteMes['gad7'] == true,
      TipoCuestionario.isi: completadosEsteMes['isi'] == true,
    };
  }

  /// Obtener contactos nacionales por defecto (siempre disponibles)
  List<ContactoEmergencia> _obtenerContactosNacionalesPorDefecto() {
    return [
      ContactoEmergencia(
        id: 'emergencia_123',
        nombre: 'Emergencias 123',
        telefono: '123',
        descripcion: 'Línea de emergencias 123 (Colombia)',
        esNacional: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ContactoEmergencia(
        id: 'emergencia_911',
        nombre: 'Emergencias 911',
        telefono: '911',
        descripcion: 'Línea de emergencias 911',
        esNacional: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ContactoEmergencia(
        id: 'emergencia_106',
        nombre: 'Línea de Prevención del Suicidio',
        telefono: '106',
        descripcion: 'Línea Nacional de Prevención del Suicidio 24/7 (Colombia)',
        esNacional: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ContactoEmergencia(
        id: 'emergencia_vida',
        nombre: 'Línea de Vida',
        telefono: '01 800 911 2000',
        descripcion: 'Atención psicológica 24/7',
        esNacional: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Cargar mensaje inicial del chat
  void _cargarMensajeInicialChat() {
    _mensajesChat = [
      MensajeChat(
        id: 'msg_001',
        texto: '¡Hola! 👋 Soy tu asistente de bienestar 💙. ¿Cómo te sientes hoy? 😊 Estoy aquí para escucharte y ayudarte en lo que necesites ✨. ¿Hay algo en lo que pueda asistirte? 💬',
        esUsuario: false,
        fecha: DateTime.now(),
      ),
    ];
  }

  // Agregar contacto de emergencia
  Future<bool> agregarContactoEmergencia({
    required String nombre,
    required String telefono,
    String? descripcion,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final nuevoContacto = await _bienestarService.crearContactoEmergencia(
        nombre: nombre,
        telefono: telefono,
        descripcion: descripcion,
        esNacional: false,
      );
      _contactosEmergencia.add(nuevoContacto);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al agregar contacto: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar contacto de emergencia (solo los no nacionales)
  Future<bool> eliminarContactoEmergencia(String id) async {
    try {
      // Verificar si es un contacto nacional por defecto
      final contactosNacionales = _obtenerContactosNacionalesPorDefecto();
      final esContactoNacional = contactosNacionales.any((c) => c.id == id);
      
      if (esContactoNacional) {
        _setError('No se pueden eliminar contactos nacionales');
        return false;
      }
      
      // Buscar el contacto en la lista actual
      final contacto = _contactosEmergencia.firstWhere(
        (c) => c.id == id,
        orElse: () => ContactoEmergencia(
          id: '',
          nombre: '',
          telefono: '',
          esNacional: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      if (contacto.id.isEmpty) {
        _setError('Contacto no encontrado');
        return false;
      }
      
      if (contacto.esNacional) {
        _setError('No se pueden eliminar contactos nacionales');
        return false;
      }
      
      await _bienestarService.eliminarContactoEmergencia(id);
      _contactosEmergencia.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al eliminar contacto: ${e.toString()}');
      return false;
    }
  }

  // Guardar resultado de cuestionario
  Future<bool> guardarResultadoCuestionario(ResultadoCuestionario resultado) async {
    _setLoading(true);
    _clearError();
    try {
      final resultadoGuardado = await _bienestarService.guardarResultadoCuestionario(resultado);
      _resultadosCuestionarios.add(resultadoGuardado);
      // Recargar estadísticas después de guardar
      await cargarEstadisticas();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al guardar resultado: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Establecer emoción actual (ahora es un valor numérico de 0-10)
  void setEmocionActual(double valor) {
    _emocionActual = valor.clamp(0.0, 10.0);
    notifyListeners();
  }

  // Enviar mensaje en el chat
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
    final mensajeUsuarioUI = MensajeChat(
      id: 'msg_temp_${DateTime.now().millisecondsSinceEpoch}',
      texto: texto,
      esUsuario: true,
      fecha: DateTime.now(),
    );
    _mensajesChat.add(mensajeUsuarioUI);
    _setLoading(true);
    notifyListeners();

    try {
      print('📤 [BienestarProvider] Enviando mensaje: "$texto"');
      print('📤 [BienestarProvider] Tipo IA: $_tipoIA');
      print('📤 [BienestarProvider] Usuario ID: $_usuarioId');
      
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
      final mensajeUsuario = _convertirMensajeAMensajeChat(resultado['usuario']!);
      _mensajesChat.add(mensajeUsuario);

      // Agregar respuesta de la IA
      final mensajeIA = _convertirMensajeAMensajeChat(resultado['ia']!);
      _mensajesChat.add(mensajeIA);

      _clearError();
    } catch (e) {
      // Remover mensaje temporal del usuario
      if (_mensajesChat.isNotEmpty && _mensajesChat.last.id.startsWith('msg_temp_')) {
        _mensajesChat.removeLast();
      }
      _setError('Error al enviar mensaje: ${e.toString()}');
      print('❌ [BienestarProvider] Error al enviar mensaje: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
  
  // Limpiar mensajes del chat
  Future<void> limpiarChat() async {
    if (_usuarioId == null) {
      // Si no hay usuario, solo limpiar localmente
      _mensajesChat = [];
      _cargarMensajeInicialChat();
      notifyListeners();
      return;
    }
    
    try {
      await _chatService.eliminarHistorial(
        usuarioId: _usuarioId!,
        tipoIA: _tipoIA,
      );
      _mensajesChat = [];
      _cargarMensajeInicialChat();
      notifyListeners();
    } catch (e) {
      print('❌ [BienestarProvider] Error al limpiar chat: $e');
      _setError('Error al limpiar chat: ${e.toString()}');
    }
  }

  // Métodos privados
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Obtener resultados de un cuestionario específico
  List<ResultadoCuestionario> obtenerResultadosPorTipo(TipoCuestionario tipo) {
    return _resultadosCuestionarios
        .where((r) => r.tipo == tipo)
        .toList();
  }

  // Obtener último resultado de un cuestionario
  ResultadoCuestionario? obtenerUltimoResultado(TipoCuestionario tipo) {
    final resultados = obtenerResultadosPorTipo(tipo);
    if (resultados.isEmpty) return null;
    resultados.sort((a, b) => b.fechaCompletado.compareTo(a.fechaCompletado));
    return resultados.first;
  }
}

