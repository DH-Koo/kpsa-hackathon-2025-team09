class Music {
  final int id;
  final String title;
  final int medicine;
  final String description;

  Music({
    required this.id,
    required this.title,
    required this.medicine,
    required this.description,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      medicine: json['medicine'] ?? 0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'medicine': medicine,
      'description': description,
    };
  }
} 