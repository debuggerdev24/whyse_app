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
      title: 'Themes',
      body: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        itemCount: AppThemes.all.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          mainAxisExtent: 292,
        ),
        itemBuilder: (context, index) {
          final theme = AppThemes.all[index];
          return _ThemeCard(
            theme: theme,
            selected: theme.id == selectedId,
            onTap: () => context.read<AppThemeProvider>().select(theme),
          );
        },
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final AppThemePalette theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _MiniStatusBar(),
            const SizedBox(height: 8),
            _MiniHeader(highlight: theme.highlight),
            const SizedBox(height: 8),
            const _SparksLabel(),
            const SizedBox(height: 6),
            Expanded(child: _HeroArt(theme: theme)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppText(
                    text: theme.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(
                      fontSize: 15,
                      color: settingsInk,
                    ),
                  ),
                ),
                _SelectMark(selected: selected, color: theme.primary),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < theme.swatches.length; i++) ...[
                  if (i > 0) const SizedBox(width: 5),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: theme.swatches[i],
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatusBar extends StatelessWidget {
  const _MiniStatusBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '9:41',
          style: AppTextStyles.semibold(fontSize: 9, color: settingsInk),
        ),
        const Spacer(),
        Container(
          width: 36,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const Spacer(),
        const Icon(Icons.signal_cellular_alt, size: 10, color: settingsInk),
        const SizedBox(width: 2),
        const Icon(Icons.wifi, size: 10, color: settingsInk),
        const SizedBox(width: 2),
        const Icon(Icons.battery_full, size: 11, color: settingsInk),
      ],
    );
  }
}

class _MiniHeader extends StatelessWidget {
  const _MiniHeader({required this.highlight});

  final Color highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            AppAssets.profile,
            width: 22,
            height: 22,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Hey, ',
                      style: AppTextStyles.bold(fontSize: 11, color: settingsInk),
                    ),
                    TextSpan(
                      text: 'Alex!',
                      style: AppTextStyles.bold(fontSize: 11, color: highlight),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Ready for a new adventure?',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.medium(
                  fontSize: 8,
                  color: const Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
        const _MiniIcon(
          icon: Icons.local_fire_department_rounded,
          color: Color(0xFFFF8A00),
        ),
        const SizedBox(width: 4),
        const _MiniIcon(
          icon: Icons.notifications_none_rounded,
          color: Color(0xFF8E8E93),
        ),
      ],
    );
  }
}

class _MiniIcon extends StatelessWidget {
  const _MiniIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F4),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }
}

class _SparksLabel extends StatelessWidget {
  const _SparksLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Today's Sparks",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bold(fontSize: 11, color: settingsInk),
          ),
        ),
        const Icon(Icons.bookmark_border_rounded, size: 13, color: settingsInk),
      ],
    );
  }
}

class _HeroArt extends StatelessWidget {
  const _HeroArt({required this.theme});

  final AppThemePalette theme;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.heroStart, theme.heroEnd],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 18,
              top: 10,
              child: Container(
                width: 36,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 6,
              child: Container(
                width: 28,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Science',
                    style: AppTextStyles.medium(
                      fontSize: 9,
                      color: settingsInk,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
        color: selected ? color : Colors.white,
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
