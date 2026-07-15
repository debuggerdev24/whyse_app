import 'package:redstreakapp/core/utils/app_imports.dart';

class StreakCoutnerWidget extends StatelessWidget {
  const StreakCoutnerWidget({
    super.key,
    this.streakCount = 1,
    this.longestStreak,
  });

  final int streakCount;
  final int? longestStreak;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: '$streakCount',
                  style: AppTextStyles.semiBold(
                    fontSize: 48.sp,
                    color: AppColors.black,
                  ),
                ),
                4.h.verticalSpace,
                AppText(
                  text: streakCount == 1 ? 'Day Streak!' : 'Days Streak!',
                  style: AppTextStyles.semiBold(
                    fontSize: 18.sp,
                    color: AppColors.black,
                  ),
                ),
                if (longestStreak != null && longestStreak! > 0) ...[
                  8.h.verticalSpace,
                  AppText(
                    text: longestStreak == 1
                        ? 'Longest streak: 1 day'
                        : 'Longest streak: $longestStreak days',
                    style: AppTextStyles.medium(
                      fontSize: 14.sp,
                      color: AppColors.black.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Image.asset(AppAssets.streakFire, height: 110.h, fit: BoxFit.contain),
        ],
      ),
    );
  }
}
