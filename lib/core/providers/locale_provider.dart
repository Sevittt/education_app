import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _appLocale;

  static const String _languageCodeKey = 'app_language_code';
  static const String _scriptCodeKey = 'app_script_code';

  /// Oʻzbek tilining yangi lotin alifbosi (Ö, Ğ, Ş, Ç — OʻRQ-1184).
  /// gen-l10n alifbo variantini faqat skript kodi orqali ajratadi, shuning
  /// uchun `Latn` shu variantga ajratilgan; `Locale('uz')` — amaldagi alifbo.
  static const Locale uzNewAlphabet =
      Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Latn');

  Locale? get appLocale => _appLocale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_languageCodeKey);

    if (languageCode != null && languageCode.isNotEmpty) {
      _appLocale = Locale.fromSubtags(
        languageCode: languageCode,
        scriptCode: prefs.getString(_scriptCodeKey),
      );
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
    final scriptCode = locale.scriptCode;
    if (scriptCode != null) {
      await prefs.setString(_scriptCodeKey, scriptCode);
    } else {
      await prefs.remove(_scriptCodeKey);
    }
    _appLocale = locale;
    notifyListeners();

    if (userId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'preferredLanguage': locale.languageCode});
      } catch (_) {}
    }
  }

  Future<void> clearLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageCodeKey);
    await prefs.remove(_scriptCodeKey);
    _appLocale = null;
    notifyListeners();
  }
}
