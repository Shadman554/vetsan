class NormalRange {
  final String id;
  final String name;
  final String unit;
  final String minValue;
  final String maxValue;
  final String? notes;
  final String? category;
  final String? species;
  final String? sex;
  final String? ageRange;
  final String? description;
  final String? imageUrl;

  NormalRange({
    required this.id,
    required this.name,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    this.notes,
    this.category,
    this.species,
    this.sex,
    this.ageRange,
    this.description,
    this.imageUrl,
  });

  factory NormalRange.fromJson(Map<String, dynamic> json) {
    return NormalRange(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      minValue: json['min_value'] ?? '',
      maxValue: json['max_value'] ?? '',
      notes: json['notes'],
      category: json['category'],
      species: json['species'],
      sex: json['sex'],
      ageRange: json['age_range'],
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }

  factory NormalRange.fromMap(String id, Map<String, dynamic> data) {
    return NormalRange(
      id: id,
      name: data['name'] ?? '',
      unit: data['unit'] ?? '',
      minValue: data['min_value'] ?? '',
      maxValue: data['max_value'] ?? '',
      notes: data['notes'],
      category: data['category'],
      species: data['species'],
      sex: data['sex'],
      ageRange: data['age_range'],
      description: data['description'],
      imageUrl: data['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
      'minValue': minValue,
      'maxValue': maxValue,
      'notes': notes,
      'category': category,
      'species': species,
    };
  }
}
