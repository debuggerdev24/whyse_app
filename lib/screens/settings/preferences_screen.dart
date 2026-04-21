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
        body: Padding(
          padding: EdgeInsets.fromLTRB(25.r, 20.h, 25.r, 0),
          child: Column(
            children: [
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
