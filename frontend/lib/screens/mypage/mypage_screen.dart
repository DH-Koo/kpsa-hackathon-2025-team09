import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = Colors.black;
    final Color cardColor = Colors.grey[900]!;
    final Color iconBgColor = Colors.grey[800]!;
    final Color textColor = Colors.white;
    final Color subTextColor = Colors.grey[400]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: 세팅 화면
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
        // TODO: 잠시만 로그아웃 버튼 나중에 이용!!!
        // actions: [
        //   IconButton(
        //     onPressed: () async {
        //       // 로딩 상태 표시
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(
        //           content: Text('로그아웃 중...'),
        //           duration: Duration(seconds: 1),
        //         ),
        //       );

        //       final authProvider = context.read<AuthProvider>();
        //       await authProvider.logout();

        //       if (context.mounted) {
        //         // 즉시 홈으로 이동
        //         Navigator.of(
        //           context,
        //         ).pushNamedAndRemoveUntil('/', (route) => false);
        //       }
        //     },
        //     icon: const Icon(Icons.logout, color: Colors.white),
        //   ),
        // ],
      ),
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 영역
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: iconBgColor,
                    child: Icon(Icons.person, color: subTextColor, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '이름',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '안녕하세요 000님!',
                          style: TextStyle(fontSize: 15, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 포인트 관리
              Text(
                '포인트 관리',
                style: TextStyle(fontSize: 14, color: subTextColor),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.circle, color: textColor, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            '50,000P',
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront, color: textColor, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            '포인트 상점',
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 내 음악
              Text(
                '나의 음악',
                style: TextStyle(fontSize: 14, color: subTextColor),
              ),
              const SizedBox(height: 12),
              _ListTile(
                icon: Icons.music_note,
                title: '최근 들은 음악',
                subtitle: '다시 듣고 싶은 음악을 감상해보세요',
                textColor: textColor,
                subTextColor: subTextColor,
                iconBgColor: iconBgColor,
              ),
              _ListTile(
                icon: Icons.favorite_border,
                title: '내가 생성한 음악',
                subtitle: '내가 생성한 음악을 감상해보세요',
                textColor: textColor,
                subTextColor: subTextColor,
                iconBgColor: iconBgColor,
              ),
              const SizedBox(height: 32),

              // 정보
              Text('정보', style: TextStyle(fontSize: 14, color: subTextColor)),
              const SizedBox(height: 12),
              _ListTile(
                icon: Icons.card_giftcard,
                title: '내 쿠폰',
                textColor: textColor,
                subTextColor: subTextColor,
                iconBgColor: iconBgColor,
              ),
              _ListTile(
                icon: Icons.notifications_none,
                title: '알림 설정',
                textColor: textColor,
                subTextColor: subTextColor,
                iconBgColor: iconBgColor,
              ),
              _ListTile(
                icon: Icons.description,
                title: '이용약관',
                textColor: textColor,
                subTextColor: subTextColor,
                iconBgColor: iconBgColor,
              ),
              _ListTile(
                icon: Icons.code,
                title: '오픈소스 라이선스',
                textColor: textColor,
                subTextColor: subTextColor,
                iconBgColor: iconBgColor,
              ),
              _ListTile(
                icon: Icons.headset_mic,
                title: '고객 문의',
                textColor: textColor,
                subTextColor: subTextColor,
                iconBgColor: iconBgColor,
              ),
              const SizedBox(height: 12),
              _ListTile(
                icon: Icons.logout,
                title: '로그아웃',
                textColor: Colors.red[300]!,
                subTextColor: subTextColor,
                iconBgColor: Colors.red[900]!,
                onTap: () async {
                  // final authProvider = context.read<AuthProvider>();
                  // await authProvider.logout();
                  // if (context.mounted) {
                  //   Navigator.of(context).pushReplacementNamed('/');
                  // }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color textColor;
  final Color subTextColor;
  final Color iconBgColor;
  final VoidCallback? onTap;

  const _ListTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.textColor,
    required this.subTextColor,
    required this.iconBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: subTextColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 17, color: textColor),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: TextStyle(fontSize: 13, color: subTextColor),
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
  }
}
