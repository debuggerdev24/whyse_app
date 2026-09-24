import 'package:flutter/material.dart';

/// Single place to change the app look.
///
/// The client is trying themes often. Edit the hex values in [light] and
/// [dark] only. The rest of the app reads these through [AppColors] and
/// [AppThemes], so a change here shows up everywhere.
///
/// Brand tokens match the shared Whyse boards for light and dark.
/// Sunny and Ocean keep the white and beige pages. Only their accents differ.
/// Berry and Adventure are night themes.
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.cardSurface,
    required this.subSurface,
    required this.primary,
    required this.secondary,
    required this.reward,
    required this.textPrimary,
    required this.textSecondary,
    required this.onPrimary,
    required this.onImage,
    required this.navBar,
    required this.border,
    required this.warmSurface,
    required this.mutedSurface,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  final Brightness brightness;

  /// Page background. Light `#F7F4EC`, dark `#0F1A20`.
  final Color background;

  /// Cards, sheets, and chips. Light `#FFFFFF`, dark `#0C2C32`.
  final Color cardSurface;

  /// Soft fills behind search bars and secondary blocks.
  /// Light `#E4F7F0`, dark `#223E41`.
  final Color subSurface;

  /// Primary accent. Light `#22B8A6`, dark `#22B8A3`.
  final Color primary;

  /// Secondary accent. Light `#86D7D1`, dark `#86D7D0`.
  final Color secondary;

  /// Reward / streak orange. Both themes `#F5A523`.
  final Color reward;

  final Color textPrimary;
  final Color textSecondary;

  /// Label on primary buttons. Stays light in both themes.
  final Color onPrimary;

  /// Text and icons that sit on photos. Stays light in both themes.
  final Color onImage;

  final Color navBar;
  final Color border;
  final Color warmSurface;
  final Color mutedSurface;
  final Color shimmerBase;
  final Color shimmerHighlight;

  bool get isDark => brightness == Brightness.dark;

  static const light = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF7F4EC),
    cardSurface: Color(0xFFFFFFFF),
    subSurface: Color(0xFFE4F7F0),
    primary: Color(0xFF22B8A6),
    secondary: Color(0xFF86D7D1),
    reward: Color(0xFFF5A523),
    textPrimary: Color(0xFF142428),
    textSecondary: Color(0xFF5E716E),
    onPrimary: Color(0xFFFFFFFF),
    onImage: Color(0xFFFFFFFF),
    navBar: Color(0xFFFFFFFF),
    border: Color(0xFFE4DDD2),
    warmSurface: Color(0xFFF3EBDD),
    mutedSurface: Color(0xFFEFEAE0),
    shimmerBase: Color(0xFFE4DDD0),
    shimmerHighlight: Color(0xFFFBF8F1),
  );

  static const dark = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF0F1A20),
    cardSurface: Color(0xFF0C2C32),
    subSurface: Color(0xFF223E41),
    primary: Color(0xFF22B8A3),
    secondary: Color(0xFF86D7D0),
    reward: Color(0xFFF5A523),
    textPrimary: Color(0xFFF4F8F7),
    textSecondary: Color(0xFFA8BEBA),
    onPrimary: Color(0xFFFFFFFF),
    onImage: Color(0xFFFFFFFF),
    navBar: Color(0xFF0F1A20),
    border: Color(0xFF2A4548),
    warmSurface: Color(0xFF24342C),
    mutedSurface: Color(0xFF1A3338),
    shimmerBase: Color(0xFF1A3036),
    shimmerHighlight: Color(0xFF2C4A50),
  );

  /// Beige and white pages, coral accent. Not a yellow wash.
  static const sunny = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF7F4EC),
    cardSurface: Color(0xFFFFFFFF),
    subSurface: Color(0xFFF8EBE4),
    primary: Color(0xFFE15A3A),
    secondary: Color(0xFFF0B7A4),
    reward: Color(0xFFE0922A),
    textPrimary: Color(0xFF2A211C),
    textSecondary: Color(0xFF7A655C),
    onPrimary: Color(0xFFFFFFFF),
    onImage: Color(0xFFFFFFFF),
    navBar: Color(0xFFFFFFFF),
    border: Color(0xFFE6D9CE),
    warmSurface: Color(0xFFF6E6D8),
    mutedSurface: Color(0xFFF3EBE3),
    shimmerBase: Color(0xFFE8DDD2),
    shimmerHighlight: Color(0xFFFBF8F3),
  );

  /// Beige and white pages, deep sea accent. The blue stays on buttons and links.
  static const ocean = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF6F4EF),
    cardSurface: Color(0xFFFFFFFF),
    subSurface: Color(0xFFE8EEF0),
    primary: Color(0xFF1F5F8A),
    secondary: Color(0xFF8AAABB),
    reward: Color(0xFFD4A24C),
    textPrimary: Color(0xFF1C2428),
    textSecondary: Color(0xFF5E6E76),
    onPrimary: Color(0xFFFFFFFF),
    onImage: Color(0xFFFFFFFF),
    navBar: Color(0xFFFFFFFF),
    border: Color(0xFFD9E0E2),
    warmSurface: Color(0xFFF3EBDD),
    mutedSurface: Color(0xFFEFEDE8),
    shimmerBase: Color(0xFFE2E0DA),
    shimmerHighlight: Color(0xFFFBF9F5),
  );

  /// Night theme. Plum page, purple cards, hot-pink buttons, pale pink text.
  static const berry = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF140814),
    cardSurface: Color(0xFF3D1748),
    subSurface: Color(0xFF5A2268),
    primary: Color(0xFFE0126A),
    secondary: Color(0xFFFF7AAB),
    reward: Color(0xFFFFE14A),
    textPrimary: Color(0xFFFFE6F2),
    textSecondary: Color(0xFFE7B4D0),
    onPrimary: Color(0xFFFFFFFF),
    onImage: Color(0xFFFFFFFF),
    navBar: Color(0xFF140814),
    border: Color(0xFF6E3478),
    warmSurface: Color(0xFF4A1830),
    mutedSurface: Color(0xFF2A102F),
    shimmerBase: Color(0xFF2A1028),
    shimmerHighlight: Color(0xFF4A2048),
  );

  /// Night theme. Pine page, moss cards, lime buttons with dark labels.
  static const adventure = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF06110A),
    cardSurface: Color(0xFF163322),
    subSurface: Color(0xFF1E4A30),
    primary: Color(0xFFC8F542),
    secondary: Color(0xFF7DDE6A),
    reward: Color(0xFFFF8A1F),
    textPrimary: Color(0xFFE7FFE4),
    textSecondary: Color(0xFFA8D4B0),
    onPrimary: Color(0xFF102408),
    onImage: Color(0xFFFFFFFF),
    navBar: Color(0xFF06110A),
    border: Color(0xFF2A5A38),
    warmSurface: Color(0xFF243818),
    mutedSurface: Color(0xFF102818),
    shimmerBase: Color(0xFF12281A),
    shimmerHighlight: Color(0xFF234832),
  );
}
