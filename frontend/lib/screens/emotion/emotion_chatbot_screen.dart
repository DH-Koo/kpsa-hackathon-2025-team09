import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';

class EmotionChatbotScreen extends StatefulWidget {
  const EmotionChatbotScreen({super.key});

  @override
  State<EmotionChatbotScreen> createState() => _EmotionChatbotScreenState();
}

class _EmotionChatbotScreenState extends State<EmotionChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 대화 새로고침 함수
  void _refreshChat() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232B34),
          title: const Text(
            '대화 새로고침',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '현재 대화가 모두 삭제됩니다.\n새로운 대화를 시작하시겠습니까?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performRefresh();
              },
              child: const Text(
                '새로고침',
                style: TextStyle(color: Color.fromARGB(255, 152, 205, 91)),
              ),
            ),
          ],
        );
      },
    );
  }

  // 실제 새로고침 수행
  void _performRefresh() {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? 0;
    context.read<ChatProvider>().clearMessages();
    
    // 새로고침 완료 후 스크롤을 맨 위로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF181F26),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshChat,
            tooltip: '대화 새로고침',
          ),
        ],
      ),
      backgroundColor: const Color(0xFF181F26),
      body: SafeArea(
        child: Column(
          children: [
            _buildDate(),
            const SizedBox(height: 8),
            Expanded(child: _buildChatList()),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildDate() {
    // 실제 날짜는 DateTime.now() 등으로 동적으로 변경 가능
    return Text(
      '2025년 7월 26일 토요일',
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildChatList() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messages = chatProvider.messages;
        final isLoading = chatProvider.isLoading;

        // 메시지가 추가되거나 로딩 상태가 변경될 때 스크롤을 최하단으로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          itemCount: messages.length + 1 + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == 0) {
              // 챗봇 첫 인사 + 이미지
              return _buildBotIntro();
            }
            if (isLoading && index == messages.length + 1) {
              // 로딩 애니메이션
              return _buildLoadingBubble();
            }
            final message = messages[index - 1];
            return _buildMessageBubble(message);
          },
        );
      },
    );
  }

  Widget _buildBotIntro() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 0, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.asset(
              'assets/images/chatbot.png',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '안녕!\n처음 만나서 반가워.\n앞으로 무슨 감정이든 나한테 알려줄래?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.asset(
              'assets/images/chatbot.png',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const LoadingDotsAnimation(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.sender == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                'assets/images/chatbot.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isUser
                      ? MediaQuery.of(context).size.width * 0.85
                      : MediaQuery.of(context).size.width * 0.7,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Color.fromARGB(255, 152, 205, 91).withOpacity(0.6)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildFormattedText(
                    message.message,
                    TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
          if (isUser) ...[const SizedBox(width: 8)],
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final isLoading = chatProvider.isLoading;
        final hasUserSentMessage = chatProvider.hasUserSentMessage;
        final hasText = _controller.text.trim().isNotEmpty;

        // 사용자가 메시지를 보낸 적이 있고, 텍스트가 없을 때만 "그만하기" 버튼 표시
        final shouldShowStopButton = hasUserSentMessage && !hasText;

        return Container(
          color: const Color(0xFF181F26),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF232B34),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: '답장하기',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    onChanged: (_) => setState(() {}), // 텍스트 변경 시 UI 업데이트
                    enabled: !isLoading,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              isLoading
                  ? Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(255, 152, 205, 91),
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: hasText
                          ? _sendMessage
                          : (shouldShowStopButton ? _stopChat : null),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 152, 205, 91),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id ?? 0;
      context.read<ChatProvider>().sendMessage(text, userId, false);
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _stopChat() {
    // 채팅 종료 로직 - 현재는 단순히 이전 화면으로 돌아감
    Navigator.of(context).pop();
  }
}

class LoadingDotsAnimation extends StatefulWidget {
  const LoadingDotsAnimation({super.key});

  @override
  State<LoadingDotsAnimation> createState() => _LoadingDotsAnimationState();
}

class _LoadingDotsAnimationState extends State<LoadingDotsAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        final dotCount = 3;

        // 점들이 순차적으로 나타나는 패턴: '.', '..', '...', '', '.', '..', '...'
        final cycle = (progress * 4).floor() % 4; // 0, 1, 2, 3

        String dots = '';
        for (int i = 0; i < dotCount; i++) {
          if (i < cycle) {
            dots += '.';
          } else {
            dots += ' ';
          }
        }

        return Text(
          dots,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
