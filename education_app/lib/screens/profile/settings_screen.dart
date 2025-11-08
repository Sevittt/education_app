// lib/screens/settings_screen.dart

// import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../placeholder_screen.dart'; // Import the placeholder screen
import 'language_selection_screen.dart'; // Import the new LanguageSelectionScreen
// Import AppLocalizations to use translated strings

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _receiveNotifications = true;
  bool _allowLocationAccess = false;

  static const String _notificationsKey = 'settings_receive_notifications';
  static const String _locationKey = 'settings_allow_location';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _receiveNotifications = prefs.getBool(_notificationsKey) ?? true;
      _allowLocationAccess = prefs.getBool(_locationKey) ?? false;
    });
  }

  Future<void> _updateNotificationSetting(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, newValue);
    setState(() {
      _receiveNotifications = newValue;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notifications ${_receiveNotifications ? "enabled" : "disabled"}',
          ),
        ),
      );
    }
  }

  Future<void> _updateLocationSetting(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationKey, newValue);
    setState(() {
      _allowLocationAccess = newValue;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location access ${_allowLocationAccess ? "allowed" : "disallowed"}',
          ),
        ),
      );
    }
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.primary, size: 26),
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
              : null,
      trailing:
          trailing ??
          (onTap != null
              ? Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              )
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
    );
  }

  Widget _buildSwitchSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return SwitchListTile(
      secondary: Icon(icon, color: colorScheme.primary, size: 26),
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
              : null,
      value: value,
      onChanged: onChanged,
      activeColor: colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get AppLocalizations instance
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.settingsLanguage ?? 'Account Settings',
        ), // Localized title
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          _buildSwitchSettingsItem(
            context: context,
            icon: Icons.notifications_active_outlined,
            title: 'Receive Notifications', // This could also be localized
            value: _receiveNotifications,
            onChanged: _updateNotificationSetting,
            subtitle: 'Get updates about new resources and discussions',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildSwitchSettingsItem(
            context: context,
            icon: Icons.location_on_outlined,
            title: 'Allow Location Access', // This could also be localized
            value: _allowLocationAccess,
            onChanged: _updateLocationSetting,
            subtitle: 'For features requiring your location (if any)',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildSettingsItem(
            context: context,
            icon: Icons.password_outlined,
            title: 'Change Password', // This could also be localized
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const PlaceholderScreen(title: 'Change Password'),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildSettingsItem(
            context: context,
            icon: Icons.translate_outlined,
            title: l10n?.settingsLanguage ?? 'Language', // Localized title
            subtitle:
                'English (US)', // TODO: Make this dynamic based on selected language
            onTap: () {
              // Navigate to the actual LanguageSelectionScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSelectionScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildSettingsItem(
            context: context,
            icon: Icons.help_center_outlined,
            title: 'Help Center', // This could also be localized
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const PlaceholderScreen(title: 'Help Center'),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildSettingsItem(
            context: context,
            icon: Icons.info_outline_rounded,
            title: 'About Teach & Learn', // This could also be localized
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName:
                    l10n?.appTitle ?? 'Teach & Learn', // Localized app name
                applicationVersion: '1.0.2', // Example version
                applicationIcon: Image.asset(
                  'assets/images/Shared_Knowledge.png',
                  width: 60,
                  height: 60,
                ),
                applicationLegalese: '© 2025 Teach & Learn Project',
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    // This text could also be localized if needed
                    child: Text(
                      l10n?.appTitle ??
                          'Bridging the IT skills gap through collaborative learning and resource sharing.',
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      ),
    );
  }
}
