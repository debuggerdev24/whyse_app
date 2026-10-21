import 'package:redstreakapp/core/utils/app_imports.dart';

Color get settingsPageColor => AppColors.backgroundColor;
const Color settingsInk = Color(0xFF1C1C1E);
const Color settingsMuted = Color(0xFF8E8E93);
const Color settingsLine = Color(0xFFE5E5EA);
const Color settingsSignOut = Color(0xFFFF5C4D);
const Color settingsSwitchOn = Color(0xFFFF9F0A);

class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottom,
    this.trailing,
  });

  final String title;
  final Widget body;
  final Widget? bottom;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.pop();
      },
      child: Scaffold(
        backgroundColor: settingsPageColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, top + 6, 16, 4),
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GlassIconButton(
                        size: 44,
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          size: 28,
                          color: settingsInk,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 56),
                      child: AppText(
                        text: title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bold(
                          fontSize: 18,
                          color: settingsInk,
                        ),
                      ),
                    ),
                    if (trailing != null)
                      Align(alignment: Alignment.centerRight, child: trailing!),
                  ],
                ),
              ),
            ),
            Expanded(child: body),
            ?bottom,
          ],
        ),
      ),
    );
  }
}

class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: text,
      style: AppTextStyles.regular(fontSize: 15, color: settingsMuted),
    );
  }
}

class SettingsNavRow extends StatelessWidget {
  const SettingsNavRow({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: title,
                    style: AppTextStyles.bold(fontSize: 17, color: settingsInk),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    AppText(
                      text: subtitle!,
                      style: AppTextStyles.regular(
                        fontSize: 14,
                        color: settingsMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 22, color: settingsInk),
          ],
        ),
      ),
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: settingsLine,
      child: SizedBox(height: 1, width: double.infinity),
    );
  }
}
