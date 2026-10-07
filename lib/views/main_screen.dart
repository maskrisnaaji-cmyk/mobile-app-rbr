import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'agenda_view.dart';
import 'beranda_view.dart';
import 'kedai_kopi_view.dart';
import 'komunitas_view.dart';
import 'pustaka_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  final List<Widget> _views = const [
    BerandaView(),
    KedaiKopiView(),
    PustakaView(),
    AgendaView(),
    KomunitasView(),
  ];

  void _onSelectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _views[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onSelectTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.maroon,
        unselectedItemColor: AppColors.greyText,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_cafe_outlined),
            activeIcon: Icon(Icons.local_cafe),
            label: 'Kedai Kopi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Pustaka',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Komunitas',
          ),
        ],
      ),
    );
  }
}