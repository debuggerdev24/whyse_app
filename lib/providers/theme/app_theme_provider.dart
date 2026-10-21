import 'package:flutter/material.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/theme/app_theme_palette.dart';
import 'package:redstreakapp/core/utils/shared_pref.dart';

class AppThemeProvider extends ChangeNotifier {
  static const _storageKey = 'app_theme_id';

  AppThemeProvider() {
    final stored = LocalStorageService.instance.prefs.getString(_storageKey);
    _palette = AppThemes.byId(stored);
    AppColors.apply(_palette);
  }

  late AppThemePalette _palette;

  AppThemePalette get palette => _palette;

  Future<void> select(AppThemePalette palette) async {
    if (_palette.id == palette.id) return;
    _palette = palette;
    AppColors.apply(palette);
    notifyListeners();
    await LocalStorageService.instance.prefs.setString(_storageKey, palette.id);
  }
}
