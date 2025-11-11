import 'package:flutter/material.dart';

// Enum para tipos de cuestionarios
enum TipoCuestionario {
  phq9, // Depresión
  gad7, // Ansiedad
  isi,  // Insomnio
}

extension TipoCuestionarioExtension on TipoCuestionario {
  String get nombre {
    switch (this) {
      case TipoCuestionario.phq9:
        return 'PHQ-9';
      case TipoCuestionario.gad7:
        return 'GAD-7';
      case TipoCuestionario.isi:
        return 'ISI';
    }
  }

  String get descripcion {
    switch (this) {
      case TipoCuestionario.phq9:
        return 'Cuestionario de Salud del Paciente para Depresión';
      case TipoCuestionario.gad7:
        return 'Escala de Ansiedad Generalizada';
      case TipoCuestionario.isi:
        return 'Índice de Severidad del Insomnio';
    }
  }

  String get emoji {
    switch (this) {
      case TipoCuestionario.phq9:
        return '🧠';
      case TipoCuestionario.gad7:
        return '💭';
      case TipoCuestionario.isi:
        return '😴';
    }
  }

  Color get color {
    switch (this) {
      case TipoCuestionario.phq9:
        return Colors.blue;
      case TipoCuestionario.gad7:
        return Colors.orange;
      case TipoCuestionario.isi:
        return Colors.purple;
    }
  }
}

// Modelo para preguntas de cuestionarios
class PreguntaCuestionario {
  final String id;
  final String texto;
  final int? valor; // Valor seleccionado (0-3 para PHQ-9 y GAD-7, 0-4 para ISI)

  PreguntaCuestionario({
    required this.id,
    required this.texto,
    this.valor,
  });

  PreguntaCuestionario copyWith({
    String? id,
    String? texto,
    int? valor,
  }) {
    return PreguntaCuestionario(
      id: id ?? this.id,
      texto: texto ?? this.texto,
      valor: valor ?? this.valor,
    );
  }
}

// Modelo para resultado de cuestionario
class ResultadoCuestionario {
  final String id;
  final TipoCuestionario tipo;
  final int puntuacionTotal;
  final DateTime fechaCompletado;
  final String? interpretacion;
  final Map<String, int> respuestas; // preguntaId -> valor
  final String? usuarioId; // usuario_id de la BD (para lectura)

  ResultadoCuestionario({
    required this.id,
    required this.tipo,
    required this.puntuacionTotal,
    required this.fechaCompletado,
    this.interpretacion,
    required this.respuestas,
    this.usuarioId,
  });

  factory ResultadoCuestionario.fromJson(Map<String, dynamic> json) {
    // Mapear desde los nombres de la base de datos
    return ResultadoCuestionario(
      id: json['id'] ?? '',
      tipo: _tipoFromString(json['tipo'] ?? ''),
      puntuacionTotal: json['puntuacion_total']?.toInt() ?? json['puntuacionTotal']?.toInt() ?? 0,
      fechaCompletado: json['fecha_completado'] != null
          ? DateTime.parse(json['fecha_completado'])
          : json['fechaCompletado'] != null
              ? DateTime.parse(json['fechaCompletado'])
              : DateTime.now(),
      interpretacion: json['interpretacion'],
      respuestas: json['respuestas'] != null
          ? Map<String, int>.from(
              (json['respuestas'] as Map<dynamic, dynamic>).map(
                (key, value) => MapEntry(key.toString(), value as int),
              ),
            )
          : {},
      usuarioId: json['usuario_id'],
    );
  }

  Map<String, dynamic> toJson() {
    // Convertir a los nombres de la base de datos
    // Nota: usuario_id se maneja en el servicio, no se incluye aquí
    return {
      'id': id,
      'tipo': tipo.name,
      'puntuacion_total': puntuacionTotal, // Nombre de BD
      'fecha_completado': fechaCompletado.toIso8601String(), // Nombre de BD
      'interpretacion': interpretacion,
      'respuestas': respuestas,
      if (usuarioId != null) 'usuario_id': usuarioId, // Nombre de BD (solo si existe)
    };
  }

  static TipoCuestionario _tipoFromString(String value) {
    switch (value) {
      case 'phq9':
        return TipoCuestionario.phq9;
      case 'gad7':
        return TipoCuestionario.gad7;
      case 'isi':
        return TipoCuestionario.isi;
      default:
        return TipoCuestionario.phq9;
    }
  }
}

// Modelo para contacto de emergencia
class ContactoEmergencia {
  final String id;
  final String nombre;
  final String telefono;
  final String? descripcion;
  final bool esNacional; // Si es un contacto nacional predefinido
  final String? usuarioId; // usuario_id de la BD (nullable)
  final DateTime createdAt;
  final DateTime updatedAt;

  ContactoEmergencia({
    required this.id,
    required this.nombre,
    required this.telefono,
    this.descripcion,
    this.esNacional = false,
    this.usuarioId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContactoEmergencia.fromJson(Map<String, dynamic> json) {
    // Mapear desde los nombres de la base de datos
    return ContactoEmergencia(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      telefono: json['telefono'] ?? '',
      descripcion: json['descripcion'],
      esNacional: json['es_nacional'] ?? json['esNacional'] ?? false,
      usuarioId: json['usuario_id'],
      createdAt: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt: json['fecha_actualizacion'] != null
          ? DateTime.parse(json['fecha_actualizacion'])
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    // Convertir a los nombres de la base de datos
    // Nota: usuario_id se maneja en el servicio, no se incluye aquí
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'descripcion': descripcion,
      'es_nacional': esNacional, // Nombre de BD
      if (usuarioId != null) 'usuario_id': usuarioId, // Nombre de BD (solo si existe)
      'fecha_creacion': createdAt.toIso8601String(), // Nombre de BD
      'fecha_actualizacion': updatedAt.toIso8601String(), // Nombre de BD
    };
  }

  ContactoEmergencia copyWith({
    String? id,
    String? nombre,
    String? telefono,
    String? descripcion,
    bool? esNacional,
    String? usuarioId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContactoEmergencia(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      descripcion: descripcion ?? this.descripcion,
      esNacional: esNacional ?? this.esNacional,
      usuarioId: usuarioId ?? this.usuarioId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Modelo para emoción seleccionada
enum Emocion {
  feliz,
  triste,
  ansioso,
  enojado,
  asustado,
  sorprendido,
  neutral,
  relajado,
  estresado,
  emocionado,
}

extension EmocionExtension on Emocion {
  String get emoji {
    switch (this) {
      case Emocion.feliz:
        return '😊';
      case Emocion.triste:
        return '😢';
      case Emocion.ansioso:
        return '😰';
      case Emocion.enojado:
        return '😠';
      case Emocion.asustado:
        return '😨';
      case Emocion.sorprendido:
        return '😲';
      case Emocion.neutral:
        return '😐';
      case Emocion.relajado:
        return '😌';
      case Emocion.estresado:
        return '😓';
      case Emocion.emocionado:
        return '🤩';
    }
  }

  String get nombre {
    switch (this) {
      case Emocion.feliz:
        return 'Feliz';
      case Emocion.triste:
        return 'Triste';
      case Emocion.ansioso:
        return 'Ansioso';
      case Emocion.enojado:
        return 'Enojado';
      case Emocion.asustado:
        return 'Asustado';
      case Emocion.sorprendido:
        return 'Sorprendido';
      case Emocion.neutral:
        return 'Neutral';
      case Emocion.relajado:
        return 'Relajado';
      case Emocion.estresado:
        return 'Estresado';
      case Emocion.emocionado:
        return 'Emocionado';
    }
  }

  Color get color {
    switch (this) {
      case Emocion.feliz:
        return Colors.yellow;
      case Emocion.triste:
        return Colors.blue;
      case Emocion.ansioso:
        return Colors.orange;
      case Emocion.enojado:
        return Colors.red;
      case Emocion.asustado:
        return Colors.purple;
      case Emocion.sorprendido:
        return Colors.cyan;
      case Emocion.neutral:
        return Colors.grey;
      case Emocion.relajado:
        return Colors.green;
      case Emocion.estresado:
        return Colors.deepOrange;
      case Emocion.emocionado:
        return Colors.pink;
    }
  }
}

// Modelo para mensajes del chat
class MensajeChat {
  final String id;
  final String texto;
  final bool esUsuario;
  final DateTime fecha;

  MensajeChat({
    required this.id,
    required this.texto,
    required this.esUsuario,
    required this.fecha,
  });
}

