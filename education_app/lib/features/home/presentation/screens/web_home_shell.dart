import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

class WebHomeShell extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final Widget body;
  final Widget? floatingActionButton;

  const WebHomeShell({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.floatingActionButton,
  });

  @override
  State<WebHomeShell> createState() => _WebHomeShellState();
}

class _WebHomeShellState extends State<WebHomeShell> {
  bool _isMenuOpen = true;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.floatingActionButton,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(context),
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Image.asset(
            'assets/images/app_logo.png',
            height: 40,
          ),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.appTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          // Functional profile avatar
          InkWell(
            onTap: () {
              widget.onDestinationSelected(3); // Navigate to Profile tab
            },
            borderRadius: BorderRadius.circular(18),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: widget.onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      indicatorColor:
          Colors.transparent, // Removes the "purple square" background
      leading: Column(
        children: [
          const SizedBox(height: 8),
          IconButton(
            icon: Icon(_isMenuOpen ? Icons.menu_open : Icons.menu),
            onPressed: _toggleMenu,
          ),
          const SizedBox(height: 8),
        ],
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(AppLocalizations.of(context)!.bottomNavHome),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.menu_book_outlined),
          selectedIcon: const Icon(Icons.menu_book),
          label: Text(AppLocalizations.of(context)!.bottomNavResources),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.people_outline),
          selectedIcon: const Icon(Icons.people),
          label: Text(AppLocalizations.of(context)!.bottomNavCommunity),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: Text(AppLocalizations.of(context)!.bottomNavProfile),
        ),
      ],
      extended: _isMenuOpen,
    );
  }

  // Helper getter for cleaner access to properties if needed,
  // but accessed via 'widget' directly above.
  int get _selectedIndex => widget.selectedIndex;
}
