// lib/screens/language_selection_screen.dart
import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/locale_notifier.dart';
// Import the generated localizations file to access translated strings

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  Widget _buildLanguageTile({
    required BuildContext context,
    required String languageName,
    required String currentLanguageFullName, // e.g., "English" from ARB
    required Locale localeToSet,
    Locale? currentLocale,
  }) {
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);
    final bool isSelected =
        currentLocale == localeToSet ||
        (currentLocale == null &&
            localeToSet.languageCode ==
                'en'); // Default to English if no preference

    return ListTile(
      title: Text(languageName, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        currentLanguageFullName,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing:
          isSelected
              ? Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
              )
              : null,
      onTap: () {
        localeNotifier.setLocale(localeToSet);
        Navigator.pop(context); // Go back after selection
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$languageName selected')));
      },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 10.0,
      ),
    );
  }

  Widget _buildSystemDefaultTile(BuildContext context, Locale? currentLocale) {
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);
    final bool isSelected = currentLocale == null;

    return ListTile(
      title: Text(
        "System Default",
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        "Use device language",
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing:
          isSelected
              ? Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
              )
              : null,
      onTap: () {
        localeNotifier.clearLocale();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('System default language selected')),
        );
      },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 10.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access AppLocalizations for translated strings
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final localeNotifier =
        context.watch<LocaleNotifier>(); // Watch for changes to currentLocale

    return Scaffold(
      appBar: AppBar(
        // Use localized title if available, otherwise fallback
        title: Text(l10n?.selectLanguage ?? 'Select Language'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 8),
          _buildSystemDefaultTile(context, localeNotifier.appLocale),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildLanguageTile(
            context: context,
            languageName: l10n?.languageEnglish ?? "English",
            currentLanguageFullName: "English (US)",
            localeToSet: const Locale('en'),
            currentLocale: localeNotifier.appLocale,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildLanguageTile(
            context: context,
            languageName: l10n?.languageUzbek ?? "Uzbek",
            currentLanguageFullName: "O'zbekcha (O'zbekiston)",
            localeToSet: const Locale('uz'),
            currentLocale: localeNotifier.appLocale,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildLanguageTile(
            context: context,
            languageName: l10n?.languageRussian ?? "Russian",
            currentLanguageFullName: "Русский (Россия)",
            localeToSet: const Locale('ru'),
            currentLocale: localeNotifier.appLocale,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      ),
    );
  }
}

extension on AppLocalizations? {
  get selectLanguage => null;
}
