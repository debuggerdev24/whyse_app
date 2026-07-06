import 'package:redstreakapp/core/utils/app_imports.dart';

class StreakGoalWidget extends StatelessWidget {
  const StreakGoalWidget({
    super.key,
    required this.title,
    required this.currentDays,
    required this.targetDays,
  });

  final String title;
  final int currentDays;
  final int targetDays;

  @override
  Widget build(BuildContext context) {
    final progress = targetDays <= 0
        ? 0.0
        : (currentDays / targetDays).clamp(0.0, 1.0);
    final progressLabel =
        '$currentDays/${targetDays.toString().padLeft(2, '0')} Days';
    final subtitleColor = AppColors.black.withValues(alpha: 0.45);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Streak Goal',
          style: AppTextStyles.semiBold(fontSize: 18.sp, color: AppColors.black),
        ),
        14.h.verticalSpace,
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: const BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: SvgIcon(AppAssets.page, size: 22.w),
              ),
              14.w.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: title,
                      style: AppTextStyles.semiBold(
                        fontSize: 15.sp,
                        color: subtitleColor,
                      ),
                    ),
                    6.h.verticalSpace,
                    AppText(
                      text: progressLabel,
                      style: AppTextStyles.medium(
                        fontSize: 13.sp,
                        color: subtitleColor,
                      ),
                    ),
                    10.h.verticalSpace,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6.h,
                        backgroundColor:
                            AppColors.black.withValues(alpha: 0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.orangeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
