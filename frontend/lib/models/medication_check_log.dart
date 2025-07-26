class MedicationCheckLog {
  final int id;
  final int user;
  final int medicine;
  final String date;
  final List<int> time;
  final bool isTaken;

  MedicationCheckLog({
    required this.id,
    required this.user,
    required this.medicine,
    required this.date,
    required this.time,
    required this.isTaken,
  });

  factory MedicationCheckLog.fromJson(Map<String, dynamic> json) {
    // take_time을 파싱하여 List<int>로 변환
    List<int> parseTime(String? timeStr) {
      if (timeStr == null) return [];
      try {
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          return [
            int.parse(parts[0]), // 시간
            int.parse(parts[1]), // 분
          ];
        }
      } catch (e) {
        print('시간 파싱 오류: $timeStr, $e');
      }
      return [];
    }

    return MedicationCheckLog(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      medicine: json['medicine'] ?? 0,
      date: json['date'] ?? '',
      time: parseTime(json['take_time']), // take_time 필드 사용
      isTaken: json['is_taken'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'medicine': medicine,
    'date': date,
    'time': time,
    'is_taken': isTaken,
  };
}
