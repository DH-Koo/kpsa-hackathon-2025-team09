import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../service/medication_service.dart';

class MedicationProvider extends ChangeNotifier {
  final MedicationService _service = MedicationService();
  List<MedicationRoutine> routines = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // 약 목록 조회 (필요시)
  Future<void> loadRoutines(int userId) async {
    _setLoading(true);
    _clearError();
    try {
      routines = await _service.fetchRoutines(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // 약 등록
  Future<void> addRoutine(MedicationRoutine routine) async {
    _setLoading(true);
    _clearError();
    try {
      await _service.createRoutine(routine);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 약 수정
  Future<void> updateRoutine(MedicationRoutine routine) async {
    _setLoading(true);
    _clearError();
    try {
      await _service.updateRoutine(routine);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 약 삭제
  Future<void> deleteRoutine(int routineId) async {
    _setLoading(true);
    _clearError();
    try {
      await _service.deleteRoutine(routineId);
      // 목록에서 제거
      routines.removeWhere((routine) => routine.id == routineId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 에러 초기화
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 에러 초기화
  void _clearError() {
    _error = null;
  }
}
