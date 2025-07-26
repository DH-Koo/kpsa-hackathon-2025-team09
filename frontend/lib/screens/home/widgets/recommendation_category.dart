import 'package:flutter/material.dart';

// 추천 카테고리 위젯
class RecommendationCategory extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<String>? songs;

  const RecommendationCategory({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        // 추천 곡 목록 표시
        if (songs != null) ...[
          const SizedBox(height: 12),
          ...songs!
              .map(
                (song) => Padding(
                  padding: const EdgeInsets.only(left: 36, bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.music_note, color: Colors.white54, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          song,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ],
    );
  }
}
