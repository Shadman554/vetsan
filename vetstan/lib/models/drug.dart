class Drug {
  final String id;
  final String name;
  final String description;
  final String otherInfo;
  final String sideEffect;
  final String usage;
  final String drugClass;
  final String kurdish;
  final String category;
  final String imageUrl;

  Drug({
    required this.id,
    required this.name,
    required this.description,
    required this.kurdish,
    this.category = '',
    this.otherInfo = '',
    this.sideEffect = '',
    this.usage = '',
    this.drugClass = '',
    this.imageUrl = '',
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['drug_name'] ?? '',
      description: json['description'] ?? '',
      otherInfo: json['otherInfo'] ?? json['other_info'] ?? '',
      sideEffect: json['sideEffect'] ?? json['side_effect'] ?? '',
      usage: json['usage'] ?? json['use'] ?? '',
      drugClass: json['drug_class'] ?? json['class'] ?? '',
      kurdish: json['kurdish'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'otherInfo': otherInfo,
      'sideEffect': sideEffect,
      'usage': usage,
      'class': drugClass,
      'kurdish': kurdish,
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}