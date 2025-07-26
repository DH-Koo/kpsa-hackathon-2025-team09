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
      return data.map((e) => MedicationRoutine.fromJson(e)).toList();
    } catch (e, stack) {
      print('[fetchRoutines] 에러 발생: $e\n$stack');
      // 임시 데이터 반환
      return [
        MedicationRoutine(
          id: 1,
          userId: userId,
          name: '타이레놀',
          description: '진통제',
          takeTime: [
            [8, 0],
            [20, 0],
          ],
          numPerTake: 1,
          numPerDay: 2,
          totalDays: 7,
          weekday: ['월', '화', '수', '목', '금', '토', '일'],
          startDay: DateTime.now().subtract(Duration(days: 3)),
          endDay: DateTime.now().add(Duration(days: 4)),
        ),
        MedicationRoutine(
          id: 2,
          userId: userId,
          name: '비타민C',
          description: '면역력 강화',
          takeTime: [
            [9, 0],
            [12, 0],
          ],
          numPerTake: 1,
          numPerDay: 1,
          totalDays: 30,
          weekday: ['월', '화', '수', '목', '금'],
          startDay: DateTime.now().subtract(Duration(days: 10)),
          endDay: DateTime.now().add(Duration(days: 20)),
        ),
      ];
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
      // 임시 데이터 반환
      return MedicationRoutine(
        id: 999,
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
      // 임시 데이터 반환
      return MedicationRoutine(
        id: routine.id,
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
    }
  }

  // 약 삭제
  Future<void> deleteRoutine(int routineId) async {
    try {
      final endpoint = '${ApiConfig.medicineBase}/$routineId';
      await _api.delete(endpoint);
    } catch (e, stack) {
      print('[deleteRoutine] 에러 발생: $e\n$stack');
      // 실제 API가 없으므로 예외를 던지지 않고 성공으로 처리
    }
  }
}
