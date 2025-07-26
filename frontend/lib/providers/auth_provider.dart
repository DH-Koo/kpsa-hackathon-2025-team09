import 'package:flutter/material.dart';
import 'package:frontend/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/chat_provider.dart';
import '../models/user.dart';
import '../service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  ChatProvider? _chatProvider;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // SharedPreferences 키
  static const String _keyEmail = 'saved_email';
  static const String _keyPassword = 'saved_password';
  static const String _keyAutoLogin = 'auto_login_enabled';

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  // ChatProvider 설정 메서드
  void setChatProvider(ChatProvider chatProvider) {
    _chatProvider = chatProvider;
  }

  // 초기화 - 앱 시작 시 로그인 상태 확인
  Future<void> initialize() async {
    await _authService.initialize();
    _currentUser = _authService.currentUser;
    _setLoading(false);
  }

  // 로그인
  Future<bool> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    // 디버깅: 로그인 시작
    print('[AuthProvider] 로그인 시작: email=$email, rememberMe=$rememberMe');
    
    _setLoading(true);
    _clearError();

    try {
      // 디버깅: AuthService.login 호출
      print('[AuthProvider] AuthService.login 호출');
      final result = await _authService.login(email, password);
      
      // 디버깅: 로그인 결과 출력
      print('[AuthProvider] 로그인 결과: $result');

      // success 키가 있으면 그것을 사용하고, 없으면 사용자 정보가 있으면 성공으로 처리
      final isSuccess = result['success'] == true || result['id'] != null;
      
      // 디버깅: 성공 여부 확인
      print('[AuthProvider] 로그인 성공 여부: $isSuccess');

      if (isSuccess) {
        // user 키가 있으면 user 객체를 사용, 없으면 result 자체를 사용자 정보로 사용
        final userData = result['user'] ?? result;
        _currentUser = User.fromJson(userData);
        
        // 디버깅: 사용자 정보 설정
        print('[AuthProvider] 사용자 정보 설정: ${_currentUser?.toJson()}');

        // 자동 로그인 설정
        if (rememberMe) {
          print('[AuthProvider] 자동 로그인 활성화 및 자격 증명 저장');
          await setAutoLoginEnabled(true);
          await saveLoginCredentials(email, password);
        } else {
          print('[AuthProvider] 자동 로그인 비활성화 및 자격 증명 삭제');
          await setAutoLoginEnabled(false);
          await clearSavedCredentials();
        }

        // // ChatProvider에 사용자 ID 설정
        // if (_chatProvider != null) {
        //   _chatProvider!.setCurrentUserId(_currentUser!.id);
        // }

        // // 채팅 관련 데이터 로드
        // await _loadChatData();

        notifyListeners();
        print('[AuthProvider] 로그인 성공 완료');
        return true;
      } else {
        _error = result['message'] ?? '로그인에 실패했습니다.';
        print('[AuthProvider] 로그인 실패: $_error');
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _error = e.message;
      print('[AuthProvider] ApiException 발생: $_error');
      notifyListeners();
      return false;
    } catch (e) {
      _error = '로그인 중 오류가 발생했습니다: $e';
      print('[AuthProvider] 일반 예외 발생: $_error');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
      print('[AuthProvider] 로그인 프로세스 완료');
    }
  }

  // 회원가입
  Future<bool> signup(String email, String name, String password, DateTime birth) async {
    _setLoading(true);
    _clearError();

    try {
      // 기본값으로 회원가입 (나중에 상세 정보 입력 화면 추가)
      final user = await _authService.signup(
        email: email,
        password: password,
        name: name,
        birth: birth,
      );

      _currentUser = user;

      // // ChatProvider에 사용자 ID 설정
      // if (_chatProvider != null) {
      //   _chatProvider!.setCurrentUserId(user.id);
      // }

      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '회원가입 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 로그아웃
  Future<void> logout() async {
    _setLoading(true);

    try {
      // AuthService의 logout 호출하여 완전한 로그아웃 수행
      await _authService.logout();

      _currentUser = null;

      // 자동 로그인 정보 삭제
      await clearSavedCredentials();

      // // ChatProvider에서 사용자 ID 초기화
      // if (_chatProvider != null) {
      //   _chatProvider!.setCurrentUserId(0); // 0은 유효하지 않은 ID로 처리
      // }

      _clearError();
      notifyListeners();
    } catch (e) {
      _error = '로그아웃 중 오류가 발생했습니다: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // 프로필 업데이트
  Future<bool> updateProfile(Map<String, dynamic> updateData) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _authService.updateProfile(
        _currentUser!.id,
        updateData,
      );
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '프로필 업데이트 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 프로필 새로고침
  Future<bool> refreshProfile() async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.getProfile(_currentUser!.id);
      _currentUser = user;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '프로필 새로고침 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 에러 초기화
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // 내부 메서드들
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // 자동 로그인 관련 메서드
  Future<bool> isAutoLoginEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoLogin) ?? false;
  }

  Future<void> setAutoLoginEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoLogin, enabled);
  }

  Future<void> saveLoginCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyEmail);
    final password = prefs.getString(_keyPassword);

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.setBool(_keyAutoLogin, false);
  }

  // 자동 로그인 시도
  Future<bool> tryAutoLogin() async {
    try {
      final isEnabled = await isAutoLoginEnabled();
      if (!isEnabled) {
        return false;
      }

      final credentials = await getSavedCredentials();
      if (credentials == null) {
        return false;
      }

      _isLoading = true;
      notifyListeners();

      final result = await _authService.login(
        credentials['email']!,
        credentials['password']!,
      );

      // success 키가 있으면 그것을 사용하고, 없으면 사용자 정보가 있으면 성공으로 처리
      final isSuccess = result['success'] == true || result['id'] != null;

      if (isSuccess) {
        _currentUser = User.fromJson(result['user'] ?? result);
        _error = null;

        // // ChatProvider에 사용자 ID 설정
        // if (_chatProvider != null) {
        //   _chatProvider!.setCurrentUserId(_currentUser!.id);
        // }

        // // 채팅 관련 데이터 로드
        // await _loadChatData();

        notifyListeners();
        return true;
      } else {
        final errorMsg = result['message'] ?? '자동 로그인에 실패했습니다.';
        _error = errorMsg;
        await clearSavedCredentials(); // 실패 시 저장된 정보 삭제
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '자동 로그인 중 오류가 발생했습니다: $e';
      await clearSavedCredentials(); // 오류 시 저장된 정보 삭제
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // // 채팅 데이터 로드
  // Future<void> _loadChatData() async {
  //   if (_chatProvider != null) {
  //     await _chatProvider!.loadSessions();
  //   }
  // }
}
