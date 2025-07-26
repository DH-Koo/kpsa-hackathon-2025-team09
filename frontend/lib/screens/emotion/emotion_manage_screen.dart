import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'emotion_bar_chart.dart';
import 'emotion_line_chart.dart';

class EmotionManageScreen extends StatefulWidget {
  const EmotionManageScreen({super.key});

  @override
  State<EmotionManageScreen> createState() => _EmotionManageScreenState();
}

class _EmotionManageScreenState extends State<EmotionManageScreen> {
  DateTime _selectedDate = DateTime.now();

  void _showCalendarBottomSheet() async {
    DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        DateTime tempSelected = _selectedDate;
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF232329),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        // 중앙 맞추기 용!
                        IconButton(
                          icon: const Icon(
                            Icons.cached,
                            size: 24,
                            color: Colors.transparent,
                          ),
                          onPressed: () {
                            setModalState(() {
                              tempSelected = DateTime.now();
                            });
                          },
                          style: IconButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            size: 24,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setModalState(() {
                              tempSelected = DateTime(
                                tempSelected.year,
                                tempSelected.month - 1,
                                1,
                              );
                            });
                          },
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '${tempSelected.year}.${tempSelected.month}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_right,
                            size: 24,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setModalState(() {
                              tempSelected = DateTime(
                                tempSelected.year,
                                tempSelected.month + 1,
                                1,
                              );
                            });
                          },
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(
                            Icons.cached,
                            size: 24,
                            color: Colors.transparent,
                          ),
                          onPressed: () {
                            setModalState(() {
                              tempSelected = DateTime.now();
                            });
                          },
                          style: IconButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                          ),
                        ),
                      ],
                    ),
                    TableCalendar(
                      locale: 'ko_KR',
                      firstDay: DateTime(2000),
                      lastDay: DateTime.now(),
                      focusedDay: tempSelected,
                      selectedDayPredicate: (day) =>
                          isSameDay(day, tempSelected),
                      onDaySelected: (selected, focused) {
                        setModalState(() {
                          tempSelected = selected;
                        });
                      },
                      headerVisible: false,
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          //color: Color.fromARGB(255, 152, 205, 91),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color.fromARGB(255, 152, 205, 91),
                            width: 1.5,
                          ),
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Color.fromARGB(255, 152, 205, 91),
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        todayTextStyle: const TextStyle(color: Colors.white),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          color: Colors.white,
                          // fontWeight: FontWeight.bold,
                        ),
                        weekendStyle: TextStyle(
                          color: Colors.grey[400],
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          final isWeekday =
                              day.weekday >= DateTime.monday &&
                              day.weekday <= DateTime.friday;
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: isWeekday
                                    ? Colors.white
                                    : Colors.grey[400], // 주중/주말
                              ),
                            ),
                          );
                        },
                        outsideBuilder: (context, day, focusedDay) {
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: Colors.grey[700], // 해당 월이 아니면 더 진한 회색
                              ),
                            ),
                          );
                        },
                        // todayBuilder, selectedBuilder 등은 기존 스타일 유지
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                            ),
                            onPressed: () {
                              Navigator.pop(context, null);
                            },
                            child: const Text(
                              '취소',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                255,
                                152,
                                205,
                                91,
                              ),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: (tempSelected.isAfter(DateTime.now()))
                                ? null
                                : () {
                                    Navigator.pop(context, tempSelected);
                                  },
                            child: const Text('완료'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = '${_selectedDate.month}월 ${_selectedDate.day}일의 감정';
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('감정 관리', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _showCalendarBottomSheet,
                        child: Row(
                          children: [
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  EmotionBarChart(
                    data: [
                      BarChartEmotionData(
                        label: '긍정성',
                        value: 70,
                        color: Colors.pinkAccent,
                      ),
                      BarChartEmotionData(
                        label: '에너지',
                        value: 50,
                        color: Colors.amber,
                      ),
                      BarChartEmotionData(
                        label: '스트레스',
                        value: 30,
                        color: Colors.lightBlueAccent,
                      ),
                      BarChartEmotionData(
                        label: '통제력',
                        value: 80,
                        color: Colors.greenAccent,
                      ),
                    ],
                    backgroundColor: Colors.white,
                    summary: '일에 집중이 잘 되었고 평온한 하루였네요!',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '최근 일주일간 감정 추이',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  SizedBox(height: 8),
                  EmotionLineChart(
                    dates: List.generate(7, (index) {
                      final date = DateTime.now().subtract(
                        Duration(days: 6 - index),
                      );
                      return '${date.month}/${date.day}';
                    }),
                    valenceList: [60, 65, 70, 80, 75, 85, 70],
                    arousalList: [40, 50, 55, 60, 65, 70, 50],
                    stressList: [30, 35, 40, 38, 36, 32, 30],
                    dominanceList: [70, 72, 74, 76, 78, 80, 70],
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
