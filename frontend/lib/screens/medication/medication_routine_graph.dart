import 'package:flutter/material.dart';

class RoutineBarGraph extends StatelessWidget {
  final List<int> values;
  final List<String> days = const ['월', '화', '수', '목', '금', '토', '일'];
  final void Function(int idx)? onBarTap;
  final int? selectedBarIndex;
  const RoutineBarGraph({
    required this.values,
    this.onBarTap,
    this.selectedBarIndex,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final maxVal = 100;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 0; i < 7; i++)
              GestureDetector(
                onTap: () {
                  if (onBarTap != null) onBarTap!(i);
                },
                child: Column(
                  children: [
                    Text(
                      values[i] == 0 ? '' : '${values[i]}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: selectedBarIndex == i
                            ? Color.fromARGB(255, 152, 205, 91)
                            : Colors.white,
                        fontWeight: selectedBarIndex == i
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 16,
                      height: 100 * (values[i] / maxVal),
                      decoration: BoxDecoration(
                        color: selectedBarIndex == i
                            ? Color.fromARGB(255, 152, 205, 91)
                            : Color.fromARGB(255, 152, 205, 91),
                        borderRadius: BorderRadius.circular(2),
                        border: selectedBarIndex == i
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 16,
                      child: Text(
                        days[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: selectedBarIndex == i
                              ? Color.fromARGB(255, 152, 205, 91)
                              : Colors.white,
                          fontWeight: selectedBarIndex == i
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

String getRoutineBarText(int? idx) {
  if (idx != null && idx >= 0 && idx < 7) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    return '${days[idx]}요일 복약 성공률을 확인하세요!';
  }
  return '막대를 눌러 확인하세요!';
}
