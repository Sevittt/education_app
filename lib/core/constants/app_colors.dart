import 'package:flutter/material.dart';

/// Mizan Design System — "Judicial Authority Dark"
///
/// Two-mode palette:
///   Light:  Indigo primary (#3B4FCC) + white surfaces  (trustworthy, clean)
///   Dark:   Deep navy (#0C1520) + amber gold (#C9A84C)  (authoritative, premium)
///
/// The amber accent evokes official court seals and judicial prestige.
class AppColors {
  AppColors._();

  // ── PRIMARY BRAND (light mode header, light buttons) ─────────────────────
  static const Color primary          = Color(0xFF3B4FCC); // Royal Indigo
  static const Color primaryDark      = Color(0xFF2A3A9E);
  static const Color primaryLight     = Color(0xFF6B7DE8);
  static const Color primaryContainer = Color(0xFFE8EBFF);
  static const Color onPrimary        = Color(0xFFFFFFFF);

  // ── AMBER ACCENT (dark mode primary, CTAs, active states) ────────────────
  static const Color amber          = Color(0xFFC9A84C); // Judicial gold
  static const Color amberLight     = Color(0xFFE8C96E); // Hover / pressed
  static const Color amberContainer = Color(0xFF2A2210); // Amber tint bg (icon boxes, badges)

  // ── SEMANTIC ──────────────────────────────────────────────────────────────
  static const Color success  = Color(0xFF27AE7A); // Emerald
  static const Color error    = Color(0xFFE05050); // Red
  static const Color warning  = Color(0xFFE8A020); // Amber-orange
  static const Color info     = Color(0xFF0284C7); // Sky 600

  // ── GAMIFICATION ──────────────────────────────────────────────────────────
  static const Color streakAccent = Color(0xFFFF7043); // Streak fire orange
  // Leaderboard — real metals
  static const Color goldPodium   = Color(0xFFFBBF24); // Amber 400
  static const Color goldText     = Color(0xFF78350F); // Amber 900
  static const Color silverPodium = Color(0xFFCBD5E1); // Slate 300
  static const Color silverText   = Color(0xFF334155); // Slate 700
  static const Color bronzePodium = Color(0xFFCD853F); // Peru / bronze
  static const Color bronzeText   = Color(0xFF7C2D12); // Orange 900

  // ── LIGHT MODE SURFACES ───────────────────────────────────────────────────
  static const Color backgroundLight     = Color(0xFFF0F2FA); // Cool grey-blue tint
  static const Color surfaceLight        = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF7F8FC);
  static const Color textPrimaryLight    = Color(0xFF111827); // Grey 900
  static const Color textSecondaryLight  = Color(0xFF6B7280); // Grey 500
  static const Color borderLight         = Color(0xFFE5E7EB); // Grey 200
  static const Color dividerLight        = Color(0xFFF3F4F6); // Grey 100

  // ── DARK MODE SURFACES — "Judicial Authority" ─────────────────────────────
  static const Color scaffoldDark      = Color(0xFF0C1520); // App bg (deepest navy)
  static const Color surfaceDark       = Color(0xFF152032); // Card / sheet surfaces
  static const Color surfaceElevated   = Color(0xFF1C2D42); // Elevated cards, dialogs
  static const Color borderDark        = Color(0xFF253545); // Card borders, dividers
  static const Color dividerDark       = Color(0xFF1C2D42); // Subtle dividers

  // Legacy aliases (used in light theme ColorScheme)
  static const Color backgroundDark    = scaffoldDark;
  static const Color surfaceVariantDark = surfaceElevated;

  // ── DARK MODE TEXT ────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFFEFF4FA); // Near-white
  static const Color textSecondary  = Color(0xFF7A9BBE); // Muted blue-grey

  // Legacy aliases kept for backward compat
  static const Color textPrimaryDark   = textPrimary;
  static const Color textSecondaryDark = textSecondary;

  // ── GRADIENTS ─────────────────────────────────────────────────────────────
  /// Used for light-mode header strips and hero sections
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B4FCC), Color(0xFF5B6EE8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Amber gradient for dark-mode hero accents
  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFC9A84C), Color(0xFFE8C96E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── BACKWARD COMPAT ───────────────────────────────────────────────────────
  // Kept so stale imports compile; not used in new screens
  static const Color accent      = Color(0xFF0EA5E9);
  static const Color accentDark  = Color(0xFF0369A1);
  static const Color accentLight = Color(0xFFBAE6FD);
  static const Color streakGradientStart = streakAccent;
  static const Color streakGradientEnd   = Color(0xFFFFB300);
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x99FFFFFF), Color(0x66FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient darkGlassGradient = LinearGradient(
    colors: [Color(0x99161B22), Color(0x66161B22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF4F63D2), Color(0xFF7C8FF5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
