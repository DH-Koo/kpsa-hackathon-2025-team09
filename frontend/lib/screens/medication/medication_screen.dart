import 'package:flutter/material.dart';
import 'package:frontend/screens/medication/medication_routine_graph.dart';
import 'package:provider/provider.dart';
import '../../models/medication.dart';
import '../../service/medication_service.dart';
import '../../providers/medication_check_log_provider.dart';
import 'medication_day_card.dart';
import 'package:intl/intl.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  // 현재 보고 있는 주의 시작 날짜(월요일)
  late DateTime weekStartDate;
  // 선택된 요일 인덱스 (0:월 ~ 6:일)
  int selectedDayIndex = 0;
  // 복약 알람 카드 확장 상태 (약 개수만큼)
  List<bool> alarmCardExpandedList = [];
  // 각 약별로 펼쳐진 시간 칩 인덱스 (null이면 닫힘)
  List<int?> selectedTimeIndexList = [];
  // 각 루틴별, 각 시간별로 선택된 음악 카드 인덱스 (null이면 미선택, 기본 0)
  List<List<int?>> selectedMusicIndexList = [];

  // ★ 추가: 현재 PageView 인덱스 추적용
  int _currentPageIndex = 1000;

  late Future<List<MedicationRoutine>> routinesFuture;
  final int userId = 1; // TODO: 임시 유저 아이디, 나중에 user 모델 나오면 바꾸기!!

  late PageController _pageController;
  late DateTime selectedDate;
  int? selectedBarIndex; // 그래프 막대 선택 인덱스

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // 이번 주 월요일 구하기
    weekStartDate = now.subtract(Duration(days: now.weekday - 1));
    selectedDayIndex = now.weekday - 1;
    selectedDate = now;
    routinesFuture = MedicationService().fetchRoutines(userId);
    // 체크로그 초기 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedDate = weekStartDate.add(Duration(days: selectedDayIndex));
      final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      final selectedDayStr = [
        '월',
        '화',
        '수',
        '목',
        '금',
        '토',
        '일',
      ][selectedDate.weekday - 1];
      Provider.of<MedicationCheckLogProvider>(
        context,
        listen: false,
      ).loadCheckLogs(userId, selectedDateStr, selectedDayStr);
    });
    _pageController = PageController(initialPage: 1000);
    _currentPageIndex = 1000; // ★ 추가: 인덱스 초기화
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 날짜 리스트 구하기
  List<DateTime> getWeekDates(DateTime monday) {
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  // 선택된 날짜에 해당하는 요일 문자열 반환
  String get selectedDayStr =>
      ['월', '화', '수', '목', '금', '토', '일'][selectedDayIndex];

  // 날짜의 시,분,초를 0으로 맞추는 함수
  DateTime onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MedicationCheckLogProvider(),
      child: Builder(
        builder: (context) {
          final weekDates = getWeekDates(weekStartDate);
          final checkLogProvider = Provider.of<MedicationCheckLogProvider>(
            context,
          );

          // TODO: 복약 성공률 계산 함수 (일단은 항상 이번 주 기준으로 계산함! 다른 주도 가능하긴 한데 굳이??)
          Future<List<int>> getFixedWeeklySuccessRates() async {
            final routines = await routinesFuture;
            final today = DateTime.now();
            final thisMonday = today.subtract(
              Duration(days: today.weekday - 1),
            );
            final fixedWeekDates = getWeekDates(thisMonday);
            List<int> rates = [];
            for (int i = 0; i < 7; i++) {
              final date = fixedWeekDates[i];
              final dayStr = ['월', '화', '수', '목', '금', '토', '일'][i];
              final todaysRoutines = routines
                  .where(
                    (r) =>
                        r.weekday.contains(dayStr) &&
                        !date.isBefore(r.startDay) &&
                        date.isBefore(r.endDay),
                  )
                  .toList();
              int totalCount = 0;
              int checkedCount = 0;
              for (final r in todaysRoutines) {
                for (final time in r.takeTime) {
                  totalCount++;
                  if (checkLogProvider.isCheckedTime(r.id, time)) {
                    checkedCount++;
                  }
                }
              }
              final int percent = totalCount == 0
                  ? 0
                  : ((checkedCount / totalCount) * 100).round();
              rates.add(percent);
            }
            return rates;
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(
                '복약 관리',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              surfaceTintColor: Colors.transparent,
              // backgroundColor: Color(0xFF18181B),
              backgroundColor: Colors.black,
            ),
            // backgroundColor: Color(0xFF18181B),
            backgroundColor: Colors.black,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 날짜/요일 선택 바 (분리: 요일 고정, 날짜만 스와이프)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          // 1. 요일 Row (항상 고정)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (i) {
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        ['월', '화', '수', '목', '금', '토', '일'][i],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          // 2. 날짜 Row (PageView로 스와이프)
                          SizedBox(
                            height: 40,
                            child: PageView.builder(
                              controller: _pageController,
                              // 무한 스와이프처럼 보이게 itemCount 없이
                              onPageChanged: (index) {
                                setState(() {
                                  weekStartDate = DateTime.now()
                                      .subtract(
                                        Duration(
                                          days: DateTime.now().weekday - 1,
                                        ),
                                      )
                                      .add(Duration(days: 7 * (index - 1000)));
                                  if (index > _currentPageIndex) {
                                    // 오른쪽(미래 주) → 월요일
                                    selectedDayIndex = 0;
                                    selectedDate = weekStartDate;
                                  } else if (index < _currentPageIndex) {
                                    // 왼쪽(과거 주) → 일요일
                                    selectedDayIndex = 6;
                                    selectedDate = weekStartDate.add(
                                      const Duration(days: 6),
                                    );
                                  }
                                  _currentPageIndex = index; // 인덱스 갱신
                                  final selectedDateStr = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(selectedDate);
                                  final selectedDayStr = [
                                    '월',
                                    '화',
                                    '수',
                                    '목',
                                    '금',
                                    '토',
                                    '일',
                                  ][selectedDate.weekday - 1];
                                  checkLogProvider.loadCheckLogs(
                                    userId,
                                    selectedDateStr,
                                    selectedDayStr,
                                  );
                                });
                              },
                              itemBuilder: (context, index) {
                                final weekStart = DateTime.now()
                                    .subtract(
                                      Duration(
                                        days: DateTime.now().weekday - 1,
                                      ),
                                    )
                                    .add(Duration(days: 7 * (index - 1000)));
                                final weekDates = getWeekDates(weekStart);
                                final today = DateTime.now();
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(7, (i) {
                                    final date = weekDates[i];
                                    final selected =
                                        date.year == selectedDate.year &&
                                        date.month == selectedDate.month &&
                                        date.day ==
                                            selectedDate
                                                .day; // selectedDate와 비교
                                    final isToday =
                                        date.year == today.year &&
                                        date.month == today.month &&
                                        date.day == today.day;
                                    return Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          setState(() {
                                            weekStartDate = weekStart;
                                            selectedDayIndex = i;
                                            selectedDate = date;
                                            final selectedDateStr = DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(date);
                                            final selectedDayStr = [
                                              '월',
                                              '화',
                                              '수',
                                              '목',
                                              '금',
                                              '토',
                                              '일',
                                            ][date.weekday - 1];
                                            checkLogProvider.loadCheckLogs(
                                              userId,
                                              selectedDateStr,
                                              selectedDayStr,
                                            );
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? const Color.fromARGB(
                                                    255,
                                                    152,
                                                    205,
                                                    91,
                                                  )
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: isToday && !selected
                                                ? Border.all(
                                                    color: const Color.fromARGB(
                                                      255,
                                                      152,
                                                      205,
                                                      91,
                                                    ),
                                                    width: 1.5,
                                                  )
                                                : null,
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              child: Text(
                                                date.day.toString(),
                                                style: TextStyle(
                                                  color: selected
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontWeight: selected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 오늘의 복약 리스트 카드 (다른 파일로 분리함)
                    MedicationDayCard(
                      routinesFuture: routinesFuture,
                      weekDates: weekDates,
                      selectedDayIndex: selectedDayIndex,
                      selectedDayStr: selectedDayStr,
                      checkLogProvider: checkLogProvider,
                      userId: userId,
                      selectedDate: selectedDate,
                      onDateSelected: (currentDate) async {
                        final picked = currentDate;
                        if (picked != null) {
                          final monday = onlyDate(
                            picked.subtract(Duration(days: picked.weekday - 1)),
                          );
                          final today = DateTime.now();
                          final thisMonday = onlyDate(
                            today.subtract(Duration(days: today.weekday - 1)),
                          );
                          final weekDiff =
                              monday.difference(thisMonday).inDays ~/ 7;
                          setState(() {
                            weekStartDate = monday;
                            selectedDayIndex = picked.weekday - 1;
                            selectedDate = picked;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _pageController.jumpToPage(1000 + weekDiff);
                          });
                          final selectedDateStr = DateFormat(
                            'yyyy-MM-dd',
                          ).format(picked);
                          final selectedDayStr = [
                            '월',
                            '화',
                            '수',
                            '목',
                            '금',
                            '토',
                            '일',
                          ][picked.weekday - 1];
                          checkLogProvider.loadCheckLogs(
                            userId,
                            selectedDateStr,
                            selectedDayStr,
                          );
                        }
                      },
                    ),

                    // 복약 루틴 그래프 영역 (다른 파일로 분리함)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '이번 주 복약루틴 한 눈에 확인하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF232329),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 그래프 (실제 데이터)
                                FutureBuilder<List<int>>(
                                  future: getFixedWeeklySuccessRates(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return SizedBox(
                                        height: 120,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    final values = snapshot.data!;
                                    return RoutineBarGraph(
                                      values: values,
                                      onBarTap: (idx) {
                                        setState(() {
                                          selectedBarIndex = idx;
                                        });
                                      },
                                      selectedBarIndex: selectedBarIndex,
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF393939),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    getRoutineBarText(selectedBarIndex),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
