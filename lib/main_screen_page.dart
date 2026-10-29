import 'package:flutter/material.dart';
import 'package:virtual_companion/home_page.dart';
import 'package:virtual_companion/logic_page.dart';
import 'package:virtual_companion/logs_page.dart';
import 'package:virtual_companion/setting_page.dart';
import 'package:virtual_companion/stats_page.dart';
import 'package:virtual_companion/user_log.dart';

class MainScreenPage extends StatefulWidget {
  const MainScreenPage({super.key});

  @override
  State<MainScreenPage> createState() => _MainScreenPageState();
}

class _MainScreenPageState extends State<MainScreenPage> {
  final _pages = const [
    HomePage(),
    UserLog(),
    StatsPage(),
    LogsPage(),
    SettingPage(),
  ];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    LogicPage.instance.init();
  }

  @override
  void dispose() {
    LogicPage.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LogicPage.instance.currentMood,
      builder: (context, mood, child) {
        final bgColor = LogicPage.instance.getBgColor(mood);
        return Scaffold(
          body: IndexedStack(index: _currentPage, children: _pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentPage,
            type: BottomNavigationBarType.fixed,
            backgroundColor: bgColor,
            selectedItemColor: const Color.fromRGBO(255, 203, 71, 1),
            unselectedItemColor: Colors.white,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            iconSize: 28,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notes),
                label: 'Journal',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                label: 'Stats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_outlined),
                label: 'Logs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                label: 'Settings',
              ),
            ],
            onTap: (value) => setState(() => _currentPage = value),
          ),
        );
      },
    );
  }
}
