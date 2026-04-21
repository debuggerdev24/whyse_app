import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/settings/widget/text_with_switch.dart';

class FriendsNotificationSettingsScreen extends StatefulWidget {
  const FriendsNotificationSettingsScreen({super.key});

  @override
  State<FriendsNotificationSettingsScreen> createState() =>
      _FriendsNotificationSettingsScreenState();
}

class _FriendsNotificationSettingsScreenState
    extends State<FriendsNotificationSettingsScreen> {
  bool _friendActivity = true;
  bool _friendRequest = false;

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
            text: 'Friends',
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
                title: 'Friend Activity',
                value: _friendActivity,
                onChanged: (value) {
                  setState(() {
                    _friendActivity = value;
                  });
                },
              ),
              22.verticalSpace,
              TextWithSwitch(
                title: 'Friend Request',
                value: _friendRequest,
                onChanged: (value) {
                  setState(() {
                    _friendRequest = value;
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
