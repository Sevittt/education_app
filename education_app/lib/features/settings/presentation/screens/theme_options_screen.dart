// lib/screens/theme_options_screen.dart

import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:provider/provider.dart'; // Import provider

import 'package:sud_qollanma/core/providers/theme_notifier.dart';

class ThemeOptionsScreen extends StatelessWidget {
  const ThemeOptionsScreen({super.key});

  // Helper method to build a styled RadioListTile
  Widget _buildThemeOptionTile({
    required BuildContext context,
    required String title,
    required ThemeMode value,
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
      groupValue: context.watch<ThemeNotifier>().themeMode,
      onChanged: (ThemeMode? mode) {
        if (mode != null) {
          context.read<ThemeNotifier>().setThemeMode(mode);
        }
      },
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
        title: Text(AppLocalizations.of(context)!.themeOptionsTitle),
        centerTitle: true,
        backgroundColor: currentTheme.colorScheme.surface, // M3 style appbar
        foregroundColor: currentTheme.colorScheme.onSurface,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8), // A little space at the top

          _buildThemeOptionTile(
            context: context,
            title: AppLocalizations.of(context)!.themeSystemDefault,
            value: ThemeMode.system,
            iconData: Icons.brightness_auto_outlined, // Icon for system default
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildThemeOptionTile(
            context: context,
            title: AppLocalizations.of(context)!.themeLight,
            value: ThemeMode.light,
            iconData: Icons.light_mode_outlined, // Icon for light mode
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildThemeOptionTile(
            context: context,
            title: AppLocalizations.of(context)!.themeDark,
            value: ThemeMode.dark,
            iconData: Icons.dark_mode_outlined, // Icon for dark mode
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      ),
    );
  }
}
