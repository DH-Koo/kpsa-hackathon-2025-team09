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
  final TextEditingController _customInputController = TextEditingController();

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

  @override
  void dispose() {
    _customInputController.dispose();
    super.dispose();
  }

  // **로 감싸진 텍스트를 볼드체로 변환하는 함수
  Widget _buildFormattedText(String text, TextStyle baseStyle) {
    final List<Widget> widgets = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;
    
    for (Match match in boldPattern.allMatches(text)) {
      // ** 이전의 일반 텍스트
      if (match.start > lastIndex) {
        widgets.add(Text(
          text.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }
      
      // **로 감싸진 볼드 텍스트
      widgets.add(Text(
        match.group(1)!,
        style: baseStyle.copyWith(fontWeight: FontWeight.bold),
      ));
      
      lastIndex = match.end;
    }
    
    // 마지막 ** 이후의 일반 텍스트
    if (lastIndex < text.length) {
      widgets.add(Text(
        text.substring(lastIndex),
        style: baseStyle,
      ));
    }
    
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: widgets.map((widget) {
          if (widget is Text) {
            return TextSpan(
              text: widget.data,
              style: widget.style,
            );
          }
          return TextSpan();
        }).toList(),
      ),
    );
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

        // 로딩 상태 확인
        final bool isLoading = chatProvider.isLoading;
        
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
                    child: SingleChildScrollView(
                      child: _responseList.isEmpty && !isLoading
                          ? _buildLoadingView()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 질문 텍스트 또는 로딩 텍스트
                                  isLoading 
                                    ? Text(
                                        '생각 중...',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          height: 1.4,
                                        ),
                                      )
                                    : _buildFormattedText(
                                        _responseList.isNotEmpty ? _responseList[0] : '',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          height: 1.4,
                                        ),
                                      ),
                                  const SizedBox(height: 48),
                                  // 로딩 중이 아닐 때만 옵션 버튼들 표시
                                  if (!isLoading) ...[
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
                                    // 직접 입력 카드
                                    _buildCustomInputCard(),
                                    const SizedBox(height: 24),
                                  ],
                                ],
                              ),
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
                          onPressed: ((_selectedIndex != null || _customInputController.text.isNotEmpty) && !isLoading)
                              ? () {
                                  String selectedText = '';
                                  
                                  // 직접 입력이 있는 경우
                                  if (_customInputController.text.isNotEmpty) {
                                    selectedText = _customInputController.text;
                                  }
                                  // 옵션 선택이 있는 경우
                                  else if (_selectedIndex != null &&
                                      _responseList.length >
                                          _selectedIndex! + 1) {
                                    selectedText = _responseList[_selectedIndex! + 1];
                                  }
                                  
                                  if (selectedText.isNotEmpty) {
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
                                      _customInputController.clear();
                                    });
                                  }
                                }
                              : null, // 로딩 중이거나 아무것도 선택하지 않았을 때 비활성화
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ((_selectedIndex != null || _customInputController.text.isNotEmpty) && !isLoading)
                                ? Color.fromARGB(255, 152, 205, 91) 
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
                              color: ((_selectedIndex != null || _customInputController.text.isNotEmpty) && !isLoading)
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
        print('check point 1');
        final Map<String, dynamic> responseData = json.decode(message);
        final response = responseData['response'];
        print(responseData);
        final isFinalAnswer = responseData['is_final_answer'] ?? false;

        print('is_final_answer: $isFinalAnswer');
        // is_final_answer가 true인 경우 WorkflowChatProvider 상태 초기화 후 EmotionReportScreen으로 이동
        if (response[0] is List) {
          // WorkflowChatProvider 상태 초기화
          print('!!!!!!!!!!!!!!!!!!!!!!!!!resetState!!!!!!!!!!!!!!!!!!!!!!!');
          print('DEBUG: About to reset WorkflowChatProvider state');
          context.read<WorkflowChatProvider>().resetState();
          print('DEBUG: WorkflowChatProvider state reset completed');
          print(response);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('DEBUG: Navigating to EmotionReportScreen');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => EmotionReportScreen(
                  finalResponse: response[0] ,
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
            color: isSelected ? Color.fromARGB(255, 152, 205, 91) : Colors.white24,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: _buildFormattedText(
          text,
          TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.white54,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomInputCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Colors.white24,
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: TextField(
        controller: _customInputController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          hintText: '직접 입력하기',
          hintStyle: TextStyle(
            color: Colors.white54,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) {
          // 직접 입력 시 다른 옵션 선택 해제
          if (value.isNotEmpty) {
            setState(() {
              _selectedIndex = null;
            });
          }
        },
      ),
    );
  }
}