import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redstreakapp/core/theme/app_theme_controller.dart';

class ReadingFontOption {
  final String name;
  final String fontFamily;
  /// True when [fontFamily] is not available on all platforms (e.g. Baskerville on Android).
  final bool useLibreBaskerville;
  const ReadingFontOption({
    required this.name,
    required this.fontFamily,
    this.useLibreBaskerville = false,
  });
}

class ReadingThemeOption {
  final String name;
  final Color background;
  final Color text;
  const ReadingThemeOption({
    required this.name,
    required this.background,
    required this.text,
  });
}

class ReadingAppearanceProvider extends ChangeNotifier {
  static const List<ReadingFontOption> fonts = [
    ReadingFontOption(name: 'SF Pro', fontFamily: 'SFProDisplay'),
    ReadingFontOption(name: 'Georgia', fontFamily: 'Georgia'),
    ReadingFontOption(
      name: 'Baskerville',
      fontFamily: 'Baskerville',
      useLibreBaskerville: true,
    ),
  ];

  /// Default follows the app theme. Sepia, Night, and Gray stay fixed
  /// so a reader can still pick a paper color on purpose.
  static List<ReadingThemeOption> get themes {
    final palette = AppThemeController.instance.palette;
    return [
      ReadingThemeOption(
        name: 'Default',
        background: palette.background,
        text: palette.textPrimary,
      ),
      const ReadingThemeOption(
        name: 'Sepia',
        background: Color(0xFFF5ECD7),
        text: Color(0xFF5C4A1E),
      ),
      const ReadingThemeOption(
        name: 'Night',
        background: Color(0xFF1C1C1E),
        text: Color(0xFFEEEEEE),
      ),
      const ReadingThemeOption(
        name: 'Gray',
        background: Color(0xFF3A3A3C),
        text: Color(0xFFE5E5EA),
      ),
    ];
  }

  /// Matches [Slider] range 0–1 with [divisions: 12] in the font bottom sheet.
  double _fontSizeNormalized = 0.45;
  int _selectedFontIndex = 0;
  int _selectedThemeIndex = 0;

  double get fontSizeNormalized => _fontSizeNormalized;
  int get selectedFontIndex => _selectedFontIndex;
  int get selectedThemeIndex => _selectedThemeIndex;

  ReadingFontOption get selectedFont => fonts[_selectedFontIndex];

  ReadingThemeOption get activeTheme => themes[_selectedThemeIndex];

  /// Body text size in logical pixels (before `.sp` in the reading screen).
  double get contentFontLogicalSize => 12 + (22 - 12) * _fontSizeNormalized;

  /// Story body style: Baskerville uses bundled Libre Baskerville so it works on Android too.
  TextStyle storyBodyTextStyle({
    required Color color,
    double height = 1.6,
  }) {
    final fontSize = contentFontLogicalSize.sp;
    final font = selectedFont;
    if (font.useLibreBaskerville) {
      return GoogleFonts.libreBaskerville(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        height: height,
        color: color,
      );
    }
    return TextStyle(
      fontFamily: font.fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
      height: height,
      color: color,
    );
  }

  void setFontSizeNormalized(double value) {
    final v = value.clamp(0.0, 1.0);
    if (v == _fontSizeNormalized) return;
    _fontSizeNormalized = v;
    notifyListeners();
  }

  void setSelectedFontIndex(int index) {
    if (index < 0 || index >= fonts.length) return;
    if (index == _selectedFontIndex) return;
    _selectedFontIndex = index;
    notifyListeners();
  }

  void setSelectedThemeIndex(int index) {
    if (index < 0 || index >= themes.length) return;
    if (index == _selectedThemeIndex) return;
    _selectedThemeIndex = index;
    notifyListeners();
  }
}
