import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// SF Pro family names.
///
/// Apple does not allow these font files inside an iOS app. On iPhone the
/// system SF Pro Display is used, which is the same face the bundled files
/// came from. Android still uses the files registered in pubspec.yaml.
class AppFonts {
  AppFonts._();

  static const String sfProDisplayAsset = 'SFProDisplay';
  static const String sfProDisplaySystem = '.SF Pro Display';

  static bool get _useSystemSfPro {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      default:
        return false;
    }
  }

  static String get sfProDisplay =>
      _useSystemSfPro ? sfProDisplaySystem : sfProDisplayAsset;

  /// Weight 600 is wired to the Semibold Italic file in pubspec.yaml.
  /// The system font is upright at that weight, so iPhone keeps italic.
  static FontStyle? legacyItalic(FontWeight weight) {
    if (!_useSystemSfPro || weight != FontWeight.w600) return null;
    return FontStyle.italic;
  }
}
