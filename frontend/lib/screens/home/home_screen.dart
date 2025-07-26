import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Mindtune',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Symbols.notifications, color: Colors.white),
            onPressed: () {
              // TODO: 알림 화면으로 이동
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단~네모 4개까지 패딩 적용
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23232A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '\n이 컨테이너에',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '무슨 내용이 들어가면 좋을까요????\n',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 네비게이션 카드 4개 (버튼 + 아이콘 + 텍스트)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _HomeNavButton(
                        icon: Symbols.pill,
                        label: '복약 추가',
                        onTap: () {
                          // TODO: 복약 관리 화면에서 바로 복약 추가 바텀시트 띄우기
                        },
                      ),
                      _HomeNavButton(
                        icon: Symbols.psychology,
                        label: '감정 진단',
                        onTap: () {
                          // TODO: 감정 진단 세 가지 종류 선택하는 화면으로 이동
                        },
                      ),
                      _HomeNavButton(
                        icon: Symbols.music_note,
                        label: '음악 목록',
                        onTap: () {
                          // TODO: 출석 체크 화면으로 이동
                        },
                      ),
                      _HomeNavButton(
                        icon: Symbols.store,
                        label: '포인트 상점',
                        onTap: () {
                          // TODO: 포인트 상점 화면으로 이동
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // 아래 영역은 패딩 없이 전체 너비
            Container(
              decoration: const BoxDecoration(color: Color(0xFF141414)),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // 건강 미션 헤더
                    const Text(
                      '건강 미션으로 포인트 받기!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 미션 리스트
                    Column(
                      children: [
                        _MissionCard(
                          missionText: '오늘치 모든 약을 먹었어요!',
                          isCompleted: true,
                        ),
                        const SizedBox(height: 8),
                        _MissionCard(
                          missionText: '오늘 내 감정을 살펴봤어요.',
                          isCompleted: true,
                        ),
                        const SizedBox(height: 8),
                        _MissionCard(
                          missionText: '건강한 잠을 잤어요~',
                          isCompleted: true,
                        ),
                        const SizedBox(height: 8),
                        _MissionCard(
                          missionText: '오늘 내 마음을 기록해요.',
                          isCompleted: true,
                        ),
                        const SizedBox(height: 8),
                        _MissionCard(
                          missionText: 'MindTune으로 나를 보살펴요',
                          isCompleted: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // 상단 복약상태/음악 추천 박스
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 헤더
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '오늘의 추천 플레이리스트',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '지금 기분이 어떠신가요?',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '00님의 기분에 맞는 음악을 추천해드릴게요!',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        // 기분 선택
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _MoodSelector(emoji: '😄', isSelected: true),
                              _MoodDivider(),
                              _MoodSelector(emoji: '🙂', isSelected: false),
                              _MoodDivider(),
                              _MoodSelector(emoji: '😐', isSelected: false),
                              _MoodDivider(),
                              _MoodSelector(emoji: '😔', isSelected: false),
                              _MoodDivider(),
                              _MoodSelector(emoji: '😢', isSelected: false),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 추천 카테고리
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              _RecommendationCategory(
                                icon: Icons.celebration,
                                iconColor: Colors.red,
                                title: '기분 고조/에너지 충전 - 100-120 BPM',
                                description: '활력 유지, 도파민 유지, 활동 유도',
                              ),
                              const SizedBox(height: 12),
                              _RecommendationCategory(
                                icon: Icons.wb_sunny,
                                iconColor: Colors.orange,
                                title: '미소 머금은 따뜻함 유지 - 80-95 BPM',
                                description: '평온한 기쁨 유지, 정서 안정',
                              ),
                              const SizedBox(height: 12),
                              _RecommendationCategory(
                                icon: Icons.local_florist,
                                iconColor: Colors.pink,
                                title: '잔잔한 행복감 정착 - 70-80 BPM',
                                description: '과잉 자극 없이 감정의 여운을 유지',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 네비게이션 버튼 위젯
class _HomeNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _HomeNavButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// 미션 카드 위젯
class _MissionCard extends StatelessWidget {
  final String missionText;
  final bool isCompleted;

  const _MissionCard({required this.missionText, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 왼쪽 세로 바
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // 원형 아이콘
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '약',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 미션 텍스트
          Expanded(
            child: Text(
              missionText,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          // 체크마크
          Icon(Icons.check, color: Colors.green, size: 20),
        ],
      ),
    );
  }
}

// 기분 선택 위젯
class _MoodSelector extends StatelessWidget {
  final String emoji;
  final bool isSelected;

  const _MoodSelector({required this.emoji, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: 기분 선택 로직 구현
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          emoji,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

// 기분 선택 구분선 위젯
class _MoodDivider extends StatelessWidget {
  const _MoodDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 20, color: Colors.white70);
  }
}

// 추천 카테고리 위젯
class _RecommendationCategory extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _RecommendationCategory({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
