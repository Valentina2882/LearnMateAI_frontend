class Horario {
  final String id;
  final String? nombrehor;
  final String? descripcionhor;
  final String? fechainiciosemestre;
  final String? fechafinsemestre;
  final DateTime createdAt;
  final DateTime updatedAt;

  Horario({
    required this.id,
    this.nombrehor,
    this.descripcionhor,
    this.fechainiciosemestre,
    this.fechafinsemestre,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      id: json['id'] ?? '',
      nombrehor: json['nombrehor'],
      descripcionhor: json['descripcionhor'],
      fechainiciosemestre: json['fechainiciosemestre'],
      fechafinsemestre: json['fechafinsemestre'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombrehor': nombrehor,
      'descripcionhor': descripcionhor,
      'fechainiciosemestre': fechainiciosemestre,
      'fechafinsemestre': fechafinsemestre,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Horario copyWith({
    String? id,
    String? nombrehor,
    String? descripcionhor,
    String? fechainiciosemestre,
    String? fechafinsemestre,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Horario(
      id: id ?? this.id,
      nombrehor: nombrehor ?? this.nombrehor,
      descripcionhor: descripcionhor ?? this.descripcionhor,
      fechainiciosemestre: fechainiciosemestre ?? this.fechainiciosemestre,
      fechafinsemestre: fechafinsemestre ?? this.fechafinsemestre,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get horarioCompleto {
    return 'Horario del semestre $fechainiciosemestre al $fechafinsemestre';
  }

}
