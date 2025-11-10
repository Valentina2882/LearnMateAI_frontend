import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bienestar.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class BienestarService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  // Obtener resultados de cuestionarios
  Future<List<ResultadoCuestionario>> obtenerResultadosCuestionarios({
    TipoCuestionario? tipo,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final uri = tipo != null
          ? Uri.parse('$baseUrl/bienestar/cuestionarios').replace(
              queryParameters: {'tipo': tipo.name},
            )
          : Uri.parse('$baseUrl/bienestar/cuestionarios');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => ResultadoCuestionario.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Error al obtener resultados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Guardar resultado de cuestionario
  Future<ResultadoCuestionario> guardarResultadoCuestionario(
    ResultadoCuestionario resultado,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final body = {
        'tipo': resultado.tipo.name,
        'puntuacionTotal': resultado.puntuacionTotal,
        'fechaCompletado': resultado.fechaCompletado.toIso8601String(),
        'interpretacion': resultado.interpretacion,
        'respuestas': resultado.respuestas,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/bienestar/cuestionarios'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return ResultadoCuestionario.fromJson(responseData['data']);
        }
        throw Exception('Error al guardar resultado');
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al guardar resultado');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener contactos de emergencia
  Future<List<ContactoEmergencia>> obtenerContactosEmergencia() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/bienestar/contactos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => ContactoEmergencia.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Error al obtener contactos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
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
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final body = {
        'nombre': nombre,
        'telefono': telefono,
        if (descripcion != null) 'descripcion': descripcion,
        'esNacional': esNacional,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/bienestar/contactos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return ContactoEmergencia.fromJson(responseData['data']);
        }
        throw Exception('Error al crear contacto');
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al crear contacto');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Eliminar contacto de emergencia
  Future<void> eliminarContactoEmergencia(String contactoId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/bienestar/contactos/$contactoId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al eliminar contacto');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener estadísticas
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/bienestar/cuestionarios/estadisticas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        }
        return {};
      } else {
        throw Exception('Error al obtener estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}

