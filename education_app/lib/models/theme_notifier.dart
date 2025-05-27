// lib/models/theme_notifier.dart

import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  // Default theme mode is system default
  ThemeMode _themeMode = ThemeMode.system;

  // Getter to access the current theme mode
  ThemeMode get themeMode => _themeMode;

  // Method to set the theme mode and notify listeners
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners(); // Notify widgets listening to this Change Notifier
  }

  // Optional: Methods to check current mode for RadioListTile
  bool isSystemDefault() => _themeMode == ThemeMode.system;
  bool isLightMode() => _themeMode == ThemeMode.light;
  bool isDarkMode() => _themeMode == ThemeMode.dark;

  getTheme() {}
}
