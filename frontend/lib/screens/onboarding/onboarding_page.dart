import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final int currentPage;
  final int totalPages;

  const OnboardingPage({
    Key? key,
    required this.data,
    required this.currentPage,
    required this.totalPages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 그라데이션 구체
          Container(
            width: 200,
            height: 200,
            child: Image.asset('assets/images/chatbot.png'),
          ),
          
          const SizedBox(height: 48),
          
          // 메인 텍스트
          if (data.mainText != null)
            Text(
              data.mainText!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: data.subtitle != null ? const Color(0xFF4CAF50) : Colors.white,
                fontSize: data.subtitle != null ? 32 : 16,
                fontWeight: data.subtitle != null ? FontWeight.bold : FontWeight.normal,
                height: 1.5,
              ),
            ),
          
          // 서브타이틀
          if (data.subtitle != null) ...[
            const SizedBox(height: 16),
            Text(
              data.subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
          
          // 페이지네이션 점들
          if (data.showPagination) ...[
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3, // 총 3개의 페이지
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentPage == index 
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String? mainText;
  final String? subtitle;
  final bool showCloseButton;
  final bool showPagination;
  final String? buttonText;

  OnboardingPageData({
    required this.title,
    this.mainText,
    this.subtitle,
    required this.showCloseButton,
    required this.showPagination,
    this.buttonText,
  });
} 