class User {
  final String id;
  final String email;
  final String nombre;
  final String? apellido;
  final String? telefono;
  final String? carrera;
  final int? semestre;
  final int? sistemaCalificacion;
  final String? avatar;
  final bool? profileCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    this.apellido,
    this.telefono,
    this.carrera,
    this.semestre,
    this.sistemaCalificacion,
    this.avatar,
    this.profileCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Mapear desde los nombres de la base de datos
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? json['nombreusu'] ?? '',
      apellido: json['apellido'],
      telefono: json['telefono'],
      carrera: json['carrerausu'] ?? json['carrera'],
      semestre: json['semestreusu']?.toInt() ?? json['semestre']?.toInt(),
      sistemaCalificacion: json['sistemacalificacion']?.toInt() ?? json['sistemaCalificacion']?.toInt() ?? 5,
      avatar: json['avatar'],
      profileCompleted: json['profile_completed'] ?? json['profileCompleted'] ?? false,
      createdAt: json['fechacreacion'] != null
          ? DateTime.parse(json['fechacreacion'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt: json['fechaactualizacion'] != null
          ? DateTime.parse(json['fechaactualizacion'])
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    // Convertir a los nombres de la base de datos
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'nombreusu': nombre, // Campo requerido en BD
      'apellido': apellido,
      'telefono': telefono,
      'carrerausu': carrera, // Nombre de BD
      'carrera': carrera, // Mantener para compatibilidad
      'semestreusu': semestre, // Nombre de BD
      'semestre': semestre, // Mantener para compatibilidad
      'sistemacalificacion': sistemaCalificacion, // Nombre de BD
      'avatar': avatar,
      'profile_completed': profileCompleted ?? false, // Nombre de BD
      'fechacreacion': createdAt.toIso8601String(), // Nombre de BD
      'fechaactualizacion': updatedAt.toIso8601String(), // Nombre de BD
    };
  }

  String get nombreCompleto {
    if (apellido != null && apellido!.isNotEmpty) {
      return '$nombre $apellido';
    }
    return nombre;
  }

  bool get isProfileCompleted {
    return profileCompleted ?? false;
  }
}
