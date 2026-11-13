import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_tokens.dart';

/// Sud Qoʻllanma mavzusi — Figma "Yangi dizayn" (AppTokens).
///
/// Yorugʻ va qorongʻi rejim bitta quruvchidan: farq faqat tokenlarda.
/// Sarlavhalar — Noto Serif (rasmiy ohang), qolgan matn — Inter.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(AppTokens.light, Brightness.light);
  static ThemeData get darkTheme => _build(AppTokens.dark, Brightness.dark);

  // Kirill (rus tili) va oʻ/gʻ, Ö/Ğ/Ş/Ç uchun zaxira shrift
  static final List<String> _fallback = [GoogleFonts.notoSans().fontFamily!];

  /// Figma matn uslublari → Material TextTheme:
  ///   Display/L → displayLarge, Display/M → displayMedium/displaySmall,
  ///   Numeric/L → headlineLarge, Numeric/M → headlineMedium,
  ///   Title/L|M|S → titleLarge|Medium|Small, Body/L|M|S → bodyLarge|Medium|Small,
  ///   Label/M → labelLarge, Label/S → labelMedium, Caption → labelSmall.
  static TextTheme _textTheme(Color c) {
    TextStyle inter(double size, FontWeight w, double height, [double spacing = 0]) =>
        GoogleFonts.inter(fontSize: size, fontWeight: w, height: height / size,
            letterSpacing: spacing, color: c);
    TextStyle serif(double size, double height, double spacing) =>
        GoogleFonts.notoSerif(fontSize: size, fontWeight: FontWeight.w600,
            height: height / size, letterSpacing: spacing, color: c);

    return TextTheme(
      displayLarge: serif(28, 34, -0.14),
      displayMedium: serif(22, 28, -0.07),
      displaySmall: serif(22, 28, -0.07),
      headlineLarge: inter(32, FontWeight.w700, 36, -0.64),
      headlineMedium: inter(20, FontWeight.w600, 24, -0.2),
      headlineSmall: inter(18, FontWeight.w600, 24, -0.09),
      titleLarge: inter(18, FontWeight.w600, 24, -0.09),
      titleMedium: inter(16, FontWeight.w600, 22, -0.05),
      titleSmall: inter(14, FontWeight.w600, 20),
      bodyLarge: inter(16, FontWeight.w400, 24),
      bodyMedium: inter(14, FontWeight.w400, 20),
      bodySmall: inter(12, FontWeight.w400, 16),
      labelLarge: inter(14, FontWeight.w500, 20),
      labelMedium: inter(12, FontWeight.w500, 16),
      labelSmall: inter(11, FontWeight.w600, 14, 0.22),
    ).apply(fontFamilyFallback: _fallback);
  }

  static ThemeData _build(AppTokens t, Brightness b) {
    final isDark = b == Brightness.dark;
    final text = _textTheme(t.textPrimary);
    final cs = ColorScheme(
      brightness: b,
      primary: t.brandPrimary,
      onPrimary: t.textOnBrand,
      primaryContainer: t.brandContainer,
      onPrimaryContainer: t.brandOnContainer,
      secondary: t.goldSolid,
      onSecondary: t.textOnBrand,
      secondaryContainer: t.goldContainer,
      onSecondaryContainer: t.goldInk,
      tertiary: t.successSolid,
      onTertiary: t.textOnBrand,
      tertiaryContainer: t.successContainer,
      onTertiaryContainer: t.successSolid,
      error: t.dangerSolid,
      onError: t.textOnBrand,
      errorContainer: t.dangerContainer,
      onErrorContainer: t.dangerSolid,
      surface: t.bgSurface,
      onSurface: t.textPrimary,
      surfaceContainerLowest: t.bgCanvas,
      surfaceContainerLow: t.bgSurface,
      surfaceContainer: t.bgSurface,
      surfaceContainerHigh: t.bgSubtle,
      surfaceContainerHighest: t.bgSubtle,
      onSurfaceVariant: t.textSecondary,
      outline: t.borderStrong,
      outlineVariant: t.borderDefault,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: isDark ? AppTokens.light.bgSurface : AppTokens.dark.bgSurface,
      onInverseSurface: isDark ? AppTokens.light.textPrimary : AppTokens.dark.textPrimary,
      inversePrimary: isDark ? AppTokens.light.brandPrimary : AppTokens.dark.brandPrimary,
    );

    final radius12 = BorderRadius.circular(AppRadius.md);
    OutlineInputBorder field(Color c, [double w = 1]) =>
        OutlineInputBorder(borderRadius: radius12, borderSide: BorderSide(color: c, width: w));

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: cs,
      extensions: [t],
      scaffoldBackgroundColor: t.bgCanvas,
      textTheme: text,
      primaryTextTheme: text,
      fontFamily: GoogleFonts.inter().fontFamily,
      dividerColor: t.borderDefault,

      appBarTheme: AppBarTheme(
        backgroundColor: t.bgCanvas,
        foregroundColor: t.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: t.textPrimary),
        actionsIconTheme: IconThemeData(color: t.textPrimary),
        titleTextStyle: text.titleMedium,
      ),

      cardTheme: CardThemeData(
        color: t.bgSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: t.borderDefault),
        ),
      ),

      // Asosiy tugma: L — 52px, radius 12
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: t.brandPrimary,
          foregroundColor: t.textOnBrand,
          disabledBackgroundColor: t.bgSubtle,
          disabledForegroundColor: t.textTertiary,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s20),
          shape: RoundedRectangleBorder(borderRadius: radius12),
          textStyle: text.titleMedium,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: t.brandPrimary,
          foregroundColor: t.textOnBrand,
          disabledBackgroundColor: t.bgSubtle,
          disabledForegroundColor: t.textTertiary,
          elevation: 0,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s20),
          shape: RoundedRectangleBorder(borderRadius: radius12),
          textStyle: text.titleMedium,
        ),
      ),
      // "Chegarali" tugma
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.textPrimary,
          backgroundColor: t.bgSurface,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s20),
          side: BorderSide(color: t.borderStrong),
          shape: RoundedRectangleBorder(borderRadius: radius12),
          textStyle: text.titleMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.brandPrimary,
          textStyle: text.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.s16, vertical: 14),
        border: field(t.borderDefault),
        enabledBorder: field(t.borderDefault),
        focusedBorder: field(t.brandPrimary, 2),
        errorBorder: field(t.dangerSolid),
        focusedErrorBorder: field(t.dangerSolid, 2),
        labelStyle: text.bodyMedium?.copyWith(color: t.textSecondary),
        hintStyle: text.bodyMedium?.copyWith(color: t.textTertiary),
        prefixIconColor: t.textTertiary,
        suffixIconColor: t.textTertiary,
      ),

      // Pastki navigatsiya: indikator — brand/container pill
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: t.bgSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: t.brandContainer,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? text.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: t.textPrimary)
            : text.labelMedium?.copyWith(color: t.textSecondary)),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            size: 22,
            color: s.contains(WidgetState.selected) ? t.brandOnContainer : t.textSecondary)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: t.bgSurface,
        selectedItemColor: t.brandPrimary,
        unselectedItemColor: t.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: text.labelMedium,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: t.textPrimary,
        unselectedLabelColor: t.textSecondary,
        indicatorColor: t.brandPrimary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.labelLarge,
        dividerColor: t.borderDefault,
      ),

      // Filtr chip: tanlangan — brand/primary, oddiy — surface + chegara
      chipTheme: ChipThemeData(
        backgroundColor: t.bgSurface,
        selectedColor: t.brandPrimary,
        disabledColor: t.bgSubtle,
        checkmarkColor: t.textOnBrand,
        labelStyle: text.labelLarge?.copyWith(color: t.textSecondary),
        secondaryLabelStyle: text.labelLarge?.copyWith(color: t.textOnBrand),
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
        shape: const StadiumBorder(),
        side: BorderSide(color: t.borderDefault),
        showCheckmark: false,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: t.brandPrimary,
        foregroundColor: t.textOnBrand,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: t.brandPrimary,
        linearTrackColor: t.bgSubtle,
        circularTrackColor: t.bgSubtle,
      ),

      dividerTheme: DividerThemeData(color: t.borderDefault, thickness: 1, space: 1),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.s16, vertical: AppSpace.s4),
        shape: RoundedRectangleBorder(borderRadius: radius12),
        tileColor: Colors.transparent,
        textColor: t.textPrimary,
        iconColor: t.textSecondary,
      ),

      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(t.bgSurface),
        side: WidgetStatePropertyAll(BorderSide(color: t.borderDefault)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: radius12)),
        hintStyle: WidgetStatePropertyAll(text.bodyMedium?.copyWith(color: t.textTertiary)),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: cs.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: radius12),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: t.bgElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium?.copyWith(color: t.textSecondary),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.bgElevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
    );
  }
}
