import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../config/api_config.dart';

class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/profile';
  static const String completeProfileEndpoint = '/auth/profile/complete';
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Login
  Future<AuthResponse> login(String email, String password) async {
    try {
      print('🔐 [AuthService] Intentando login');
      print('🔐 [AuthService] URL: $baseUrl$loginEndpoint');
      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(LoginRequest(
          email: email,
          password: password,
        ).toJson()),
      );

      print('🔐 [AuthService] Status code: ${response.statusCode}');
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        print('🔐 [AuthService] ✅ Login exitoso');
        final authResponse = AuthResponse.fromJson(data);
        
        if (authResponse.success && authResponse.token != null) {
          // Guardar token y datos del usuario
          await _saveAuthData(authResponse.token!, authResponse.user!);
        }
        
        return authResponse;
      } else {
        print('🔐 [AuthService] ❌ Login fallido: ${data['message']}');
        return AuthResponse(
          success: false,
          error: data['message'] ?? 'Error en el servidor',
        );
      }
    } catch (e, stackTrace) {
      print('🔐 [AuthService] ❌❌❌ ERROR en login: $e');
      print('🔐 [AuthService] Stack trace: $stackTrace');
      print('🔐 [AuthService] URL intentada: $baseUrl$loginEndpoint');
      return AuthResponse(
        success: false,
        error: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  // Registro
  Future<AuthResponse> register({
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
      print('🔐 [AuthService] Registrando usuario');
      
      // Solo enviar los campos básicos requeridos
      final body = <String, dynamic>{
        'email': email,
        'password': password,
        'nombre': nombre,
      };
      
      // Solo agregar campos opcionales si tienen valor
      if (apellido != null && apellido.isNotEmpty) body['apellido'] = apellido;
      if (telefono != null && telefono.isNotEmpty) body['telefono'] = telefono;
      if (carrera != null && carrera.isNotEmpty) body['carrera'] = carrera;
      if (semestre != null) body['semestre'] = semestre;
      if (sistemaCalificacion != null) body['sistemaCalificacion'] = sistemaCalificacion;
      
      final response = await http.post(
        Uri.parse('$baseUrl$registerEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(data);
        
        if (authResponse.success && authResponse.token != null) {
          await _saveAuthData(authResponse.token!, authResponse.user!);
        }
        
        return authResponse;
      } else {
        return AuthResponse(
          success: false,
          error: data['message'] ?? 'Error en el servidor',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        error: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  // Obtener perfil del usuario
  Future<User?> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl$profileEndpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Completar perfil del usuario
  Future<AuthResponse> completeProfile({
    String? nombre,
    String? apellido,
    String? telefono,
    String? carrera,
    int? semestre,
    int? sistemaCalificacion,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return AuthResponse(
          success: false,
          error: 'No hay sesión activa',
        );
      }

      // En completeProfile, todos los campos son obligatorios
      // Ya se validan en el frontend antes de llamar a este método
      final body = <String, dynamic>{
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'carrera': carrera,
        'semestre': semestre,
        'sistemaCalificacion': sistemaCalificacion,
      };

      final response = await http.patch(
        Uri.parse('$baseUrl$completeProfileEndpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(data);
        // Actualizar datos del usuario guardados
        await _saveAuthData(token, updatedUser);
        return AuthResponse(
          success: true,
          user: updatedUser,
        );
      } else {
        // Extraer el mensaje de error del backend
        String errorMessage = 'Error al completar el perfil';
        if (data.containsKey('message')) {
          errorMessage = data['message'];
        } else if (data.containsKey('error')) {
          errorMessage = data['error'];
        }
        return AuthResponse(
          success: false,
          error: errorMessage,
        );
      }
    } catch (e) {
      // Capturar errores de formato JSON o de conexión
      String errorMessage = 'Error de conexión: ${e.toString()}';
      
      // Si es un error de formato, intentar parsear el body de la respuesta
      if (e.toString().contains('FormatException') || e.toString().contains('Bad state')) {
        errorMessage = 'Error al procesar la respuesta del servidor';
      }
      
      return AuthResponse(
        success: false,
        error: errorMessage,
      );
    }
  }

  // Actualizar perfil del usuario
  Future<AuthResponse> updateProfile({
    String? nombre,
    String? apellido,
    String? telefono,
    String? carrera,
    int? semestre,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return AuthResponse(
          success: false,
          error: 'No hay sesión activa',
        );
      }

      final body = <String, dynamic>{};
      if (nombre != null && nombre.isNotEmpty) body['nombre'] = nombre;
      if (apellido != null && apellido.isNotEmpty) body['apellido'] = apellido;
      if (telefono != null && telefono.isNotEmpty) body['telefono'] = telefono;
      if (carrera != null && carrera.isNotEmpty) body['carrera'] = carrera;
      if (semestre != null) body['semestre'] = semestre;

      final response = await http.patch(
        Uri.parse('$baseUrl$profileEndpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(data);
        // Actualizar datos del usuario guardados
        await _saveAuthData(token, updatedUser);
        return AuthResponse(
          success: true,
          user: updatedUser,
        );
      } else {
        return AuthResponse(
          success: false,
          error: data['message'] ?? 'Error al actualizar el perfil',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        error: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Obtener token guardado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Obtener datos del usuario guardados
  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  // Eliminar perfil
  Future<AuthResponse> deleteProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return AuthResponse(
          success: false,
          error: 'No hay sesión activa',
        );
      }

      final response = await http.delete(
        Uri.parse('$baseUrl$profileEndpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Limpiar datos locales primero, antes de verificar la respuesta
      await logout();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return AuthResponse(
          success: data['success'] ?? true,
          message: data['message'] ?? 'Perfil eliminado exitosamente',
        );
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        return AuthResponse(
          success: false,
          error: data['message'] ?? 'Error al eliminar el perfil',
        );
      }
    } catch (e) {
      // Asegurar que siempre limpiamos los datos locales
      await logout();
      return AuthResponse(
        success: false,
        error: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Guardar datos de autenticación
  Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }
}
