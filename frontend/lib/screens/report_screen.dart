import 'package:flutter/material.dart';
import 'emotion/emotion_bar_chart.dart';

class MusicRecommendationScreen extends StatelessWidget {
  final int valenceLevel;
  final int arousalLevel;
  final int stressLevel;
  final int dominanceLevel;

  const MusicRecommendationScreen({
    super.key,
    required this.valenceLevel,
    required this.arousalLevel,
    required this.stressLevel,
    required this.dominanceLevel,
  });

  @override
  Widget build(BuildContext context) {
    // 임시 더미 음악 데이터
    final List<Map<String, String>> musicList = [
      {"title": "Calm Breeze", "artist": "Relaxing Sounds"},
      {"title": "Morning Energy", "artist": "Sunrise Band"},
      {"title": "Peaceful Mind", "artist": "Meditation Crew"},
      {"title": "Stress Free", "artist": "Chill Vibes"},
    ];

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
      body: Padding(
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
            Text(
              '오늘의 감정에 어울리는 음악을 추천드려요!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: musicList.length,
                separatorBuilder: (_, __) => Divider(color: Colors.grey[700]),
                itemBuilder: (context, index) {
                  final music = musicList[index];
                  return ListTile(
                    leading: Icon(Icons.music_note, color: Colors.greenAccent),
                    title: Text(
                      music["title"] ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      music["artist"] ?? '',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    trailing: Icon(Icons.play_arrow, color: Colors.white),
                    onTap: () {
                      // TODO: 음악 재생 기능 연결
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('음악 재생 기능은 추후 제공됩니다.')),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
