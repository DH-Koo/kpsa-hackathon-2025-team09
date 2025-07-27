import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/emotion_report.dart';

class EmotionReportProvider with ChangeNotifier {
  List<EmotionReport> _reports = [];
  static const String _storageKey = 'emotion_reports';

  List<EmotionReport> get reports => List.unmodifiable(_reports);

  EmotionReportProvider() {
    _loadReports();
  }

  // 리포트 추가
  void addReport(EmotionReport report) {
    _reports.insert(0, report); // 최신 리포트를 맨 위에 추가
    _saveReports();
    notifyListeners();
  }

  // 리포트 삭제
  void removeReport(String id) {
    _reports.removeWhere((report) => report.id == id);
    _saveReports();
    notifyListeners();
  }

  // 특정 리포트 가져오기
  EmotionReport? getReport(String id) {
    try {
      return _reports.firstWhere((report) => report.id == id);
    } catch (e) {
      return null;
    }
  }

  // 날짜별 리포트 가져오기
  List<EmotionReport> getReportsByDate(DateTime date) {
    return _reports.where((report) {
      return report.createdAt.year == date.year &&
             report.createdAt.month == date.month &&
             report.createdAt.day == date.day;
    }).toList();
  }

  // 저장된 리포트 로드
  Future<void> _loadReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? reportsJson = prefs.getString(_storageKey);
      
      if (reportsJson != null) {
        final List<dynamic> reportsList = json.decode(reportsJson);
        _reports = reportsList
            .map((json) => EmotionReport.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading emotion reports: $e');
    }
  }

  // 리포트 저장
  Future<void> _saveReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String reportsJson = json.encode(
        _reports.map((report) => report.toJson()).toList(),
      );
      await prefs.setString(_storageKey, reportsJson);
    } catch (e) {
      print('Error saving emotion reports: $e');
    }
  }
} 