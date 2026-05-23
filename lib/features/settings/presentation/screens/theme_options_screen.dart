// lib/screens/theme_options_screen.dart

import 'package:flutter/material.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:sud_qollanma/core/providers/theme_notifier.dart';
import 'package:sud_qollanma/shared/widgets/glass_card.dart';
import 'package:sud_qollanma/shared/widgets/radio_group.dart';

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

    return AppRadioListTile<ThemeMode>(
      secondary: Icon(
        iconData,
        color: colorScheme.primary,
        size: 26,
      ),
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      ),
      value: value,
      activeColor: colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final ThemeData currentTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.themeOptionsTitle),
        centerTitle: true,
        backgroundColor: currentTheme.colorScheme.surface,
        foregroundColor: currentTheme.colorScheme.onSurface,
      ),
      body: AppRadioGroup<ThemeMode>(
        groupValue: themeNotifier.themeMode,
        onChanged: (ThemeMode? mode) {
          if (mode != null) {
            context.read<ThemeNotifier>().setThemeMode(mode);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildThemeOptionTile(
                    context: context,
                    title: AppLocalizations.of(context)!.themeSystemDefault,
                    value: ThemeMode.system,
                    iconData: Icons.brightness_auto_outlined,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildThemeOptionTile(
                    context: context,
                    title: AppLocalizations.of(context)!.themeLight,
                    value: ThemeMode.light,
                    iconData: Icons.light_mode_outlined,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildThemeOptionTile(
                    context: context,
                    title: AppLocalizations.of(context)!.themeDark,
                    value: ThemeMode.dark,
                    iconData: Icons.dark_mode_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

