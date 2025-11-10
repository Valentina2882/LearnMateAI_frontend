import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class HorariosMaterialsService {
  final AuthService _authService = AuthService();
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<Map<String, dynamic>>> getMateriasByHorario(String horarioId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No hay token de autenticación');

      final response = await http.get(
        Uri.parse('$baseUrl/horarios/$horarioId/materias'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener materias: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener materias: $e');
    }
  }

  Future<Map<String, dynamic>> createMateriaEnHorario({
    required String horarioId,
    required String materiaId,
    required String dia,
    required String horaInicio,
    required String horaFin,
    String? aula,
    String? notas,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No hay token de autenticación');

      final response = await http.post(
        Uri.parse('$baseUrl/horarios/$horarioId/materias'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'materia_id': materiaId,
          'dia': dia,
          'hora_inicio': horaInicio,
          'hora_fin': horaFin,
          'aula': aula,
          'notas': notas,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear materia en horario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear materia en horario: $e');
    }
  }

  Future<void> deleteMateriaDeHorario(String horarioId, String materiaHorarioId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No hay token de autenticación');

      print('DELETE - Attempting to delete materiaHorarioId: $materiaHorarioId from horarioId: $horarioId');

      final response = await http.delete(
        Uri.parse('$baseUrl/horarios/$horarioId/materias/$materiaHorarioId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('DELETE Response Status: ${response.statusCode}');
      print('DELETE Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('DELETE successful');
      } else {
        throw Exception('Error al eliminar materia: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DELETE Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateMateriaEnHorario({
    required String horarioId,
    required String materiaHorarioId,
    String? dia,
    String? horaInicio,
    String? horaFin,
    String? aula,
    String? notas,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No hay token de autenticación');

      final body = <String, dynamic>{};
      if (dia != null) body['dia'] = dia;
      if (horaInicio != null) body['hora_inicio'] = horaInicio;
      if (horaFin != null) body['hora_fin'] = horaFin;
      if (aula != null) body['aula'] = aula;
      if (notas != null) body['notas'] = notas;

      final response = await http.put(
        Uri.parse('$baseUrl/horarios/$horarioId/materias/$materiaHorarioId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al actualizar materia: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar materia: $e');
    }
  }
}

