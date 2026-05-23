import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier to manage the app's theme mode with persistence.
class ThemeNotifier with ChangeNotifier {
  static const String _themeKey = 'user_theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  /// Current theme mode of the application.
  ThemeMode get themeMode => _themeMode;

  /// Sets the theme mode and persists it to local storage.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Loads the persisted theme mode from local storage.
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null && themeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeIndex];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  // Helper methods for UI state
  bool isSystemDefault() => _themeMode == ThemeMode.system;
  bool isLightMode() => _themeMode == ThemeMode.light;
  bool isDarkMode() => _themeMode == ThemeMode.dark;
}
