import 'package:redstreakapp/core/theme/app_theme_palette.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/theme/app_theme_provider.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedId = context.watch<AppThemeProvider>().palette.id;

    return SettingsScaffold(
      title: 'Theme',
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          const SettingsSectionLabel('Appearance'),
          const SizedBox(height: 6),
          AppText(
            text: 'Ocean Teal',
            style: AppTextStyles.regular(fontSize: 14, color: settingsMuted),
          ),
          const SizedBox(height: 16),
          _ModeOption(
            palette: AppThemes.light,
            selected: selectedId == AppThemes.light.id,
            onTap: () => context
                .read<AppThemeProvider>()
                .setBrightness(Brightness.light),
          ),
          const SizedBox(height: 12),
          _ModeOption(
            palette: AppThemes.dark,
            selected: selectedId == AppThemes.dark.id,
            onTap: () => context
                .read<AppThemeProvider>()
                .setBrightness(Brightness.dark),
          ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final AppThemePalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? palette.primary : palette.divider,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            _ModePreview(palette: palette),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: palette.name,
                    style: AppTextStyles.bold(
                      fontSize: 17,
                      color: palette.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    text: 'Ocean Teal',
                    style: AppTextStyles.regular(
                      fontSize: 14,
                      color: palette.muted,
                    ),
                  ),
                ],
              ),
            ),
            _SelectMark(selected: selected, color: palette.primary),
          ],
        ),
      ),
    );
  }
}

class _ModePreview extends StatelessWidget {
  const _ModePreview({required this.palette});

  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 6,
            decoration: BoxDecoration(
              color: palette.primary,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const Spacer(),
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: palette.onSurface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 24,
            height: 5,
            decoration: BoxDecoration(
              color: palette.muted,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectMark extends StatelessWidget {
  const _SelectMark({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? color : Colors.transparent,
        border: Border.all(
          color: selected ? color : const Color(0xFFD1D1D6),
          width: 1.6,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}
