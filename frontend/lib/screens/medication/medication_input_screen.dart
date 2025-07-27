import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../models/medication.dart';
import '../../providers/medication_provider.dart';
import '../../providers/auth_provider.dart';

class MedicationInputScreen extends StatefulWidget {
  const MedicationInputScreen({super.key});

  @override
  State<MedicationInputScreen> createState() => _MedicationInputScreenState();
}

class _MedicationInputScreenState extends State<MedicationInputScreen> {
  final TextEditingController _medicationNameController =
      TextEditingController();
  final TextEditingController _medicationPurposeController =
      TextEditingController();
  final TextEditingController _medicationAmountController =
      TextEditingController();

  // 복용 시작일과 종료일 변수 추가
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  // 복용 시간 관련 변수 추가
  List<List<int>> _selectedTimes = []; // [[9,0], [21,0]] 형태
  final List<String> _weekDays = ['월', '화', '수', '목', '금', '토', '일'];

  // 로딩 상태 변수 추가
  bool _isLoading = false;

  void _showCalendarBottomSheet({required bool isStartDate}) async {
    DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        DateTime tempSelected = isStartDate
            ? _startDate
            : (_endDate ?? DateTime.now());
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
                      firstDay: isStartDate ? DateTime(2000) : DateTime.now(),
                      lastDay: DateTime.now().add(Duration(days: 365)),
                      focusedDay: tempSelected,
                      selectedDayPredicate: (day) =>
                          isSameDay(day, tempSelected),
                      onDaySelected: (selected, focused) {
                        // 복용 종료일인 경우 과거 날짜 선택 방지
                        if (!isStartDate && selected.isBefore(DateTime.now())) {
                          return;
                        }
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
                        disabledTextStyle: TextStyle(color: Colors.grey[600]),
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
                          final isPastDay =
                              !isStartDate && day.isBefore(DateTime.now());
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: isPastDay
                                    ? Colors.grey[600]
                                    : (isWeekday
                                          ? Colors.white
                                          : Colors.grey[400]), // 주중/주말
                              ),
                            ),
                          );
                        },
                        outsideBuilder: (context, day, focusedDay) {
                          final isPastDay =
                              !isStartDate && day.isBefore(DateTime.now());
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: isPastDay
                                    ? Colors.grey[600]
                                    : Colors.grey[700], // 해당 월이 아니면 더 진한 회색
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
                            onPressed:
                                (!isStartDate &&
                                    tempSelected.isBefore(DateTime.now()))
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
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // 시간 선택 다이얼로그
  void _showTimePickerDialog() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Color(0xFF232329),
              hourMinuteTextColor: Colors.white,
              hourMinuteColor: Colors.grey[800],
              dialHandColor: Color.fromARGB(255, 152, 205, 91),
              dialBackgroundColor: Colors.grey[800],
              dialTextColor: Colors.white,
              entryModeIconColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTimes.add([picked.hour, picked.minute]);
        // 시간 순서대로 정렬
        _selectedTimes.sort((a, b) {
          if (a[0] != b[0]) return a[0].compareTo(b[0]);
          return a[1].compareTo(b[1]);
        });
      });
    }
  }

  // 시간 삭제
  void _removeTime(int index) {
    setState(() {
      _selectedTimes.removeAt(index);
    });
  }

  // 날짜 포맷팅 함수
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일';
  }

  // 시간 포맷팅 함수
  String _formatTime(List<int> time) {
    return '${time[0].toString().padLeft(2, '0')}:${time[1].toString().padLeft(2, '0')}';
  }

  // 요일 선택 관련 변수 추가
  final Set<int> _selectedDays = <int>{};

  @override
  void dispose() {
    _medicationNameController.dispose();
    _medicationPurposeController.dispose();
    _medicationAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '복약 정보 입력',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildMainQuestion(),
                        const SizedBox(height: 40),
                        _buildInputSection(
                          '어떤 약인가요?',
                          '약을 구분할 수 있는 이름을 적어주세요.',
                          _medicationNameController,
                        ),
                        const SizedBox(height: 24),
                        _buildInputSection(
                          '얼마나 드시나요? (정)',
                          '숫자로 입력해 주세요',
                          _medicationAmountController,
                        ),
                        const SizedBox(height: 24),
                        _buildTimeSelectionSection(),
                        const SizedBox(height: 24),
                        _buildWeekDaySelector(),
                        const SizedBox(height: 24),
                        _buildDateSelectionSection(),
                      ],
                    ),
                  ),
                ),
                _buildNextButton(),
              ],
            ),
          ),
          // 로딩 오버레이
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 152, 205, 91),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '음악을 생성하고 있습니다...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainQuestion() {
    return const Text(
      '어떤 약을 무엇을 위해 복용하시나요?',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.3,
      ),
    );
  }

  Widget _buildInputSection(
    String title,
    String placeholder,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '복용 시간',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            TextButton.icon(
              onPressed: _showTimePickerDialog,
              icon: const Icon(
                Icons.add,
                color: Color.fromARGB(255, 152, 205, 91),
                size: 20,
              ),
              label: const Text(
                '시간 추가',
                style: TextStyle(
                  color: Color.fromARGB(255, 152, 205, 91),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedTimes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '복용 시간을 추가해주세요',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTimes.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 152, 205, 91),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(time),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _removeTime(index),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildDateSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 복용 시작일
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '복용 시작일',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showCalendarBottomSheet(isStartDate: true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(_startDate),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // 복용 종료일
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '복용 종료일',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showCalendarBottomSheet(isStartDate: false),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _endDate != null ? _formatDate(_endDate!) : '선택',
                      style: TextStyle(
                        fontSize: 16,
                        color: _endDate != null
                            ? Colors.black
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '알림 받을 요일',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedDays.length == 7) {
                    // 모든 요일이 선택되어 있으면 모두 해제
                    _selectedDays.clear();
                  } else {
                    // 모든 요일 선택
                    _selectedDays.clear();
                    for (int i = 0; i < 7; i++) {
                      _selectedDays.add(i);
                    }
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _selectedDays.length == 7
                      ? Color.fromARGB(255, 152, 205, 91)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '매일',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedDays.length == 7
                        ? Colors.white
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final isSelected = _selectedDays.contains(index);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedDays.remove(index);
                  } else {
                    _selectedDays.add(index);
                  }
                });
              },
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color.fromARGB(255, 152, 205, 91)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    _weekDays[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _isFormValid() ? _submitForm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid()
              ? Color.fromARGB(255, 152, 205, 91)
              : Colors.grey.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          '완료',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  bool _isFormValid() {
    return _medicationNameController.text.isNotEmpty &&
        _medicationAmountController.text.isNotEmpty &&
        _selectedTimes.isNotEmpty &&
        _selectedDays.isNotEmpty &&
        _endDate != null;
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final medicationProvider = Provider.of<MedicationProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentUser == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
        return;
      }

      // 선택된 요일을 문자열로 변환
      final selectedWeekdays = _selectedDays
          .map((index) => _weekDays[index])
          .toList();

      // MedicationRoutine 객체 생성
      final routine = MedicationRoutine.create(
        userId: authProvider.currentUser!.id,
        name: _medicationNameController.text,
        description: _medicationPurposeController.text.isNotEmpty
            ? _medicationPurposeController.text
            : null,
        takeTime: _selectedTimes,
        numPerTake: int.parse(_medicationAmountController.text),
        weekday: selectedWeekdays,
        startDay: _startDate,
        endDay: _endDate!,
      );

      // Provider를 통해 약 등록
      await medicationProvider.addRoutine(routine);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('약이 성공적으로 등록되었습니다.')));
        Navigator.of(context).pop(true); // 약 추가 완료를 나타내는 true 반환
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('약 등록에 실패했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
