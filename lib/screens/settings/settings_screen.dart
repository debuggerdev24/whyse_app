import 'package:redstreakapp/core/utils/app_imports.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            text: 'Settings',
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
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(left: 25.r, right: 25.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: 'Account',
                        style: AppTextStyles.semibold(
                          fontSize: 14,
                          color: AppColors.black.withValues(alpha: 0.6),
                        ),
                      ),
                      25.verticalSpace,
                      _settingsItem(
                        title: 'Preferences',
                        onTap: () =>
                            context.pushNamed(AppRoutes.preferencesScreen.name),
                      ),
                      25.verticalSpace,
                      _settingsItem(
                        title: 'Profile',
                        onTap: () =>
                            context.pushNamed(AppRoutes.editProfileScreen.name),
                      ),
                      25.verticalSpace,
                      _settingsItem(
                        title: 'Notifications',
                        onTap: () => context.pushNamed(
                          AppRoutes.settingsNotificationScreen.name,
                        ),
                      ),
                      25.verticalSpace,
                      _settingsItem(title: 'Curriculum', onTap: () {}),
                      25.verticalSpace,
                      Container(
                        color: AppColors.black.withValues(alpha: 0.1),
                        height: 1,
                        width: double.infinity,
                      ),
                      25.verticalSpace,
                      AppText(
                        text: 'Support',
                        style: AppTextStyles.semibold(
                          fontSize: 14,
                          color: AppColors.black.withValues(alpha: 0.6),
                        ),
                      ),
                      25.verticalSpace,
                      _settingsItem(title: 'Help Center', onTap: () {}),
                      25.verticalSpace,
                      _settingsItem(title: 'Feedback', onTap: () {}),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12, left: 25.r, right: 25.r),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: AppText(
                        text: 'Sign out',
                        style: AppTextStyles.bold(
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsItem({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(text: title, style: AppTextStyles.bold(fontSize: 16)),
          Icon(Icons.arrow_forward_ios_rounded, size: 12.sp),
        ],
      ),
    );
  }
}
