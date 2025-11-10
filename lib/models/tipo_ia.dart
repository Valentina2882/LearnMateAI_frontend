/// Modelo para representar un tipo de IA (Kora o Kora Pro)
class TipoIA {
  final String id;
  final String codigo; // 'emocional' o 'academica'
  final String nombre; // 'Kora' o 'Kora Pro'
  final String? descripcion;
  final String? avatarUrl;
  final String colorPrimario; // Color HEX
  final String colorSecundario; // Color HEX
  final String? promptBase; // Prompt base para la IA
  final bool activo;
  final int orden;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  TipoIA({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    this.avatarUrl,
    required this.colorPrimario,
    required this.colorSecundario,
    this.promptBase,
    required this.activo,
    required this.orden,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  /// Crear TipoIA desde JSON (Supabase)
  factory TipoIA.fromJson(Map<String, dynamic> json) {
    return TipoIA(
      id: json['id'] as String,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      colorPrimario: json['color_primario'] as String? ?? '#6366F1',
      colorSecundario: json['color_secundario'] as String? ?? '#8B5CF6',
      promptBase: json['prompt_base'] as String?,
      activo: json['activo'] as bool? ?? true,
      orden: json['orden'] as int? ?? 0,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fechaActualizacion: DateTime.parse(json['fecha_actualizacion'] as String),
    );
  }

  /// Convertir TipoIA a JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'avatar_url': avatarUrl,
      'color_primario': colorPrimario,
      'color_secundario': colorSecundario,
      'prompt_base': promptBase,
      'activo': activo,
      'orden': orden,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  /// Crear una copia con algunos campos modificados
  TipoIA copyWith({
    String? id,
    String? codigo,
    String? nombre,
    String? descripcion,
    String? avatarUrl,
    String? colorPrimario,
    String? colorSecundario,
    String? promptBase,
    bool? activo,
    int? orden,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return TipoIA(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      colorPrimario: colorPrimario ?? this.colorPrimario,
      colorSecundario: colorSecundario ?? this.colorSecundario,
      promptBase: promptBase ?? this.promptBase,
      activo: activo ?? this.activo,
      orden: orden ?? this.orden,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return 'TipoIA(id: $id, codigo: $codigo, nombre: $nombre, activo: $activo)';
  }
}

