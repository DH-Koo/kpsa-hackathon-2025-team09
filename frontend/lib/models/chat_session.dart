import 'chat_message.dart';

class ChatSession {
  final int id;
  final int userId;
  final String summary;
  final String topic;
  final DateTime time;
  final DateTime startTime;
  final bool isWorkflow; // 워크플로우 여부

  // UI를 위한 추가 필드들
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.userId,
    required this.summary,
    required this.topic,
    required this.time,
    required this.startTime,
    this.isWorkflow = false, // 기본값 false
    this.messages = const [],
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? 0,
      userId: json['user'] ?? 0,
      summary: json['summary'] ?? '',
      topic: json['topic'] ?? 'None',
      time: json['time'] != null
          ? DateTime.parse(json['time'])
          : DateTime.now(),
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : DateTime.now(),
      isWorkflow: json['is_workflow'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'summary': summary,
      'topic': topic,
      'time': time.toIso8601String(),
      'start_time': startTime.toIso8601String(),
      'is_workflow': isWorkflow,
    };
  }

  /// UI 표시용 제목 반환
  String get displayTitle {
    return summary.isNotEmpty ? summary : '새로운 대화';
  }

  /// 마지막 업데이트 시간 (time 필드 사용)
  DateTime get updatedAt => time;

  /// 객체의 일부 속성만 변경하여 새로운 객체를 생성하는 메서드
  ChatSession copyWith({
    int? id,
    int? userId,
    String? summary,
    String? topic,
    DateTime? time,
    DateTime? startTime,
    bool? isWorkflow,
    List<ChatMessage>? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      summary: summary ?? this.summary,
      topic: topic ?? this.topic,
      time: time ?? this.time,
      startTime: startTime ?? this.startTime,
      isWorkflow: isWorkflow ?? this.isWorkflow,
      messages: messages ?? this.messages,
    );
  }
}
