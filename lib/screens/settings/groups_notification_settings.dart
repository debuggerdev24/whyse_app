import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/settings/widget/text_with_switch.dart';

class GroupsNotificationSettingsScreen extends StatefulWidget {
  const GroupsNotificationSettingsScreen({super.key});

  @override
  State<GroupsNotificationSettingsScreen> createState() => _GroupState();
}

class _GroupState extends State<GroupsNotificationSettingsScreen> {
  bool _topicShared = true;
  bool _joiningGroup = false;

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
            text: 'Groups',
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
                title: 'Topics Shared',
                value: _topicShared,
                onChanged: (value) {
                  setState(() {
                    _topicShared = value;
                  });
                },
              ),
              22.verticalSpace,
              TextWithSwitch(
                title: 'Joining Group',
                value: _joiningGroup,
                onChanged: (value) {
                  setState(() {
                    _joiningGroup = value;
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
