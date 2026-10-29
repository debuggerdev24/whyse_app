import 'package:flutter/material.dart';

/// Ocean Teal colors for one appearance (light or dark).
class AppThemePalette {
  const AppThemePalette({
    required this.id,
    required this.name,
    required this.brightness,
    required this.primary,
    required this.primaryLight,
    required this.primaryWash,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.muted,
    required this.divider,
    required this.highlight,
  });

  final String id;
  final String name;
  final Brightness brightness;
  final Color primary;
  final Color primaryLight;
  final Color primaryWash;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color muted;
  final Color divider;
  final Color highlight;

  bool get isDark => brightness == Brightness.dark;
}

class AppThemes {
  AppThemes._();

  static const light = AppThemePalette(
    id: 'light',
    name: 'Light',
    brightness: Brightness.light,
    primary: Color(0xFF167C80),
    primaryLight: Color(0xFFCFE5E5),
    primaryWash: Color(0xFFE4EFF0),
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A1A),
    muted: Color(0xFF8E8E93),
    divider: Color(0xFFE5E5EA),
    highlight: Color(0xFF22B56E),
  );

  static const dark = AppThemePalette(
    id: 'dark',
    name: 'Dark',
    brightness: Brightness.dark,
    primary: Color(0xFF167C80),
    primaryLight: Color(0xFF1A3A3C),
    primaryWash: Color(0xFF122224),
    background: Color(0xFF0B1416),
    surface: Color(0xFF172426),
    onSurface: Color(0xFFF2F6F6),
    muted: Color(0xFF93A4A5),
    divider: Color(0xFF2C3E40),
    highlight: Color(0xFF3DDC8A),
  );

  static const ocean = light;

  static AppThemePalette forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }
}
