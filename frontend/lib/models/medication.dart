class MedicationRoutine {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final List<List<int>> takeTime; // 복용 시간: [[9,0],[21,0]]
  final int numPerTake; // 1회 투여량
  final int numPerDay; // 1일 투여 횟수
  final int totalDays; // 총 투여일수
  final List<String> weekday; // 복용 요일: ["월", "화", ...]
  final DateTime startDay; // 시작일
  final DateTime endDay; // 종료일

  MedicationRoutine({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.takeTime,
    required this.numPerTake,
    required this.numPerDay,
    required this.totalDays,
    required this.weekday,
    required this.startDay,
    required this.endDay,
  });

  factory MedicationRoutine.fromJson(Map<String, dynamic> json) {
    return MedicationRoutine(
      id: json['id'],
      userId: json['user'],
      name: json['name'] ?? '',
      description: json['description'],
      takeTime: (json['take_time'] as List)
          .map<List<int>>((e) => List<int>.from(e))
          .toList(),
      numPerTake: json['num_per_take'],
      numPerDay: json['num_per_day'],
      totalDays: json['total_days'],
      weekday: List<String>.from(json['weekday'] ?? []),
      startDay: DateTime.parse(json['start_day']),
      endDay: DateTime.parse(json['end_day']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'name': name,
      'description': description,
      'take_time': takeTime,
      'num_per_take': numPerTake,
      'num_per_day': numPerDay,
      'total_days': totalDays,
      'weekday': weekday,
      'start_day': startDay.toIso8601String().split('T')[0],
      'end_day': endDay.toIso8601String().split('T')[0],
    };
  }
}
