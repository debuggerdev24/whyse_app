import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/gamification/achievement_progress_model.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/screens/achivements/widgets/achievement_goal_card.dart';

class StreakGoalWidget extends StatelessWidget {
  const StreakGoalWidget({
    super.key,
    required this.achievement,
  });

  final AchievementProgress achievement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Streak Goal',
          style: AppTextStyles.semiBold(fontSize: 18.sp, color: AppColors.black),
        ),
        14.h.verticalSpace,
        Consumer<GamificationProvider>(
          builder: (context, gp, _) {
            return AchievementGoalCard(
              achievement: achievement,
              isClaiming: gp.claimingAchievementId == achievement.id,
              onClaim: achievement.claimable && !achievement.claimed
                  ? () => claimAchievementReward(context, gp, achievement)
                  : null,
              icon: Image.asset(
                AppAssets.streakFire,
                width: 52.w,
                height: 52.w,
              ),
            );
          },
        ),
      ],
    );
  }
}
