// lib/home_page.dart

// lib/screens/home/home_page.dart
// import 'package:education_app/l10n/app_localizations.dart'; // O'ZGARISH: Lokalizatsiyani import qilish
// import 'package:education_app/screens/community/community_screen.dart';
// import 'package:education_app/screens/home/home_dashboard_screen.dart';
// import 'package:education_app/screens/profile/profile_screen.dart';
// import 'package:education_app/screens/resource/resources_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/screens/community/community_screen.dart';
import 'package:sud_qollanma/screens/home/home_dashboard_screen.dart';
import 'package:sud_qollanma/screens/profile/profile_screen.dart';
import 'package:sud_qollanma/screens/resource/resources_screen.dart';
import '../../models/auth_notifier.dart';
import '../../models/users.dart'; // Import UserRole
import '../resource/create_resource_screen.dart';
import '../community/create_topic_screen.dart';
import '../resource/quiz/create_quiz_screen.dart'; // Make sure this import is present

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

  Widget _buildSpeedDial() {
    // Get the user's data from AuthNotifier
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final user = authNotifier.appAppUser;

    // If there's no user, don't show the button
    if (user == null) {
      return const SizedBox.shrink(); // Use SizedBox.shrink() for an empty widget
    }

    // A helper function to build the list of actions based on role
    List<SpeedDialChild> getRoleBasedActions() {
      final List<SpeedDialChild> actions = [];

      // ACTION: Create Discussion (available to all roles)
      actions.add(
        SpeedDialChild(
          child: const Icon(Icons.chat_bubble),
          label: 'Create Discussion',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateTopicScreen(),
              ),
            );
          },
        ),
      );

      // ACTIONS: Create Resource & Quiz (only for teachers and admins)
      if (user.role == UserRole.teacher || user.role == UserRole.admin) {
        actions.add(
          SpeedDialChild(
            child: const Icon(Icons.description),
            label: 'Create Resource',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateResourceScreen(),
                ),
              );
            },
          ),
        );
        actions.add(
          SpeedDialChild(
            child: const Icon(Icons.quiz),
            label: 'Create Quiz',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateQuizScreen(),
                ),
              );
            },
          ),
        );
      }

      // You could add admin-only actions here in the future
      // if (user.role == UserRole.admin) { ... }

      return actions;
    }

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      animationCurve: Curves.bounceIn,
      children: getRoleBasedActions(), // Use the role-aware list of actions
    );
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      title: Text(
        AppLocalizations.of(context)!.appTitle,
      ), // O'ZGARISH: Sarlavhani lokalizatsiyadan olish
      centerTitle: true,
      elevation: Theme.of(context).appBarTheme.elevation ?? 2.0,
    );
    return Scaffold(
      appBar: appBar,
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      // --- Add the floatingActionButton here ---
      floatingActionButton:
          (_selectedIndex == 1 || _selectedIndex == 2)
              ? _buildSpeedDial()
              : null,
      bottomNavigationBar: BottomNavigationBar(
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
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        type: Theme.of(context).bottomNavigationBarTheme.type,
      ),
    );
  }
}
