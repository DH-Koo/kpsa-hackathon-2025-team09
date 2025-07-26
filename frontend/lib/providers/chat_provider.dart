import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../service/api_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String content, int userId, bool isWorkflow) async {
    final order = _messages.length;
    _messages.add(ChatMessage(id: 0, sessionId: 0, message: content, sender: 'user', order: order));

    _isLoading = true;
    notifyListeners();

    try {
      final botResponse = await ChatApiService.sendMessageToBot(content, userId, isWorkflow);
      _messages.add(ChatMessage(id: 0, sessionId: 0, message: botResponse, sender: 'model', order: _messages.length));
    } catch (e) {
      _messages.add(ChatMessage(id: 0, sessionId: 0, message: '챗봇 응답 오류: $e', sender: 'model', order: _messages.length));
    }
    _isLoading = false;
    notifyListeners();
  }
}
