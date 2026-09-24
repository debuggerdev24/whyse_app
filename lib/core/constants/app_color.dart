import 'package:flutter/material.dart';
import 'package:redstreakapp/core/theme/app_palette.dart';
import 'package:redstreakapp/core/theme/app_theme_controller.dart';

/// Colors used across the app.
///
/// Do not put new hex values here. Edit the palettes in
/// `lib/core/theme/app_palette.dart`. These names stay so existing screens
/// pick up the active theme without a rewrite.
///
/// [white] is the card surface (white in light mode, deep teal in dark mode).
/// [black] is body text. Text that must stay light on a photo uses [onImage].
/// Text on a teal button uses [onPrimary].
class AppColors {
  AppColors._();

  static AppPalette get palette => AppThemeController.instance.palette;

  static Color get teal => palette.primary;
  static Color get darkGrey => palette.textSecondary;
  static Color get black => palette.textPrimary;
  static Color get lightblackColor => palette.textPrimary;

  static Color get white => palette.cardSurface;
  static Color get backgroundColor => palette.background;
  static Color get searchBackgroundColor => palette.subSurface;

  static Color get orangeColor => palette.reward;
  static const Color streakFreezeBlue = Color(0xFF2B9FD9);
  static const Color streakFreezeBlueLight = Color(0xFFE3F4FF);
  static Color get lightyellowcolor => palette.warmSurface;
  static const Color bluecolor = Color(0xFF011E41);

  static Color get lightwhiteColor => palette.mutedSurface;
  static const Color greenColor = Color(0xFF1EA437);
  static const Color darkgreenColor = Color(0xFF0CBA65);

  static Color get lighttealcolor => palette.secondary;
  static Color get extealighttealcolor => palette.subSurface;
  static const Color redColor = Color(0xFFE52222);
  static Color get indicatorColor => palette.textPrimary;

  static Color get shimmerBaseColor => palette.shimmerBase;
  static Color get shimmerHighlightColor => palette.shimmerHighlight;

  static Color get onPrimary => palette.onPrimary;
  static Color get onImage => palette.onImage;
  static Color get navBar => palette.navBar;
  static Color get border => palette.border;
}
