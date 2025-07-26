import 'package:flutter/material.dart';
import 'package:frontend/screens/emotion/emotion_understand_screen.dart';
import 'package:frontend/screens/navigationbar_screen.dart';

// 미션 카드 위젯
class MissionCard extends StatefulWidget {
  final String missionText;
  final bool isCompleted;
  final VoidCallback? onTap;

  const MissionCard({
    super.key,
    required this.missionText,
    required this.isCompleted,
    this.onTap,
  });

  @override
  State<MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends State<MissionCard> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF393939),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 왼쪽 컬러 바: 체크되지 않았을 때만 표시
              !isChecked
                  ? Container(
                      width: 8,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 152, 205, 91),
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(12),
                        ),
                      ),
                    )
                  : const SizedBox(width: 0),
              Expanded(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: Container(
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
                  title: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      widget.missionText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    isChecked ? Icons.check : Icons.crop_square,
                    color: isChecked
                        ? const Color.fromARGB(255, 152, 205, 91)
                        : Colors.grey[300],
                    size: 28,
                  ),
                  onTap: () {
                    // 각 미션에 따른 페이지 이동
                    switch (widget.missionText) {
                      case '오늘치 모든 약을 먹었어요!':
                        // 바텀 네비게이션을 통해 복약 화면으로 이동 (인덱스 1)
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NavigationScreen(initialIndex: 1),
                          ),
                        );
                        break;
                      case '오늘 내 감정을 살펴봤어요.':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmotionUnderstandScreen(),
                          ),
                        );
                        break;
                      case '건강한 잠을 잤어요~':
                        // 바텀 네비게이션을 통해 수면 화면으로 이동 (인덱스 3)
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NavigationScreen(initialIndex: 3),
                          ),
                        );
                        break;
                      case '추천 음악을 들어봐요!':
                        widget.onTap?.call();
                        break;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
