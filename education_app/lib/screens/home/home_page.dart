// lib/home_page.dart

import 'package:flutter/material.dart';
// Import the screen files
import '../community/community_screen.dart';
import 'home_dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../resource/resources_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeDashboardScreen(onTabSelected: _onItemTapped),
      const ResourcesScreen(),
      const CommunityScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // The BottomNavigationBarThemeData from main.dart will be applied here.
    // We can override specific properties if needed, but usually, it's better
    // to define them in the theme for consistency.

    var appBar = AppBar(
      title: const Text('Teach & Learn'), // Updated App Title
      centerTitle: true,
      // Example: Add a subtle shadow or remove it if preferred by theme
      elevation: Theme.of(context).appBarTheme.elevation ?? 2.0,
    );
    return Scaffold(
      // AppBar is kept simple, its theme is controlled from main.dart
      appBar: appBar,
      body: IndexedStack(
        // Use IndexedStack to preserve state of screens
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // Properties like backgroundColor, selectedItemColor, unselectedItemColor,
        // label styles, type, and elevation are now primarily controlled by
        // BottomNavigationBarThemeData in main.dart's ThemeData.
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 1
                  ? Icons.library_books
                  : Icons.library_books_outlined,
            ),
            label: 'Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 2 ? Icons.people : Icons.people_outline,
            ),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 3 ? Icons.person : Icons.person_outline,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // We can remove selectedItemColor and unselectedItemColor here
        // if we are happy with the theme's definition.
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        type: Theme.of(context).bottomNavigationBarTheme.type,
      ),
    );
  }
}
