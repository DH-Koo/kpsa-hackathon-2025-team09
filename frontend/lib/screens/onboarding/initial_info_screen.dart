import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class InitialInfoScreen extends StatefulWidget {
  const InitialInfoScreen({Key? key}) : super(key: key);

  @override
  State<InitialInfoScreen> createState() => _InitialInfoScreenState();
}

class _InitialInfoScreenState extends State<InitialInfoScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 8;

  // 각 페이지의 상태를 저장
  Map<int, dynamic> _pageStates = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onNextPressed() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 마지막 페이지에서 홈 화면으로 이동
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  void _onSkipPressed() {
    // 온보딩을 건너뛰고 홈 화면으로 이동
    Navigator.pushReplacementNamed(context, '/main');
  }

  void _updatePageState(int pageIndex, dynamic state) {
    setState(() {
      _pageStates[pageIndex] = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더 영역
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentPage > 0 
                        ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                        : null,
                    icon: Icon(
                      Icons.arrow_back,
                      color: _currentPage > 0 ? Colors.white : Colors.white.withOpacity(0.3),
                      size: 24,
                    ),
                  ),
                  // 진행률 바
                  Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (_currentPage + 1) / _totalPages,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _onSkipPressed,
                    child: const Text(
                      '건너뛰기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 페이지뷰 영역
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  return _buildPage(index);
                },
              ),
            ),
            
            // 하단 버튼 영역
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _totalPages - 1 ? '완료' : '다음',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return _buildWelcomePage();
      case 1:
        return _buildMedicalDiagnosisPage();
      case 2:
        return _buildCurrentMedicationPage();
      case 3:
        return _buildAllergyPage();
      case 4:
        return _buildSupplementsPage();
      case 5:
        return _buildSideEffectsPage();
      case 6:
        return _buildAlcoholPage();
      case 7:
        return _buildSmokingPage();
      default:
        return Container();
    }
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          Text(
            '만나서 반가워요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '몇 가지 질문으로, 00님에게\n딱 맞는 MindTune을 만들어드릴게요',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalDiagnosisPage() {
    bool? hasDiagnosis = _pageStates[1];
    List<String> selectedDiseases = _pageStates[1]?['diseases'] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          const Text(
            '의사에게 진단받은 질환이 있나요?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildSelectionButton(
                  '네',
                  hasDiagnosis == true,
                  () => _updatePageState(1, {'hasDiagnosis': true, 'diseases': selectedDiseases}),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSelectionButton(
                  '아니오',
                  hasDiagnosis == false,
                  () => _updatePageState(1, {'hasDiagnosis': false, 'diseases': []}),
                ),
              ),
            ],
          ),
          if (hasDiagnosis == true) ...[
            const SizedBox(height: 32),
            const Text(
              '어떤 질환인가요?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDiseaseCategory('기분장애', [
                      '우울증/조울증',
                      '월경전불쾌장애',
                    ], selectedDiseases),
                    const SizedBox(height: 16),
                    _buildDiseaseCategory('불안장애', [
                      '공황장애',
                      '광장공포증',
                      '사회공포증',
                      '특정공포증',
                      '범불안장애',
                    ], selectedDiseases),
                    const SizedBox(height: 16),
                    _buildDiseaseCategory('외상 및 스트레스 관련 장애', [
                      '급성/외상 후 스트레스 장애',
                      '불면증 과다졸림 기면증 일주기리듬 수면-각성 장애',
                    ], selectedDiseases),
                    const SizedBox(height: 16),
                    _buildDiseaseCategory('신체증상장애 및 강박장애', [
                      '신체증상장애',
                      '강박장애',
                    ], selectedDiseases),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiseaseCategory(String category, List<String> diseases, List<String> selectedDiseases) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...diseases.map((disease) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildDiseaseButton(disease, selectedDiseases),
        )),
      ],
    );
  }

  Widget _buildDiseaseButton(String disease, List<String> selectedDiseases) {
    bool isSelected = selectedDiseases.contains(disease);
    return GestureDetector(
      onTap: () {
        List<String> newSelected = List.from(selectedDiseases);
        if (isSelected) {
          newSelected.remove(disease);
        } else {
          newSelected.add(disease);
        }
        _updatePageState(1, {
          'hasDiagnosis': true,
          'diseases': newSelected,
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          disease,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentMedicationPage() {
    String searchText = _pageStates[2]?['searchText'] ?? '';
    List<String> medications = _pageStates[2]?['medications'] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          const Text(
            '현재 복용 중인 약이 있나요?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => _updatePageState(2, {
                      'searchText': value,
                      'medications': medications,
                    }),
                    decoration: const InputDecoration(
                      hintText: '간편하게 복용 약을 검색해보세요.',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const Icon(Icons.search, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (medications.isNotEmpty) ...[
            Text(
              '추가된 약물',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...medications.map((med) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                med,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            )),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (searchText.isNotEmpty) {
                  List<String> newMedications = List.from(medications);
                  if (!newMedications.contains(searchText)) {
                    newMedications.add(searchText);
                  }
                  _updatePageState(2, {
                    'searchText': '',
                    'medications': newMedications,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('약물 추가'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyPage() {
    bool? hasAllergy = _pageStates[3];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          const Text(
            '알레르기가 있으신가요?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildSelectionButton(
                  '네',
                  hasAllergy == true,
                  () => _updatePageState(3, true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSelectionButton(
                  '아니오',
                  hasAllergy == false,
                  () => _updatePageState(3, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupplementsPage() {
    bool? hasSupplements = _pageStates[4];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          const Text(
            '복용 중인 건강기능식품, 한약, 기타 자가 복용 제품이 있나요?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildSelectionButton(
                  '네',
                  hasSupplements == true,
                  () => _updatePageState(4, true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSelectionButton(
                  '아니오',
                  hasSupplements == false,
                  () => _updatePageState(4, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideEffectsPage() {
    bool? hasSideEffects = _pageStates[5];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          const Text(
            '복약하면서 부작용이 생겼던 적이 있다면 알려주세요.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildSelectionButton(
                  '네',
                  hasSideEffects == true,
                  () => _updatePageState(5, true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSelectionButton(
                  '아니오',
                  hasSideEffects == false,
                  () => _updatePageState(5, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlcoholPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          const Text(
            '거의 다 왔어요!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '음주는 얼마나 하시나요?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          _buildAlcoholOptions(),
        ],
      ),
    );
  }

  Widget _buildAlcoholOptions() {
    String? selectedOption = _pageStates[6];
    List<String> options = ['전혀 안 함', '가끔', '주 1-2회', '주 3-4회', '매일'];

    return Column(
      children: options.map((option) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildSelectionButton(
          option,
          selectedOption == option,
          () => _updatePageState(6, option),
        ),
      )).toList(),
    );
  }

  Widget _buildSmokingPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          const Text(
            '흡연은 얼마나 하시나요?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          _buildSmokingOptions(),
        ],
      ),
    );
  }

  Widget _buildSmokingOptions() {
    String? selectedOption = _pageStates[7];
    List<String> options = ['전혀 안 함', '가끔', '하루 1-5개비', '하루 6-10개비', '하루 10개비 이상'];

    return Column(
      children: options.map((option) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildSelectionButton(
          option,
          selectedOption == option,
          () => _updatePageState(7, option),
        ),
      )).toList(),
    );
  }

  Widget _buildSelectionButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
} 