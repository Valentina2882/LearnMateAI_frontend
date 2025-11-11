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
    // La tabla horarios NO tiene created_at ni updated_at en la BD
    // Usamos valores por defecto
    return Horario(
      id: json['id'] ?? '',
      nombrehor: json['nombrehor'],
      descripcionhor: json['descripcionhor'],
      fechainiciosemestre: json['fechainiciosemestre'],
      fechafinsemestre: json['fechafinsemestre'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(), // Valor por defecto ya que no existe en BD
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(), // Valor por defecto ya que no existe en BD
    );
  }

  Map<String, dynamic> toJson() {
    // La tabla horarios NO tiene created_at ni updated_at en la BD
    // Solo devolvemos los campos que existen en la BD
    return {
      'id': id,
      'nombrehor': nombrehor,
      'descripcionhor': descripcionhor,
      'fechainiciosemestre': fechainiciosemestre,
      'fechafinsemestre': fechafinsemestre,
      // No incluimos createdAt/updatedAt porque no existen en la BD
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
