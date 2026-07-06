import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/gamification/streak_score_model.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';

class StreakFreezeWidget extends StatelessWidget {
  const StreakFreezeWidget({
    super.key,
    required this.data,
  });

  final StreakScoreModel data;

  @override
  Widget build(BuildContext context) {
    final freezes = data.freezesAvailable;
    final cost = data.freezeCostPoints;
    final totalPoints = data.scores.totalScore;
    final canAfford = totalPoints >= cost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Streak Freeze',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F4FF),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.ac_unit_rounded,
                      size: 26.w,
                      color: const Color(0xFF2B9FD9),
                    ),
                  ),
                  14.w.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: freezes == 1
                              ? '1 Streak Freeze'
                              : '$freezes Streak Freezes',
                          style: AppTextStyles.bold(
                            fontSize: 16.sp,
                            color: AppColors.black,
                          ),
                        ),
                        6.h.verticalSpace,
                        AppText(
                          text:
                              'Miss a day without losing your streak. A freeze is used automatically when you skip a day.',
                          style: AppTextStyles.medium(
                            fontSize: 12.sp,
                            color: AppColors.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              16.h.verticalSpace,
              Consumer<GamificationProvider>(
                builder: (context, gp, _) {
                  return AppFilledButton(
                    text: 'Buy Streak Freeze · $cost pts',
                    backgroundColor:
                        canAfford ? AppColors.teal : AppColors.black.withValues(alpha: 0.2),
                    fixedSize: Size(double.infinity, 44.h),
                    isLoading: gp.isBuyingFreeze,
                    onTap: !canAfford || gp.isBuyingFreeze
                        ? null
                        : () => _confirmAndBuy(context, gp, cost),
                  );
                },
              ),
              if (!canAfford) ...[
                8.h.verticalSpace,
                AppText(
                  text: 'You need $cost Sparks Points to buy a freeze.',
                  style: AppTextStyles.medium(
                    fontSize: 12.sp,
                    color: AppColors.orangeColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmAndBuy(
    BuildContext context,
    GamificationProvider gp,
    int cost,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          title: AppText(
            text: 'Buy Streak Freeze?',
            style: AppTextStyles.bold(fontSize: 18.sp, color: AppColors.black),
          ),
          content: AppText(
            text:
                'Spend $cost Sparks Points to add 1 Streak Freeze to your inventory?',
            style: AppTextStyles.medium(
              fontSize: 14.sp,
              color: AppColors.black.withValues(alpha: 0.65),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: AppText(
                text: 'Cancel',
                style: AppTextStyles.semibold(
                  fontSize: 14.sp,
                  color: AppColors.black.withValues(alpha: 0.5),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: AppText(
                text: 'Buy',
                style: AppTextStyles.bold(fontSize: 14.sp, color: AppColors.teal),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final success = await gp.buyStreakFreeze();
    if (!context.mounted) return;

    if (success) {
      AppToast.success(context, 'Streak Freeze added!');
    } else {
      AppToast.error(
        context,
        gp.freezeBuyError ?? 'Unable to buy Streak Freeze.',
      );
    }
  }
}
