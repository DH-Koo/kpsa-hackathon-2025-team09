class EmotionReport {
  final String id;
  final DateTime createdAt;
  final String title;
  final String type; // 'simple' 또는 'workflow'
  final Map<String, dynamic> data;
  final List<String> responses;

  EmotionReport({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.type,
    required this.data,
    required this.responses,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'title': title,
      'type': type,
      'data': data,
      'responses': responses,
    };
  }

  factory EmotionReport.fromJson(Map<String, dynamic> json) {
    return EmotionReport(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      title: json['title'],
      type: json['type'],
      data: json['data'],
      responses: List<String>.from(json['responses']),
    );
  }
} 