import 'package:flutter/material.dart';

/// Sud Qoʻllanma dizayn tokenlari — Figma "Sud Qoʻllanma — Yangi dizayn (mobil)"
/// faylidagi «Ranglar · Yorugʻ» va «Ranglar · Qorongʻi» kolleksiyalari bilan bir xil.
///
/// Ekranlarda `context.tokens.brandPrimary` kabi ishlatiladi; `isDark ? … : …`
/// tanlovi kerak emas — mavzu oʻzi yorugʻ yoki qorongʻi qiymatni beradi.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final Color bgCanvas;
  final Color bgSurface;
  final Color bgSubtle;
  final Color bgElevated;
  final Color borderDefault;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnBrand;
  final Color brandPrimary;
  final Color brandPressed;
  final Color brandContainer;
  final Color brandOnContainer;
  final Color goldSolid;
  final Color goldInk;
  final Color goldContainer;
  final Color successSolid;
  final Color successContainer;
  final Color dangerSolid;
  final Color dangerContainer;
  final Color streakSolid;
  final Color streakContainer;
  final Color heroBg;
  final Color heroFg;
  final Color heroMuted;
  final Color heroTrack;

  const AppTokens({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgSubtle,
    required this.bgElevated,
    required this.borderDefault,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnBrand,
    required this.brandPrimary,
    required this.brandPressed,
    required this.brandContainer,
    required this.brandOnContainer,
    required this.goldSolid,
    required this.goldInk,
    required this.goldContainer,
    required this.successSolid,
    required this.successContainer,
    required this.dangerSolid,
    required this.dangerContainer,
    required this.streakSolid,
    required this.streakContainer,
    required this.heroBg,
    required this.heroFg,
    required this.heroMuted,
    required this.heroTrack,
  });

  static const light = AppTokens(
    bgCanvas: Color(0xFFF5F6F8),
    bgSurface: Color(0xFFFFFFFF),
    bgSubtle: Color(0xFFEEF1F5),
    bgElevated: Color(0xFFFFFFFF),
    borderDefault: Color(0xFFE2E6EC),
    borderStrong: Color(0xFFC9D0DA),
    textPrimary: Color(0xFF0F1B2D),
    textSecondary: Color(0xFF556274),
    textTertiary: Color(0xFF8792A2),
    textOnBrand: Color(0xFFFFFFFF),
    brandPrimary: Color(0xFF1B3B6F),
    brandPressed: Color(0xFF142D56),
    brandContainer: Color(0xFFE5ECF7),
    brandOnContainer: Color(0xFF1B3B6F),
    goldSolid: Color(0xFFC8962E),
    goldInk: Color(0xFF8A5F0E),
    goldContainer: Color(0xFFF7EEDB),
    successSolid: Color(0xFF1E7F55),
    successContainer: Color(0xFFE2F3EA),
    dangerSolid: Color(0xFFB93A32),
    dangerContainer: Color(0xFFFBE8E6),
    streakSolid: Color(0xFFC2610F),
    streakContainer: Color(0xFFFDEEDD),
    heroBg: Color(0xFF1B3B6F),
    heroFg: Color(0xFFFFFFFF),
    heroMuted: Color(0xFFC5D2E8),
    heroTrack: Color(0xFF3A5888),
  );

  static const dark = AppTokens(
    bgCanvas: Color(0xFF0A111E),
    bgSurface: Color(0xFF121B2B),
    bgSubtle: Color(0xFF1A2536),
    bgElevated: Color(0xFF1E2A3D),
    borderDefault: Color(0xFF253247),
    borderStrong: Color(0xFF34435C),
    textPrimary: Color(0xFFEDF1F7),
    textSecondary: Color(0xFFA3AEC0),
    textTertiary: Color(0xFF6F7C91),
    textOnBrand: Color(0xFF0A111E),
    brandPrimary: Color(0xFF8EB1EE),
    brandPressed: Color(0xFFA9C4F3),
    brandContainer: Color(0xFF1B2C49),
    brandOnContainer: Color(0xFFC6D7F6),
    goldSolid: Color(0xFFD9AE52),
    goldInk: Color(0xFFE5C27A),
    goldContainer: Color(0xFF2C2414),
    successSolid: Color(0xFF52C48D),
    successContainer: Color(0xFF11301F),
    dangerSolid: Color(0xFFF0776C),
    dangerContainer: Color(0xFF3A1B19),
    streakSolid: Color(0xFFF29B4C),
    streakContainer: Color(0xFF39250F),
    heroBg: Color(0xFF182A4A),
    heroFg: Color(0xFFEDF1F7),
    heroMuted: Color(0xFFA3B4D1),
    heroTrack: Color(0xFF2B3F63),
  );

  @override
  AppTokens copyWith() => this;

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      bgCanvas: l(bgCanvas, other.bgCanvas),
      bgSurface: l(bgSurface, other.bgSurface),
      bgSubtle: l(bgSubtle, other.bgSubtle),
      bgElevated: l(bgElevated, other.bgElevated),
      borderDefault: l(borderDefault, other.borderDefault),
      borderStrong: l(borderStrong, other.borderStrong),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textTertiary: l(textTertiary, other.textTertiary),
      textOnBrand: l(textOnBrand, other.textOnBrand),
      brandPrimary: l(brandPrimary, other.brandPrimary),
      brandPressed: l(brandPressed, other.brandPressed),
      brandContainer: l(brandContainer, other.brandContainer),
      brandOnContainer: l(brandOnContainer, other.brandOnContainer),
      goldSolid: l(goldSolid, other.goldSolid),
      goldInk: l(goldInk, other.goldInk),
      goldContainer: l(goldContainer, other.goldContainer),
      successSolid: l(successSolid, other.successSolid),
      successContainer: l(successContainer, other.successContainer),
      dangerSolid: l(dangerSolid, other.dangerSolid),
      dangerContainer: l(dangerContainer, other.dangerContainer),
      streakSolid: l(streakSolid, other.streakSolid),
      streakContainer: l(streakContainer, other.streakContainer),
      heroBg: l(heroBg, other.heroBg),
      heroFg: l(heroFg, other.heroFg),
      heroMuted: l(heroMuted, other.heroMuted),
      heroTrack: l(heroTrack, other.heroTrack),
    );
  }
}

/// Oraliq va burchak oʻlchamlari (Figma «Oʻlchamlar»).
abstract final class AppSpace {
  static const double s4 = 4, s8 = 8, s12 = 12, s16 = 16, s20 = 20, s24 = 24, s32 = 32;
}

abstract final class AppRadius {
  static const double sm = 8, md = 12, lg = 16, xl = 20, full = 999;
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>() ?? AppTokens.light;
}
