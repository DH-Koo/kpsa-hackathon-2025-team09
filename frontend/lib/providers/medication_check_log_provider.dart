import 'package:flutter/material.dart';
import '../models/medication_check_log.dart';
import '../service/medication_check_log_service.dart';
import 'package:collection/collection.dart';

class MedicationCheckLogProvider extends ChangeNotifier {
  final MedicationCheckLogService _service = MedicationCheckLogService();
  List<MedicationCheckLog> checkLogs = [];

  // 오늘의 복약 목록 불러오기
  Future<void> loadCheckLogs(int userId, String day, String weekday) async {
    checkLogs = await _service.fetchMedicineOfDay(userId, day, weekday);
    notifyListeners();
  }

  // 복약 체크/해제
  Future<void> toggleCheck(
    int userId,
    String day,
    int medicineId,
    String weekday,
    List<int> time,
  ) async {
    await _service.toggleMedicineCheck(userId, day, medicineId, time);
    await loadCheckLogs(userId, day, weekday);
  }

  // 특정 약의 특정 시간(time)이 체크됐는지 확인
  bool isCheckedTime(int medicineId, List<int> time) {
    final eq = const ListEquality();
    return checkLogs.any(
      (log) =>
          log.medicine == medicineId &&
          eq.equals(log.time, time) &&
          log.isTaken,
    );
  }
}
