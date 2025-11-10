import 'package:flutter/material.dart';

class Materia {
  final String id;
  final String nombre;
  final String codigo;
  final int creditos;
  final String? descripcion;
  final String? profesor;
  final String? aula;
  final String? horario;
  final String? color; // Color en formato hex para la UI
  final DateTime createdAt;
  final DateTime updatedAt;

  Materia({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.creditos,
    this.descripcion,
    this.profesor,
    this.aula,
    this.horario,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'] ?? '',
      creditos: json['creditos']?.toInt() ?? 0,
      descripcion: json['descripcion'],
      profesor: json['profesor'],
      aula: json['aula'],
      horario: json['horario'],
      color: json['color'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'creditos': creditos,
      'descripcion': descripcion,
      'profesor': profesor,
      'aula': aula,
      'horario': horario,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Método para crear una copia con campos actualizados
  Materia copyWith({
    String? id,
    String? nombre,
    String? codigo,
    int? creditos,
    String? descripcion,
    String? profesor,
    String? aula,
    String? horario,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Materia(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      creditos: creditos ?? this.creditos,
      descripcion: descripcion ?? this.descripcion,
      profesor: profesor ?? this.profesor,
      aula: aula ?? this.aula,
      horario: horario ?? this.horario,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Método para obtener el color como Color de Flutter
  String get colorHex {
    return color ?? '#2196F3'; // Color azul por defecto
  }

  // Getter para obtener el color como Color de Flutter
  Color get flutterColor {
    try {
      return Color(int.parse(colorHex.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return const Color(0xFF2196F3); // Fallback color
    }
  }

  // Método para obtener información resumida
  String get infoResumida {
    return '$codigo - $nombre ($creditos créditos)';
  }

  // Método para verificar si tiene información completa
  bool get tieneInfoCompleta {
    return profesor != null && aula != null && horario != null;
  }
}
