import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Inicializar el estado de autenticación
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _user = await _authService.getStoredUser();
        if (_user == null) {
          _user = await _authService.getProfile();
        }
      }
    } catch (e) {
      _setError('Error al inicializar autenticación: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.login(email, password);
      
      if (response.success && response.user != null) {
        _user = response.user;
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Error en el login');
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Registro
  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    String? apellido,
    String? telefono,
    String? carrera,
    int? semestre,
    int? sistemaCalificacion,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.register(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        carrera: carrera,
        semestre: semestre,
        sistemaCalificacion: sistemaCalificacion,
      );
      
      if (response.success && response.user != null) {
        _user = response.user;
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Error en el registro');
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Error al cerrar sesión: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Completar perfil
  Future<bool> completeProfile({
    String? nombre,
    String? apellido,
    String? telefono,
    String? carrera,
    int? semestre,
    int? sistemaCalificacion,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.completeProfile(
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        carrera: carrera,
        semestre: semestre,
        sistemaCalificacion: sistemaCalificacion,
      );
      
      if (response.success && response.user != null) {
        _user = response.user;
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Error al completar el perfil');
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar perfil
  Future<bool> updateProfile({
    String? nombre,
    String? apellido,
    String? telefono,
    String? carrera,
    int? semestre,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.updateProfile(
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        carrera: carrera,
        semestre: semestre,
      );
      
      if (response.success && response.user != null) {
        _user = response.user;
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Error al actualizar el perfil');
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar perfil
  Future<bool> deleteProfile() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.deleteProfile();
      
      if (response.success) {
        _user = null;
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Error al eliminar el perfil');
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Actualizar usuario (útil después de completar perfil)
  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }
}
