import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/settings/widget/text_with_switch.dart';

class RemindersSettingsScreen extends StatefulWidget {
  const RemindersSettingsScreen({super.key});

  @override
  State<RemindersSettingsScreen> createState() =>
      _RemindersSettingsScreenState();
}

class _RemindersSettingsScreenState extends State<RemindersSettingsScreen> {
  bool _practiceReminder = true;
  bool _weeklyProgress = false;

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
            text: 'Reminders',
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
          padding: EdgeInsets.symmetric(horizontal: 27.r),
          child: Column(
            children: [
              30.verticalSpace,
              TextWithSwitch(
                title: 'Practice Reminder',
                value: _practiceReminder,
                onChanged: (value) {
                  setState(() {
                    _practiceReminder = value;
                  });
                },
              ),
              22.verticalSpace,
              TextWithSwitch(
                title: 'Weekly Progress',
                value: _weeklyProgress,
                onChanged: (value) {
                  setState(() {
                    _weeklyProgress = value;
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
