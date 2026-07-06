import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/gamification/achievement_progress_model.dart';
import 'package:redstreakapp/models/gamification/score_event_config.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';

Future<void> showSparkSessionSummarySheet(
  BuildContext context,
  SparkSessionSummary summary,
) {
  final gp = context.read<GamificationProvider>();

  final sparkAchievement =
      summary.achievementProgress ?? gp.currentSparkAchievement;
  final interestAchievement =
      summary.interestAchievementProgress ?? gp.currentInterestAchievement;
  final streakGoal = gp.currentActiveStreakGoal;

  final hasInterestBonus = summary.events.any(
    (e) => e.eventType == ScoreEventConfig.firstInterestCompleted,
  );
  final pointsLabel = hasInterestBonus ? 'Points Earned' : 'Sparks Points';

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              text: 'Sparks session complete',
              style: AppTextStyles.bold(fontSize: 20.sp, color: AppColors.black),
            ),
            8.h.verticalSpace,
            AppText(
              text:
                  'You finished ${summary.sparksCompleted} spark${summary.sparksCompleted == 1 ? '' : 's'} this session.',
              textAlign: TextAlign.center,
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: AppColors.black.withValues(alpha: 0.55),
              ),
            ),
            20.h.verticalSpace,
            Container(
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
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppText(
                        text: '+${summary.pointsEarned}',
                        style: AppTextStyles.bold(
                          fontSize: 28.sp,
                          color: AppColors.orangeColor,
                        ),
                      ),
                      AppText(
                        text: pointsLabel,
                        style: AppTextStyles.semibold(
                          fontSize: 13.sp,
                          color: AppColors.bluecolor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (sparkAchievement != null) ...[
              16.h.verticalSpace,
              _AchievementProgressCard(
                progress: sparkAchievement,
                icon: Image.asset(
                  AppAssets.streakFire,
                  width: 36.w,
                  height: 36.w,
                ),
              ),
            ],
            if (interestAchievement != null) ...[
              12.h.verticalSpace,
              _AchievementProgressCard(
                progress: interestAchievement,
                icon: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEBDD),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  alignment: Alignment.center,
                  child: SvgIcon(
                    AppAssets.brain,
                    size: 18.w,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ],
            if (sparkAchievement == null &&
                interestAchievement == null &&
                streakGoal != null) ...[
              16.h.verticalSpace,
              _AchievementProgressCard(
                progress: streakGoal,
                subtitle: 'Keep your streak alive!',
                icon: Image.asset(
                  AppAssets.streakFire,
                  width: 36.w,
                  height: 36.w,
                ),
              ),
            ],
            20.h.verticalSpace,
            AppFilledButton(
              text: 'Done',
              backgroundColor: AppColors.teal,
              fixedSize: Size(double.infinity, 48.h),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      );
    },
  );
}

class _AchievementProgressCard extends StatelessWidget {
  const _AchievementProgressCard({
    required this.progress,
    required this.icon,
    this.subtitle,
  });

  final AchievementProgress progress;
  final Widget icon;
  final String? subtitle;

  String get _subtitle {
    if (subtitle != null) return subtitle!;
    if (progress.claimable && !progress.claimed) {
      return 'Achievement complete! Claim ${progress.rewardPoints ?? 0} points.';
    }
    if (progress.completed) return 'Achievement unlocked!';
    return progress.label;
  }

  @override
  Widget build(BuildContext context) {
    final barProgress = progress.progressValue;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          icon,
          12.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: progress.progressText.isNotEmpty
                      ? progress.progressText
                      : '${progress.progress}/${progress.target} Completed',
                  style: AppTextStyles.bold(
                    fontSize: 14.sp,
                    color: AppColors.black,
                  ),
                ),
                4.h.verticalSpace,
                AppText(
                  text: _subtitle,
                  style: AppTextStyles.medium(
                    fontSize: 12.sp,
                    color: AppColors.black.withValues(alpha: 0.5),
                  ),
                ),
                8.h.verticalSpace,
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: barProgress,
                    minHeight: 6.h,
                    backgroundColor: AppColors.black.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress.completed || progress.claimable
                          ? AppColors.teal
                          : AppColors.orangeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
