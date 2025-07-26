class ApiConfig {
  // 개발 환경
  static const String baseUrl = 'http://10.64.143.171:8000/api';

  // 유저 API 엔드포인트
  static const String userCreate = '/user/create/';
  static const String userLogin = '/user/login/';
  static const String userProfile = '/user/'; // /user/{user_id}/

  // 채팅 API 엔드포인트
  static const String getChatSessions =
      '/chat/users/'; // GET: users/{user_id}/sessions/
  static const String postChatSession =
      '/sessions/'; // POST: sessions/{user_id}/

  // 복약 관리 API 엔드포인트
  static const String medicineBase = '/medicine';
  static String medicineOfDay(int userId, String day, String weekday) =>
      '/medicine/medicine_of_day/$userId/$day/$weekday/';
  static const String medicineMusic = '/medicine/music/';
  static String medicineMusicList(int medicineId) =>
      '/medicine/music/$medicineId/';
  static const String medicineAI = '/medicine/ai/';

  // 헤더 설정
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 타임아웃 설정
  static const Duration timeout = Duration(seconds: 3);
}
