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
      // 복약 체크 로그가 없을 때는 빈 배열 반환
      if (e.toString().contains('404') || e.toString().contains('500')) {
        print('[fetchMedicineOfDay] 복약 체크 로그가 없거나 서버 오류, 빈 배열 반환');
        return [];
      }
      rethrow;
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
