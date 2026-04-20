import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/notification/widgets/notification_widgets.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final newItems = [
      const NotificationItemData(
        name: 'Emma Rodriguez',
        message: 'sent you a friend request',
        avatarEmoji: '👩🏽',
      ),
      const NotificationItemData(
        name: 'Liam Kumar',
        message: 'sent you a friend request',
        avatarEmoji: '👨🏽',
      ),
    ];

    final yesterdayItems = [
      const NotificationItemData(
        name: 'Sofia Mendes',
        message: 'sent you a friend request',
        avatarEmoji: '👨🏻',
      ),
      const NotificationItemData(
        name: 'Noah Patel',
        message: 'sent you a friend request',
        avatarEmoji: '👨🏾',
      ),
      const NotificationItemData(
        name: 'Gp1e',
        message: 'eva_thompson added you to the group',
        avatarEmoji: '👩🏾',
      ),
    ];

    return AppLayout(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: SvgIcon(AppAssets.backButton, size: 12.w),
                  ),
                  Expanded(
                    child: Center(
                      child: AppText(
                        text: 'Notifications',
                        style: AppTextStyles.bold(fontSize: 20.sp),
                      ),
                    ),
                  ),
                  20.w.horizontalSpace,
                ],
              ),
            ),
            Divider(
              height: 1.w,
              color: AppColors.black.withValues(alpha: 0.08),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NotificationSection(title: 'New', items: newItems),
                    19.w.verticalSpace,
                    Divider(
                      height: 1.w,
                      color: AppColors.black.withValues(alpha: 0.08),
                    ),
                    19.w.verticalSpace,
                    NotificationSection(
                      title: 'Yesterday',
                      items: yesterdayItems,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
