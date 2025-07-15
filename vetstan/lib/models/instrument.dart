class Instrument {
  final int? id;
  final int? categoryId;
  final String nameEn;
  final String nameKu;
  final String imagePath;
  final String descriptionEn;
  final String descriptionKu;

  Instrument({
    this.id,
    this.categoryId,
    required this.nameEn,
    required this.nameKu,
    required this.imagePath,
    required this.descriptionEn,
    required this.descriptionKu,
  });

  String getName(bool isEnglish) => isEnglish ? nameEn : nameKu;
  String getDescription(bool isEnglish) => isEnglish ? descriptionEn : descriptionKu;

  factory Instrument.fromMap(Map<String, dynamic> map) {
    return Instrument(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int?,
      nameEn: map['name_en'] as String,
      nameKu: map['name_ku'] as String,
      imagePath: map['image_path'] as String,
      descriptionEn: map['description_en'] as String,
      descriptionKu: map['description_ku'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name_en': nameEn,
      'name_ku': nameKu,
      'image_path': imagePath,
      'description_en': descriptionEn,
      'description_ku': descriptionKu,
    };
  }
}
