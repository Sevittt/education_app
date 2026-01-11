// lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/screens/community/community_screen.dart';
import 'package:sud_qollanma/screens/home/home_dashboard_screen.dart';
import 'package:sud_qollanma/screens/profile/profile_screen.dart';

import 'package:sud_qollanma/screens/resource/resources_screen.dart';

import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';
import '../../models/users.dart'; // Import UserRole
import '../resource/create_resource_screen.dart';
import '../community/create_topic_screen.dart';
import '../resource/quiz/create_quiz_screen.dart'; // Make sure this import is present
import '../notifications/notifications_screen.dart';
import '../../services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shared/layouts/responsive_layout.dart';
import 'web_home_shell.dart';

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
    final user = authNotifier.appUser;

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
          label: AppLocalizations.of(context)!.actionCreateDiscussion,
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

      // ACTIONS: Create Resource & Quiz (only for experts and admins)
      if (user.role == UserRole.ekspert || user.role == UserRole.admin) {
        actions.add(
          SpeedDialChild(
            child: const Icon(Icons.description),
            label: AppLocalizations.of(context)!.actionCreateResource,
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
            label: AppLocalizations.of(context)!.actionCreateQuiz,
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

  Widget _buildNotificationBell() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const SizedBox.shrink();

    final NotificationService notificationService = NotificationService();

    return StreamBuilder<int>(
      stream: notificationService.getUnreadCount(userId),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return IconButton(
          icon: Badge(
            label: Text(unreadCount.toString()),
            isLabelVisible: unreadCount > 0,
            child: const Icon(Icons.notifications),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Shared AppBar Logic
    var appBar = AppBar(
      title: Text(
        AppLocalizations.of(context)!.appTitle,
      ),
      centerTitle: true,
      elevation: Theme.of(context).appBarTheme.elevation ?? 2.0,
      actions: [
        _buildNotificationBell(),
      ],
    );

    // Mobile Body (Existing Logic)
    Widget mobileBody = Scaffold(
      appBar: appBar,
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      floatingActionButton:
          (_selectedIndex == 1 || _selectedIndex == 2)
              ? _buildSpeedDial()
              : null,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined),
            label: AppLocalizations.of(context)!.bottomNavHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 1 ? Icons.menu_book : Icons.menu_book_outlined,
            ),
            label: AppLocalizations.of(context)!.bottomNavResources,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 2 ? Icons.people : Icons.people_outline,
            ),
            label: AppLocalizations.of(context)!.bottomNavCommunity,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 3 ? Icons.person : Icons.person_outline,
            ),
            label: AppLocalizations.of(context)!.bottomNavProfile,
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

    // Desktop Body (New WebHomeShell Logic)
    Widget desktopBody = WebHomeShell(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      floatingActionButton:
          (_selectedIndex == 1 || _selectedIndex == 2)
              ? _buildSpeedDial()
              : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
    );

    return ResponsiveLayout(
      mobileBody: mobileBody,
      tabletBody: desktopBody,
      desktopBody: desktopBody,
    );
  }
}
