// lib/screens/settings_screen.dart

// import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import 'package:sud_qollanma/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:sud_qollanma/features/faq/presentation/screens/faq_list_screen.dart';
import 'package:sud_qollanma/features/settings/presentation/screens/change_password_screen.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';

import 'package:provider/provider.dart';
import 'package:sud_qollanma/features/auth/presentation/providers/auth_notifier.dart';

import 'package:sud_qollanma/core/providers/locale_provider.dart';
import 'package:sud_qollanma/features/profile/presentation/screens/language_screen.dart';


import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

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

  Future<void> _openTelegram() async {
    final Uri url = Uri.parse('https://t.me/sudqollanma');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
         // Fallback or error message, though usually externalApplication mode handles it gracefully/silently if fails
         debugPrint('Could not launch using external application');
         // Try default mode as backup
         if (!await launchUrl(url)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.errorTelegramOpen)),
              );
            }
         }
      }
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
      activeThumbColor: colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
    );
  }

  String _getLanguageName(String localeCode) {
    switch (localeCode) {
      case 'uz':
        return 'O\'zbekcha';
      case 'ru':
        return 'Русский';
      case 'en':
      default:
        return 'English (US)';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get AppLocalizations instance
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLanguage = _getLanguageName(localeProvider.appLocale?.languageCode ?? 'en');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.settingsTitle ?? 'Settings',
        ), // Localized title
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              'assets/images/app_logo.png',
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.settings, size: 80, color: Colors.grey);
              },
            ),
          ),
          const SizedBox(height: 20),

          _buildSwitchSettingsItem(
            context: context,
            icon: Icons.notifications_active_outlined,
            title: l10n?.settingsNotifications ?? 'Notifications',
            value: _receiveNotifications,
            onChanged: _updateNotificationSetting,
            subtitle: l10n?.settingsReceiveNotificationsSubtitle ?? 'Get updates about new resources and discussions',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildSwitchSettingsItem(
            context: context,
            icon: Icons.location_on_outlined,
            title: l10n?.settingsAllowLocation ?? 'Allow Location Access',
            value: _allowLocationAccess,
            onChanged: _updateLocationSetting,
            subtitle: l10n?.settingsAllowLocationSubtitle ?? 'For features requiring your location (if any)',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildSettingsItem(
            context: context,
            icon: Icons.language,
            title: l10n?.settingsLanguage ?? 'Language',
            subtitle: currentLanguage,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildSettingsItem(
            context: context,
            icon: Icons.password_outlined,
            title: l10n?.changePasswordTitle ?? 'Change Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const ChangePasswordScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),



          _buildSettingsItem(
            context: context,
            icon: Icons.send_rounded, // Telegram icon style
            title: l10n?.contactSupport ?? 'Contact Support',
            subtitle: '@sudqollanma',
            onTap: _openTelegram,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildSettingsItem(
            context: context,
            icon: Icons.help_center_outlined,
            title: l10n?.helpCenterTitle ?? 'Help Center',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const FaqListScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildSettingsItem(
            context: context,
            icon: Icons.info_outline_rounded,
            title: l10n?.settingsAbout ?? 'About App',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName:
                    l10n?.appTitle ?? 'Court Handbook',
                applicationVersion: '1.0.2',
                applicationIcon: Image.asset(
                  'assets/images/app_logo.png',
                  width: 60,
                  height: 60,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.info, size: 50),
                ),
                applicationLegalese: l10n?.settingsAppLegalese ?? '© 2025 Court Handbook Project',
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      l10n?.settingsAppDescription ??
                          'Bridging the IT skills gap through collaborative learning and resource sharing.',
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // --- ADMIN PANEL ENTRY POINT ---
          // Only show for Admins
          if (context.watch<AuthNotifier>().appUser?.role == UserRole.admin)
            Column(
              children: [
                _buildSettingsItem(
                  context: context,
                  icon: Icons.admin_panel_settings_outlined,
                  title: l10n?.adminPanelTitle ?? 'Admin Panel',
                  subtitle: l10n?.manageNewsSubtitle ?? 'Manage app content',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminPanelScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            ),
        ],
      ),
    );
  }
}
