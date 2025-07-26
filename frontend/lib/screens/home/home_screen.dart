import 'package:flutter/material.dart';
import 'package:frontend/screens/home/widgets/mission_card.dart';
import 'package:frontend/screens/home/widgets/recommendation_category.dart';
import 'package:frontend/screens/navigationbar_screen.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  int? selectedMoodIndex; // 선택된 기분 인덱스 (null이면 아무것도 선택되지 않음)

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _toggleMoodSelection(int index) {
    setState(() {
      if (selectedMoodIndex == index) {
        // 같은 기분을 다시 누르면 선택 해제
        selectedMoodIndex = null;
      } else {
        // 다른 기분을 누르면 해당 기분 선택
        selectedMoodIndex = index;
        // 음악 추천 목록이 표시된 후 자동 스크롤
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToMusicRecommendations();
        });
      }
    });
  }

  void _scrollToMusicRecommendations() {
    // 음악 추천 섹션까지 스크롤
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  // TODO: 임시 기분별 음악 추천 데이터
  List<Map<String, dynamic>> _getMoodRecommendations(int moodIndex) {
    switch (moodIndex) {
      case 0: // 😄 매우 행복
        return [
          {
            'icon': Icons.celebration,
            'iconColor': Colors.red,
            'title': '기분 고조/에너지 충전 - 100-120 BPM',
            'description': '활력 유지, 도파민 유지, 활동 유도',
            'songs': [
              'Happy - Pharrell Williams',
              'Uptown Funk - Mark Ronson ft. Bruno Mars',
              'Can\'t Stop the Feeling! - Justin Timberlake',
            ],
          },
          {
            'icon': Icons.wb_sunny,
            'iconColor': Colors.orange,
            'title': '미소 머금은 따뜻함 유지 - 80-95 BPM',
            'description': '평온한 기쁨 유지, 정서 안정',
            'songs': [
              'Good Life - OneRepublic',
              'Walking on Sunshine - Katrina & The Waves',
              'I Gotta Feeling - The Black Eyed Peas',
            ],
          },
        ];
      case 1: // 🙂 보통
        return [
          {
            'icon': Icons.local_florist,
            'iconColor': Colors.pink,
            'title': '잔잔한 행복감 정착 - 70-80 BPM',
            'description': '과잉 자극 없이 감정의 여운을 유지',
            'songs': [
              'Perfect - Ed Sheeran',
              'All of Me - John Legend',
              'A Thousand Years - Christina Perri',
            ],
          },
          {
            'icon': Icons.music_note,
            'iconColor': Colors.blue,
            'title': '편안한 일상의 소리 - 60-70 BPM',
            'description': '일상의 평화로움을 느끼는 음악',
            'songs': [
              'The Scientist - Coldplay',
              'Fix You - Coldplay',
              'Yellow - Coldplay',
            ],
          },
        ];
      case 2: // 😐 무덤덤
        return [
          {
            'icon': Icons.cloud,
            'iconColor': Colors.grey,
            'title': '차분한 마음 정리 - 65-75 BPM',
            'description': '감정을 정리하고 마음을 차분히 하는 음악',
            'songs': [
              'Someone Like You - Adele',
              'Hello - Adele',
              'When We Were Young - Adele',
            ],
          },
          {
            'icon': Icons.psychology,
            'iconColor': Colors.purple,
            'title': '깊은 사고를 위한 음악 - 55-65 BPM',
            'description': '생각을 정리하고 깊이 있게 사고할 수 있는 음악',
            'songs': [
              'Mad World - Gary Jules',
              'Creep - Radiohead',
              'Hallelujah - Jeff Buckley',
            ],
          },
        ];
      case 3: // 😔 우울
        return [
          {
            'icon': Icons.favorite,
            'iconColor': Colors.pink,
            'title': '위로와 공감의 음악 - 70-80 BPM',
            'description': '슬픔을 이해하고 위로해주는 음악',
            'songs': [
              'Say Something - A Great Big World',
              'Skinny Love - Bon Iver',
              'The Night We Met - Lord Huron',
            ],
          },
          {
            'icon': Icons.lightbulb,
            'iconColor': Colors.yellow,
            'title': '희망을 찾는 음악 - 80-90 BPM',
            'description': '어둠 속에서 빛을 찾는 음악',
            'songs': [
              'Fight Song - Rachel Platten',
              'Brave - Sara Bareilles',
              'Roar - Katy Perry',
            ],
          },
        ];
      case 4: // 😢 매우 슬픔
        return [
          {
            'icon': Icons.healing,
            'iconColor': Colors.green,
            'title': '치유와 회복의 음악 - 60-70 BPM',
            'description': '마음의 상처를 치유하는 음악',
            'songs': [
              'Bridge Over Troubled Water - Simon & Garfunkel',
              'Lean On Me - Bill Withers',
              'You\'ve Got a Friend - James Taylor',
            ],
          },
          {
            'icon': Icons.self_improvement,
            'iconColor': Colors.teal,
            'title': '명상과 평온 - 50-60 BPM',
            'description': '마음을 진정시키고 평온을 찾는 음악',
            'songs': [
              'Weightless - Marconi Union',
              'Claire de Lune - Debussy',
              'Gymnopedie No.1 - Satie',
            ],
          },
        ];
      default:
        return [];
    }
  }

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
        controller: _scrollController,
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '복약상태 확인',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // TODO: 남은 약 개수 표시
                                  Text(
                                    '오늘 복용해야하는 약이 2개 남았어요!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NavigationScreen(initialIndex: 1),
                                    ),
                                  );
                                },
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
                      HomeNavButton(
                        icon: Symbols.pill,
                        iconColor: Colors.white,
                        label: '복약 추가',
                        onTap: () {
                          // TODO: 복약 관리 화면에서 바로 복약 추가 바텀시트 띄우기
                        },
                      ),
                      HomeNavButton(
                        icon: Symbols.psychology,
                        iconColor: Colors.white,
                        label: '감정 진단',
                        onTap: () {
                          // TODO: 감정 진단 세 가지 종류 선택하는 화면으로 이동
                        },
                      ),
                      HomeNavButton(
                        icon: Symbols.music_note,
                        iconColor: Colors.white,
                        label: '음악 목록',
                        onTap: () {
                          // TODO: 출석 체크 화면으로 이동
                        },
                      ),
                      HomeNavButton(
                        icon: Symbols.store,
                        iconColor: Colors.white,
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
              decoration: const BoxDecoration(color: Color(0xFF181818)),
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
                        MissionCard(
                          missionText: '오늘치 모든 약을 먹었어요!',
                          isCompleted: false,
                        ),
                        const SizedBox(height: 8),
                        MissionCard(
                          missionText: '오늘 내 감정을 살펴봤어요.',
                          isCompleted: false,
                        ),
                        const SizedBox(height: 8),
                        MissionCard(
                          missionText: '건강한 잠을 잤어요~',
                          isCompleted: false,
                        ),
                        const SizedBox(height: 8),
                        MissionCard(
                          missionText: '추천 음악을 들어봐요!',
                          isCompleted: false,
                          onTap: _scrollToBottom,
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
                              MoodSelector(
                                emoji: '😄',
                                isSelected: selectedMoodIndex == 0,
                                onTap: () => _toggleMoodSelection(0),
                              ),
                              MoodDivider(),
                              MoodSelector(
                                emoji: '🙂',
                                isSelected: selectedMoodIndex == 1,
                                onTap: () => _toggleMoodSelection(1),
                              ),
                              MoodDivider(),
                              MoodSelector(
                                emoji: '😐',
                                isSelected: selectedMoodIndex == 2,
                                onTap: () => _toggleMoodSelection(2),
                              ),
                              MoodDivider(),
                              MoodSelector(
                                emoji: '😔',
                                isSelected: selectedMoodIndex == 3,
                                onTap: () => _toggleMoodSelection(3),
                              ),
                              MoodDivider(),
                              MoodSelector(
                                emoji: '😢',
                                isSelected: selectedMoodIndex == 4,
                                onTap: () => _toggleMoodSelection(4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 선택된 기분에 따른 음악 추천 표시
                        if (selectedMoodIndex != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children:
                                  _getMoodRecommendations(selectedMoodIndex!)
                                      .map(
                                        (recommendation) => Column(
                                          children: [
                                            RecommendationCategory(
                                              icon: recommendation['icon'],
                                              iconColor:
                                                  recommendation['iconColor'],
                                              title: recommendation['title'],
                                              description:
                                                  recommendation['description'],
                                              songs: recommendation['songs'],
                                            ),
                                            if (_getMoodRecommendations(
                                                  selectedMoodIndex!,
                                                ).last !=
                                                recommendation)
                                              const SizedBox(height: 12),
                                          ],
                                        ),
                                      )
                                      .toList(),
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
class HomeNavButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const HomeNavButton({
    super.key,
    required this.icon,
    required this.iconColor,
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
              child: Icon(icon, color: iconColor, size: 32),
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

// 기분 선택 위젯
class MoodSelector extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodSelector({
    super.key,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 152, 205, 91)
              : Colors.transparent,
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
class MoodDivider extends StatelessWidget {
  const MoodDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 20, color: Colors.white70);
  }
}
