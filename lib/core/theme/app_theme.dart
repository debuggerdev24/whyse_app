import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/theme/app_palette.dart';

/// Builds the Material theme from an [AppPalette].
///
/// Color values live in [AppPalette]. This file only maps those tokens onto
/// Flutter's theme so bars, sheets, text, and inputs follow the same palette.
class AppThemes {
  AppThemes._();

  static ThemeData light() => fromPalette(AppPalette.light);

  static ThemeData dark() => fromPalette(AppPalette.dark);

  static ThemeData fromPalette(AppPalette palette) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: palette.brightness,
    ).copyWith(
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      secondary: palette.secondary,
      onSecondary: palette.textPrimary,
      surface: palette.cardSurface,
      onSurface: palette.textPrimary,
      error: const Color(0xFFE52222),
      onError: const Color(0xFFFFFFFF),
    );

    final textColor = palette.textPrimary;
    final baseText = TextStyle(
      fontFamily: 'SFProDisplay',
      color: textColor,
    );

    return ThemeData(
      brightness: palette.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      cardColor: palette.cardSurface,
      dividerColor: palette.border,
      splashColor: palette.primary.withValues(alpha: 0.08),
      highlightColor: palette.primary.withValues(alpha: 0.04),
      iconTheme: IconThemeData(color: textColor),
      primaryIconTheme: IconThemeData(color: textColor),
      textTheme: TextTheme(
        bodyLarge: baseText,
        bodyMedium: baseText,
        bodySmall: baseText.copyWith(color: palette.textSecondary),
        titleLarge: baseText.copyWith(fontWeight: FontWeight.w700),
        titleMedium: baseText.copyWith(fontWeight: FontWeight.w600),
        titleSmall: baseText.copyWith(fontWeight: FontWeight.w600),
        labelLarge: baseText,
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: overlayStyle(palette),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: AppTextStyles.semibold(
          fontSize: 20,
          color: textColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.cardSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.cardSurface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.cardSurface,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: palette.border, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.primary,
        selectionColor: palette.primary.withValues(alpha: 0.28),
        selectionHandleColor: palette.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          elevation: 0,
        ),
      ),
    );
  }

  static SystemUiOverlayStyle overlayStyle(AppPalette palette) {
    final lightIcons = palette.isDark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: lightIcons ? Brightness.light : Brightness.dark,
      statusBarBrightness: lightIcons ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: palette.navBar,
      systemNavigationBarIconBrightness:
          lightIcons ? Brightness.light : Brightness.dark,
    );
  }
}
