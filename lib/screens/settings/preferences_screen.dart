import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_switch_button.dart';

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
    return Scaffold(
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
            _PreferenceToggleItem(
              title: 'Sound Effects',
              value: _soundEffectsEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEffectsEnabled = value;
                });
              },
            ),
            22.verticalSpace,
            _PreferenceToggleItem(
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
    );
  }
}

class _PreferenceToggleItem extends StatelessWidget {
  const _PreferenceToggleItem({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppText(text: title, style: AppTextStyles.bold(fontSize: 16)),
        ),
        AppSwitchButton(
          trackHeight: 12,
          trackWidth: 28,
          thumbDiameter: 22,
          value: value,
          onChanged: onChanged,
        ),
        // CupertinoSwitch(
        //   value: value,
        //   onChanged: onChanged,
        //   activeTrackColor: AppColors.primaryColor,
        //   inactiveTrackColor: const Color(0xFFF1F1F1),
        //   thumbColor: value ? AppColors.black : const Color(0xFFD0D0D0),
        // ),
      ],
    );
  }
}
