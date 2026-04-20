import 'package:redstreakapp/core/utils/app_imports.dart';

/// Tan header for profile (static placeholders until API).
const Color _profileHeaderBg = Color(0xFFE8D9C4);

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _profileHeaderBg,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 2.w, 14.w, 12.w),
        child: Column(
          children: [
            SafeArea(
              child: SizedBox(
                // height: 44.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _CircleOutlineIconButton(
                        onTap: () {
                          if (context.canPop()) context.pop();
                        },
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 20.sp,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    AppText(
                      text: 'Your Profile',
                      style: AppTextStyles.bold(
                        fontSize: 18,
                        color: AppColors.black,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CircleOutlineIconButton(
                            onTap: () {},
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 20.sp,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _CircleOutlineIconButton(
                            onTap: () {
                              context.pushNamed(AppRoutes.settingsScreen.name);
                            },

                            child: Icon(
                              Icons.settings_outlined,
                              size: 20.sp,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            8.w.verticalSpace,
            SizedBox(
              height: 140.w,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 72.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppText(
                          text: '#12',
                          style: AppTextStyles.bold(
                            fontSize: 28,
                            color: AppColors.black,
                          ),
                        ),
                        // 4.w.verticalSpace,
                        AppText(
                          text: 'Your Rank',
                          style: AppTextStyles.medium(
                            fontSize: 13,
                            color: AppColors.black.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white.withValues(alpha: 0.85),
                          border: Border.all(
                            color: AppColors.black.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.person_rounded,
                          size: 64.sp,
                          color: AppColors.black.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 72.w,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: _CircleOutlineIconButton(
                          onTap: () {},
                          child: SvgIcon(
                            AppAssets.shareIcon,
                            size: 18.w,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleOutlineIconButton extends StatelessWidget {
  const _CircleOutlineIconButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.black.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
