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
  Future<void> toggleCheck(int userId, String day, int medicineId) async {
    // PUT 요청 실행
    final updatedLog = await _service.toggleMedicineCheck(
      userId,
      day,
      medicineId,
    );

    // PUT 응답을 사용하여 로컬 상태 업데이트
    final existingIndex = checkLogs.indexWhere(
      (log) =>
          log.medicine == updatedLog.medicine &&
          const ListEquality().equals(log.time, updatedLog.time),
    );

    if (existingIndex != -1) {
      // 기존 로그 업데이트
      checkLogs[existingIndex] = updatedLog;
    } else {
      // 새 로그 추가
      checkLogs.add(updatedLog);
    }

    // UI 업데이트
    notifyListeners();

    print(
      '[toggleCheck] PUT 응답으로 로컬 상태 업데이트 완료 - medicine: ${updatedLog.medicine}, isTaken: ${updatedLog.isTaken}',
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
