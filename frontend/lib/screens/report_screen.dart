import 'package:flutter/material.dart';
import 'emotion/emotion_bar_chart.dart';

// **로 감싸진 텍스트를 볼드체로 변환하는 함수
Widget buildFormattedText(String text, TextStyle baseStyle) {
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

class MusicRecommendationScreen extends StatelessWidget {
  final int valenceLevel;
  final int arousalLevel;
  final int stressLevel;
  final int dominanceLevel;
  final String responseText;

  const MusicRecommendationScreen({
    super.key,
    required this.valenceLevel,
    required this.arousalLevel,
    required this.stressLevel,
    required this.dominanceLevel,
    this.responseText = '',
  });

  @override
  Widget build(BuildContext context) {

    // 감정별 데이터 (null이면 데이터 없음)
    final emotionBarData = [
      BarChartEmotionData(
        label: '긍정성',
        value: valenceLevel.toDouble(),
        color: Colors.pinkAccent,
      ),
      BarChartEmotionData(
        label: '에너지',
        value: arousalLevel.toDouble(),
        color: Colors.amber,
      ),
      BarChartEmotionData(
        label: '스트레스',
        value: stressLevel.toDouble(),
        color: Colors.lightBlueAccent,
      ),
      BarChartEmotionData(
        label: '통제력',
        value: dominanceLevel.toDouble(),
        color: Colors.greenAccent,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('음악 추천'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 16),
            Text(
              '오늘의 감정 상태',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            EmotionBarChart(
              data: emotionBarData,
              backgroundColor: Colors.black,
              summary: '일에 집중이 잘 되었고 평온한 하루였네요!',
            ),
            SizedBox(height: 32),
            // API 응답 텍스트 표시
            if (responseText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[700]!, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.greenAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'AI 분석 결과',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    buildFormattedText(
                      responseText,
                      TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}
