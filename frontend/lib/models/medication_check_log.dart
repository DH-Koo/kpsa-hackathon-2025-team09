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
    return MedicationCheckLog(
      id: json['id'],
      user: json['user'],
      medicine: json['medicine'],
      date: json['date'],
      time: json['time'],
      isTaken: json['is_taken'],
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
