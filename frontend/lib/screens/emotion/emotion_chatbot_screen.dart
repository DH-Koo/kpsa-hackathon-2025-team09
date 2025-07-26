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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF181F26),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      '2025년 7월 24일 목요일',
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
                  fontSize: 16,
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
                  child: Text(
                    message.message,
                    style: TextStyle(color: Colors.white, fontSize: 15),
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
                        width: hasText ? 44 : (shouldShowStopButton ? 60 : 44),
                        height: 44,
                        padding: hasText
                            ? null
                            : (shouldShowStopButton
                                  ? const EdgeInsets.symmetric(horizontal: 16)
                                  : null),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 152, 205, 91),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: hasText
                            ? const Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                              )
                            : shouldShowStopButton
                            ? Container(
                                alignment: Alignment.center,
                                child: Text(
                                  '그만하기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : const Icon(
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
