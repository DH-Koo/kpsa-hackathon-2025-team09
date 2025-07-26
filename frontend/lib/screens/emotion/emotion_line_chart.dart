import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EmotionLineChart extends StatefulWidget {
  final List<String> dates; // 7개
  final List<int> valenceList;
  final List<int> arousalList;
  final List<int> stressList;
  final List<int> dominanceList;
  const EmotionLineChart({
    super.key,
    required this.dates,
    required this.valenceList,
    required this.arousalList,
    required this.stressList,
    required this.dominanceList,
  });

  @override
  State<EmotionLineChart> createState() => _EmotionLineChartState();
}

class _EmotionLineChartState extends State<EmotionLineChart> {
  final List<String> categories = ['긍정성', '에너지', '스트레스', '통제력'];
  int selectedIndex = 0;
  final Color lineColor = const Color.fromARGB(255, 152, 205, 91);
  final double indicatorWidth = 28;

  List<int> get selectedList {
    switch (selectedIndex) {
      case 0:
        return widget.valenceList;
      case 1:
        return widget.arousalList;
      case 2:
        return widget.stressList;
      case 3:
        return widget.dominanceList;
      case 4:
        return widget.valenceList; // 임시: AI 자가도 valenceList로 매핑
      default:
        return widget.valenceList;
    }
  }

  String get selectedLabel => categories[selectedIndex];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF232329),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // 카테고리 선택 UI
          // TODO: 적응형 UI 적용 필수!!!!!!!!!!!!!!!!!!!
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(categories.length, (idx) {
                final isSelected = idx == selectedIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = idx;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          categories[idx],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[400],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontFamily: 'Pretendard',
                            fontSize: isSelected ? 15 : 13,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (isSelected)
                          Container(
                            width: indicatorWidth,
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 152, 205, 91),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                        else
                          SizedBox(height: 3),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: Colors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 20,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          // fontWeight: FontWeight.bold,
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        // x축 값이 정수이고, 0~dates.length-1 범위 내에서만 라벨 표시
                        if (value != idx.toDouble() ||
                            idx < 0 ||
                            idx >= widget.dates.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            widget.dates[idx],
                            style: const TextStyle(
                              color: Colors.white,
                              // fontWeight: FontWeight.bold,
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black),
                ),
                lineBarsData: [
                  _makeLine(selectedList, lineColor, selectedLabel),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spots) => Color(0xFF393939),
                    getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '$selectedLabel\n${spot.y.toInt()}',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Pretendard',
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '긍정성은 증가하고, 스트레스는 감소하는 추세에요!',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontFamily: 'Pretendard',
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  LineChartBarData _makeLine(List<int> values, Color color, String label) {
    return LineChartBarData(
      spots: [
        for (int i = 0; i < values.length; i++)
          FlSpot(i.toDouble(), values[i].toDouble()),
      ],
      isCurved: true,
      color: color,
      barWidth: 1.5,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
      isStrokeCapRound: true,
    );
  }
}
