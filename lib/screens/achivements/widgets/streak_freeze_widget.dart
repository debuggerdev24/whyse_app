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

    final title = freezes == 1
        ? '1 Streak Freeze'
        : '$freezes Streak Freeze${freezes == 0 ? '' : 's'}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SvgIcon(AppAssets.snow, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: title,
                      style: AppTextStyles.semibold(
                        fontSize: 16,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      text:
                          'Miss a day without losing your streak. A freeze is used automatically when you skip a day',
                      style: AppTextStyles.regular(
                        fontSize: 13,
                        color: const Color(0xFF8E8E93),
                      ).copyWith(height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Consumer<GamificationProvider>(
            builder: (context, gp, _) {
              return AppFilledButton(
                text: 'Buy Streak Freeze - ${cost}pts',
                backgroundColor: canAfford
                    ? AppColors.teal
                    : const Color(0xFFE5E5EA),
                textStyle: AppTextStyles.semibold(
                  fontSize: 14,
                  color: canAfford ? Colors.white : const Color(0xFF8E8E93),
                ).copyWith(height: 17 / 14),
                fixedSize: Size(MediaQuery.sizeOf(context).width - 64, 48),
                isLoading: gp.isBuyingFreeze,
                loadingColor: Colors.white,
                onTap: !canAfford || gp.isBuyingFreeze
                    ? null
                    : () => _confirmAndBuy(context, gp, cost),
              );
            },
          ),
        ],
      ),
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
