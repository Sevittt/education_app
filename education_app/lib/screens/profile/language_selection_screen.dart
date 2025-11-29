import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';
import '../../models/locale_notifier.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final localeNotifier = context.watch<LocaleNotifier>();
    final currentLocale = localeNotifier.appLocale;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.selectLanguage ?? 'Select Language'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildSectionTitle(context, "System"),
              const SizedBox(height: 12),
              _buildLanguageCard(
                context: context,
                title: "System Default",
                subtitle: "Use device language settings",
                icon: Icons.settings_system_daydream,
                isSelected: currentLocale == null,
                onTap: () {
                  localeNotifier.clearLocale();
                  _showConfirmation(context, "System default language selected");
                },
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, "Available Languages"),
              const SizedBox(height: 12),
              _buildLanguageCard(
                context: context,
                title: l10n?.languageEnglish ?? "English",
                subtitle: "English (US)",
                flag: "🇺🇸",
                isSelected: currentLocale?.languageCode == 'en',
                onTap: () {
                  localeNotifier.setLocale(const Locale('en'));
                  _showConfirmation(context, "English selected");
                },
              ),
              const SizedBox(height: 16),
              _buildLanguageCard(
                context: context,
                title: l10n?.languageUzbek ?? "Uzbek",
                subtitle: "O'zbekcha (O'zbekiston)",
                flag: "🇺🇿",
                isSelected: currentLocale?.languageCode == 'uz',
                onTap: () {
                  localeNotifier.setLocale(const Locale('uz'));
                  _showConfirmation(context, "O'zbek tili tanlandi");
                },
              ),
              const SizedBox(height: 16),
              _buildLanguageCard(
                context: context,
                title: l10n?.languageRussian ?? "Russian",
                subtitle: "Русский (Россия)",
                flag: "🇷🇺",
                isSelected: currentLocale?.languageCode == 'ru',
                onTap: () {
                  localeNotifier.setLocale(const Locale('ru'));
                  _showConfirmation(context, "Русский язык выбран");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    String? flag,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: isSelected ? 4 : 0,
      shadowColor: colorScheme.primary.withAlpha(80),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected 
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      color: isSelected 
          ? colorScheme.primaryContainer.withAlpha(30) 
          : colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: colorScheme.primary.withAlpha(100),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Center(
                  child: flag != null
                      ? Text(
                          flag,
                          style: const TextStyle(fontSize: 24),
                        )
                      : Icon(
                          icon,
                          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmation(BuildContext context, String message) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}


