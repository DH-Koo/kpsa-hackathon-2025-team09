import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';

/// 백엔드 API와 통신하는 채팅 서비스 클래스
class ChatApiService {
  static final ChatApiService _instance = ChatApiService._internal();
  factory ChatApiService() => _instance;
  ChatApiService._internal();

  // HTTP 클라이언트 - 연결 관리를 위해 수정
  http.Client? _client;

  // HTTP 클라이언트 초기화
  http.Client get _getClient {
    _client ??= http.Client();
    return _client!;
  }

  // 기본 헤더
  Map<String, String> get _headers => {...ApiConfig.defaultHeaders};

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
            switch (response.statusCode) {
              case 404:
                errorMessage = '요청한 API 엔드포인트를 찾을 수 없습니다.';
                break;
              case 500:
                errorMessage = '서버 내부 오류가 발생했습니다.';
                break;
              case 401:
                errorMessage = '인증이 필요합니다. 로그인을 다시 시도해주세요.';
                break;
              case 403:
                errorMessage = '접근 권한이 없습니다.';
                break;
              default:
                errorMessage = '서버 오류가 발생했습니다. (${response.statusCode})';
            }
          } else {
            errorMessage = '서버 응답을 처리할 수 없습니다. (${response.statusCode})';
          }
        }
      } catch (e) {
        // JSON 파싱 실패 시
        if (response.body.contains('<!DOCTYPE html>') ||
            response.body.contains('<html>')) {
          errorMessage = '서버에서 HTML 페이지를 반환했습니다. (${response.statusCode})';
        } else {
          errorMessage = '응답을 처리할 수 없습니다. (${response.statusCode})';
        }
      }

      throw ApiException(errorMessage, response.statusCode);
    }
  }

  // GET 요청 헬퍼 (재시도 로직 제거)
  Future<T> get<T>(String endpoint) async {
    try {
      final response = await _getClient
          .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: _headers)
          .timeout(ApiConfig.timeout);

      _handleError(response);
      return json.decode(response.body) as T;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
    }
  }

  // POST 요청 헬퍼 (재시도 로직 제거)
  Future<T> post<T>(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _getClient
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
            body: json.encode(data),
          )
          .timeout(ApiConfig.timeout);
      print(response);
      _handleError(response);
      final parsedResponse = json.decode(response.body) as T;
      return parsedResponse;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
    }
  }

  // PUT 요청 헬퍼
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _getClient
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
// DELETE 요청 헬퍼
  Future<void> delete(String endpoint) async {
    try {
      final response = await _getClient
          .delete(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: _headers)
          .timeout(ApiConfig.timeout);
      _handleError(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
    }
  }
  
  static Future<String> sendMessageToBot(String userInput, int userId, bool isWorkflow, int? sessionId) async {
    final data = <String, dynamic>{
      'user_input': userInput,
      'user_id': userId,
      'is_workflow': isWorkflow ?? false,
      'character_id': 0,
    };
    
    // session_id가 있으면 추가
    if (sessionId != null) {
      data['session_id'] = sessionId;
    }
    print(data);
    try {
      final response = await ChatApiService().post<dynamic>(ApiConfig.postChatSession, data);
      print(response);
      // 응답이 List인 경우와 Map인 경우를 모두 처리
      if (response is List) {
        // List인 경우 첫 번째 요소의 'response' 필드를 사용하거나 전체를 문자열로 변환
        if (response.isNotEmpty && response.first is Map) {
          final firstItem = response.first as Map;
          final responseText = firstItem['response'];
          return responseText?.toString() ?? firstItem.toString();
        } else {
          return response.toString();
        }
      } else if (response is Map) {
        // Map인 경우 전체 객체를 JSON 문자열로 반환 (session_id 포함)
        return json.encode(response);
      } else {
        // 그 외의 경우 문자열로 변환
        return response.toString();
      }
    } catch (e) {
      rethrow;
    }
  }
}


// API 예외 클래스
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}