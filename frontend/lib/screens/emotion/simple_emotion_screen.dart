import 'package:flutter/material.dart';
import '../report_screen.dart';

class SimpleEmotionScreen extends StatefulWidget {
  const SimpleEmotionScreen({super.key});

  @override
  SimpleEmotionScreenState createState() => SimpleEmotionScreenState();
}

class SimpleEmotionScreenState extends State<SimpleEmotionScreen>
    with TickerProviderStateMixin {
  // 페이지 인덱스 상태 추가
  int _pageIndex = 0; // 0: 첫 페이지, 1: 감정 선택, 2: 마지막 페이지
  int _stressLevel = 0; // 1~10
  int _dominanceLevel = 0; // 1~10
  // 긍정성(Valence), 긴장도(Arousal) 상태 추가
  int _valenceLevel = 0; // 0~100
  int _arousalLevel = 0; // 0~100

  // 마우스 포인터 위치 상태
  Offset _mousePosition = Offset(0, 0);
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
        ),
        body: Stack(
          children: [
            // AnimatedSwitcher로 페이지별 내용 전환
            AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _buildPage(_pageIndex, screenSize),
            ),
            // 하단 dot indicator & Next/Prev 버튼
            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _pageIndex == i ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
            // Prev 버튼 (좌측 하단)
            if (_pageIndex > 0)
              Positioned(
                left: 30,
                bottom: 50,
                child: GestureDetector(
                  onTap: () {
                    if (_pageIndex > 0) setState(() => _pageIndex--);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white, size: 18),
                        SizedBox(width: 10),
                        Text(
                          "Prev",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Next 버튼 (우측 하단)
            if (_pageIndex < 2)
              Positioned(
                right: 30,
                bottom: 50,
                child: GestureDetector(
                  onTap: () {
                    if (_pageIndex < 2) setState(() => _pageIndex++);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Next",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int pageIndex, Size screenSize) {
    switch (pageIndex) {
      case 0:
        return Container(
          key: ValueKey(0),
          width: screenSize.width,
          height: screenSize.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              // X축, Y축 길이 계산 (여백 40)
              final double xStart = 40;
              final double xEnd = screenSize.width - 40;
              final double yStart = (screenSize.height - (xEnd - xStart)) / 2;
              final double yEnd = yStart + (xEnd - xStart);
              final double xMid = (xStart + xEnd) / 2;
              final double yMid = (yStart + yEnd) / 2;

              if (!_isInitialized) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateMousePosition(
                    Offset(xMid, yMid),
                    screenSize,
                    xStart: xStart,
                    xEnd: xEnd,
                    yStart: yStart,
                    yEnd: yEnd,
                  );
                });
              }
              final pointerAbs = Offset(
                xMid + _mousePosition.dx,
                yMid + _mousePosition.dy,
              );
              return GestureDetector(
                onTapDown: (details) {
                  _updateMousePosition(
                    details.localPosition, // globalPosition → localPosition
                    screenSize,
                    xStart: xStart,
                    xEnd: xEnd,
                    yStart: yStart,
                    yEnd: yEnd,
                  );
                },
                onPanUpdate: (details) {
                  _updateMousePosition(
                    details.localPosition, // globalPosition → localPosition
                    screenSize,
                    xStart: xStart,
                    xEnd: xEnd,
                    yStart: yStart,
                    yEnd: yEnd,
                  );
                },
                child: MouseRegion(
                  onHover: (event) {
                    _updateMousePosition(
                      event.localPosition, // position → localPosition
                      screenSize,
                      xStart: xStart,
                      xEnd: xEnd,
                      yStart: yStart,
                      yEnd: yEnd,
                    );
                  },
                  child: Stack(
                    children: [
                      PointerRadialBackground(
                        pointer: pointerAbs,
                        screenSize: screenSize,
                      ),
                      XYAxisBackground(
                        screenSize: screenSize,
                        xStart: xStart,
                        xEnd: xEnd,
                        yStart: yStart,
                        yEnd: yEnd,
                      ),
                      // 동그라미 포인터
                      Positioned(
                        left: pointerAbs.dx - 4,
                        top: pointerAbs.dy - 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 상단 중앙 문구
                      Positioned(
                        top: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '현재 감정 상태가 어떠신가요?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                              SizedBox(height: 40),
                              Text(
                                '긍정성: 감정의 긍정적/부정적 정도를 의미합니다.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Pretendard',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '긴장도: 감정의 흥분 또는 에너지 수준을 나타냅니다.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Pretendard',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 사분면별 감정 텍스트 (애니메이션)
                      _QuadrantEmotions(
                        pointerOffset: _mousePosition,
                        xLength: xEnd - xStart,
                        yLength: yEnd - yStart,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      case 1:
        return StressOnboardingPage(
          key: ValueKey(1),
          screenSize: screenSize,
          stressLevel: _stressLevel,
          onChanged: (v) => setState(() => _stressLevel = v),
        );
      case 2:
        return DominanceOnboardingPage(
          key: ValueKey(2),
          screenSize: screenSize,
          dominanceLevel: _dominanceLevel,
          onChanged: (v) => setState(() => _dominanceLevel = v),
          onComplete: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MusicRecommendationScreen(
                  valenceLevel: _valenceLevel,
                  arousalLevel: _arousalLevel,
                  stressLevel: _stressLevel,
                  dominanceLevel: _dominanceLevel,
                ),
              ),
            );
          },
        );
      default:
        return SizedBox.shrink();
    }
  }

  // 마우스 포인터 이동 제한
  void _updateMousePosition(
    Offset position,
    Size screenSize, {
    required double xStart,
    required double xEnd,
    required double yStart,
    required double yEnd,
  }) {
    setState(() {
      // 축 중앙 기준 상대좌표
      final double xMid = (xStart + xEnd) / 2;
      final double yMid = (yStart + yEnd) / 2;
      double dx = position.dx - xMid;
      double dy = position.dy - yMid;
      // 축 범위 내로 제한
      dx = dx.clamp(xStart - xMid, xEnd - xMid);
      dy = dy.clamp(yStart - yMid, yEnd - yMid);
      _mousePosition = Offset(dx, dy);
      // --- 긍정성/긴장도 계산 (0~100) ---
      // X축: xStart~xEnd → 0~100
      double xAbs = dx + xMid;
      double valence = ((xAbs - xStart) / (xEnd - xStart)) * 100;
      valence = valence.clamp(0, 100);
      _valenceLevel = valence.round();
      // Y축: yStart~yEnd → 0~100 (위가 0, 아래가 100)
      double yAbs = dy + yMid;
      double arousal = (1 - ((yAbs - yStart) / (yEnd - yStart))) * 100;
      arousal = arousal.clamp(0, 100);
      _arousalLevel = arousal.round();
      if (!_isInitialized) {
        _isInitialized = true;
      }
    });
  }
}

class PointerRadialBackground extends StatelessWidget {
  final Offset pointer;
  final Size screenSize;
  const PointerRadialBackground({
    required this.pointer,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: screenSize,
      painter: _PointerRadialPainter(pointer: pointer, screenSize: screenSize),
    );
  }
}

class _PointerRadialPainter extends CustomPainter {
  final Offset pointer;
  final Size screenSize;
  _PointerRadialPainter({required this.pointer, required this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    final center = pointer;
    final radius = size.longestSide * 0.1;
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.2,
      colors: [
        Color.fromARGB(255, 152, 205,91),
        //Color(0xFFB2FF59), // 0.0 - 형광 연두 (중심 밝은 초록)
        Color(0xFFCCFF90), // 0.2 - 연한 연두
        Color(0xFFE6F8C9), // 0.4 - 연초록-흰빛 섞인 느낌
        Color(0xFF101F10), // 0.85 - 거의 검정에 가까운 어두운 녹색
        Colors.black, // 1.0 - 완전 어두운 배경
      ],
      stops: [0.0, 0.2, 0.4, 0.6, 0.8],
    );
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _PointerRadialPainter oldDelegate) {
    return oldDelegate.pointer != pointer;
  }
}

class StressGradientBackground extends StatelessWidget {
  final double fillRatio; // 0.0 ~ 1.0
  final Size screenSize;
  const StressGradientBackground({
    required this.fillRatio,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: screenSize,
      painter: _StressGradientPainter(
        fillRatio: fillRatio,
        screenSize: screenSize,
      ),
    );
  }
}

class _StressGradientPainter extends CustomPainter {
  final double fillRatio;
  final Size screenSize;
  _StressGradientPainter({required this.fillRatio, required this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    final double fillHeight = size.height * fillRatio;
    // 연두색 그라데이션 (PointerRadialBackground에서 사용한 색상과 동일)
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Color.fromARGB(255, 152, 205,91),
        //Color(0xFFB2FF59), // 형광 연두
        Color(0xFFCCFF90),
        Color(0xFFE6F8C9),
        Color(0xFFDDE5CC),
        Color(0xFF101F10),
      ],
      stops: [0.0, 0.2, 0.4, 0.7, 1.0],
    );
    final rect = Rect.fromLTWH(
      0,
      size.height - fillHeight,
      size.width,
      fillHeight,
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    // 연두색 부분
    canvas.drawRect(rect, paint);
    // 나머지 검정색 부분
    if (fillHeight < size.height) {
      final blackRect = Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height - fillHeight,
      );
      final blackPaint = Paint()..color = Colors.black;
      canvas.drawRect(blackRect, blackPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StressGradientPainter oldDelegate) {
    return oldDelegate.fillRatio != fillRatio;
  }
}

class StressOnboardingPage extends StatelessWidget {
  final Size screenSize;
  final int stressLevel;
  final ValueChanged<int> onChanged;
  const StressOnboardingPage({
    Key? key,
    required this.screenSize,
    required this.stressLevel,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenSize.width,
      height: screenSize.height,
      child: Stack(
        children: [
          // 배경 그라데이션 차오름
          StressGradientBackground(
            fillRatio: stressLevel / 100.0,
            screenSize: screenSize,
          ),
          // 상단 문구
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '최근 스트레스는 어느정도 이신가요?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ),
          // 슬라이더
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$stressLevel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  width: screenSize.width * 0.7,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Color(0xFFB2FF59),
                      inactiveTrackColor: Colors.grey[800],
                      thumbColor: Color(0xFFB2FF59),
                      overlayColor: Color(0xFFB2FF59).withOpacity(0.2),
                      trackHeight: 8,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 14),
                    ),
                    child: Slider(
                      min: 0,
                      max: 100,
                      divisions: 100,
                      value: stressLevel.toDouble(),
                      onChanged: (v) => onChanged(v.round()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DominanceOnboardingPage extends StatelessWidget {
  final Size screenSize;
  final int dominanceLevel;
  final ValueChanged<int> onChanged;
  final VoidCallback? onComplete;
  const DominanceOnboardingPage({
    super.key,
    required this.screenSize,
    required this.dominanceLevel,
    required this.onChanged,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenSize.width,
      height: screenSize.height,
      child: Stack(
        children: [
          // 배경 그라데이션 차오름
          StressGradientBackground(
            fillRatio: dominanceLevel / 100.0,
            screenSize: screenSize,
          ),
          // 상단 문구
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '감정을 얼마나 통제하고 계신가요?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ),
          // 슬라이더
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$dominanceLevel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  width: screenSize.width * 0.7,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Color(0xFFB2FF59),
                      inactiveTrackColor: Colors.grey[800],
                      thumbColor: Color(0xFFB2FF59),
                      overlayColor: Color(0xFFB2FF59).withOpacity(0.2),
                      trackHeight: 8,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 14),
                    ),
                    child: Slider(
                      min: 0,
                      max: 100,
                      divisions: 100,
                      value: dominanceLevel.toDouble(),
                      onChanged: (v) => onChanged(v.round()),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 완료 버튼 (우측 하단)
          Positioned(
            right: 30,
            bottom: 50,
            child: GestureDetector(
              onTap: () {
                if (onComplete != null) {
                  onComplete!();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "완료",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.check, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// X, Y축만 크게 그리는 위젯 추가
class XYAxisBackground extends StatelessWidget {
  final Size screenSize;
  final double xStart, xEnd, yStart, yEnd;
  const XYAxisBackground({
    required this.screenSize,
    required this.xStart,
    required this.xEnd,
    required this.yStart,
    required this.yEnd,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: screenSize,
      painter: _XYAxisPainter(
        xStart: xStart,
        xEnd: xEnd,
        yStart: yStart,
        yEnd: yEnd,
      ),
    );
  }
}

class _XYAxisPainter extends CustomPainter {
  final double xStart, xEnd, yStart, yEnd;
  _XYAxisPainter({
    required this.xStart,
    required this.xEnd,
    required this.yStart,
    required this.yEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 격자선 추가
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1;
    // x축 기준 4등분(5개 선), y축 기준 4등분(5개 선)
    for (int i = 1; i < 10; i++) {
      // 수직선 (y축과 평행)
      final double x = xStart + (xEnd - xStart) * i / 10;
      canvas.drawLine(Offset(x, yStart), Offset(x, yEnd), gridPaint);
      // 수평선 (x축과 평행)
      final double y = yStart + (yEnd - yStart) * i / 10;
      canvas.drawLine(Offset(xStart, y), Offset(xEnd, y), gridPaint);
    }
    final Paint axisPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
    final Paint arrowPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    // X축
    canvas.drawLine(
      Offset(xStart, (yStart + yEnd) / 2),
      Offset(xEnd, (yStart + yEnd) / 2),
      axisPaint,
    );
    // Y축
    canvas.drawLine(
      Offset((xStart + xEnd) / 2, yStart),
      Offset((xStart + xEnd) / 2, yEnd),
      axisPaint,
    );
    // X축 화살표
    canvas.drawLine(
      Offset(xEnd - 10, (yStart + yEnd) / 2 - 10),
      Offset(xEnd, (yStart + yEnd) / 2),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(xEnd - 10, (yStart + yEnd) / 2 + 10),
      Offset(xEnd, (yStart + yEnd) / 2),
      arrowPaint,
    );
    // Y축 화살표
    canvas.drawLine(
      Offset((xStart + xEnd) / 2 - 10, yStart + 10),
      Offset((xStart + xEnd) / 2, yStart),
      arrowPaint,
    );
    canvas.drawLine(
      Offset((xStart + xEnd) / 2 + 10, yStart + 10),
      Offset((xStart + xEnd) / 2, yStart),
      arrowPaint,
    );
    // X, Y축 라벨
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    final xLabel = TextPainter(
      text: TextSpan(text: '긍정성', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final yLabel = TextPainter(
      text: TextSpan(text: '긴장도', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    xLabel.paint(canvas, Offset(xEnd - 20, (yStart + yEnd) / 2 + 20));
    yLabel.paint(canvas, Offset((xStart + xEnd) / 2 + 20, yStart));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 사분면별 감정 텍스트 위젯
class _QuadrantEmotions extends StatelessWidget {
  final Offset pointerOffset;
  final double xLength, yLength;
  _QuadrantEmotions({
    required this.pointerOffset,
    required this.xLength,
    required this.yLength,
  });

  @override
  Widget build(BuildContext context) {
    // 중심 기준 상대좌표 → 사분면 판별
    // 1사분면: x>0, y<0 / 2사분면: x<0, y<0 / 3사분면: x<0, y>0 / 4사분면: x>0, y>0
    int? activeQuadrant;
    if (pointerOffset.dx > 0 && pointerOffset.dy < 0)
      activeQuadrant = 1;
    else if (pointerOffset.dx < 0 && pointerOffset.dy < 0)
      activeQuadrant = 2;
    else if (pointerOffset.dx < 0 && pointerOffset.dy > 0)
      activeQuadrant = 3;
    else if (pointerOffset.dx > 0 && pointerOffset.dy > 0)
      activeQuadrant = 4;

    final List<_QuadrantData> quadrants = [
      _QuadrantData(
        index: 1,
        emotions: ['신남', '열정적임', '활기참', '희망참'],
        align: Alignment(0.6, -0.2),
      ),
      _QuadrantData(
        index: 2,
        emotions: ['불안함', '분노', '초조함', '짜증남'],
        align: Alignment(-0.6, -0.2),
      ),
      _QuadrantData(
        index: 3,
        emotions: ['슬픔', '우울함', '무기력', '지침'],
        align: Alignment(-0.6, 0.2),
      ),
      _QuadrantData(
        index: 4,
        emotions: ['평온함', '안정감', '만족스러움', '느긋함'],
        align: Alignment(0.6, 0.2),
      ),
    ];

    return Stack(
      children: quadrants.map((q) {
        return Align(
          alignment: q.align,
          child: AnimatedOpacity(
            opacity: activeQuadrant == q.index ? 1.0 : 0.0,
            duration: Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        q.emotions[0],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        q.emotions[1],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        q.emotions[2],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        q.emotions[3],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuadrantData {
  final int index;
  final List<String> emotions;
  final Alignment align;
  _QuadrantData({
    required this.index,
    required this.emotions,
    required this.align,
  });
}
