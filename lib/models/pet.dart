class Pet {
  final String id;
  String name;
  String species;
  String breed;
  DateTime birthDate;
  String? photoPath;
  String furColor;
  String gender;

  Pet({
    required this.id,
    required this.name,
    this.species = 'dog',
    this.breed = '',
    required this.birthDate,
    this.photoPath,
    this.furColor = '',
    this.gender = 'unknown',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'species': species,
        'breed': breed,
        'birthDate': birthDate.toIso8601String(),
        'photoPath': photoPath,
        'furColor': furColor,
        'gender': gender,
      };

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        id: json['id'] as String,
        name: json['name'] as String,
        species: json['species'] as String? ?? 'dog',
        breed: json['breed'] as String? ?? '',
        birthDate: DateTime.parse(json['birthDate'] as String),
        photoPath: json['photoPath'] as String?,
        furColor: json['furColor'] as String? ?? '',
        gender: json['gender'] as String? ?? 'unknown',
      );

  Pet copyWith({
    String? name,
    String? species,
    String? breed,
    DateTime? birthDate,
    String? photoPath,
    String? furColor,
    String? gender,
  }) =>
      Pet(
        id: id,
        name: name ?? this.name,
        species: species ?? this.species,
        breed: breed ?? this.breed,
        birthDate: birthDate ?? this.birthDate,
        photoPath: photoPath ?? this.photoPath,
        furColor: furColor ?? this.furColor,
        gender: gender ?? this.gender,
      );

  String ageLabel({bool vi = false}) {
    final now = DateTime.now();
    final days = now.difference(birthDate).inDays;
    if (days < 0) return vi ? 'Sắp sinh' : 'Due soon';
    if (days < 30) return vi ? '$days ngày' : '$days days';
    final months = (days / 30.44).floor();
    if (months < 24) {
      return vi ? '$months tháng' : '$months months';
    }
    final years = (months / 12).floor();
    final remMonths = months % 12;
    if (remMonths == 0) return vi ? '$years tuổi' : '$years years';
    return vi ? '$years tuổi $remMonths tháng' : '$years y $remMonths m';
  }

  String speciesLabel({bool vi = false}) {
    return switch (species) {
      'dog' => vi ? 'Chó' : 'Dog',
      'cat' => vi ? 'Mèo' : 'Cat',
      _ => vi ? 'Khác' : 'Other',
    };
  }
}
