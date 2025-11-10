import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/materia.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class MateriasService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  // Obtener todas las materias del usuario
  Future<List<Materia>> getMaterias() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/materias'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Materia.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al obtener materias');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Crear una nueva materia
  Future<Materia> createMateria({
    required String nombre,
    required String codigo,
    required int creditos,
    String? descripcion,
    String? profesor,
    String? aula,
    String? horario,
    String? color,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/materias'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nombre': nombre,
          'codigo': codigo,
          'creditos': creditos,
          'descripcion': descripcion,
          'profesor': profesor,
          'aula': aula,
          'horario': horario,
          'color': color ?? '#2196F3',
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Materia.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al crear la materia');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Actualizar una materia
  Future<Materia> updateMateria(
    String materiaId, {
    String? nombre,
    String? codigo,
    int? creditos,
    String? descripcion,
    String? profesor,
    String? aula,
    String? horario,
    String? color,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final Map<String, dynamic> body = {};
      if (nombre != null) body['nombre'] = nombre;
      if (codigo != null) body['codigo'] = codigo;
      if (creditos != null) body['creditos'] = creditos;
      if (descripcion != null) body['descripcion'] = descripcion;
      if (profesor != null) body['profesor'] = profesor;
      if (aula != null) body['aula'] = aula;
      if (horario != null) body['horario'] = horario;
      if (color != null) body['color'] = color;

      final response = await http.patch(
        Uri.parse('$baseUrl/materias/$materiaId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Materia.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al actualizar la materia');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Eliminar una materia
  Future<void> deleteMateria(String materiaId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/materias/$materiaId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al eliminar la materia');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
