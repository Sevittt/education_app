import 'package:flutter/material.dart';

class AppColors {
  static const Color primarySeed = Colors.indigo;

  static const Color primary = Color(0xFF1A237E); // Indigo 900
  static const Color accent = Color(0xFFFFA000); // Amber 700
  static const Color error = Color(0xFFB00020);
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;

  static final LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primary.withValues(alpha: 0.8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient glassGradient = LinearGradient(
    colors: [
      Colors.white.withValues(alpha: 0.2),
      Colors.white.withValues(alpha: 0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient darkGlassGradient = LinearGradient(
    colors: [
      Colors.white.withValues(alpha: 0.1),
      Colors.white.withValues(alpha: 0.02),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
