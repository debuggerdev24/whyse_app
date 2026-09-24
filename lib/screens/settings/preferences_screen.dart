import 'package:redstreakapp/core/theme/app_theme_controller.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/settings/widget/text_with_switch.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _soundEffectsEnabled = true;
  bool _hapticFeedbackEnabled = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 25),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.pop(),
                child: SvgIcon(AppAssets.backButton, size: 13.sp),
              ),
            ),
          ),
          centerTitle: true,
          title: AppText(
            text: 'Preferences',
            style: AppTextStyles.semibold(fontSize: 20),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.h),
            child: Container(
              color: AppColors.black.withValues(alpha: 0.1),
              height: 1,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(25.r, 20.h, 25.r, 24.h),
          child: Column(
            children: [
              const _AppearanceSection(),
              22.verticalSpace,
              TextWithSwitch(
                title: 'Sound Effects',
                value: _soundEffectsEnabled,
                onChanged: (value) {
                  setState(() {
                    _soundEffectsEnabled = value;
                  });
                },
              ),
              22.verticalSpace,
              TextWithSwitch(
                title: 'Haptic Feedback',
                value: _hapticFeedbackEnabled,
                onChanged: (value) {
                  setState(() {
                    _hapticFeedbackEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<AppThemeController>().choice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Appearance',
          style: AppTextStyles.bold(fontSize: 16),
        ),
        8.verticalSpace,
        for (final choice in AppThemeChoice.values)
          _ThemeOption(
            choice: choice,
            selected: selected == choice,
          ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.choice,
    required this.selected,
  });

  final AppThemeChoice choice;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.read<AppThemeController>().setThemeChoice(choice),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            choice == AppThemeChoice.system
                ? Container(
                    width: 28.w,
                    height: 28.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(
                      Icons.phone_iphone_rounded,
                      size: 16.sp,
                      color: AppColors.black,
                    ),
                  )
                : Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: choice.previewPalette.background,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: choice.previewPalette.primary,
                        width: 3,
                      ),
                    ),
                  ),
            12.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: choice.label,
                    style: AppTextStyles.semibold(
                      fontSize: 16,
                      color: selected ? AppColors.teal : AppColors.black,
                    ),
                  ),
                  AppText(
                    text: choice.subtitle,
                    style: AppTextStyles.medium(
                      fontSize: 12.sp,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, color: AppColors.teal, size: 22.sp),
          ],
        ),
      ),
    );
  }
}
