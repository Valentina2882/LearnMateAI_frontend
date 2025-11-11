import 'package:flutter/material.dart';
import 'materia.dart';

enum TipoEvaluacion {
  parcial,
  finalExam,
  quiz,
  tarea,
  proyecto,
  laboratorio,
  practica,
  examenOral,
  presentacion;

  String get value {
    switch (this) {
      case TipoEvaluacion.parcial:
        return 'Parcial';
      case TipoEvaluacion.finalExam:
        return 'Final';
      case TipoEvaluacion.quiz:
        return 'Quiz';
      case TipoEvaluacion.tarea:
        return 'Tarea';
      case TipoEvaluacion.proyecto:
        return 'Proyecto';
      case TipoEvaluacion.laboratorio:
        return 'Laboratorio';
      case TipoEvaluacion.practica:
        return 'Práctica';
      case TipoEvaluacion.examenOral:
        return 'Examen Oral';
      case TipoEvaluacion.presentacion:
        return 'Presentación';
    }
  }

  static TipoEvaluacion fromString(String value) {
    switch (value) {
      case 'Parcial':
        return TipoEvaluacion.parcial;
      case 'Final':
        return TipoEvaluacion.finalExam;
      case 'Quiz':
        return TipoEvaluacion.quiz;
      case 'Tarea':
        return TipoEvaluacion.tarea;
      case 'Proyecto':
        return TipoEvaluacion.proyecto;
      case 'Laboratorio':
        return TipoEvaluacion.laboratorio;
      case 'Práctica':
        return TipoEvaluacion.practica;
      case 'Examen Oral':
        return TipoEvaluacion.examenOral;
      case 'Presentación':
        return TipoEvaluacion.presentacion;
      default:
        return TipoEvaluacion.parcial;
    }
  }
}

enum EstadoEvaluacion {
  proximos,
  pendientesACalificar,
  calificados;

  String get value {
    switch (this) {
      case EstadoEvaluacion.proximos:
        return 'Próximos';
      case EstadoEvaluacion.pendientesACalificar:
        return 'Pendientes a Calificar';
      case EstadoEvaluacion.calificados:
        return 'Calificados';
    }
  }

  static EstadoEvaluacion fromString(String value) {
    switch (value) {
      case 'Próximos':
        return EstadoEvaluacion.proximos;
      case 'Pendientes a Calificar':
        return EstadoEvaluacion.pendientesACalificar;
      case 'Calificados':
        return EstadoEvaluacion.calificados;
      default:
        return EstadoEvaluacion.proximos;
    }
  }

  Color get color {
    switch (this) {
      case EstadoEvaluacion.proximos:
        return Colors.blue;
      case EstadoEvaluacion.pendientesACalificar:
        return Colors.orange;
      case EstadoEvaluacion.calificados:
        return Colors.green;
    }
  }

  IconData get icon {
    switch (this) {
      case EstadoEvaluacion.proximos:
        return Icons.event;
      case EstadoEvaluacion.pendientesACalificar:
        return Icons.pending_actions;
      case EstadoEvaluacion.calificados:
        return Icons.grade;
    }
  }
}

class Examen {
  final String id;
  final TipoEvaluacion? tipoEval;
  final String materiaId;
  final DateTime? fechaEval;
  final double? notaEval;
  final double? ponderacionEval;
  final EstadoEvaluacion? estadoEval;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Materia? materia; // Información de la materia relacionada

  Examen({
    required this.id,
    this.tipoEval,
    required this.materiaId,
    this.fechaEval,
    this.notaEval,
    this.ponderacionEval,
    this.estadoEval,
    required this.createdAt,
    required this.updatedAt,
    this.materia,
  });

  factory Examen.fromJson(Map<String, dynamic> json) {
    // Mapear desde los nombres de la base de datos
    // La BD usa: materiaid, tipoeval, fechaeval, notaeval, ponderacioneval, estadoeval
    final materiaData = json['materias'] ?? json['materia'];
    
    return Examen(
      id: json['id'] ?? '',
      tipoEval: json['tipoeval'] != null 
          ? TipoEvaluacion.fromString(json['tipoeval']) 
          : json['tipoEval'] != null 
              ? TipoEvaluacion.fromString(json['tipoEval']) 
              : null,
      materiaId: json['materiaid'] ?? json['materiaId'] ?? '',
      fechaEval: json['fechaeval'] != null 
          ? DateTime.parse(json['fechaeval'])
          : json['fechaEval'] != null 
              ? DateTime.parse(json['fechaEval']) 
              : null,
      notaEval: json['notaeval']?.toDouble() ?? json['notaEval']?.toDouble(),
      ponderacionEval: json['ponderacioneval']?.toDouble() ?? json['ponderacionEval']?.toDouble(),
      estadoEval: json['estadoeval'] != null 
          ? EstadoEvaluacion.fromString(json['estadoeval']) 
          : json['estadoEval'] != null 
              ? EstadoEvaluacion.fromString(json['estadoEval']) 
              : null,
      createdAt: DateTime.now(), // La tabla examenes no tiene created_at
      updatedAt: DateTime.now(), // La tabla examenes no tiene updated_at
      materia: materiaData != null 
          ? Materia.fromJson(materiaData is Map<String, dynamic> 
              ? materiaData 
              : Map<String, dynamic>.from(materiaData))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Convertir a los nombres de la base de datos
    return {
      'id': id,
      'tipoeval': tipoEval?.value, // Nombre de BD
      'materiaid': materiaId, // Nombre de BD
      'fechaeval': fechaEval?.toIso8601String().split('T')[0], // Solo fecha, nombre de BD
      'notaeval': notaEval, // Nombre de BD
      'ponderacioneval': ponderacionEval, // Nombre de BD
      'estadoeval': estadoEval?.value, // Nombre de BD
    };
  }

  // Método para crear una copia con campos actualizados
  Examen copyWith({
    String? id,
    TipoEvaluacion? tipoEval,
    String? materiaId,
    DateTime? fechaEval,
    double? notaEval,
    double? ponderacionEval,
    EstadoEvaluacion? estadoEval,
    DateTime? createdAt,
    DateTime? updatedAt,
    Materia? materia,
  }) {
    return Examen(
      id: id ?? this.id,
      tipoEval: tipoEval ?? this.tipoEval,
      materiaId: materiaId ?? this.materiaId,
      fechaEval: fechaEval ?? this.fechaEval,
      notaEval: notaEval ?? this.notaEval,
      ponderacionEval: ponderacionEval ?? this.ponderacionEval,
      estadoEval: estadoEval ?? this.estadoEval,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      materia: materia ?? this.materia,
    );
  }

  // Método para obtener información resumida
  String get infoResumida {
    final materiaInfo = materia?.infoResumida ?? 'Materia no disponible';
    final tipo = tipoEval?.value ?? 'Sin tipo';
    final fecha = fechaEval != null 
        ? ' - ${_formatearFecha(fechaEval!)}' 
        : '';
    return '$tipo - $materiaInfo$fecha';
  }

  // Método para obtener el estado formateado
  String get estadoFormateado {
    return estadoEval?.value ?? 'Sin estado';
  }

  // Método para obtener la nota formateada (recibe el máximo del sistema)
  String notaFormateadaConMaximo(int maxNota) {
    if (notaEval == null) return 'Sin calificar';
    return '${notaEval!.toStringAsFixed(1)}/$maxNota.0';
  }

  // Método para obtener la nota formateada (usa 5 por defecto)
  String get notaFormateada {
    if (notaEval == null) return 'Sin calificar';
    return '${notaEval!.toStringAsFixed(1)}/5.0';
  }

  // Método para obtener la ponderación formateada
  String get ponderacionFormateada {
    if (ponderacionEval == null) return 'Sin ponderación';
    return '${(ponderacionEval! * 100).toStringAsFixed(0)}%';
  }

  // Método para verificar si está próximo
  bool get estaProximo {
    if (fechaEval == null) return false;
    final hoy = DateTime.now();
    final diferencia = fechaEval!.difference(hoy).inDays;
    return diferencia >= 0 && diferencia <= 7; // Próximos 7 días
  }

  // Método para verificar si está vencido
  bool get estaVencido {
    if (fechaEval == null) return false;
    return fechaEval!.isBefore(DateTime.now());
  }

  // Método para obtener el color según el estado
  Color get colorEstado {
    return estadoEval?.color ?? Colors.grey;
  }

  // Método para obtener el icono según el estado
  IconData get iconoEstado {
    return estadoEval?.icon ?? Icons.help_outline;
  }

  // Método privado para formatear fechas
  String _formatearFecha(DateTime fecha) {
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  // Método para obtener información detallada
  String get infoDetallada {
    final buffer = StringBuffer();
    buffer.writeln('Tipo: ${tipoEval?.value ?? 'No especificado'}');
    buffer.writeln('Materia: ${materia?.nombre ?? 'No disponible'}');
    if (fechaEval != null) {
      buffer.writeln('Fecha: ${_formatearFecha(fechaEval!)}');
    }
    if (notaEval != null) {
      buffer.writeln('Nota: $notaFormateada');
    }
    if (ponderacionEval != null) {
      buffer.writeln('Ponderación: $ponderacionFormateada');
    }
    buffer.writeln('Estado: $estadoFormateado');
    return buffer.toString();
  }
}

// Clase para estadísticas de exámenes
class EstadisticasExamenes {
  final int total;
  final Map<EstadoEvaluacion, int> porEstado;
  final Map<TipoEvaluacion, int> porTipo;
  final double promedioNotas;
  final double promedioPonderacion;

  EstadisticasExamenes({
    required this.total,
    required this.porEstado,
    required this.porTipo,
    required this.promedioNotas,
    required this.promedioPonderacion,
  });

  factory EstadisticasExamenes.fromJson(Map<String, dynamic> json) {
    return EstadisticasExamenes(
      total: json['total'] ?? 0,
      porEstado: Map<EstadoEvaluacion, int>.from(
        (json['porEstado'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(EstadoEvaluacion.fromString(key), value as int),
        ),
      ),
      porTipo: Map<TipoEvaluacion, int>.from(
        (json['porTipo'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(TipoEvaluacion.fromString(key), value as int),
        ),
      ),
      promedioNotas: json['promedioNotas']?.toDouble() ?? 0.0,
      promedioPonderacion: json['promedioPonderacion']?.toDouble() ?? 0.0,
    );
  }
}
