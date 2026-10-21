import 'package:flutter/material.dart';

/// A light color set for the whole app.
class AppThemePalette {
  const AppThemePalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.primaryLight,
    required this.primaryWash,
    required this.background,
    required this.highlight,
    required this.heroStart,
    required this.heroEnd,
    required this.swatches,
  });

  final String id;
  final String name;
  final Color primary;
  final Color primaryLight;
  final Color primaryWash;
  final Color background;
  final Color highlight;
  final Color heroStart;
  final Color heroEnd;
  final List<Color> swatches;
}

class AppThemes {
  AppThemes._();

  static const ocean = AppThemePalette(
    id: 'ocean',
    name: 'Ocean Teal',
    primary: Color(0xFF167C80),
    primaryLight: Color(0xFFCFE5E5),
    primaryWash: Color(0xFFE4EFF0),
    background: Color(0xFFFAFAFA),
    highlight: Color(0xFF22B56E),
    heroStart: Color(0xFF2F6FE0),
    heroEnd: Color(0xFF8EC8F5),
    swatches: [
      Color(0xFF1C1C1E),
      Color(0xFF167C80),
      Color(0xFFF2C14E),
      Color(0xFFF07167),
    ],
  );

  static const blossom = AppThemePalette(
    id: 'blossom',
    name: 'Blossom',
    primary: Color(0xFFD23B6A),
    primaryLight: Color(0xFFF8D0DE),
    primaryWash: Color(0xFFFDECF2),
    background: Color(0xFFFFE4EF),
    highlight: Color(0xFFE14B7A),
    heroStart: Color(0xFFFF6F9A),
    heroEnd: Color(0xFFFFD0E2),
    swatches: [
      Color(0xFF3A2230),
      Color(0xFFD23B6A),
      Color(0xFFFFB703),
      Color(0xFF7C5CBF),
    ],
  );

  static const meadow = AppThemePalette(
    id: 'meadow',
    name: 'Meadow',
    primary: Color(0xFF1F8A4C),
    primaryLight: Color(0xFFD3F0DE),
    primaryWash: Color(0xFFE8F8EE),
    background: Color(0xFFDFF6E8),
    highlight: Color(0xFF178A4A),
    heroStart: Color(0xFF2E9B57),
    heroEnd: Color(0xFFB7E4C7),
    swatches: [
      Color(0xFF163024),
      Color(0xFF1F8A4C),
      Color(0xFFF4A261),
      Color(0xFF2A9D8F),
    ],
  );

  static const iris = AppThemePalette(
    id: 'iris',
    name: 'Iris',
    primary: Color(0xFF5B4DDB),
    primaryLight: Color(0xFFDED9FB),
    primaryWash: Color(0xFFF3F1FF),
    background: Color(0xFFE7E2FB),
    highlight: Color(0xFF6C5CE7),
    heroStart: Color(0xFF7464F0),
    heroEnd: Color(0xFFD6CFFF),
    swatches: [
      Color(0xFF241C45),
      Color(0xFF5B4DDB),
      Color(0xFFFFB020),
      Color(0xFFFF7A59),
    ],
  );

  static const honey = AppThemePalette(
    id: 'honey',
    name: 'Honey',
    primary: Color(0xFFC47D0E),
    primaryLight: Color(0xFFF8E4C0),
    primaryWash: Color(0xFFFFF6E8),
    background: Color(0xFFFFF0D4),
    highlight: Color(0xFFD4880F),
    heroStart: Color(0xFFF0A820),
    heroEnd: Color(0xFFFFE4B0),
    swatches: [
      Color(0xFF3A2A12),
      Color(0xFFC47D0E),
      Color(0xFF2A9D8F),
      Color(0xFFE76F51),
    ],
  );

  static const all = <AppThemePalette>[ocean, blossom, meadow, iris, honey];

  static AppThemePalette byId(String? id) {
    for (final theme in all) {
      if (theme.id == id) return theme;
    }
    return ocean;
  }
}
