import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

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

  // 복용 요일 드롭다운 관련 변수 및 위젯 추가
  String _selectedDayOption = '매일';
  final List<String> _dayOptions = ['매일', '특정 요일에만'];

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
                      '얼마나 드시나요? (정)',
                      '숫자로 입력해 주세요',
                      _medicationAmountController,
                    ),
                    const SizedBox(height: 24),
                    _buildDayDropdown(),
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

  Widget _buildDayDropdown() {
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
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            value: _selectedDayOption,
            isExpanded: true,
            items: _dayOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedDayOption = newValue!;
              });
            },

            /// ✅ 버튼 스타일
            buttonStyleData: ButtonStyleData(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),

            /// ✅ 드롭다운 스타일
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              elevation: 0,
              offset: const Offset(0, -10),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              iconSize: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {
          // 다음 단계로 이동하는 로직 구현
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          '다음',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
