import 'package:flutter/material.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';

/// Sud Qoʻllanma ranglari — Figma "Yangi dizayn" palitrasi (AppTokens).
///
/// Yangi kodda `context.tokens` dan foydalaning: u yorugʻ/qorongʻi rejimni
/// oʻzi tanlaydi. Bu klassdagi nomlar eski ekranlar uchun saqlangan, qiymatlari
/// esa yangi palitraga moslangan:
///   * `primary…` — yorugʻ rejimdagi brend (toʻq koʻk)
///   * `amber…`   — qorongʻi rejimdagi brend (och koʻk). Nomi tarixiy:
///     avval qorongʻi rejim oltin urgʻuda edi. Oltin endi faqat yutuqlar
///     uchun — `gold…` ga qarang.
class AppColors {
  AppColors._();

  static const AppTokens _l = AppTokens.light;
  static const AppTokens _d = AppTokens.dark;

  // ── BREND (yorugʻ rejim) ──────────────────────────────────────────────────
  static const Color primary          = Color(0xFF1B3B6F);
  static const Color primaryDark      = Color(0xFF142D56);
  static const Color primaryLight     = Color(0xFF3A5888);
  static const Color primaryContainer = Color(0xFFE5ECF7);
  static const Color onPrimary        = Color(0xFFFFFFFF);

  // ── BREND (qorongʻi rejim; tarixiy nom "amber") ───────────────────────────
  static const Color amber          = Color(0xFF8EB1EE);
  static const Color amberLight     = Color(0xFFA9C4F3);
  static const Color amberContainer = Color(0xFF1B2C49);

  // ── OLTIN — faqat yutuq, sertifikat, XP ───────────────────────────────────
  static const Color gold          = Color(0xFFC8962E);
  static const Color goldInk       = Color(0xFF8A5F0E);
  static const Color goldContainer = Color(0xFFF7EEDB);

  // ── SEMANTIK ──────────────────────────────────────────────────────────────
  static const Color success  = Color(0xFF1E7F55);
  static const Color error    = Color(0xFFB93A32);
  static const Color warning  = Color(0xFFC2610F);
  static const Color info     = Color(0xFF1B3B6F);

  // ── GAMIFIKATSIYA ─────────────────────────────────────────────────────────
  static const Color streakAccent = Color(0xFFC2610F);
  static const Color goldPodium   = Color(0xFFC8962E);
  static const Color goldText     = Color(0xFF8A5F0E);
  static const Color silverPodium = Color(0xFFC9D0DA);
  static const Color silverText   = Color(0xFF556274);
  static const Color bronzePodium = Color(0xFFC2610F);
  static const Color bronzeText   = Color(0xFF7C3D0A);

  // ── YORUGʻ SIRTLAR ────────────────────────────────────────────────────────
  static const Color backgroundLight     = Color(0xFFF5F6F8);
  static const Color surfaceLight        = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFEEF1F5);
  static const Color textPrimaryLight    = Color(0xFF0F1B2D);
  static const Color textSecondaryLight  = Color(0xFF556274);
  static const Color borderLight         = Color(0xFFE2E6EC);
  static const Color dividerLight        = Color(0xFFEEF1F5);

  // ── QORONGʻI SIRTLAR ──────────────────────────────────────────────────────
  static const Color scaffoldDark    = Color(0xFF0A111E);
  static const Color surfaceDark     = Color(0xFF121B2B);
  static const Color surfaceElevated = Color(0xFF1A2536);
  static const Color borderDark      = Color(0xFF253247);
  static const Color dividerDark     = Color(0xFF1A2536);

  static const Color backgroundDark     = scaffoldDark;
  static const Color surfaceVariantDark = surfaceElevated;

  // ── QORONGʻI MATN ─────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFEDF1F7);
  static const Color textSecondary = Color(0xFFA3AEC0);

  static const Color textPrimaryDark   = textPrimary;
  static const Color textSecondaryDark = textSecondary;

  // ── GRADIENTLAR ───────────────────────────────────────────────────────────
  // Yangi dizaynda gradient yoʻq: eski ekranlar uchun bir xil rangli "gradient".
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1B3B6F), Color(0xFF1B3B6F)],
  );
  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFF8EB1EE), Color(0xFF8EB1EE)],
  );

  // ── ESKI NOMLAR ───────────────────────────────────────────────────────────
  static const Color accent      = Color(0xFF1B3B6F);
  static const Color accentDark  = Color(0xFF142D56);
  static const Color accentLight = Color(0xFFE5ECF7);
  static const Color streakGradientStart = streakAccent;
  static const Color streakGradientEnd   = Color(0xFFC8962E);
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
  );
  static const LinearGradient darkGlassGradient = LinearGradient(
    colors: [Color(0xFF121B2B), Color(0xFF121B2B)],
  );
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF1B3B6F), Color(0xFF1B3B6F)],
  );

  /// Tokenlar bilan bir xil boʻlishini tekshirish uchun (test).
  static List<(Color, Color)> get tokenPairs => [
        (primary, _l.brandPrimary),
        (amber, _d.brandPrimary),
        (backgroundLight, _l.bgCanvas),
        (scaffoldDark, _d.bgCanvas),
        (surfaceDark, _d.bgSurface),
        (textPrimaryLight, _l.textPrimary),
        (textPrimary, _d.textPrimary),
        (borderLight, _l.borderDefault),
        (borderDark, _d.borderDefault),
      ];
}
