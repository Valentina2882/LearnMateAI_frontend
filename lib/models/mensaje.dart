/// Modelo para representar un mensaje en el chat
class Mensaje {
  final String id;
  final String usuarioId;
  final String tipoIA; // 'emocional' o 'academica'
  final String role; // 'user' o 'ia'
  final String mensaje; // Contenido del mensaje
  final Map<String, dynamic>? metadata; // Metadatos adicionales (tokens, modelo, etc.)
  final DateTime createdAt;
  final DateTime? updatedAt;

  Mensaje({
    required this.id,
    required this.usuarioId,
    required this.tipoIA,
    required this.role,
    required this.mensaje,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  /// Verificar si el mensaje es del usuario
  bool get esUsuario => role == 'user';

  /// Verificar si el mensaje es de la IA
  bool get esIA => role == 'ia';

  /// Crear Mensaje desde JSON (Supabase)
  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String,
      tipoIA: json['tipo_ia'] as String,
      role: json['role'] as String,
      mensaje: json['mensaje'] as String,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convertir Mensaje a JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'tipo_ia': tipoIA,
      'role': role,
      'mensaje': mensaje,
      'metadata': metadata ?? {},
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Crear un mensaje para insertar (sin id ni fechas)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'usuario_id': usuarioId,
      'tipo_ia': tipoIA,
      'role': role,
      'mensaje': mensaje,
      'metadata': metadata ?? {},
    };
  }

  /// Crear una copia con algunos campos modificados
  Mensaje copyWith({
    String? id,
    String? usuarioId,
    String? tipoIA,
    String? role,
    String? mensaje,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Mensaje(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      tipoIA: tipoIA ?? this.tipoIA,
      role: role ?? this.role,
      mensaje: mensaje ?? this.mensaje,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Mensaje(id: $id, tipoIA: $tipoIA, role: $role, mensaje: ${mensaje.substring(0, mensaje.length > 50 ? 50 : mensaje.length)}...)';
  }
}

