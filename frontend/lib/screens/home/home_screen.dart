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
                  // 상단 복약상태/음악 추천 박스
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
                        icon: Symbols.calendar_month,
                        label: '출석 체크',
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
              decoration: const BoxDecoration(
                color: Color(0xFF141414),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
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
                    // 복약 알림 카드 2x2 그리드
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // 상단(앱바+상단영역+패딩 등) 높이 대략 260으로 가정
                        final double availableHeight =
                            MediaQuery.of(context).size.height - 400;
                        final double cardHeight =
                            (availableHeight - 12) / 2; // 12는 중간 간격
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _HomeBigCard(
                                    icon: null,
                                    label: '오늘 복약률\n30%',
                                    onTap: () {
                                      // TODO: 복약 관리 화면으로 이동
                                    },
                                    height: cardHeight,
                                    medicationRate: 30,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _HomeBigCard(
                                    icon: Symbols.bar_chart,
                                    label: '추이 분석',
                                    onTap: () {
                                      // TODO: 복약, 감정, 수면 추이 분석 다 모아놓은 화면으로 이동
                                    },
                                    height: cardHeight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _HomeBigCard(
                                    icon: Symbols.flag,
                                    label: '미션',
                                    onTap: () {
                                      // TODO: 미션 화면으로 이동
                                    },
                                    height: cardHeight,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _HomeBigCard(
                                    icon: Symbols.book,
                                    label: '마음 일기',
                                    onTap: () {
                                      // TODO: 마음 일기 화면으로 이동
                                    },
                                    height: cardHeight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
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

// 2x2 카드 위젯 추가
class _HomeBigCard extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final double? height;
  final int? medicationRate;
  const _HomeBigCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.height,
    this.medicationRate,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 90,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // 배터리 효과 (복약률이 있을 때만)
            if (medicationRate != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: (height ?? 90) * (medicationRate! / 100),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 152, 205, 91),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
            // 기존 콘텐츠
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon != null
                      ? Icon(icon, color: Colors.white, size: 36)
                      : const SizedBox.shrink(),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
