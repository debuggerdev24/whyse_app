import 'package:flutter/material.dart';
import 'package:redstreakapp/core/theme/app_theme_palette.dart';

class AppColors {
  AppColors._();

  static AppThemePalette _active = AppThemes.dark;

  static void apply(AppThemePalette palette) {
    _active = palette;
  }

  static bool get isDark => _active.isDark;

  /// Text and icons on fills that stay dark in both modes: photos, navy
  /// cards, teal and orange chips, and black pills.
  static const Color onFill = Color(0xFFFFFFFF);

  /// Text and icons on fills that stay light in both modes, such as a
  /// frosted white button.
  static const Color onLight = Color(0xFF1A1A1A);

  /// Light accent cards darken in dark mode so labels can use [black].
  static Color accentFill(Color light) {
    if (!isDark) return light;
    return Color.alphaBlend(light.withValues(alpha: 0.34), _active.surface);
  }

  static Color get teal => _active.primary;
  static Color get highlight => _active.highlight;
  static Color get lighttealcolor => _active.primaryLight;
  static Color get extealighttealcolor => _active.primaryWash;
  static Color get backgroundColor => _active.background;
  static Color get surface => _active.surface;

  /// Primary text and icons on [backgroundColor] and [surface].
  static Color get black => _active.onSurface;

  /// Cards, sheets, and input fills.
  static Color get white => _active.surface;

  /// Solid button fill. Teal in dark mode so the label stays light.
  static Color get buttonBackground =>
      isDark ? _active.primary : const Color(0xFF1A1A1A);

  static Color get darkGrey => isDark ? _active.muted : const Color(0xFF4A4A4A);
  static const Color lightblackColor = Color(0xFF1E1E1E);

  static Color get searchBackgroundColor =>
      isDark ? const Color(0xFF1E2E30) : const Color(0xFFF1F1F1);

  static const Color orangeColor = Color(0xFFF28518);
  static const Color streakFreezeBlue = Color(0xFF2B9FD9);
  static Color get streakFreezeBlueLight =>
      isDark ? const Color(0xFF163040) : const Color(0xFFE3F4FF);
  static Color get lightyellowcolor =>
      isDark ? const Color(0xFF2A241C) : const Color(0xFFF2ECE6);
  static const Color bluecolor = Color(0xFF011E41);

  static Color get lightwhiteColor =>
      isDark ? const Color(0xFF1E2E30) : const Color(0xFFF0F0F0);
  static const Color greenColor = Color(0xFF1EA437);
  static const Color darkgreenColor = Color(0xFF0CBA65);

  static const Color redColor = Color(0xFFE52222);
  static Color get indicatorColor =>
      isDark ? const Color(0xFFF2F6F6) : const Color(0xff030C09);

  static Color get shimmerBaseColor => isDark
      ? const Color(0xFF243234)
      : const Color.fromARGB(255, 207, 209, 213);
  static Color get shimmerHighlightColor =>
      isDark ? const Color(0xFF355052) : const Color(0xFFFBFCFF);

  static Color get muted => _active.muted;
  static Color get divider => _active.divider;
}
