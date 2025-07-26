import '../models/medication.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class MedicationService {
  final _api = ChatApiService();

  // 약 목록 전체 조회
  Future<List<MedicationRoutine>> fetchRoutines(int userId) async {
    try {
      final endpoint = '${ApiConfig.medicineBase}?user=$userId';
      final data = await _api.get<List<dynamic>>(endpoint);

      // 디버깅을 위한 로그 추가
      print('[fetchRoutines] API 응답: $data');

      return data.map((e) => MedicationRoutine.fromJson(e)).toList();
    } catch (e, stack) {
      print('[fetchRoutines] 에러 발생: $e\n$stack');
      // 약이 없을 때는 빈 배열 반환
      if (e.toString().contains('404') || e.toString().contains('500')) {
        print('[fetchRoutines] 약 목록이 없거나 서버 오류, 빈 배열 반환');
        return [];
      }
      rethrow;
    }
  }

  // 약 등록
  Future<MedicationRoutine> createRoutine(MedicationRoutine routine) async {
    try {
      final endpoint = ApiConfig.medicineBase;
      final data = await _api.post<Map<String, dynamic>>(
        endpoint,
        routine.toJson(),
      );
      return MedicationRoutine.fromJson(data);
    } catch (e, stack) {
      print('[createRoutine] 에러 발생: $e\n$stack');
      rethrow;
    }
  }

  // 약 수정
  Future<MedicationRoutine> updateRoutine(MedicationRoutine routine) async {
    try {
      final endpoint = '${ApiConfig.medicineBase}/${routine.id}';
      final data = await _api.put(endpoint, routine.toJson());
      return MedicationRoutine.fromJson(data);
    } catch (e, stack) {
      print('[updateRoutine] 에러 발생: $e\n$stack');
      rethrow;
    }
  }

  // 약 삭제
  Future<void> deleteRoutine(int routineId) async {
    try {
      final endpoint = '${ApiConfig.medicineBase}/$routineId';
      await _api.delete(endpoint);
    } catch (e, stack) {
      print('[deleteRoutine] 에러 발생: $e\n$stack');
      rethrow;
    }
  }
}
