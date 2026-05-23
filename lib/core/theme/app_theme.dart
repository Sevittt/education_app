import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Mizan Design System — Theme Configuration
///
/// Light mode is primary. Dark mode uses GitHub-style layering:
///   background (#0D1117) → surface (#161B22) → card (#21262D)
class AppTheme {
  AppTheme._();

  // ── TYPOGRAPHY ─────────────────────────────────────────────────────────────
  // Noto Sans covers Cyrillic (Russian) and Latin Extended (Uzbek) characters
  // that Poppins doesn't include, preventing the "missing characters" warning on web.
  static final List<String> _fallbackFonts = [
    GoogleFonts.notoSans().fontFamily!,
  ];

  static TextTheme _buildTextTheme(TextTheme base, Color bodyColor) {
    return GoogleFonts.poppinsTextTheme(base).copyWith(
      // Display
      displayLarge:  GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: bodyColor, height: 1.2),
      displayMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: bodyColor, height: 1.2),
      displaySmall:  GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: bodyColor, height: 1.25),
      // Headline
      headlineLarge:  GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: bodyColor, height: 1.3),
      headlineMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: bodyColor, height: 1.3),
      headlineSmall:  GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: bodyColor, height: 1.35),
      // Title
      titleLarge:  GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: bodyColor),
      titleMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: bodyColor),
      titleSmall:  GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: bodyColor),
      // Body
      bodyLarge:  GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, color: bodyColor, height: 1.5),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: bodyColor, height: 1.5),
      bodySmall:  GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: bodyColor, height: 1.4),
      // Label
      labelLarge:  GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: bodyColor),
      labelMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: bodyColor),
      labelSmall:  GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: bodyColor),
    ).apply(fontFamilyFallback: _fallbackFonts);
  }

  // ── LIGHT THEME ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary:            AppColors.primary,
      onPrimary:          AppColors.onPrimary,
      primaryContainer:   AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primaryDark,
      secondary:          AppColors.info,
      onSecondary:        Colors.white,
      secondaryContainer: Color(0xFFE0F2FE),
      onSecondaryContainer: Color(0xFF0C4A6E),
      tertiary:           AppColors.success,
      onTertiary:         Colors.white,
      error:              AppColors.error,
      onError:            Colors.white,
      surface:            AppColors.surfaceLight,
      onSurface:          AppColors.textPrimaryLight,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
      onSurfaceVariant:   AppColors.textSecondaryLight,
      outline:            AppColors.borderLight,
      outlineVariant:     AppColors.dividerLight,
      shadow:             Color(0xFF000000),
      scrim:              Color(0xFF000000),
      inverseSurface:     AppColors.surfaceDark,
      onInverseSurface:   AppColors.textPrimaryDark,
      inversePrimary:     AppColors.primaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.backgroundLight,

      textTheme: _buildTextTheme(
        ThemeData.light().textTheme,
        AppColors.textPrimaryLight,
      ),
      primaryTextTheme: _buildTextTheme(
        ThemeData.light().textTheme,
        AppColors.textPrimaryLight,
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,

      // AppBar — solid primary with white text (all secondary screens)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Cards — white with a whisper of shadow
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),

      // Elevated buttons — full-width, 52dp tall
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Filled buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Input fields — outlined, clean white
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondaryLight),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondaryLight),
        prefixIconColor: AppColors.primary,
      ),

      // Bottom nav — white bar, M3 indicator pill
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFF9CA3AF),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400),
      ),

      // Tabs
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondaryLight,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400),
        dividerColor: AppColors.borderLight,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryContainer,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.surfaceVariantLight,
        labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
        space: 1,
      ),

      // List tiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.transparent,
      ),

      // Search
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: const WidgetStatePropertyAll(AppColors.surfaceLight),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        hintStyle: WidgetStatePropertyAll(
          GoogleFonts.poppins(color: AppColors.textSecondaryLight, fontSize: 14),
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: GoogleFonts.poppins(color: AppColors.textPrimaryDark, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14, color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  // ── DARK THEME — "Judicial Authority Dark" ──────────────────────────────
  static ThemeData get darkTheme {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      // Amber gold is the primary accent in dark mode
      primary:            AppColors.amber,          // #C9A84C
      onPrimary:          AppColors.scaffoldDark,   // dark text ON amber
      primaryContainer:   AppColors.amberContainer, // #2A2210
      onPrimaryContainer: AppColors.amberLight,     // #E8C96E
      secondary:          AppColors.amberLight,     // #E8C96E
      onSecondary:        AppColors.scaffoldDark,
      secondaryContainer: AppColors.amberContainer,
      onSecondaryContainer: AppColors.amber,
      tertiary:           AppColors.success,        // #27AE7A
      onTertiary:         AppColors.scaffoldDark,
      error:              AppColors.error,          // #E05050
      onError:            AppColors.scaffoldDark,
      surface:            AppColors.surfaceDark,    // #152032
      onSurface:          AppColors.textPrimary,    // #EFF4FA
      surfaceContainerHighest: AppColors.surfaceElevated, // #1C2D42
      onSurfaceVariant:   AppColors.textSecondary,  // #7A9BBE
      outline:            AppColors.borderDark,     // #253545
      outlineVariant:     AppColors.dividerDark,    // #1C2D42
      shadow:             Color(0xFF000000),
      scrim:              Color(0xFF000000),
      inverseSurface:     AppColors.surfaceLight,
      onInverseSurface:   AppColors.textPrimaryLight,
      inversePrimary:     AppColors.primary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.scaffoldDark, // #0C1520

      textTheme: _buildTextTheme(
        ThemeData.dark().textTheme,
        AppColors.textPrimary,
      ),
      primaryTextTheme: _buildTextTheme(
        ThemeData.dark().textTheme,
        AppColors.textPrimary,
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,

      // AppBar — deepest navy, matches scaffold
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.scaffoldDark,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actionsIconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      // Cards — one step lighter than scaffold, with border
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark, // #152032
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated buttons — amber gold
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.scaffoldDark,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Filled buttons — amber gold
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.scaffoldDark,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined buttons — amber border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.amber,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.amber, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Text buttons — amber
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.amber,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Input fields — navy fill, amber focus border
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark, // #152032
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.amber, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        prefixIconColor: AppColors.amber,
      ),

      // Bottom nav — scaffold-colored bar, amber active
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.scaffoldDark,
        selectedItemColor: AppColors.amber,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400),
      ),

      // Tabs — amber indicator
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.amber,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.amber,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400),
        dividerColor: AppColors.borderDark,
      ),

      // Chips — elevated surface, amber accent
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.amberContainer,
        disabledColor: AppColors.surfaceDark,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: AppColors.borderDark, width: 0.8),
      ),

      // FAB — amber
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.scaffoldDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 0.8,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.transparent,
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
