import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../models/medication.dart';
import '../../service/medication_service.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _numPerTakeController = TextEditingController();
  final TextEditingController _totalDaysController = TextEditingController();

  // 복용 요일 선택 (리스트 형식)
  final List<String> _allWeekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final List<String> _selectedWeekdays = [];

  // 복용 시간 선택
  final List<List<int>> _selectedTimes = [];
  final List<String> _timeOptions = [
    '아침 (09:00)',
    '점심 (12:00)',
    '저녁 (18:00)',
    '취침 전 (21:00)',
  ];
  final Map<String, List<int>> _timeMap = {
    '아침 (09:00)': [9, 0],
    '점심 (12:00)': [12, 0],
    '저녁 (18:00)': [18, 0],
    '취침 전 (21:00)': [21, 0],
  };

  // 약 등록 서비스
  final MedicationService _medicationService = MedicationService();
  final int userId = 1; // TODO: 실제 사용자 ID로 변경

  bool _isLoading = false;

  @override
  void dispose() {
    _medicationNameController.dispose();
    _medicationPurposeController.dispose();
    _medicationAmountController.dispose();
    _numPerTakeController.dispose();
    _totalDaysController.dispose();
    super.dispose();
  }

  // 약 등록 메서드
  Future<void> _registerMedication() async {
    // 입력값 검증
    if (_medicationNameController.text.isEmpty) {
      _showErrorDialog('약 이름을 입력해주세요.');
      return;
    }

    if (_numPerTakeController.text.isEmpty) {
      _showErrorDialog('1회 투여량을 입력해주세요.');
      return;
    }

    if (_selectedWeekdays.isEmpty) {
      _showErrorDialog('복용 요일을 선택해주세요.');
      return;
    }

    if (_selectedTimes.isEmpty) {
      _showErrorDialog('복용 시간을 선택해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 약 루틴 생성
      final routine = MedicationRoutine(
        id: 0, // 서버에서 생성
        userId: userId,
        name: _medicationNameController.text,
        description: _medicationPurposeController.text.isEmpty
            ? null
            : _medicationPurposeController.text,
        takeTime: _selectedTimes,
        numPerTake: int.tryParse(_numPerTakeController.text) ?? 1,
        numPerDay: _selectedTimes.length,
        totalDays: int.tryParse(_totalDaysController.text) ?? 30,
        weekday: _selectedWeekdays,
        startDay: DateTime.now(),
        endDay: DateTime.now().add(
          Duration(days: int.tryParse(_totalDaysController.text) ?? 30),
        ),
      );

      // 서버에 등록
      await _medicationService.createRoutine(routine);

      // 성공 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_medicationNameController.text}이(가) 등록되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('약 등록 실패: $e');
      if (mounted) {
        _showErrorDialog('약 등록에 실패했습니다.\n$e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 에러 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '복약 정보 입력',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
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
                      '무엇을 위한 약인가요?',
                      '우울증, 영양제 등 카테고리를 적어주세요.',
                      _medicationPurposeController,
                    ),
                    const SizedBox(height: 24),
                    _buildInputSection(
                      '1회 투여량 (정)',
                      '숫자로 입력해 주세요',
                      _numPerTakeController,
                    ),
                    const SizedBox(height: 24),
                    _buildInputSection(
                      '총 투여일수',
                      '숫자로 입력해 주세요 (기본: 30일)',
                      _totalDaysController,
                    ),
                    const SizedBox(height: 24),
                    _buildWeekdaySelection(),
                    const SizedBox(height: 24),
                    _buildTimeSelection(),
                  ],
                ),
              ),
            ),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainQuestion() {
    return const Text(
      '어떤 약을 무엇을 위해 복용하시나요?',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
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
            color: Colors.black,
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

  Widget _buildWeekdaySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '복용 요일',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allWeekdays.map((weekday) {
            final isSelected = _selectedWeekdays.contains(weekday);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedWeekdays.remove(weekday);
                  } else {
                    _selectedWeekdays.add(weekday);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  weekday,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '복용 시간',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timeOptions.map((timeOption) {
            final timeValue = _timeMap[timeOption]!;
            final isSelected = _selectedTimes.any(
              (time) => time[0] == timeValue[0] && time[1] == timeValue[1],
            );

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTimes.removeWhere(
                      (time) =>
                          time[0] == timeValue[0] && time[1] == timeValue[1],
                    );
                  } else {
                    _selectedTimes.add(timeValue);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  timeOption,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _registerMedication,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLoading
              ? Colors.grey.shade400
              : Colors.grey.shade300,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '등록 중...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Text(
                '약 등록하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
