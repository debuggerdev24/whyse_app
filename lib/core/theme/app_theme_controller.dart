import 'package:flutter/material.dart';
import 'package:redstreakapp/core/theme/app_palette.dart';
import 'package:redstreakapp/core/utils/shared_pref.dart';

/// Saved appearance. Light, Dark, and Match device stay as they were.
/// Sunny and Ocean are day themes. Berry and Adventure are night themes.
enum AppThemeChoice {
  light('Light', 'Calm cream'),
  dark('Dark', 'Aurora night'),
  system('Match device', 'Follows your phone'),
  sunny('Sunny', 'Coral accent'),
  ocean('Ocean', 'Sea accent'),
  berry('Berry', 'Plum night'),
  adventure('Adventure', 'Forest night');

  const AppThemeChoice(this.label, this.subtitle);

  final String label;
  final String subtitle;

  /// Color used for the swatch in Preferences. Match device shows light.
  AppPalette get previewPalette {
    switch (this) {
      case AppThemeChoice.light:
      case AppThemeChoice.system:
        return AppPalette.light;
      case AppThemeChoice.dark:
        return AppPalette.dark;
      case AppThemeChoice.sunny:
        return AppPalette.sunny;
      case AppThemeChoice.ocean:
        return AppPalette.ocean;
      case AppThemeChoice.berry:
        return AppPalette.berry;
      case AppThemeChoice.adventure:
        return AppPalette.adventure;
    }
  }
}

/// Remembers the appearance choice and exposes the active [AppPalette].
///
/// Widgets keep using [AppColors]. This controller only decides which
/// palette those colors resolve to, and rebuilds the tree when it changes.
class AppThemeController extends ChangeNotifier {
  AppThemeController._();

  static final AppThemeController instance = AppThemeController._();

  AppThemeChoice _choice = AppThemeChoice.light;

  AppThemeChoice get choice => _choice;

  /// Flutter only has light, dark, and system. Berry and Adventure use dark.
  ThemeMode get themeMode {
    switch (_choice) {
      case AppThemeChoice.dark:
      case AppThemeChoice.berry:
      case AppThemeChoice.adventure:
        return ThemeMode.dark;
      case AppThemeChoice.system:
        return ThemeMode.system;
      case AppThemeChoice.light:
      case AppThemeChoice.sunny:
      case AppThemeChoice.ocean:
        return ThemeMode.light;
    }
  }

  AppPalette get palette {
    switch (_choice) {
      case AppThemeChoice.dark:
        return AppPalette.dark;
      case AppThemeChoice.light:
        return AppPalette.light;
      case AppThemeChoice.sunny:
        return AppPalette.sunny;
      case AppThemeChoice.ocean:
        return AppPalette.ocean;
      case AppThemeChoice.berry:
        return AppPalette.berry;
      case AppThemeChoice.adventure:
        return AppPalette.adventure;
      case AppThemeChoice.system:
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark
            ? AppPalette.dark
            : AppPalette.light;
    }
  }

  void load() {
    _choice = _decode(LocalStorageService.instance.themeModeName);
  }

  Future<void> setThemeChoice(AppThemeChoice choice) async {
    if (_choice == choice) return;
    _choice = choice;
    notifyListeners();
    await LocalStorageService.instance.saveThemeMode(choice.name);
  }

  /// Called when the phone appearance changes and the choice is Match device.
  void refreshSystemBrightness() {
    if (_choice == AppThemeChoice.system) {
      notifyListeners();
    }
  }

  AppThemeChoice _decode(String? value) {
    for (final choice in AppThemeChoice.values) {
      if (choice.name == value) return choice;
    }
    return AppThemeChoice.light;
  }
}
