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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: _isMenuOpen ? 250.0 : 72.0,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        children: [
          // Toggle Button
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(_isMenuOpen ? Icons.chevron_left : Icons.menu),
              onPressed: _toggleMenu,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          // Menu Items
          _buildMenuItem(
            context,
            index: 0,
            icon: _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
            label: AppLocalizations.of(context)!.bottomNavHome,
          ),
          _buildMenuItem(
            context,
            index: 1,
            icon: _selectedIndex == 1
                ? Icons.menu_book
                : Icons.menu_book_outlined,
            label: AppLocalizations.of(context)!.bottomNavResources,
          ),
          _buildMenuItem(
            context,
            index: 2,
            icon: _selectedIndex == 2 ? Icons.people : Icons.people_outline,
            label: AppLocalizations.of(context)!.bottomNavCommunity,
          ),
          _buildMenuItem(
            context,
            index: 3,
            icon: _selectedIndex == 3 ? Icons.person : Icons.person_outline,
            label: AppLocalizations.of(context)!.bottomNavProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = widget.selectedIndex == index;
    final theme = Theme.of(context);

    return Tooltip(
      message: _isMenuOpen ? '' : label, // Only show tooltip when collapsed
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: () => widget.onDestinationSelected(index),
        child: Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: _isMenuOpen
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              if (_isMenuOpen) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper getter for cleaner access to properties if needed,
  // but accessed via 'widget' directly above.
  int get _selectedIndex => widget.selectedIndex;
}
