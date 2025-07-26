import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // HTTP 클라이언트
  final http.Client _client = http.Client();

  // SharedPreferences 키
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';

  // 현재 사용자 정보
  User? _currentUser;
  String? _authToken;

  // 기본 헤더
  Map<String, String> get _headers => {...ApiConfig.defaultHeaders};

  // 현재 사용자 getter
  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoggedIn => _currentUser != null && _authToken != null;

  // 초기화
  Future<void> initialize() async {
    await _loadUserFromStorage();
    await _loadTokenFromStorage();
  }

  // 로컬 저장소에서 사용자 정보 로드
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final userData = json.decode(userJson);
        _currentUser = User.fromJson(userData);
      }
    } catch (e) {
      print('사용자 정보 로드 실패: $e');
      _currentUser = null;
    }
  }

  // 로컬 저장소에 사용자 정보 저장
  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(user.toJson()));
      _currentUser = user;
    } catch (e) {
      print('사용자 정보 저장 실패: $e');
    }
  }

  // 로컬 저장소에 토큰 저장
  Future<void> _saveTokenToStorage(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      _authToken = token;
    } catch (e) {
      print('토큰 저장 실패: $e');
    }
  }

  // 로컬 저장소에서 토큰 로드
  Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(_tokenKey);
    } catch (e) {
      print('토큰 로드 실패: $e');
      _authToken = null;
    }
  }

  // 자동 로그인 시도
  Future<bool> tryAutoLogin() async {
    if (_currentUser != null && _authToken != null) {
      try {
        // 토큰 유효성 검증을 위해 프로필 조회
        await getProfile(_currentUser!.id);
        return true;
      } catch (e) {
        // 토큰이 유효하지 않으면 로그아웃
        await logout();
        return false;
      }
    }
    return false;
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
    } catch (e) {
      print('로그아웃 중 오류: $e');
    } finally {
      _currentUser = null;
      _authToken = null;
    }
  }

  // 사용자 데이터 삭제
  Future<void> deleteUserData() async {
    await logout();
  }

  // 에러 처리
  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      String errorMessage = '알 수 없는 오류가 발생했습니다.';

      try {
        // JSON 응답인지 확인
        if (response.headers['content-type']?.contains('application/json') ==
            true) {
          final errorData = json.decode(response.body);
          errorMessage =
              errorData['error'] ?? errorData['message'] ?? errorMessage;
        } else {
          // HTML 응답인 경우 (서버 에러 페이지)
          if (response.body.contains('<!DOCTYPE html>') ||
              response.body.contains('<html>')) {
            // HTML에서 에러 메시지 추출 시도
            if (response.body.contains('IntegrityError')) {
              errorMessage = '이미 존재하는 이메일입니다.';
            } else if (response.body.contains('ValidationError')) {
              errorMessage = '입력 데이터가 올바르지 않습니다.';
            } else {
              switch (response.statusCode) {
                case 400:
                  errorMessage = '잘못된 요청입니다.';
                  break;
                case 401:
                  errorMessage = '인증이 필요합니다.';
                  break;
                case 403:
                  errorMessage = '접근 권한이 없습니다.';
                  break;
                case 404:
                  errorMessage = '요청한 리소스를 찾을 수 없습니다.';
                  break;
                case 500:
                  errorMessage = '서버 내부 오류가 발생했습니다.';
                  break;
                default:
                  errorMessage = '서버 오류가 발생했습니다. (${response.statusCode})';
              }
            }
          } else {
            errorMessage = '서버 응답을 처리할 수 없습니다. (${response.statusCode})';
          }
        }
      } catch (e) {
        // JSON 파싱 실패 시
        if (response.body.contains('IntegrityError')) {
          errorMessage = '이미 존재하는 이메일입니다.';
        } else if (response.body.contains('ValidationError')) {
          errorMessage = '입력 데이터가 올바르지 않습니다.';
        } else {
          errorMessage = '서버 응답을 처리할 수 없습니다. (${response.statusCode})';
        }
      }

      throw ApiException(errorMessage, response.statusCode);
    }
  }

  // POST 요청 헬퍼
  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
            body: json.encode(data),
          )
          .timeout(ApiConfig.timeout);

      _handleError(response);
      return json.decode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
    }
  }

  // GET 요청 헬퍼
  Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: _headers)
          .timeout(ApiConfig.timeout);

      _handleError(response);
      return json.decode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
    }
  }

  // PUT 요청 헬퍼
  Future<Map<String, dynamic>> _put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .put(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
            body: json.encode(data),
          )
          .timeout(ApiConfig.timeout);

      _handleError(response);
      return json.decode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
    }
  }

  // 회원가입
  Future<User> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final userData = {'email': email, 'password': password, 'name': name};

    try {
      await _post(ApiConfig.userCreate, userData);

      // 회원가입 성공 후 로그인하여 사용자 정보 반환
      final loginResponse = await login(email, password);
      final user = User.fromJson(loginResponse);

      // 로컬 저장소에 사용자 정보와 토큰 저장
      await _saveUserToStorage(user);
      if (loginResponse['token'] != null) {
        await _saveTokenToStorage(loginResponse['token']);
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // 로그인
  Future<Map<String, dynamic>> login(String email, String password) async {
    // 더미 계정 로그인 (임시)
    if (email == 'test@test.com' && password == '123456') {
      final dummyUser = User(
        id: 1,
        email: email,
        name: '전성준',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        birth: DateTime(2002, 05, 20),
        job: '학생',
      );
      final dummyToken = 'dummy_token_123';
      await _saveUserToStorage(dummyUser);
      await _saveTokenToStorage(dummyToken);
      return {'user': dummyUser.toJson(), 'token': dummyToken, 'success': true};
    }

    final loginData = {'email': email, 'password': password};
    final response = await _post(ApiConfig.userLogin, loginData);

    // 로그인 성공 시 사용자 정보와 토큰을 로컬 저장소에 저장
    if (response['user'] != null) {
      final user = User.fromJson(response['user']);
      await _saveUserToStorage(user);
    }

    if (response['token'] != null) {
      await _saveTokenToStorage(response['token']);
    }

    return response;
  }

  // 프로필 조회
  Future<User> getProfile(int userId) async {
    final response = await _get('${ApiConfig.userProfile}$userId/');
    return User.fromJson(response);
  }

  // 프로필 수정
  Future<User> updateProfile(
    int userId,
    Map<String, dynamic> updateData,
  ) async {
    final response = await _put('${ApiConfig.userProfile}$userId/', updateData);
    return User.fromJson(response);
  }

  // 연결 해제
  void dispose() {
    _client.close();
  }
}
