import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/horario.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class HorariosService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  // Obtener todos los horarios del usuario
  Future<List<Horario>> getHorarios() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/horarios'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Horario.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al obtener horarios');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener un horario por ID
  Future<Horario> getHorarioById(String id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/horarios/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Horario.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al obtener el horario');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
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
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/horarios'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nombrehor': nombrehor,
          'descripcionhor': descripcionhor,
          'fechainiciosemestre': fechainiciosemestre,
          'fechafinsemestre': fechafinsemestre,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Horario.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al crear el horario');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
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
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final Map<String, dynamic> body = {};
      if (nombrehor != null) body['nombrehor'] = nombrehor;
      if (descripcionhor != null) body['descripcionhor'] = descripcionhor;
      if (fechainiciosemestre != null) body['fechainiciosemestre'] = fechainiciosemestre;
      if (fechafinsemestre != null) body['fechafinsemestre'] = fechafinsemestre;

      final response = await http.patch(
        Uri.parse('$baseUrl/horarios/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Horario.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al actualizar el horario');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Eliminar un horario
  Future<bool> deleteHorario(String id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/horarios/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al eliminar el horario');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
