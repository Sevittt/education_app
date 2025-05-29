// lib/models/locale_notifier.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier with ChangeNotifier {
  Locale?
  _appLocale; // Can be null if no preference is set, then system locale is used by MaterialApp

  static const String _languageCodeKey = 'app_language_code';
  // static const String _countryCodeKey = 'app_country_code'; // Optional

  Locale? get appLocale => _appLocale;

  LocaleNotifier() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_languageCodeKey);
    // final String? countryCode = prefs.getString(_countryCodeKey); // Optional

    if (languageCode != null && languageCode.isNotEmpty) {
      // For simplicity, not handling countryCode here, but you could add it:
      // _appLocale = Locale(languageCode, countryCode);
      _appLocale = Locale(languageCode);
      notifyListeners();
    } else {}
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
    // if (locale.countryCode != null) { // Optional
    //   await prefs.setString(_countryCodeKey, locale.countryCode!);
    // } else {
    //   await prefs.remove(_countryCodeKey);
    // }
    _appLocale = locale;
    notifyListeners();
  }

  // Helper to clear locale preference (e.g., for "System Default" option)
  Future<void> clearLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageCodeKey);
    // await prefs.remove(_countryCodeKey); // Optional
    _appLocale =
        null; // Setting to null will make MaterialApp use system locale or first supported
    notifyListeners();
  }
}
