import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workflow_chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/chat_message.dart';
import 'dart:convert'; // Added for json.decode
import 'emotion_report_screen.dart';

class EmotionWorkFlowScreen extends StatefulWidget {
  const EmotionWorkFlowScreen({super.key});

  @override
  State<EmotionWorkFlowScreen> createState() => _EmotionWorkFlowScreenState();
}

class _EmotionWorkFlowScreenState extends State<EmotionWorkFlowScreen> {
  int? _selectedIndex;
  bool _hasInitialized = false;
  List<String> _responseList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        _sendInitialMessage();
        _hasInitialized = true;
      }
    });
  }

  void _sendInitialMessage() {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? 0;
    context.read<WorkflowChatProvider>().sendMessage('start!', userId, true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkflowChatProvider>(
      builder: (context, chatProvider, child) {
        // 마지막 model 메시지에서 response 리스트 파싱
        final lastModelMsg = chatProvider.messages.lastWhere(
          (m) => m.isModel,
          orElse: () => ChatMessage(
            id: 0,
            sessionId: 0,
            sender: 'model',
            message: '',
            order: 0,
          ),
        );
        List<String> responseList = _parseResponseList(lastModelMsg.message);
        if (responseList.isNotEmpty && responseList != _responseList) {
          _responseList = responseList;
        }
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Expanded(
                    child: _responseList.isEmpty
                        ? _buildLoadingView()
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 24),
                                Text(
                                  _responseList[0],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 48),
                                ...List.generate(
                                  _responseList.length > 1
                                      ? _responseList.length - 1
                                      : 0,
                                  (i) => Column(
                                    children: [
                                      _buildOptionButton(
                                        i,
                                        _responseList[i + 1],
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).maybePop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF232B34),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: const Text(
                            '이전',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedIndex != null
                              ? () {
                                  // 선택한 옵션의 텍스트를 content로 하여 메시지 전송
                                  if (_selectedIndex != null &&
                                      _responseList.length >
                                          _selectedIndex! + 1) {
                                    final selectedText =
                                        _responseList[_selectedIndex! + 1];
                                    final authProvider = context
                                        .read<AuthProvider>();
                                    final userId =
                                        authProvider.currentUser?.id ?? 0;
                                    final chatProvider = context
                                        .read<WorkflowChatProvider>();
                                    chatProvider.sendMessage(
                                      selectedText,
                                      userId,
                                      true,
                                      chatProvider.currentSessionId,
                                    );

                                    // 선택 상태 초기화
                                    setState(() {
                                      _selectedIndex = null;
                                    });
                                  }
                                }
                              : () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedIndex != null
                                ? const Color(0xFF232B34)
                                : const Color(0xFF232B34).withOpacity(0.5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: Text(
                            '다음 단계',
                            style: TextStyle(
                              color: _selectedIndex != null
                                  ? Colors.white
                                  : Colors.white24,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // message(String)에서 response 리스트 파싱 (JSON 형태)
  List<String> _parseResponseList(String message) {
    try {
      // 전체 응답이 JSON 객체인지 확인 (session_id 포함)
      if (message.startsWith('{') && message.endsWith('}')) {
        final Map<String, dynamic> responseData = json.decode(message);
        final response = responseData['response'];
        final isFinalAnswer = responseData['is_final_answer'] ?? false;

        // is_final_answer가 true인 경우 WorkflowChatProvider 상태 초기화 후 EmotionReportScreen으로 이동
        if (isFinalAnswer) {
          // WorkflowChatProvider 상태 초기화
          print('!!!!!!!!!!!!!!!!!!!!!!!!!resetState!!!!!!!!!!!!!!!!!!!!!!!');
          context.read<WorkflowChatProvider>().resetState();
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => EmotionReportScreen(
                  finalResponse: response is List ? response[0] : response.toString(),
                ),
              ),
            );
          });
          return [];
        }

        // response가 리스트인 경우
        if (response is List) {
          final List<String> result = response
              .map((item) => item.toString())
              .toList();
          return result;
        }
        // response가 문자열인 경우 (단일 질문)
        else if (response is String) {
          return [response];
        }
      }

      // JSON 형태의 리스트인지 확인
      if (message.startsWith('[') && message.endsWith(']')) {
        final List<dynamic> jsonList = json.decode(message);
        final List<String> result = jsonList
            .map((item) => item.toString())
            .toList();
        return result;
      }

      // 기존 정규식 방식 (백업)
      final decoded = message.contains('[')
          ? RegExp(r'\[(.*?)\]', dotAll: true).firstMatch(message)?.group(0)
          : null;
      if (decoded != null) {
        final list = decoded
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((e) => e.trim().replaceAll(RegExp(r'^"|"$'), ''))
            .where((e) => e.isNotEmpty)
            .toList();
        return list;
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/character_icon.png',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 24),
          const Text(
            '로딩 중...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(int index, String text) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
