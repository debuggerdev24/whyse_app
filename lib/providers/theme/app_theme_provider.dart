import 'package:flutter/material.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/theme/app_theme_palette.dart';
import 'package:redstreakapp/core/utils/shared_pref.dart';

class AppThemeProvider extends ChangeNotifier {
  static const _storageKey = 'app_appearance';

  AppThemeProvider() {
    final stored = LocalStorageService.instance.prefs.getString(_storageKey);
    _palette = stored == 'light' ? AppThemes.light : AppThemes.dark;
    AppColors.apply(_palette);
  }

  late AppThemePalette _palette;

  AppThemePalette get palette => _palette;

  bool get isDark => _palette.isDark;

  Future<void> setBrightness(Brightness brightness) async {
    final next = AppThemes.forBrightness(brightness);
    if (_palette.id == next.id) return;
    _palette = next;
    AppColors.apply(next);
    notifyListeners();
    await LocalStorageService.instance.prefs.setString(_storageKey, next.id);
  }
}
