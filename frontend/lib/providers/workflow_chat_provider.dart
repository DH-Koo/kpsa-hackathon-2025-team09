import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../service/api_service.dart';

class WorkflowChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _hasUserSentMessage = false;
  int? _currentSessionId;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get hasUserSentMessage => _hasUserSentMessage;
  int? get currentSessionId => _currentSessionId;

  Future<void> sendMessage(String content, int userId, bool isWorkflow, [int? sessionId]) async {
    final order = _messages.length;
    _messages.add(ChatMessage(id: 0, sessionId: 0, message: content, sender: 'user', order: order));
    
    _hasUserSentMessage = true;
    _isLoading = true;
    notifyListeners();

    try {
      final botResponse = await ChatApiService.sendMessageToBot(content, userId, isWorkflow, sessionId ?? _currentSessionId);
      
      final responseData = _parseBotResponse(botResponse);
      if (responseData['session_id'] != null) {
        _currentSessionId = responseData['session_id'];
      }
      
      _messages.add(ChatMessage(id: 0, sessionId: 0, message: botResponse, sender: 'model', order: _messages.length));
    } catch (e) {
      _messages.add(ChatMessage(id: 0, sessionId: 0, message: '챗봇 응답 오류: $e', sender: 'model', order: _messages.length));
    }
    _isLoading = false;
    notifyListeners();
  }

  Map<String, dynamic> _parseBotResponse(String botResponse) {
    try {
      final data = json.decode(botResponse);
      if (data is Map) {
        return {
          'session_id': data['session_id'],
          'response': data['response'],
        };
      }
    } catch (e) {
      // 응답 파싱 실패 시 기본값 반환
    }
    return {'session_id': null, 'response': botResponse};
  }

  void resetState() {
    print('DEBUG: WorkflowChatProvider.resetState() called');
    _messages = [];
    _hasUserSentMessage = false;
    _currentSessionId = null;
    print('DEBUG: WorkflowChatProvider state reset - messages: ${_messages.length}, hasUserSentMessage: $_hasUserSentMessage, currentSessionId: $_currentSessionId');
    notifyListeners();
    print('DEBUG: WorkflowChatProvider.resetState() completed');
  }
} 