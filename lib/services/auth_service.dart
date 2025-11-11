import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as models;
import '../models/auth_response.dart' as models;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener el usuario actual de Supabase Auth
  User? get currentUser => _supabase.auth.currentUser;

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    return _supabase.auth.currentUser != null;
  }

  // Obtener token (para compatibilidad con código existente)
  Future<String?> getToken() async {
    final session = _supabase.auth.currentSession;
    return session?.accessToken;
  }

  // Login con Supabase Auth
  Future<models.AuthResponse> login(String email, String password) async {
    try {
      print('🔐 [AuthService] Intentando login con Supabase');
      
      // Normalizar el email: trim y convertir a minúsculas
      final normalizedEmail = email.trim().toLowerCase();
      
      final response = await _supabase.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );

      if (response.user != null) {
        print('🔐 [AuthService] ✅ Login exitoso');
        
        // Obtener perfil del usuario desde la tabla usuarios
        final user = await getProfile();
        
        if (user != null) {
          return models.AuthResponse(
            success: true,
            token: response.session?.accessToken,
            user: user,
          );
        } else {
          // Si no tiene perfil, crear uno básico
          return models.AuthResponse(
            success: true,
            token: response.session?.accessToken,
            user: models.User(
              id: response.user!.id,
              email: response.user!.email ?? normalizedEmail,
              nombre: response.user!.userMetadata?['nombre'] ?? response.user!.email?.split('@')[0] ?? 'Usuario',
              apellido: response.user!.userMetadata?['apellido'],
              telefono: response.user!.userMetadata?['telefono'],
              carrera: response.user!.userMetadata?['carrera'],
              semestre: response.user!.userMetadata?['semestre'],
              sistemaCalificacion: response.user!.userMetadata?['sistemaCalificacion'] ?? 5,
              profileCompleted: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }
      } else {
        return models.AuthResponse(
          success: false,
          error: 'Error al iniciar sesión',
        );
      }
    } on AuthException catch (e) {
      print('🔐 [AuthService] ❌ Error de autenticación: ${e.message}');
      return models.AuthResponse(
        success: false,
        error: e.message,
      );
    } catch (e) {
      print('🔐 [AuthService] ❌❌❌ ERROR en login: $e');
      return models.AuthResponse(
        success: false,
        error: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  // Registro con Supabase Auth
  Future<models.AuthResponse> register({
    required String email,
    required String password,
    required String nombre,
    String? apellido,
    String? telefono,
    String? carrera,
    int? semestre,
    int? sistemaCalificacion,
  }) async {
    try {
      print('🔐 [AuthService] Registrando usuario con Supabase');
      
      // Normalizar el email: trim y convertir a minúsculas
      final normalizedEmail = email.trim().toLowerCase();
      print('🔐 [AuthService] Email original: "$email"');
      print('🔐 [AuthService] Email normalizado: "$normalizedEmail"');
      print('🔐 [AuthService] Longitud del email: ${normalizedEmail.length}');
      print('🔐 [AuthService] Bytes del email: ${normalizedEmail.codeUnits}');
      
      // Validar formato de email básico
      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalizedEmail)) {
        print('🔐 [AuthService] ❌ Validación local falló');
        return models.AuthResponse(
          success: false,
          error: 'El formato del email no es válido',
        );
      }
      
      print('🔐 [AuthService] ✅ Validación local pasada, intentando registro con Supabase...');
      
      // Registrar usuario en Supabase Auth
      // Nota: El metadata de Auth puede usar 'carrera', pero en la BD usamos 'carrerausu'
      final response = await _supabase.auth.signUp(
        email: normalizedEmail,
        password: password,
        data: {
          'nombre': nombre,
          if (apellido != null) 'apellido': apellido,
          if (telefono != null) 'telefono': telefono,
          if (carrera != null) 'carrera': carrera, // Metadata de Auth (puede usar 'carrera')
          if (semestre != null) 'semestre': semestre, // Metadata de Auth (puede usar 'semestre')
          if (sistemaCalificacion != null) 'sistemaCalificacion': sistemaCalificacion,
        },
      );

      if (response.user != null) {
        print('🔐 [AuthService] ✅ Usuario registrado en Auth');
        
        // Crear perfil en la tabla usuarios
        // IMPORTANTE: Usar solo los nombres de campos que existen en la BD
        final userData = {
          'id': response.user!.id,
          'email': normalizedEmail,
          'nombre': nombre,
          'nombreusu': nombre, // Campo requerido en BD
          'contrasenausu': '', // No almacenamos contraseña aquí, está en Auth
          if (apellido != null) 'apellido': apellido,
          if (telefono != null) 'telefono': telefono,
          if (carrera != null) 'carrerausu': carrera, // Solo carrerausu (no existe 'carrera' en BD)
          if (semestre != null) 'semestreusu': semestre, // Solo semestreusu (no existe 'semestre' en BD)
          if (sistemaCalificacion != null) 'sistemacalificacion': sistemaCalificacion,
          'profile_completed': false,
          'fechacreacion': DateTime.now().toIso8601String(),
          'fechaactualizacion': DateTime.now().toIso8601String(),
        };

        try {
          await _supabase
              .from('usuarios')
              .insert(userData);
        } catch (e) {
          print('🔐 [AuthService] ⚠️ Error al crear perfil: $e');
          // Continuar de todas formas, el usuario ya está registrado en Auth
        }

        final user = models.User(
          id: response.user!.id,
          email: normalizedEmail,
          nombre: nombre,
          apellido: apellido,
          telefono: telefono,
          carrera: carrera,
          semestre: semestre,
          sistemaCalificacion: sistemaCalificacion ?? 5,
          profileCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        return models.AuthResponse(
          success: true,
          token: response.session?.accessToken,
          user: user,
        );
      } else {
        return models.AuthResponse(
          success: false,
          error: 'Error al registrar usuario',
        );
      }
    } on AuthException catch (e) {
      print('🔐 [AuthService] ❌ Error de registro (AuthException):');
      print('   - Mensaje: ${e.message}');
      print('   - Tipo: ${e.runtimeType}');
      print('   - Error completo: $e');
      
      // Proporcionar mensajes de error más amigables
      String errorMessage = e.message;
      final lowerMessage = e.message.toLowerCase();
      
      // Verificar si el email ya existe (a veces Supabase dice "invalid" cuando ya existe)
      if (lowerMessage.contains('already registered') || 
          lowerMessage.contains('user already exists') ||
          lowerMessage.contains('already exists') ||
          lowerMessage.contains('email already registered')) {
        errorMessage = 'Este email ya está registrado. Intenta iniciar sesión en su lugar.';
      } else if (lowerMessage.contains('invalid') && 
                 lowerMessage.contains('email')) {
        // Error específico: email_address_invalid (código 400)
        // Causado por: SMTP predeterminado de Supabase solo permite emails a miembros del equipo
        errorMessage = 'No se pudo registrar el email.\n\n'
            '🔧 Soluciones (SIN configurar SMTP):\n\n'
            '1. DESHABILITAR confirmación de email:\n'
            '   Authentication > Settings > Desactiva "Enable email confirmations"\n\n'
            '2. Agregar email al equipo:\n'
            '   Settings > Team > Invite Member > Agrega este email\n\n'
            '💡 La opción 1 es la más rápida si no necesitas confirmación de email.';
      } else if (lowerMessage.contains('password')) {
        errorMessage = 'La contraseña no cumple con los requisitos. Debe tener al menos 6 caracteres.';
      } else if (lowerMessage.contains('rate limit') || lowerMessage.contains('too many')) {
        errorMessage = 'Demasiados intentos. Espera un momento e intenta de nuevo.';
      }
      
      return models.AuthResponse(
        success: false,
        error: errorMessage,
      );
    } catch (e, stackTrace) {
      print('🔐 [AuthService] ❌❌❌ ERROR en register: $e');
      print('🔐 [AuthService] Stack trace: $stackTrace');
      return models.AuthResponse(
        success: false,
        error: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  // Obtener perfil del usuario desde la tabla usuarios
  Future<models.User?> getProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('usuarios')
          .select()
          .eq('id', user.id)
          .single();

      final data = Map<String, dynamic>.from(response);
      // Usar User.fromJson que ya maneja correctamente los nombres de la BD
      return models.User.fromJson(data);
    } catch (e) {
      print('🔐 [AuthService] Error al obtener perfil: $e');
      return null;
    }
  }

  // Obtener datos del usuario guardados (para compatibilidad)
  Future<models.User?> getStoredUser() async {
    return getProfile();
  }

  // Completar perfil del usuario
  Future<models.AuthResponse> completeProfile({
    String? nombre,
    String? apellido,
    String? telefono,
    String? carrera,
    int? semestre,
    int? sistemaCalificacion,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return models.AuthResponse(
          success: false,
          error: 'No hay sesión activa',
        );
      }

      final updateData = <String, dynamic>{
        'fechaactualizacion': DateTime.now().toIso8601String(),
        'profile_completed': true,
      };

      if (nombre != null) {
        updateData['nombre'] = nombre;
        updateData['nombreusu'] = nombre;
      }
      if (apellido != null) updateData['apellido'] = apellido;
      if (telefono != null) updateData['telefono'] = telefono;
      if (carrera != null) {
        // Solo usar 'carrerausu' en la BD (no existe 'carrera' en la tabla usuarios)
        updateData['carrerausu'] = carrera;
      }
      if (semestre != null) {
        // Solo usar 'semestreusu' en la BD (no existe 'semestre' en la tabla usuarios)
        updateData['semestreusu'] = semestre;
      }
      if (sistemaCalificacion != null) {
        updateData['sistemacalificacion'] = sistemaCalificacion;
      }

      final response = await _supabase
          .from('usuarios')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      final data = Map<String, dynamic>.from(response);

      // Actualizar metadata del usuario en Auth
      // Nota: El metadata de Auth puede usar 'carrera' y 'semestre' (diferente de la BD)
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'nombre': nombre ?? data['nombre'],
            if (apellido != null) 'apellido': apellido,
            if (telefono != null) 'telefono': telefono,
            if (carrera != null) 'carrera': carrera, // Metadata de Auth (puede usar 'carrera')
            if (semestre != null) 'semestre': semestre, // Metadata de Auth (puede usar 'semestre')
            if (sistemaCalificacion != null) 'sistemaCalificacion': sistemaCalificacion,
          },
        ),
      );

      // Usar User.fromJson que ya maneja correctamente los nombres de la BD
      final updatedUser = models.User.fromJson(data);

      return models.AuthResponse(
        success: true,
        user: updatedUser,
      );
    } catch (e) {
      return models.AuthResponse(
        success: false,
        error: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  // Actualizar perfil del usuario
  Future<models.AuthResponse> updateProfile({
    String? nombre,
    String? apellido,
    String? telefono,
    String? carrera,
    int? semestre,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return models.AuthResponse(
          success: false,
          error: 'No hay sesión activa',
        );
      }

      final updateData = <String, dynamic>{
        'fechaactualizacion': DateTime.now().toIso8601String(),
      };

      if (nombre != null) {
        updateData['nombre'] = nombre;
        updateData['nombreusu'] = nombre;
      }
      if (apellido != null) updateData['apellido'] = apellido;
      if (telefono != null) updateData['telefono'] = telefono;
      if (carrera != null) {
        updateData['carrerausu'] = carrera; // Solo carrerausu (no existe 'carrera' en BD)
      }
      if (semestre != null) {
        updateData['semestreusu'] = semestre; // Solo semestreusu (no existe 'semestre' en BD)
      }

      final response = await _supabase
        .from('usuarios')
        .update(updateData)
        .eq('id', user.id)
        .select()
        .single();

      final data = Map<String, dynamic>.from(response);

      // Usar User.fromJson que ya maneja correctamente los nombres de la BD
      final updatedUser = models.User.fromJson(data);

      return models.AuthResponse(
        success: true,
        user: updatedUser,
      );
    } catch (e) {
      return models.AuthResponse(
        success: false,
        error: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  // Eliminar perfil
  Future<models.AuthResponse> deleteProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return models.AuthResponse(
          success: false,
          error: 'No hay sesión activa',
        );
      }

      // Eliminar perfil de la tabla usuarios
      // Nota: No podemos eliminar el usuario de Auth desde el cliente
      // Se debería hacer desde una función edge o marcar como eliminado
      try {
        await _supabase
            .from('usuarios')
            .delete()
            .eq('id', user.id);
      } catch (e) {
        print('⚠️ Error al eliminar perfil: $e');
      }

      // Cerrar sesión
      await logout();

      return models.AuthResponse(
        success: true,
        message: 'Perfil eliminado exitosamente',
      );
    } catch (e) {
      await logout(); // Asegurar que siempre cerramos sesión
      return models.AuthResponse(
        success: false,
        error: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
