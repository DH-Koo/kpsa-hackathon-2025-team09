import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/emotion_report_provider.dart';
import '../../models/emotion_report.dart';
import 'emotion_bar_chart.dart';
import 'emotion_line_chart.dart';
import 'emotion_report_screen.dart';
import '../report_screen.dart';

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
    return Consumer<EmotionReportProvider>(
      builder: (context, reportProvider, child) {
        final reports = reportProvider.getReportsByDate(_selectedDate);
        
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
                // 날짜 선택 섹션
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _showCalendarBottomSheet,
                        child: Row(
                          children: [
                            Text(
                              '${_selectedDate.month}월 ${_selectedDate.day}일의 감정',
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
                ),
                const SizedBox(height: 24),
                // 리포트 카드들
                if (reports.isNotEmpty) ...[
                  ...reports.map((report) => _buildReportCard(report)).toList(),
                ] else ...[
                  // 리포트가 없을 때 표시할 메시지
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.psychology_outlined,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '이 날의 감정 리포트가 없습니다',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '감정 체크를 완료하면 여기에 리포트가 표시됩니다',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportCard(EmotionReport report) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => _navigateToReport(report),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: report.type == 'workflow' 
                  ? Color.fromARGB(255, 152, 205, 91)
                  : Colors.grey[700]!,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    report.type == 'workflow' 
                        ? Icons.psychology 
                        : Icons.music_note,
                    color: report.type == 'workflow' 
                        ? Color.fromARGB(255, 152, 205, 91)
                        : Colors.blue[300],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${report.createdAt.hour.toString().padLeft(2, '0')}:${report.createdAt.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: report.type == 'workflow' 
                      ? Color.fromARGB(255, 152, 205, 91).withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report.type == 'workflow' ? '감정 워크플로우' : '음악 추천',
                  style: TextStyle(
                    color: report.type == 'workflow' 
                        ? Color.fromARGB(255, 152, 205, 91)
                        : Colors.blue[300],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToReport(EmotionReport report) {
    if (report.type == 'workflow') {
      // 워크플로우 리포트로 이동
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EmotionReportScreen(
            finalResponse: report.responses,
          ),
        ),
      );
    } else {
      // 음악 추천 리포트로 이동
      final data = report.data;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MusicRecommendationScreen(
            valenceLevel: data['valenceLevel'] ?? 0,
            arousalLevel: data['arousalLevel'] ?? 0,
            stressLevel: data['stressLevel'] ?? 0,
            dominanceLevel: data['dominanceLevel'] ?? 0,
            responseText: report.responses.isNotEmpty ? report.responses[0] : '',
          ),
        ),
      );
    }
  }
}
