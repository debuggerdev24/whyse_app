import 'package:redstreakapp/core/utils/app_imports.dart';

class SettingsNotificationScreen extends StatelessWidget {
  const SettingsNotificationScreen({super.key});

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
          text: 'Notifications',
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
        padding: EdgeInsets.fromLTRB(25.r, 22.h, 25.r, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationSettingItem(
              title: 'Reminders',
              subtitle: 'Daily Practice Reminders',
              onTap: () =>
                  context.pushNamed(AppRoutes.remindersSettingsScreen.name),
            ),
            SizedBox(height: 18),
            _NotificationSettingItem(
              title: 'Friends',
              subtitle: 'Updates from your friends',
              onTap: () => context.pushNamed(
                AppRoutes.friendsNotificationSettingsScreen.name,
              ),
            ),
            SizedBox(height: 18),
            _NotificationSettingItem(
              title: 'Groups',
              subtitle: 'Updates from groups',
              onTap: () => context.pushNamed(
                AppRoutes.groupsNotificationSettingsScreen.name,
              ),
            ),
            SizedBox(height: 18),
            _NotificationSettingItem(title: 'Announcements', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _NotificationSettingItem extends StatelessWidget {
  const _NotificationSettingItem({
    required this.onTap,
    required this.title,
    this.subtitle,
  });
  final String title;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(text: title, style: AppTextStyles.bold(fontSize: 16)),
                if (subtitle != null) ...[
                  2.verticalSpace,
                  AppText(
                    text: subtitle!,
                    style: AppTextStyles.medium(
                      fontSize: 14,
                      color: AppColors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: subtitle == null ? 2.h : 8.h),
            child: Icon(Icons.arrow_forward_ios_rounded, size: 12.sp),
          ),
        ],
      ),
    );
  }
}
