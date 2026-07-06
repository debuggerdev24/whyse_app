import 'package:redstreakapp/core/utils/app_imports.dart';

class UserPointsWidget extends StatelessWidget {
  const UserPointsWidget({super.key, required this.totalPoints});

  final int totalPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEBDD),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgIcon(
              AppAssets.thunder,
              size: 22.w,
              color: AppColors.orangeColor,
            ),
          ),
          12.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'Total Sparks Points',
                  style: AppTextStyles.medium(
                    fontSize: 13.sp,
                    color: AppColors.black.withValues(alpha: 0.55),
                  ),
                ),
                2.h.verticalSpace,
                AppText(
                  text: _formatPoints(totalPoints),
                  style: AppTextStyles.bold(
                    fontSize: 28.sp,
                    color: AppColors.orangeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPoints(int points) {
    if (points >= 1000000) {
      return '${(points / 1000000).toStringAsFixed(1)}M';
    }
    if (points >= 10000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    }
    return '$points';
  }
}
