import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _appLocale;

  static const String _languageCodeKey = 'app_language_code';

  Locale? get appLocale => _appLocale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_languageCodeKey);

    if (languageCode != null && languageCode.isNotEmpty) {
      _appLocale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
    _appLocale = locale;
    notifyListeners();
  }

  Future<void> clearLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageCodeKey);
    _appLocale = null;
    notifyListeners();
  }
}
