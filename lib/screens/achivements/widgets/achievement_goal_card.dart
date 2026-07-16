import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/gamification/achievement_progress_model.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';

class AchievementGoalCard extends StatelessWidget {
  const AchievementGoalCard({
    super.key,
    required this.achievement,
    this.icon,
    this.onClaim,
    this.isClaiming = false,
  });

  final AchievementProgress achievement;
  final Widget? icon;
  final VoidCallback? onClaim;
  final bool isClaiming;

  @override
  Widget build(BuildContext context) {
    final subtitleColor = AppColors.black.withValues(alpha: 0.45);
    final progress = achievement.progressValue;
    final progressLabel = achievement.progressText.isNotEmpty
        ? achievement.progressText
        : '${achievement.progress}/${achievement.target}';

    return Container(
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
          icon ??
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: _iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: _buildDefaultIcon(),
              ),
          14.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: achievement.label.toUpperCase(),
                        style: AppTextStyles.semiBold(
                          fontSize: 15.sp,
                          color: subtitleColor,
                        ),
                      ),
                    ),
                    if (achievement.claimed)
                      _StatusChip(
                        label: 'Claimed',
                        color: AppColors.teal,
                      )
                    else if (achievement.claimable)
                      GestureDetector(
                        onTap: isClaiming ? null : onClaim,
                        child: _StatusChip(
                          label: isClaiming ? 'Claiming...' : 'Claim',
                          color: AppColors.orangeColor,
                        ),
                      )
                    else if (achievement.completed)
                      _StatusChip(
                        label: 'Done',
                        color: AppColors.teal,
                      ),
                  ],
                ),
                6.h.verticalSpace,
                AppText(
                  text: progressLabel,
                  style: AppTextStyles.medium(
                    fontSize: 13.sp,
                    color: subtitleColor,
                  ),
                ),
                if (achievement.rewardPoints != null &&
                    achievement.rewardPoints! > 0) ...[
                  4.h.verticalSpace,
                  AppText(
                    text: '+${achievement.rewardPoints} pts reward',
                    style: AppTextStyles.medium(
                      fontSize: 12.sp,
                      color: AppColors.bluecolor,
                    ),
                  ),
                ],
                10.h.verticalSpace,
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6.h,
                    backgroundColor: AppColors.black.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      achievement.completed || achievement.claimable
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

  Color get _iconBackgroundColor {
    switch (achievement.type) {
      case 'spark':
        return const Color(0xFFFDEBDD);
      case 'series':
        return const Color(0xFFE8F4FF);
      case 'interest':
        return const Color(0xFFEAF8F0);
      default:
        return AppColors.teal;
    }
  }

  Widget _buildDefaultIcon() {
    switch (achievement.type) {
      case 'spark':
        return SvgIcon(
          AppAssets.thunder,
          size: 22.w,
          color: AppColors.orangeColor,
        );
      case 'series':
        return SvgIcon(
          AppAssets.bookOpen,
          size: 22.w,
          color: AppColors.bluecolor,
        );
      case 'interest':
        return SvgIcon(
          AppAssets.brain,
          size: 22.w,
          color: AppColors.teal,
        );
      default:
        return SvgIcon(AppAssets.page, size: 22.w, color: AppColors.white);
    }
  }
}

class AchievementsSectionWidget extends StatelessWidget {
  const AchievementsSectionWidget({
    super.key,
    required this.title,
    required this.achievements,
  });

  final String title;
  final List<AchievementProgress> achievements;

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: title,
          style: AppTextStyles.semiBold(fontSize: 18.sp, color: AppColors.black),
        ),
        14.h.verticalSpace,
        Consumer<GamificationProvider>(
          builder: (context, gp, _) {
            return Column(
              children: achievements
                  .map(
                    (achievement) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: AchievementGoalCard(
                        achievement: achievement,
                        isClaiming: gp.claimingAchievementId == achievement.id,
                        onClaim: achievement.claimable && !achievement.claimed
                            ? () => claimAchievementReward(
                                  context,
                                  gp,
                                  achievement,
                                )
                            : null,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

Future<void> claimAchievementReward(
  BuildContext context,
  GamificationProvider gp,
  AchievementProgress achievement,
) async {
  final points = achievement.rewardPoints ?? 0;
  final success = await gp.claimAchievement(achievement.id);
  if (!context.mounted) return;

  if (success) {
    final message = points > 0
        ? '${achievement.label} claimed! +$points pts'
        : '${achievement.label} claimed!';
    AppToast.success(context, message);
    return;
  }

  AppToast.error(
    context,
    gp.claimAchievementError ?? 'Unable to claim achievement.',
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: AppText(
        text: label,
        style: AppTextStyles.semibold(fontSize: 11.sp, color: color),
      ),
    );
  }
}
