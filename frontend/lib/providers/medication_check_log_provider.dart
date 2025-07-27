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

  // 복약 체크/해제 (UI에서만 상태 변경)
  Future<void> toggleCheck(int userId, String day, int medicineId, List<int> time) async {
    // 해당 약의 특정 시간에 대한 체크 상태를 토글
    final existingIndex = checkLogs.indexWhere(
      (log) => log.medicine == medicineId && 
                const ListEquality().equals(log.time, time),
    );

    if (existingIndex != -1) {
      // 기존 로그 토글
      final existingLog = checkLogs[existingIndex];
      final updatedLog = MedicationCheckLog(
        id: existingLog.id,
        user: existingLog.user,
        medicine: existingLog.medicine,
        date: existingLog.date,
        time: existingLog.time,
        isTaken: !existingLog.isTaken,
      );
      checkLogs[existingIndex] = updatedLog;
    } else {
      // 새 로그 생성
      final newLog = MedicationCheckLog(
        id: DateTime.now().millisecondsSinceEpoch, // 임시 ID
        user: userId,
        medicine: medicineId,
        date: day,
        time: time,
        isTaken: true,
      );
      checkLogs.add(newLog);
    }

    // UI 업데이트
    notifyListeners();

    print(
      '[toggleCheck] UI에서만 상태 변경 완료 - medicine: $medicineId, time: $time',
    );
  }

  // 특정 약의 특정 시간(time)이 체크됐는지 확인
  bool isCheckedTime(int medicineId, List<int> time) {
    final eq = const ListEquality();

    for (var log in checkLogs) {
      if (log.medicine == medicineId &&
          eq.equals(log.time, time) &&
          log.isTaken) {
        return true;
      }
    }

    return false;
  }
}
