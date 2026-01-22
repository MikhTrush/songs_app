// pages/main_navigation.dart
import 'package:flutter/material.dart';
import 'home.dart';
import 'collections_page.dart';
import 'statistics_page.dart';
import 'recommendations_page.dart'; // Add the recommendations page
import 'settings_page.dart'; // или используй /settings через маршруты

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // final List<Widget> _pages = [
  //   HomePage(), // index 0
  //   CollectionsPage(), // index 1
  //   RecommendationsPage(), // index 2 - newly added
  //   StatisticsPage(), // index 3
  //   SettingsPage(), // index 4 - or replace with Navigator.pushNamed if you want a separate route
  // ];
  Widget _page = HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page,
      // body: IndexedStack(
      //   index: _currentIndex,
      //   children: _pages,
      // ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
            _page = switch (index) {
              0 => HomePage(),
              1 => CollectionsPage(), // index 1
              2 => RecommendationsPage(), // index 2 - newly added
              3 => StatisticsPage(), // index 3
              4 =>
                SettingsPage(), // index 4 - or replace with Navigator.pushNamed if you want a separate route
              _ => HomePage(),
            };
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.collections),
            label: 'Collections',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome),
            label: 'Recommend',
          ),
          NavigationDestination(icon: Icon(Icons.calculate), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
    );
  }
}
