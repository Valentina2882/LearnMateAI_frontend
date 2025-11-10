import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/examen.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class ExamenesService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  ExamenesService() {
    print('🚀 [ExamenesService] Servicio inicializado - Base URL: $baseUrl');
  }

  // Obtener todos los exámenes con filtros opcionales
  Future<List<Examen>> getExamenes({
    String? materiaId,
    String? estadoEval,
    String? tipoEval,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      print('═══════════════════════════════════════════════════════════');
      print('[ExamenesService] Obteniendo exámenes con filtros:');
      print('[ExamenesService] - materiaId: $materiaId');
      print('[ExamenesService] - estadoEval: $estadoEval');
      print('[ExamenesService] - tipoEval: $tipoEval');
      print('[ExamenesService] - fechaInicio: $fechaInicio');
      print('[ExamenesService] - fechaFin: $fechaFin');

      final token = await _authService.getToken();
      if (token == null) {
        print('[ExamenesService] ❌ ERROR: No hay sesión activa');
        throw Exception('No hay sesión activa');
      }
      print('[ExamenesService] ✅ Token obtenido correctamente');

      // Construir query parameters
      final queryParams = <String, String>{};
      if (materiaId != null && materiaId.isNotEmpty) {
        queryParams['materiaId'] = materiaId;
      }
      if (estadoEval != null && estadoEval.isNotEmpty) {
        queryParams['estadoEval'] = estadoEval;
      }
      if (tipoEval != null && tipoEval.isNotEmpty) {
        queryParams['tipoEval'] = tipoEval;
      }
      if (fechaInicio != null && fechaInicio.isNotEmpty) {
        queryParams['fechaInicio'] = fechaInicio;
      }
      if (fechaFin != null && fechaFin.isNotEmpty) {
        queryParams['fechaFin'] = fechaFin;
      }

      final uri = Uri.parse('$baseUrl/examenes').replace(queryParameters: queryParams);
      print('[ExamenesService] 🌐 URL de petición: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('[ExamenesService] ⏱️ TIMEOUT: La petición tardó más de 10 segundos');
          throw Exception('Timeout: La petición tardó demasiado');
        },
      );

      print('[ExamenesService] 📊 Status code: ${response.statusCode}');
      final bodyPreview = response.body.length > 500 
          ? '${response.body.substring(0, 500)}...' 
          : response.body;
      print('[ExamenesService] 📦 Response body: $bodyPreview');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          final examenes = data.map((json) => Examen.fromJson(json)).toList();
          print('[ExamenesService] ✅ Exámenes obtenidos exitosamente: ${examenes.length} registros');
          print('═══════════════════════════════════════════════════════════');
          return examenes;
        } else {
          print('[ExamenesService] ❌ ERROR: Respuesta sin datos válidos');
          print('[ExamenesService] Response data: $responseData');
          throw Exception(responseData['message'] ?? 'Error al obtener exámenes');
        }
      } else {
        print('[ExamenesService] ❌ ERROR: Status code ${response.statusCode}');
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('[ExamenesService] Error data: $errorData');
        throw Exception(errorData['message'] ?? 'Error al obtener exámenes');
      }
    } catch (e, stackTrace) {
      print('[ExamenesService] ❌❌❌ ERROR en getExamenes: $e');
      print('[ExamenesService] Stack trace: $stackTrace');
      print('═══════════════════════════════════════════════════════════');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener exámenes por materia
  Future<List<Examen>> getExamenesPorMateria(String materiaId) async {
    return getExamenes(materiaId: materiaId);
  }

  // Obtener exámenes por estado
  Future<List<Examen>> getExamenesPorEstado(String estadoEval) async {
    return getExamenes(estadoEval: estadoEval);
  }

  // Obtener un examen específico
  Future<Examen> getExamen(String examenId) async {
    try {
      print('[ExamenesService] 🔍 Obteniendo examen: $examenId');
      final token = await _authService.getToken();
      if (token == null) {
        print('[ExamenesService] ❌ ERROR: No hay sesión activa');
        throw Exception('No hay sesión activa');
      }

      final uri = Uri.parse('$baseUrl/examenes/$examenId');
      print('[ExamenesService] 🌐 URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('[ExamenesService] 📊 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          print('[ExamenesService] ✅ Examen obtenido exitosamente');
          return Examen.fromJson(responseData['data']);
        } else {
          print('[ExamenesService] ❌ ERROR: Respuesta sin datos válidos');
          throw Exception(responseData['message'] ?? 'Examen no encontrado');
        }
      } else {
        print('[ExamenesService] ❌ ERROR: Status code ${response.statusCode}');
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('[ExamenesService] Error data: $errorData');
        throw Exception(errorData['message'] ?? 'Error al obtener el examen');
      }
    } catch (e, stackTrace) {
      print('[ExamenesService] ❌❌❌ ERROR en getExamen: $e');
      print('[ExamenesService] Stack trace: $stackTrace');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Crear un nuevo examen
  Future<Examen> createExamen({
    required String materiaId,
    TipoEvaluacion? tipoEval,
    DateTime? fechaEval,
    double? notaEval,
    double? ponderacionEval,
    EstadoEvaluacion? estadoEval,
  }) async {
    try {
      print('═══════════════════════════════════════════════════════════');
      print('[ExamenesService] ➕ Creando examen:');
      print('[ExamenesService] - materiaId: $materiaId');
      print('[ExamenesService] - tipoEval: $tipoEval');
      print('[ExamenesService] - fechaEval: $fechaEval');
      print('[ExamenesService] - notaEval: $notaEval');
      print('[ExamenesService] - ponderacionEval: $ponderacionEval');
      print('[ExamenesService] - estadoEval: $estadoEval');

      final token = await _authService.getToken();
      if (token == null) {
        print('[ExamenesService] ❌ ERROR: No hay sesión activa');
        throw Exception('No hay sesión activa');
      }

      final Map<String, dynamic> body = {
        'materiaId': materiaId,
      };

      if (tipoEval != null) body['tipoEval'] = tipoEval.value;
      if (fechaEval != null) body['fechaEval'] = fechaEval.toIso8601String().split('T')[0];
      if (notaEval != null) body['notaEval'] = notaEval;
      if (ponderacionEval != null) body['ponderacionEval'] = ponderacionEval;
      if (estadoEval != null) body['estadoEval'] = estadoEval.value;

      print('[ExamenesService] 📤 Body: ${json.encode(body)}');
      print('[ExamenesService] 🌐 URL: $baseUrl/examenes');

      final response = await http.post(
        Uri.parse('$baseUrl/examenes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('[ExamenesService] 📊 Status code: ${response.statusCode}');
      final bodyPreview = response.body.length > 500 
          ? '${response.body.substring(0, 500)}...' 
          : response.body;
      print('[ExamenesService] 📦 Response body: $bodyPreview');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          print('[ExamenesService] ✅ Examen creado exitosamente');
          print('═══════════════════════════════════════════════════════════');
          return Examen.fromJson(responseData['data']);
        } else {
          print('[ExamenesService] ❌ ERROR: Respuesta sin datos válidos');
          throw Exception(responseData['message'] ?? 'Error al crear el examen');
        }
      } else {
        print('[ExamenesService] ❌ ERROR: Status code ${response.statusCode}');
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('[ExamenesService] Error data: $errorData');
        throw Exception(errorData['message'] ?? 'Error al crear el examen');
      }
    } catch (e, stackTrace) {
      print('[ExamenesService] ❌❌❌ ERROR en createExamen: $e');
      print('[ExamenesService] Stack trace: $stackTrace');
      print('═══════════════════════════════════════════════════════════');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Actualizar un examen
  Future<Examen> updateExamen(
    String examenId, {
    TipoEvaluacion? tipoEval,
    DateTime? fechaEval,
    double? notaEval,
    double? ponderacionEval,
    EstadoEvaluacion? estadoEval,
  }) async {
    try {
      print('[ExamenesService] ✏️ Actualizando examen: $examenId');
      print('[ExamenesService] - tipoEval: $tipoEval');
      print('[ExamenesService] - fechaEval: $fechaEval');
      print('[ExamenesService] - notaEval: $notaEval');
      print('[ExamenesService] - ponderacionEval: $ponderacionEval');
      print('[ExamenesService] - estadoEval: $estadoEval');

      final token = await _authService.getToken();
      if (token == null) {
        print('[ExamenesService] ❌ ERROR: No hay sesión activa');
        throw Exception('No hay sesión activa');
      }

      final Map<String, dynamic> body = {};
      if (tipoEval != null) body['tipoEval'] = tipoEval.value;
      if (fechaEval != null) body['fechaEval'] = fechaEval.toIso8601String().split('T')[0];
      if (notaEval != null) body['notaEval'] = notaEval;
      if (ponderacionEval != null) body['ponderacionEval'] = ponderacionEval;
      if (estadoEval != null) body['estadoEval'] = estadoEval.value;

      print('[ExamenesService] 📤 Body: ${json.encode(body)}');
      print('[ExamenesService] 🌐 URL: $baseUrl/examenes/$examenId');

      final response = await http.patch(
        Uri.parse('$baseUrl/examenes/$examenId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('[ExamenesService] 📊 Status code: ${response.statusCode}');
      final bodyPreview = response.body.length > 500 
          ? '${response.body.substring(0, 500)}...' 
          : response.body;
      print('[ExamenesService] 📦 Response body: $bodyPreview');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          print('[ExamenesService] ✅ Examen actualizado exitosamente');
          return Examen.fromJson(responseData['data']);
        } else {
          print('[ExamenesService] ❌ ERROR: Respuesta sin datos válidos');
          throw Exception(responseData['message'] ?? 'Error al actualizar el examen');
        }
      } else {
        print('[ExamenesService] ❌ ERROR: Status code ${response.statusCode}');
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('[ExamenesService] Error data: $errorData');
        throw Exception(errorData['message'] ?? 'Error al actualizar el examen');
      }
    } catch (e, stackTrace) {
      print('[ExamenesService] ❌❌❌ ERROR en updateExamen: $e');
      print('[ExamenesService] Stack trace: $stackTrace');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Eliminar un examen
  Future<bool> deleteExamen(String examenId) async {
    try {
      print('[ExamenesService] 🗑️ Eliminando examen: $examenId');
      final token = await _authService.getToken();
      if (token == null) {
        print('[ExamenesService] ❌ ERROR: No hay sesión activa');
        throw Exception('No hay sesión activa');
      }

      print('[ExamenesService] 🌐 URL: $baseUrl/examenes/$examenId');

      final response = await http.delete(
        Uri.parse('$baseUrl/examenes/$examenId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('[ExamenesService] 📊 Status code: ${response.statusCode}');
      final bodyPreview = response.body.length > 500 
          ? '${response.body.substring(0, 500)}...' 
          : response.body;
      print('[ExamenesService] 📦 Response body: $bodyPreview');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final success = responseData['success'] == true;
        print('[ExamenesService] ✅ Examen eliminado: $success');
        return success;
      } else {
        print('[ExamenesService] ❌ ERROR: Status code ${response.statusCode}');
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('[ExamenesService] Error data: $errorData');
        throw Exception(errorData['message'] ?? 'Error al eliminar el examen');
      }
    } catch (e, stackTrace) {
      print('[ExamenesService] ❌❌❌ ERROR en deleteExamen: $e');
      print('[ExamenesService] Stack trace: $stackTrace');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener estadísticas generales
  Future<EstadisticasExamenes> getEstadisticasGenerales() async {
    try {
      print('[ExamenesService] 📈 Obteniendo estadísticas generales');
      final token = await _authService.getToken();
      if (token == null) {
        print('[ExamenesService] ❌ ERROR: No hay sesión activa');
        throw Exception('No hay sesión activa');
      }

      print('[ExamenesService] 🌐 URL: $baseUrl/examenes/estadisticas/generales');

      final response = await http.get(
        Uri.parse('$baseUrl/examenes/estadisticas/generales'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('[ExamenesService] 📊 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          print('[ExamenesService] ✅ Estadísticas obtenidas exitosamente');
          return EstadisticasExamenes.fromJson(responseData['data']);
        } else {
          print('[ExamenesService] ❌ ERROR: Respuesta sin datos válidos');
          throw Exception(responseData['message'] ?? 'Error al obtener estadísticas');
        }
      } else {
        print('[ExamenesService] ❌ ERROR: Status code ${response.statusCode}');
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('[ExamenesService] Error data: $errorData');
        throw Exception(errorData['message'] ?? 'Error al obtener estadísticas');
      }
    } catch (e, stackTrace) {
      print('[ExamenesService] ❌❌❌ ERROR en getEstadisticasGenerales: $e');
      print('[ExamenesService] Stack trace: $stackTrace');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener estadísticas por materia
  Future<EstadisticasExamenes> getEstadisticasPorMateria(String materiaId) async {
    try {
      print('[ExamenesService] 📈 Obteniendo estadísticas por materia: $materiaId');
      final token = await _authService.getToken();
      if (token == null) {
        print('[ExamenesService] ❌ ERROR: No hay sesión activa');
        throw Exception('No hay sesión activa');
      }

      final url = '$baseUrl/examenes/estadisticas/materia/$materiaId';
      print('[ExamenesService] 🌐 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('[ExamenesService] 📊 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          print('[ExamenesService] ✅ Estadísticas de materia obtenidas exitosamente');
          return EstadisticasExamenes.fromJson(responseData['data']);
        } else {
          print('[ExamenesService] ❌ ERROR: Respuesta sin datos válidos');
          throw Exception(responseData['message'] ?? 'Error al obtener estadísticas de la materia');
        }
      } else {
        print('[ExamenesService] ❌ ERROR: Status code ${response.statusCode}');
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('[ExamenesService] Error data: $errorData');
        throw Exception(errorData['message'] ?? 'Error al obtener estadísticas de la materia');
      }
    } catch (e, stackTrace) {
      print('[ExamenesService] ❌❌❌ ERROR en getEstadisticasPorMateria: $e');
      print('[ExamenesService] Stack trace: $stackTrace');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
