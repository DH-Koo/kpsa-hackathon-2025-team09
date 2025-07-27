import 'dart:convert'; // Added for json.decode
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../service/api_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _hasUserSentMessage = false;
  int? _currentSessionId; // session_id 저장

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get hasUserSentMessage => _hasUserSentMessage;
  int? get currentSessionId => _currentSessionId;

  Future<void> sendMessage(String content, int userId, bool isWorkflow, [int? sessionId]) async {
    final order = _messages.length;
    _messages.add(ChatMessage(id: 0, sessionId: 0, message: content, sender: 'user', order: order));
    
    // 사용자가 메시지를 보냈음을 표시
    _hasUserSentMessage = true;

    _isLoading = true;
    notifyListeners();

    try {
      final botResponse = await ChatApiService.sendMessageToBot(content, userId, isWorkflow, sessionId ?? _currentSessionId);
      
      // 응답에서 session_id와 response 추출
      final responseData = _parseBotResponse(botResponse);
      if (responseData['session_id'] != null) {
        _currentSessionId = responseData['session_id'];
      }
      
      // 파싱된 response 텍스트를 사용
      final responseText = responseData['response'] ?? botResponse;
      _messages.add(ChatMessage(id: 0, sessionId: 0, message: responseText, sender: 'model', order: _messages.length));
    } catch (e) {
      _messages.add(ChatMessage(id: 0, sessionId: 0, message: '챗봇 응답 오류: $e', sender: 'model', order: _messages.length));
    }
    _isLoading = false;
    notifyListeners();
  }

  // 봇 응답에서 session_id와 response 추출
  Map<String, dynamic> _parseBotResponse(String botResponse) {
    try {
      final data = json.decode(botResponse);
      if (data is Map) {
        String responseText = '';
        
        // response 필드가 있는 경우
        if (data['response'] != null) {
          final response = data['response'];
          
          // response가 문자열인 경우
          if (response is String) {
            responseText = response;
          }
          // response가 리스트인 경우 첫 번째 요소 사용
          else if (response is List && response.isNotEmpty) {
            final firstItem = response.first;
            if (firstItem is String) {
              responseText = firstItem;
            } else {
              responseText = firstItem.toString();
            }
          }
          // 그 외의 경우 문자열로 변환
          else {
            responseText = response.toString();
          }
        }
        
        return {
          'session_id': data['session_id'],
          'response': responseText,
        };
      }
    } catch (e) {
      // 응답 파싱 실패 시 기본값 반환
      print('응답 파싱 오류: $e');
    }
    return {'session_id': null, 'response': botResponse};
  }

  // 상태 초기화 메서드
  void resetState() {
    print('!!!!!!!!!!!!!!!!!!!!!!!!!resetState');
    _messages = [];
    _hasUserSentMessage = false;
    _currentSessionId = null;
    notifyListeners();
  }

  // 대화 메시지 초기화 메서드
  void clearMessages() {
    _messages = [];
    _hasUserSentMessage = false;
    _currentSessionId = null;
    _isLoading = false;
    notifyListeners();
  }
}
