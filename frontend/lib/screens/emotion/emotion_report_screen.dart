import 'package:flutter/material.dart';

class EmotionReportScreen extends StatelessWidget {
  final List<dynamic> finalResponse;

  const EmotionReportScreen({
    super.key,
    required this.finalResponse,
  });

  // **로 감싸진 텍스트를 볼드체로 변환하는 함수
  Widget _buildFormattedText(String text) {
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    final List<TextSpan> spans = [];
    int currentIndex = 0;

    for (final Match match in boldPattern.allMatches(text)) {
      // 매치 이전의 일반 텍스트 추가
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ));
      }

      // 볼드 텍스트 추가
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
      ));

      currentIndex = match.end;
    }

    // 남은 텍스트 추가
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ));
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 디버깅 출력 추가
    print('=== EmotionReportScreen Debug ===');
    print('finalResponse length: ${finalResponse.length}');
    print('finalResponse content:');
    for (int i = 0; i < finalResponse.length; i++) {
      print('  [$i]: ${finalResponse[i]}');
    }
    print('===============================');
    
    // Flutter의 debugPrint도 사용
    debugPrint('finalResponse: $finalResponse');
    
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/character_icon.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 32),
                      ...finalResponse.map((response) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildFormattedText(response),
                      )).toList(),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 