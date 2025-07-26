import 'package:flutter/material.dart';
import 'package:frontend/screens/emotion/emotion_screen.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/medication/medication_screen.dart';
import 'package:frontend/screens/mypage/mypage_screen.dart';
import 'package:frontend/screens/sleep/sleep_screen.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class NavigationScreen extends StatefulWidget {
  final int initialIndex;

  const NavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    MedicationScreen(),
    EmotionScreen(),
    SleepScreen(),
    MyPageScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          // backgroundColor: Color(0xFF18181B),
          backgroundColor: Colors.black,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Color.fromARGB(255, 152, 205, 91),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Symbols.home, fill: _selectedIndex == 0 ? 1 : 0),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.pill, fill: _selectedIndex == 1 ? 1 : 0),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.psychiatry, fill: _selectedIndex == 2 ? 1 : 0),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.sleep, fill: _selectedIndex == 3 ? 1 : 0),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.person, fill: _selectedIndex == 4 ? 1 : 0),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
