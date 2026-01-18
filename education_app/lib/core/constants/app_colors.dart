import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors - Deep & Premium
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  static const Color primaryLight = Color(0xFFC7D2FE); // Indigo 200

  // Secondary/Accent Colors - Vibrant & Modern
  static const Color accent = Color(0xFF0EA5E9); // Sky 500
  static const Color accentDark = Color(0xFF0369A1); // Sky 700
  static const Color accentLight = Color(0xFFBAE6FD); // Sky 200

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Neutral Colors (Light Mode)
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  static const Color textPrimaryLight = Color(0xFF1E293B); // Slate 800
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500

  // Neutral Colors (Dark Mode)
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Slate 100
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF818CF8)], // Indigo 600 to Indigo 400
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x99FFFFFF), // White 60%
      Color(0x66FFFFFF), // White 40%
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

    static const LinearGradient darkGlassGradient = LinearGradient(
    colors: [
      Color(0x991E293B), // Slate 800 60%
      Color(0x661E293B), // Slate 800 40%
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
