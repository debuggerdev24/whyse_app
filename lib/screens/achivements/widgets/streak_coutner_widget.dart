import 'package:redstreakapp/core/utils/app_imports.dart';

class StreakCoutnerWidget extends StatelessWidget {
  const StreakCoutnerWidget({super.key, this.streakCount = 1});

  final int streakCount;

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
              ],
            ),
          ),
          Image.asset(AppAssets.streakFire, height: 110.h, fit: BoxFit.contain),
        ],
      ),
    );  
  }
}
