// lib/screens/theme_options_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import '../models/theme_notifier.dart'; // Import ThemeNotifier

class ThemeOptionsScreen extends StatelessWidget {
  const ThemeOptionsScreen({super.key});

  // Helper method to build a styled RadioListTile
  Widget _buildThemeOptionTile({
    required BuildContext context,
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
    required IconData iconData,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return RadioListTile<ThemeMode>(
      secondary: Icon(
        iconData,
        color: colorScheme.primary,
        size: 26,
      ), // Using secondary for icon placement
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor:
          colorScheme.primary, // Color of the radio button when selected
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      // For a more custom look, you could build a ListTile and a Radio manually
      // but RadioListTile is convenient and generally follows Material guidelines.
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ThemeNotifier for changes to update the UI of the radio buttons
    final themeNotifier = context.watch<ThemeNotifier>();
    final ThemeData currentTheme = Theme.of(context); // For AppBar styling

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Options'),
        centerTitle: true,
        backgroundColor: currentTheme.colorScheme.surface, // M3 style appbar
        foregroundColor: currentTheme.colorScheme.onSurface,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8), // A little space at the top

          _buildThemeOptionTile(
            context: context,
            title: 'System Default',
            value: ThemeMode.system,
            groupValue: themeNotifier.themeMode,
            onChanged: (ThemeMode? mode) {
              if (mode != null) {
                context.read<ThemeNotifier>().setThemeMode(mode);
              }
            },
            iconData: Icons.brightness_auto_outlined, // Icon for system default
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildThemeOptionTile(
            context: context,
            title: 'Light Mode',
            value: ThemeMode.light,
            groupValue: themeNotifier.themeMode,
            onChanged: (ThemeMode? mode) {
              if (mode != null) {
                context.read<ThemeNotifier>().setThemeMode(mode);
              }
            },
            iconData: Icons.light_mode_outlined, // Icon for light mode
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildThemeOptionTile(
            context: context,
            title: 'Dark Mode',
            value: ThemeMode.dark,
            groupValue: themeNotifier.themeMode,
            onChanged: (ThemeMode? mode) {
              if (mode != null) {
                context.read<ThemeNotifier>().setThemeMode(mode);
              }
            },
            iconData: Icons.dark_mode_outlined, // Icon for dark mode
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      ),
    );
  }
}
