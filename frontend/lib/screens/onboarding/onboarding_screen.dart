import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'onboarding_page.dart';
import 'role_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: "소개 화면1",
      mainText: "오늘의 감정을 들려주세요.\nMindTune이 당신만을\n위한 음악을 만들어드립니다.",
      subtitle: null,
      showCloseButton: true,
      showPagination: true,
      buttonText: "다음",
    ),
    OnboardingPageData(
      title: "소개 화면2",
      mainText: "오늘의 복약을 잊지 마세요.\nMindTune과 알림부터\n감정·부작용 케어, 약사 연계까지",
      subtitle: null,
      showCloseButton: true,
      showPagination: true,
      buttonText: "다음",
    ),
    OnboardingPageData(
      title: "소개 화면3",
      mainText: "오늘의 밤을 준비하세요.\nMindTune이 맞춤형\n수면 케어를 시작합니다.",
      subtitle: null,
      showCloseButton: true,
      showPagination: true,
      buttonText: "MindTune 시작하기",
    ),
  ];

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
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 마지막 페이지에서 역할 선택 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const RoleSelectionScreen(),
        ),
      );
    }
  }

  void _onClosePressed() {
    // 온보딩을 건너뛰고 역할 선택 화면으로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const RoleSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더 영역
            if (_pages[_currentPage].showCloseButton)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _pages[_currentPage].title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      onPressed: _onClosePressed,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _pages[_currentPage].title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            
            // 페이지뷰 영역
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    data: _pages[index],
                    currentPage: _currentPage,
                    totalPages: _pages.length,
                  );
                },
              ),
            ),
            
            // 하단 버튼 영역
            if (_pages[_currentPage].buttonText != null)
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
                      _pages[_currentPage].buttonText!,
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
}

 