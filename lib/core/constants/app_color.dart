import 'package:flutter/material.dart';
import 'package:redstreakapp/core/theme/app_theme_palette.dart';

class AppColors {
  AppColors._();

  static AppThemePalette _active = AppThemes.ocean;

  static void apply(AppThemePalette palette) {
    _active = palette;
  }

  // Login screen colors. Primary tones follow the selected light theme.
  static Color get teal => _active.primary;
  static Color get highlight => _active.highlight;
  static Color get lighttealcolor => _active.primaryLight;
  static Color get extealighttealcolor => _active.primaryWash;
  static Color get backgroundColor => _active.background;

  static const Color darkGrey = Color(0xFF4A4A4A);
  static const Color black = Color(0xFF1A1A1A);
  static const Color lightblackColor = Color(0xFF1E1E1E);

  static const Color white = Color(0xFFFFFFFF);
  static const Color searchBackgroundColor = Color(0xFFF1F1F1);

  static const Color orangeColor = Color(0xFFF28518);
  static const Color streakFreezeBlue = Color(0xFF2B9FD9);
  static const Color streakFreezeBlueLight = Color(0xFFE3F4FF);
  static const Color lightyellowcolor = Color(0xFFF2ECE6);
  static const Color bluecolor = Color(0xFF011E41);

  static const Color lightwhiteColor = Color(0xFFF0F0F0);
  static const Color greenColor = Color(0xFF1EA437);
  static const Color darkgreenColor = Color(0xFF0CBA65);

  static const Color redColor = Color(0xFFE52222);
  static const Color indicatorColor = Color(0xff030C09);

  static const Color shimmerBaseColor = Color.fromARGB(255, 207, 209, 213);
  static const Color shimmerHighlightColor = Color(0xFFFBFCFF);
}
