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
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
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
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(_isMenuOpen ? Icons.menu_open : Icons.menu),
            onPressed: _toggleMenu,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/images/app_logo.png',
            height: 40,
          ),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.appTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(),
          // Optional placeholder for profile avatar on the right
          const CircleAvatar(
             radius: 18,
             backgroundColor: Colors.grey,
             child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: _isMenuOpen ? 250.0 : 72.0,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          
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
            icon: _selectedIndex == 1 ? Icons.menu_book : Icons.menu_book_outlined,
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

  Widget _buildMenuItem(BuildContext context, {
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
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : null,
            borderRadius: BorderRadius.circular(8),
             border: isSelected ? Border(
              left: BorderSide(color: theme.colorScheme.primary, width: 4),
            ) : null,
          ),
          child: Row(
            mainAxisAlignment: _isMenuOpen ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.primary : Colors.grey.shade700,
              ),
              if (_isMenuOpen) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
    // Tip: When collapsed, you might want to wrap the InkWell or the icon in a Tooltip.
    // However, since the whole row is clickable, a tooltip on the container or handled differently
    // would be better. For this implementation, I'll stick to the Row logic.
  }
    
  // Helper getter for cleaner access to properties if needed, 
  // but accessed via 'widget' directly above.
  int get _selectedIndex => widget.selectedIndex;
}
