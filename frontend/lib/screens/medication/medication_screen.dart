import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medication.dart';
import '../../models/music.dart';
import '../../service/medication_service.dart';
import '../../service/api_service.dart';
import '../../providers/medication_check_log_provider.dart';
import '../../providers/auth_provider.dart';
import 'medication_day_card.dart';
import 'package:table_calendar/table_calendar.dart';
import 'medication_routine_graph.dart';
import 'package:intl/intl.dart';
import 'medication_list_screen.dart';
import 'medication_input_screen.dart';
import 'widgets/music_card.dart';

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

  // 음악 리스트 관련 상태
  Map<int, List<Music>> musicListMap = {}; // 약 ID별 음악 리스트
  Map<int, bool> musicListExpandedMap = {}; // 약 ID별 음악 리스트 확장 상태

  Future<List<MedicationRoutine>>? routinesFuture;
  late PageController _pageController;
  late DateTime selectedDate;
  int? selectedBarIndex; // 그래프 막대 선택 인덱스
  bool _initialized = false; // 초기화 완료 여부

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // 이번 주 월요일 구하기
    weekStartDate = now.subtract(Duration(days: now.weekday - 1));
    selectedDayIndex = now.weekday - 1;
    selectedDate = now;
    _pageController = PageController(initialPage: 1000);
  }

  // 데이터 새로고침 메서드 추가
  void _refreshData(int userId) {
    setState(() {
      routinesFuture = null; // 캐시된 데이터 초기화
    });
    // 새로운 데이터 로드
    routinesFuture = MedicationService().fetchRoutines(userId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 포커스를 받을 때마다 데이터 새로고침
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    if (currentUser != null && routinesFuture == null) {
      routinesFuture = MedicationService().fetchRoutines(currentUser.id);
    }
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

  // 초기 체크로그 로드 (한 번만 실행)
  void _initializeCheckLogs(MedicationCheckLogProvider provider, int userId) {
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
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
          provider.loadCheckLogs(userId, selectedDateStr, selectedDayStr);
        }
      });
    }
  }

  Future<DateTime?> _showCalendarBottomSheet(
    BuildContext context,
    DateTime initialDate,
  ) async {
    DateTime tempSelected = initialDate;
    return await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setModalState(() {
                              tempSelected = DateTime.now();
                            });
                          },
                        ),
                      ],
                    ),
                    TableCalendar(
                      locale: 'ko_KR',
                      firstDay: DateTime(2000),
                      lastDay: DateTime.now().add(Duration(days: 1095)),
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
                        weekdayStyle: TextStyle(color: Colors.white),
                        weekendStyle: TextStyle(color: Colors.grey[400]),
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
                                    : Colors.grey[400],
                              ),
                            ),
                          );
                        },
                        outsideBuilder: (context, day, focusedDay) {
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          );
                        },
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                255,
                                152,
                                205,
                                91,
                              ),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
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
  }

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
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final currentUser = authProvider.currentUser;

          // 사용자가 로그인하지 않은 경우 처리
          if (currentUser == null) {
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
                backgroundColor: Colors.black,
              ),
              backgroundColor: Colors.black,
              body: Center(
                child: Text(
                  '로그인이 필요합니다.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          final userId = currentUser.id;

          // routinesFuture 초기화 (한 번만)
          if (routinesFuture == null) {
            routinesFuture = MedicationService().fetchRoutines(userId);
          }

          // 초기 체크로그 로드 (한 번만)
          _initializeCheckLogs(checkLogProvider, userId);

          // 복약 성공률 계산 함수
          Future<List<int>> getFixedWeeklySuccessRates() async {
            if (routinesFuture == null) return List.filled(7, 0);
            final routines = await routinesFuture!;
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
              backgroundColor: Colors.black,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MedicationInputScreen(),
                      ),
                    );
                    // 약 추가 완료 후 화면 새로고침
                    if (result == true) {
                      _refreshData(userId);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MedicationListScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            backgroundColor: Colors.black,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 날짜/요일 선택 바
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
                              onPageChanged: (index) {
                                setState(() {
                                  final newWeekStartDate = DateTime.now()
                                      .subtract(
                                        Duration(
                                          days: DateTime.now().weekday - 1,
                                        ),
                                      )
                                      .add(Duration(days: 7 * (index - 1000)));
                                  weekStartDate = newWeekStartDate;
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
                                        date.day == selectedDate.day;
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
                                          });
                                          // 날짜 변경 시 체크로그 다시 로드
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

                    // 알림 정보 섹션
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.alarm,
                                color: Colors.green.shade400,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '복약 알림',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FutureBuilder<List<MedicationRoutine>>(
                            future: routinesFuture,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '등록된 복약이 없습니다',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final routines = snapshot.data!;

                              return Column(
                                children: routines.map((routine) {
                                  return Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade900,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                routine.name,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                // 이미 음악 리스트가 로드되어 있고 확장된 상태라면 접기
                                                if (musicListExpandedMap[routine.id] == true) {
                                                  setState(() {
                                                    musicListExpandedMap[routine.id] = false;
                                                  });
                                                  return;
                                                }

                                                // 음악 리스트가 아직 로드되지 않았다면 로드
                                                if (!musicListMap.containsKey(routine.id)) {
                                                  try {
                                                    final musicListData = await ChatApiService.getMedicineMusicList(routine.id);
                                                    final musicList = musicListData.map((data) => Music.fromJson(data)).toList();
                                                    
                                                    setState(() {
                                                      musicListMap[routine.id] = musicList;
                                                      musicListExpandedMap[routine.id] = true;
                                                    });
                                                  } catch (e) {
                                                    print('약 음악 리스트 가져오기 실패: $e');
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('음악 리스트를 가져오는데 실패했습니다.'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  // 이미 로드된 음악 리스트라면 확장 상태만 토글
                                                  setState(() {
                                                    musicListExpandedMap[routine.id] = true;
                                                  });
                                                }
                                              },
                                              child: Icon(
                                                musicListExpandedMap[routine.id] == true
                                                    ? Icons.keyboard_arrow_up
                                                    : Icons.keyboard_arrow_down,
                                                color: Colors.grey.shade400,
                                                size: 24,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 음악 리스트 표시
                                      if (musicListExpandedMap[routine.id] == true && musicListMap.containsKey(routine.id))
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF1A1A1A),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.music_note,
                                                    color: const Color.fromARGB(255, 152, 205, 91),
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '추천 음악',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              ...musicListMap[routine.id]!.map((music) => MusicCard(
                                                music: music,
                                                medicineId: routine.id,
                                                onPlay: () {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('${music.title} 재생 중...'),
                                                      backgroundColor: const Color.fromARGB(255, 152, 205, 91),
                                                    ),
                                                  );
                                                },
                                              )).toList(),
                                            ],
                                          ),
                                        ),
                                    ],
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // 오늘의 복약 리스트 카드
                    if (routinesFuture != null)
                      MedicationDayCard(
                        routinesFuture: routinesFuture!,
                        weekDates: weekDates,
                        selectedDayIndex: selectedDayIndex,
                        selectedDayStr: selectedDayStr,
                        userId: userId,
                        selectedDate: selectedDate,
                        onDateSelected: (currentDate) async {
                          final picked = await _showCalendarBottomSheet(
                            context,
                            currentDate,
                          );
                          if (picked != null) {
                            final monday = onlyDate(
                              picked.subtract(
                                Duration(days: picked.weekday - 1),
                              ),
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

                    // 복약 루틴 그래프 영역
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

String getRoutineBarText(int? idx) {
  if (idx != null && idx >= 0 && idx < 7) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    return '${days[idx]}요일 복약 성공률을 확인하세요!';
  }
  return '막대를 눌러 확인하세요!';
}
