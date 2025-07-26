import 'package:flutter/material.dart';

class EmotionBarChart extends StatelessWidget {
  final List<BarChartEmotionData> data;
  final Color? backgroundColor;
  final String? summary; // 감정 요약 문구
  const EmotionBarChart({
    super.key,
    required this.data,
    this.backgroundColor,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF232329),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 220,
            child: CustomPaint(
              size: Size(double.infinity, 200),
              painter: _BarChartPainter(data: data, labelColor: Colors.white),
            ),
          ),
          if (summary != null && summary!.isNotEmpty) ...[
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                summary!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Pretendard',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BarChartEmotionData {
  final String label;
  final double? value; // 0~100, null이면 데이터 없음
  final Color color;
  BarChartEmotionData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _BarChartPainter extends CustomPainter {
  final List<BarChartEmotionData> data;
  final Color labelColor;
  _BarChartPainter({required this.data, required this.labelColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double chartHeight = size.height - 40; // 아래 라벨 공간
    final double chartWidth = size.width; // 좌측 여백 제거
    final double barWidth = 32;
    final double barSpacing =
        (chartWidth - barWidth * data.length) / (data.length + 1);
    final double leftPadding = 0;
    final double topPadding = 8;

    final xLabelStyle = TextStyle(
      color: labelColor,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    // 가로 격자선만 추가 (0, 25, 50, 75, 100)
    final y0 = chartHeight + topPadding;
    final y100 = topPadding;
    final gridLinePaint = Paint()
      ..color = labelColor.withOpacity(0.1)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final double percent = i / 4;
      final double y = y0 - percent * (y0 - y100);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridLinePaint);
    }

    // 각 막대
    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final x = leftPadding + barSpacing * (i + 1) + barWidth * i;
      final barTop = d.value != null
          ? y0 - (d.value!.clamp(0, 100) / 100) * (y0 - y100)
          : y0;
      final barPaint = Paint()
        ..color = d.value != null
            ? Color.fromARGB(255, 152, 205, 91)
            : Colors.grey[800]!
        ..style = PaintingStyle.fill;
      // 막대
      canvas.drawRRect(
        RRect.fromLTRBR(x, barTop, x + barWidth, y0, Radius.circular(2)),
        barPaint,
      );
      // 값 표시
      if (d.value != null) {
        final tpVal = TextPainter(
          text: TextSpan(
            text: d.value!.toInt().toString(),
            style: TextStyle(
              color: labelColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tpVal.paint(
          canvas,
          Offset(x + barWidth / 2 - tpVal.width / 2, barTop - tpVal.height - 2),
        );
      } else {
        final tpNo = TextPainter(
          text: TextSpan(
            text: '-',
            style: TextStyle(color: labelColor.withOpacity(0.7), fontSize: 13),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tpNo.paint(
          canvas,
          Offset(x + barWidth / 2 - tpNo.width / 2, barTop - tpNo.height - 2),
        );
      }
      // X축 라벨
      final tpLabel = TextPainter(
        text: TextSpan(text: d.label, style: xLabelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tpLabel.paint(
        canvas,
        Offset(x + barWidth / 2 - tpLabel.width / 2, y0 + 8),
      );
    }
    // X축, Y축 선 없음, 가로 격자선만 있음
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
