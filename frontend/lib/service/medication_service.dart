import '../models/medication.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class MedicationService {
  final _api = ChatApiService();

  // 약 목록 전체 조회
  Future<List<MedicationRoutine>> fetchRoutines(int userId) async {
    try {
      final endpoint = '${ApiConfig.medicineBase}$userId/';
      print('[fetchRoutines] 호출할 엔드포인트: $endpoint');
      final data = await _api.get<List<dynamic>>(endpoint);

      // 디버깅을 위한 로그 추가
      print('[fetchRoutines] API 응답: $data');
      print('[fetchRoutines] 응답 데이터 개수: ${data.length}');

      final routines = data.map((e) => MedicationRoutine.fromJson(e)).toList();
      print('[fetchRoutines] 파싱된 루틴 개수: ${routines.length}');

      for (var routine in routines.take(3)) {
        print(
          '[fetchRoutines] 루틴 샘플 - id: ${routine.id}, name: ${routine.name}, weekday: ${routine.weekday}, startDay: ${routine.startDay}, endDay: ${routine.endDay}',
        );
      }

      return routines;
    } catch (e, stack) {
      print('[fetchRoutines] 에러 발생: $e\n$stack');
      // 약이 없거나 API 오류일 때는 빈 배열 반환
      if (e.toString().contains('404') ||
          e.toString().contains('405') ||
          e.toString().contains('500')) {
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
      final requestData = routine.toJson();

      print('[createRoutine] 요청 데이터: $requestData');
      print('[createRoutine] 엔드포인트: $endpoint');

      final data = await _api.post<Map<String, dynamic>>(endpoint, requestData);

      print('[createRoutine] 서버 응답: $data');

      // 서버 응답이 성공 메시지와 medicine_id만 포함하는 경우 처리
      if (data.containsKey('message') && data.containsKey('medicine_id')) {
        print('[createRoutine] 성공 메시지 응답 감지, medicine_id: ${data['medicine_id']}');
        
        // 원본 routine에 서버에서 생성된 ID를 설정하여 반환
        final createdRoutine = MedicationRoutine(
          id: data['medicine_id'],
          userId: routine.userId,
          name: routine.name,
          description: routine.description,
          takeTime: routine.takeTime,
          numPerTake: routine.numPerTake,
          numPerDay: routine.numPerDay,
          totalDays: routine.totalDays,
          weekday: routine.weekday,
          startDay: routine.startDay,
          endDay: routine.endDay,
        );
        
        print('[createRoutine] 생성된 루틴: ${createdRoutine.toJson()}');
        return createdRoutine;
      }

      // 기존 방식: 전체 약 데이터가 반환되는 경우
      final createdRoutine = MedicationRoutine.fromJson(data);
      print('[createRoutine] 생성된 루틴: ${createdRoutine.toJson()}');

      return createdRoutine;
    } catch (e, stack) {
      print('[createRoutine] 에러 발생: $e');
      print('[createRoutine] 스택 트레이스: $stack');
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
