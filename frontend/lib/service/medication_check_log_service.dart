import '../models/medication_check_log.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class MedicationCheckLogService {
  final _api = ChatApiService();

  // 오늘의 복약 목록 조회
  Future<List<MedicationCheckLog>> fetchMedicineOfDay(
    int userId,
    String day,
    String weekday,
  ) async {
    try {
      final endpoint = ApiConfig.medicineOfDay(userId, day, weekday);
      final data = await _api.get<List<dynamic>>(endpoint);
      return data.map((e) => MedicationCheckLog.fromJson(e)).toList();
    } catch (e, stack) {
      print('[fetchMedicineOfDay] 에러 발생: $e\n$stack');
      // 임시 데이터 반환
      return [
        MedicationCheckLog(
          id: 0,
          user: userId,
          medicine: 1,
          date: day,
          time: [8, 0],
          isTaken: true,
        ),
        MedicationCheckLog(
          id: 1,
          user: userId,
          medicine: 2,
          date: day,
          time: [9, 0],
          isTaken: false,
        ),
        MedicationCheckLog(
          id: 2,
          user: userId,
          medicine: 2,
          date: day,
          time: [12, 0],
          isTaken: true,
        ),
        MedicationCheckLog(
          id: 3,
          user: userId,
          medicine: 1,
          date: day,
          time: [20, 0],
          isTaken: false,
        ),
      ];
    }
  }

  // 복약 체크/해제 (toggle)
  Future<MedicationCheckLog> toggleMedicineCheck(
    int userId,
    String day,
    int medicineId,
    List<int> time,
  ) async {
    try {
      final endpoint = ApiConfig.medicineOfDay(
        userId,
        day,
        medicineId.toString(),
      );
      final data = await _api.put(endpoint, {"time": time});
      return MedicationCheckLog.fromJson(data);
    } catch (e, stack) {
      print('[toggleMedicineCheck] 에러 발생: $e\n$stack');
      rethrow;
    }
  }
}
