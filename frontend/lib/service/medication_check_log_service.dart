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
      print('[fetchMedicineOfDay] 호출할 엔드포인트: $endpoint');

      final data = await _api.get<List<dynamic>>(endpoint);
      return data.map((e) => MedicationCheckLog.fromJson(e)).toList();
    } catch (e, stack) {
      print('[fetchMedicineOfDay] 에러 발생: $e\n$stack');
      rethrow;
    }
  }

  // 복약 체크/해제 (toggle)
  Future<MedicationCheckLog> toggleMedicineCheck(
    int userId,
    String day,
    int medicineId,
  ) async {
    try {
      final endpoint = ApiConfig.medicineOfDay(
        userId,
        day,
        medicineId.toString(),
      );
      final data = await _api.put(endpoint, {'medicine_of_day_id': medicineId});
      return MedicationCheckLog.fromJson(data);
    } catch (e, stack) {
      print('[toggleMedicineCheck] 에러 발생: $e\n$stack');
      rethrow;
    }
  }
}
