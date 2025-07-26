import 'package:flutter/material.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  bool isSleepAlarmExpanded = false;
  bool isWakeUpAlarmExpanded = false;

  // 수면 알람 상태
  TimeOfDay sleepTime = const TimeOfDay(hour: 23, minute: 0);
  String sleepFrequency = '매일';
  bool sleepShowSpecificDays = false;
  List<bool> sleepSelectedDays = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];
  int sleepSelectedMusicIndex = 0; // 첫 번째 음악을 기본 선택
  bool sleepWeeklyRepeat = false;
  bool sleepAlarmEnabled = false;

  // 기상 알람 상태
  TimeOfDay wakeUpTime = const TimeOfDay(hour: 8, minute: 0);
  String wakeUpFrequency = '매일';
  bool wakeUpShowSpecificDays = false;
  List<bool> wakeUpSelectedDays = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];
  int wakeUpSelectedMusicIndex = 0; // 첫 번째 음악을 기본 선택
  bool wakeUpWeeklyRepeat = false;
  bool wakeUpAlarmEnabled = false;

  // 캐릭터 상태 관련 변수
  String currentCharacterImage = 'assets/images/character_icon.png';
  String currentCharacterText = '쿨쿨... 자는 시간이에요';

  final List<String> frequencies = ['매일', '주중', '주말'];
  final List<String> weekDays = ['월', '화', '수', '목', '금', '토', '일'];

  // TODO: 임시 데이터
  final List<String> sleepMusicTitles = ['잠잘 노래', '수면 음악', '백색소음'];
  final List<String> sleepMusicDescriptions = [
    '편안한 잠을 위한 음악',
    '깊은 수면을 위한 음악',
    '백색소음으로 편안하게',
  ];
  final List<String> wakeUpMusicTitles = ['노래제목', '노래제목', '노래제목'];
  final List<String> wakeUpMusicDescriptions = [
    '설명~~~~~',
    '설명~~~~~',
    '설명~~~~~',
  ];

  // 시간 스크롤 컨트롤러
  late FixedExtentScrollController _sleepHourController;
  late FixedExtentScrollController _sleepMinuteController;
  late FixedExtentScrollController _wakeUpHourController;
  late FixedExtentScrollController _wakeUpMinuteController;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _sleepAlarmKey = GlobalKey();
  final GlobalKey _wakeUpAlarmKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _sleepHourController = FixedExtentScrollController(
      initialItem: sleepTime.hour,
    );
    _sleepMinuteController = FixedExtentScrollController(
      initialItem: sleepTime.minute,
    );
    _wakeUpHourController = FixedExtentScrollController(
      initialItem: wakeUpTime.hour,
    );
    _wakeUpMinuteController = FixedExtentScrollController(
      initialItem: wakeUpTime.minute,
    );

    Widget buildTimePicker({
      required FixedExtentScrollController hourController,
      required FixedExtentScrollController minuteController,
      required TimeOfDay currentTime,
      required Function(TimeOfDay) onTimeChanged,
      required Color activeColor,
    }) {
      return Row(
        children: [
          // 시간 선택기
          Expanded(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListWheelScrollView.useDelegate(
                controller: hourController,
                itemExtent: 40,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  onTimeChanged(
                    TimeOfDay(hour: index, minute: currentTime.minute),
                  );
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    if (index < 0 || index > 23) return null;
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: currentTime.hour == index
                              ? activeColor
                              : Colors.grey[400],
                          fontSize: currentTime.hour == index ? 24 : 18,
                          fontWeight: currentTime.hour == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                  childCount: 24,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 콜론
          const Text(
            ':',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(width: 8),

          // 분 선택기
          Expanded(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListWheelScrollView.useDelegate(
                controller: minuteController,
                itemExtent: 40,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  onTimeChanged(
                    TimeOfDay(hour: currentTime.hour, minute: index),
                  );
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    if (index < 0 || index > 59) return null;
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: currentTime.minute == index
                              ? activeColor
                              : Colors.grey[400],
                          fontSize: currentTime.minute == index ? 24 : 18,
                          fontWeight: currentTime.minute == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                  childCount: 60,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildFrequencyButtons({
      required String currentFrequency,
      required Function(String) onFrequencyChanged,
      required bool showSpecificDays,
      required Function(bool) onShowSpecificDaysChanged,
      required Color activeColor,
    }) {
      return Column(
        children: [
          // 첫 번째 줄: 매일, 주중, 주말
          Row(
            children: frequencies.map((frequency) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      onFrequencyChanged(frequency);
                      if (frequency != '특정 날짜 선택') {
                        onShowSpecificDaysChanged(false);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: currentFrequency == frequency
                            ? activeColor
                            : Colors.transparent,
                        border: Border.all(
                          color: currentFrequency == frequency
                              ? activeColor
                              : Colors.grey[600]!,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          frequency,
                          style: TextStyle(
                            color: currentFrequency == frequency
                                ? Colors.black
                                : Colors.grey[400],
                            fontSize: 12,
                            fontWeight: currentFrequency == frequency
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          // 두 번째 줄: 특정 날짜 선택
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onShowSpecificDaysChanged(!showSpecificDays);
              if (!showSpecificDays) {
                onFrequencyChanged('특정 날짜 선택');
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: showSpecificDays ? activeColor : Colors.transparent,
                border: Border.all(
                  color: showSpecificDays ? activeColor : Colors.grey[600]!,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '특정 날짜 선택',
                  style: TextStyle(
                    color: showSpecificDays ? Colors.black : Colors.grey[400],
                    fontSize: 12,
                    fontWeight: showSpecificDays
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('수면 관리', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 캐릭터 이미지
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // 캐릭터 이미지
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Image.asset(
                            currentCharacterImage,
                            width: constraints.maxWidth,
                            height: constraints.maxWidth,
                            fit: BoxFit.fitWidth,
                          );
                        },
                      ),
                    ],
                  ),

                  // 아래부터 패딩 적용
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 중간 섹션: 수면부채 정보
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            currentCharacterText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // TODO: 사용자에 맞춰 수면부채 계산
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '빙수빙수빙님의 수면부채가',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.pink,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '위험',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    '7시간 15분',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '쌓였어요. 오늘은 8시간 이상 주무세요!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 하단 섹션: 알람 설정
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '알람 설정하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 수면 알람 버튼
                        Container(
                          key: _sleepAlarmKey,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // 헤더 부분
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                  final wasExpanded = isSleepAlarmExpanded;
                                  setState(() {
                                    isSleepAlarmExpanded =
                                        !isSleepAlarmExpanded;
                                    if (isSleepAlarmExpanded) {
                                      isWakeUpAlarmExpanded = false;
                                    }
                                  });
                                  // 펼칠 때만 스크롤
                                  if (!wasExpanded && isSleepAlarmExpanded) {
                                    await Future.delayed(
                                      const Duration(milliseconds: 50),
                                    );
                                    final RenderBox? box =
                                        _sleepAlarmKey.currentContext
                                                ?.findRenderObject()
                                            as RenderBox?;
                                    if (box != null) {
                                      final position = box.localToGlobal(
                                        Offset.zero,
                                        ancestor: context.findRenderObject(),
                                      );
                                      final offset =
                                          _scrollController.offset +
                                          position.dy -
                                          kToolbarHeight -
                                          24; // 앱바 높이+패딩만큼 보정
                                      _scrollController.animateTo(
                                        offset < 0 ? 0 : offset,
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.alarm,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '수면 알람',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${sleepTime.hour.toString().padLeft(2, '0')}:${sleepTime.minute.toString().padLeft(2, '0')}',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: isSleepAlarmExpanded ? 0.5 : 0,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // 확장되는 내용
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: isSleepAlarmExpanded ? null : 0,
                                child: isSleepAlarmExpanded
                                    ? Container(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // 시간 설정과 빈도 선택을 나란히 배치
                                            Row(
                                              children: [
                                                // 왼쪽: 시간 선택기
                                                Expanded(
                                                  flex: 1,
                                                  child: buildTimePicker(
                                                    hourController:
                                                        _sleepHourController,
                                                    minuteController:
                                                        _sleepMinuteController,
                                                    currentTime: sleepTime,
                                                    onTimeChanged: (time) {
                                                      setState(() {
                                                        sleepTime = time;
                                                      });
                                                    },
                                                    activeColor: Color.fromARGB(
                                                      255,
                                                      152,
                                                      205,
                                                      91,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 16),

                                                // 오른쪽: 빈도 버튼들
                                                Expanded(
                                                  flex: 1,
                                                  child: _buildFrequencyButtons(
                                                    currentFrequency:
                                                        sleepFrequency,
                                                    onFrequencyChanged:
                                                        (frequency) {
                                                          setState(() {
                                                            sleepFrequency =
                                                                frequency;
                                                          });
                                                        },
                                                    showSpecificDays:
                                                        sleepShowSpecificDays,
                                                    onShowSpecificDaysChanged:
                                                        (show) {
                                                          setState(() {
                                                            sleepShowSpecificDays =
                                                                show;
                                                          });
                                                        },
                                                    activeColor: Color.fromARGB(
                                                      255,
                                                      152,
                                                      205,
                                                      91,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 20),

                                            // 특정 날짜 선택이 활성화되었을 때만 요일 선택 표시
                                            if (sleepShowSpecificDays) ...[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: List.generate(7, (
                                                  index,
                                                ) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        sleepSelectedDays[index] =
                                                            !sleepSelectedDays[index];
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 35,
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            sleepSelectedDays[index]
                                                            ? Color.fromARGB(
                                                                255,
                                                                152,
                                                                205,
                                                                91,
                                                              )
                                                            : Colors
                                                                  .transparent,
                                                        border: Border.all(
                                                          color:
                                                              sleepSelectedDays[index]
                                                              ? Color.fromARGB(
                                                                  255,
                                                                  152,
                                                                  205,
                                                                  91,
                                                                )
                                                              : Colors
                                                                    .grey[600]!,
                                                          width: 1,
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          weekDays[index],
                                                          style: TextStyle(
                                                            color:
                                                                sleepSelectedDays[index]
                                                                ? Colors.black
                                                                : Colors
                                                                      .grey[400],
                                                            fontSize: 12,
                                                            fontWeight:
                                                                sleepSelectedDays[index]
                                                                ? FontWeight
                                                                      .bold
                                                                : FontWeight
                                                                      .w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                              const SizedBox(height: 20),
                                            ],
                                            const SizedBox(height: 20),

                                            // 추천 수면 음악
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  '추천 수면 음악',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    // TODO: 새로고침 로직
                                                  },
                                                  icon: const Icon(
                                                    Icons.refresh,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            // 음악 목록
                                            ...List.generate(3, (index) {
                                              return Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[800],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[700],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.play_arrow,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            sleepMusicTitles[index],
                                                            style: TextStyle(
                                                              color:
                                                                  sleepSelectedMusicIndex ==
                                                                      index
                                                                  ? Color.fromARGB(
                                                                      255,
                                                                      152,
                                                                      205,
                                                                      91,
                                                                    )
                                                                  : Colors
                                                                        .white,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  sleepSelectedMusicIndex ==
                                                                      index
                                                                  ? FontWeight
                                                                        .bold
                                                                  : FontWeight
                                                                        .w500,
                                                            ),
                                                          ),
                                                          Text(
                                                            sleepMusicDescriptions[index],
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[400],
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          sleepSelectedMusicIndex =
                                                              index;
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 24,
                                                        height: 24,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              sleepSelectedMusicIndex ==
                                                                  index
                                                              ? Color.fromARGB(
                                                                  255,
                                                                  152,
                                                                  205,
                                                                  91,
                                                                )
                                                              : Colors
                                                                    .transparent,
                                                          border: Border.all(
                                                            color:
                                                                sleepSelectedMusicIndex ==
                                                                    index
                                                                ? Color.fromARGB(
                                                                    255,
                                                                    152,
                                                                    205,
                                                                    91,
                                                                  )
                                                                : Colors
                                                                      .grey[600]!,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                        child:
                                                            sleepSelectedMusicIndex ==
                                                                index
                                                            ? const Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .white,
                                                                size: 16,
                                                              )
                                                            : null,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),

                                            const SizedBox(height: 20),

                                            // 하단 옵션들
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                        value:
                                                            sleepWeeklyRepeat,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            sleepWeeklyRepeat =
                                                                value!;
                                                          });
                                                        },
                                                        activeColor:
                                                            Color.fromARGB(
                                                              255,
                                                              152,
                                                              205,
                                                              91,
                                                            ),
                                                      ),
                                                      const Text(
                                                        '매주 하기',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                        value:
                                                            sleepAlarmEnabled,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            sleepAlarmEnabled =
                                                                value!;
                                                          });
                                                        },
                                                        activeColor:
                                                            Color.fromARGB(
                                                              255,
                                                              152,
                                                              205,
                                                              91,
                                                            ),
                                                      ),
                                                      const Text(
                                                        '알람 활성화하기',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 기상 알람 버튼
                        Container(
                          key: _wakeUpAlarmKey,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // 헤더 부분
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                  final wasExpanded = isWakeUpAlarmExpanded;
                                  setState(() {
                                    isWakeUpAlarmExpanded =
                                        !isWakeUpAlarmExpanded;
                                    if (isWakeUpAlarmExpanded) {
                                      isSleepAlarmExpanded = false;
                                    }
                                  });
                                  // 펼칠 때만 스크롤
                                  if (!wasExpanded && isWakeUpAlarmExpanded) {
                                    await Future.delayed(
                                      const Duration(milliseconds: 50),
                                    );
                                    final RenderBox? box =
                                        _wakeUpAlarmKey.currentContext
                                                ?.findRenderObject()
                                            as RenderBox?;
                                    if (box != null) {
                                      final position = box.localToGlobal(
                                        Offset.zero,
                                        ancestor: context.findRenderObject(),
                                      );
                                      final offset =
                                          _scrollController.offset +
                                          position.dy -
                                          kToolbarHeight -
                                          24;
                                      _scrollController.animateTo(
                                        offset < 0 ? 0 : offset,
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.alarm,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '기상 알람',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${wakeUpTime.hour.toString().padLeft(2, '0')}:${wakeUpTime.minute.toString().padLeft(2, '0')}',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: isWakeUpAlarmExpanded ? 0.5 : 0,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // 확장되는 내용
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: isWakeUpAlarmExpanded ? null : 0,
                                child: isWakeUpAlarmExpanded
                                    ? Container(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // 시간 설정과 빈도 선택을 나란히 배치
                                            Row(
                                              children: [
                                                // 왼쪽: 시간 선택기
                                                Expanded(
                                                  flex: 1,
                                                  child: buildTimePicker(
                                                    hourController:
                                                        _wakeUpHourController,
                                                    minuteController:
                                                        _wakeUpMinuteController,
                                                    currentTime: wakeUpTime,
                                                    onTimeChanged: (time) {
                                                      setState(() {
                                                        wakeUpTime = time;
                                                      });
                                                    },
                                                    activeColor: Color.fromARGB(
                                                      255,
                                                      152,
                                                      205,
                                                      91,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 16),

                                                // 오른쪽: 빈도 버튼들
                                                Expanded(
                                                  flex: 1,
                                                  child: _buildFrequencyButtons(
                                                    currentFrequency:
                                                        wakeUpFrequency,
                                                    onFrequencyChanged:
                                                        (frequency) {
                                                          setState(() {
                                                            wakeUpFrequency =
                                                                frequency;
                                                          });
                                                        },
                                                    showSpecificDays:
                                                        wakeUpShowSpecificDays,
                                                    onShowSpecificDaysChanged:
                                                        (show) {
                                                          setState(() {
                                                            wakeUpShowSpecificDays =
                                                                show;
                                                          });
                                                        },
                                                    activeColor: Color.fromARGB(
                                                      255,
                                                      152,
                                                      205,
                                                      91,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 20),

                                            // 특정 날짜 선택이 활성화되었을 때만 요일 선택 표시
                                            if (wakeUpShowSpecificDays) ...[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: List.generate(7, (
                                                  index,
                                                ) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        wakeUpSelectedDays[index] =
                                                            !wakeUpSelectedDays[index];
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 35,
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            wakeUpSelectedDays[index]
                                                            ? Color.fromARGB(
                                                                255,
                                                                152,
                                                                205,
                                                                91,
                                                              )
                                                            : Colors
                                                                  .transparent,
                                                        border: Border.all(
                                                          color:
                                                              wakeUpSelectedDays[index]
                                                              ? Color.fromARGB(
                                                                  255,
                                                                  152,
                                                                  205,
                                                                  91,
                                                                )
                                                              : Colors
                                                                    .grey[600]!,
                                                          width: 1,
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          weekDays[index],
                                                          style: TextStyle(
                                                            color:
                                                                wakeUpSelectedDays[index]
                                                                ? Colors.white
                                                                : Colors
                                                                      .grey[400],
                                                            fontSize: 12,
                                                            fontWeight:
                                                                wakeUpSelectedDays[index]
                                                                ? FontWeight
                                                                      .bold
                                                                : FontWeight
                                                                      .w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                              const SizedBox(height: 20),
                                            ],
                                            const SizedBox(height: 20),

                                            // 추천 알람 음악
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  '추천 기상 음악',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    // 새로고침 로직
                                                  },
                                                  icon: const Icon(
                                                    Icons.refresh,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            // 음악 목록
                                            ...List.generate(3, (index) {
                                              return Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[800],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[700],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.play_arrow,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            wakeUpMusicTitles[index],
                                                            style: TextStyle(
                                                              color:
                                                                  wakeUpSelectedMusicIndex ==
                                                                      index
                                                                  ? Color.fromARGB(
                                                                      255,
                                                                      152,
                                                                      205,
                                                                      91,
                                                                    )
                                                                  : Colors
                                                                        .white,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  wakeUpSelectedMusicIndex ==
                                                                      index
                                                                  ? FontWeight
                                                                        .bold
                                                                  : FontWeight
                                                                        .w500,
                                                            ),
                                                          ),
                                                          Text(
                                                            wakeUpMusicDescriptions[index],
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[400],
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          wakeUpSelectedMusicIndex =
                                                              index;
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 24,
                                                        height: 24,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              wakeUpSelectedMusicIndex ==
                                                                  index
                                                              ? Color.fromARGB(
                                                                  255,
                                                                  152,
                                                                  205,
                                                                  91,
                                                                )
                                                              : Colors
                                                                    .transparent,
                                                          border: Border.all(
                                                            color:
                                                                wakeUpSelectedMusicIndex ==
                                                                    index
                                                                ? Color.fromARGB(
                                                                    255,
                                                                    152,
                                                                    205,
                                                                    91,
                                                                  )
                                                                : Colors
                                                                      .grey[600]!,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                        child:
                                                            wakeUpSelectedMusicIndex ==
                                                                index
                                                            ? const Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .white,
                                                                size: 16,
                                                              )
                                                            : null,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),

                                            const SizedBox(height: 20),

                                            // 하단 옵션들
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                        value:
                                                            wakeUpWeeklyRepeat,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            wakeUpWeeklyRepeat =
                                                                value!;
                                                          });
                                                        },
                                                        activeColor:
                                                            Color.fromARGB(
                                                              255,
                                                              152,
                                                              205,
                                                              91,
                                                            ),
                                                      ),
                                                      const Text(
                                                        '매주 하기',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                        value:
                                                            wakeUpAlarmEnabled,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            wakeUpAlarmEnabled =
                                                                value!;
                                                          });
                                                        },
                                                        activeColor:
                                                            Color.fromARGB(
                                                              255,
                                                              152,
                                                              205,
                                                              91,
                                                            ),
                                                      ),
                                                      const Text(
                                                        '알람 활성화하기',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : null,
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
        ),
      );
    }
  }
}
