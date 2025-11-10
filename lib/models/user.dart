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
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'],
      telefono: json['telefono'],
      carrera: json['carrera'],
      semestre: json['semestre']?.toInt(),
      sistemaCalificacion: json['sistemaCalificacion']?.toInt() ?? 5,
      avatar: json['avatar'],
      profileCompleted: json['profileCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'carrera': carrera,
      'semestre': semestre,
      'sistemaCalificacion': sistemaCalificacion,
      'avatar': avatar,
      'profileCompleted': profileCompleted ?? false,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
