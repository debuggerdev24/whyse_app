import 'package:lottie/lottie.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/gamification/achievement_progress_model.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';

enum SparkSummaryAction { keepExploring, home }

Future<SparkSummaryAction?> showSparkSessionSummarySheet(
  BuildContext context,
  SparkSessionSummary summary,
) {
  return Navigator.of(context, rootNavigator: true).push<SparkSummaryAction>(
    PageRouteBuilder<SparkSummaryAction>(
      opaque: true,
      barrierDismissible: false,
      pageBuilder: (context, _, _) {
        return _SparkSessionCompletedPage(summary: summary);
      },
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class _SparkSessionCompletedPage extends StatelessWidget {
  const _SparkSessionCompletedPage({required this.summary});

  final SparkSessionSummary summary;

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GamificationProvider>();
    final spark =
        summary.achievementProgress ?? gp.currentSparkAchievement;
    final interest =
        summary.interestAchievementProgress ?? gp.currentInterestAchievement;
    final sparkCount = summary.sparksCompleted;
    final sparkWord = sparkCount == 1 ? 'spark' : 'sparks';
    final bottom = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, bottom > 0 ? 8 : 16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        const _CelebrationMark(),
                        const SizedBox(height: 18),
                        AppText(
                          text: 'Spark Session Completed!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.semibold(
                            fontSize: 26,
                            color: AppColors.black,
                          ).copyWith(height: 1.2, letterSpacing: -0.3),
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          text:
                              'You finished $sparkCount $sparkWord this session. Great curiosity!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.regular(
                            fontSize: 14,
                            color: AppColors.muted,
                          ).copyWith(height: 1.35),
                        ),
                        if (summary.pointsEarned > 0) ...[
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SvgIcon(AppAssets.thunder, size: 28),
                              const SizedBox(width: 6),
                              AppText(
                                text: '+${summary.pointsEarned}',
                                style: AppTextStyles.bold(
                                  fontSize: 32,
                                  color: AppColors.black,
                                ).copyWith(height: 1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            text: 'Sparks Points',
                            style: AppTextStyles.medium(
                              fontSize: 13,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                        if (spark != null || interest != null) ...[
                          const SizedBox(height: 28),
                          _ProgressCard(spark: spark, interest: interest),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  text: 'Keep Exploring',
                  filled: true,
                  onTap: () => Navigator.of(context).pop(
                    SparkSummaryAction.keepExploring,
                  ),
                ),
                const SizedBox(height: 10),
                _ActionButton(
                  text: 'Back to Home',
                  filled: false,
                  onTap: () =>
                      Navigator.of(context).pop(SparkSummaryAction.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CelebrationMark extends StatelessWidget {
  const _CelebrationMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/Congratulations.json',
            height: 210,
            fit: BoxFit.contain,
            repeat: true,
          ),
          const Icon(
            Icons.emoji_events_rounded,
            size: 108,
            color: Color(0xFF2BB8B4),
          ),
          const Positioned(
            top: 78,
            child: Icon(
              Icons.star_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.spark, required this.interest});

  final AchievementProgress? spark;
  final AchievementProgress? interest;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      if (spark != null)
        _ProgressRow(
          progress: spark!,
          barColor: AppColors.teal,
          iconBackground: const Color(0xFFE4EFF0),
          icon: const SvgIcon(AppAssets.streakFireIcon, size: 22),
          fallbackTitle: 'Sparks Completed',
        ),
      if (interest != null)
        _ProgressRow(
          progress: interest!,
          barColor: AppColors.orangeColor,
          iconBackground: const Color(0xFFFFF1E0),
          icon: SvgIcon(
            AppAssets.brain,
            size: 22,
            color: AppColors.black,
          ),
          fallbackTitle: 'Interests Completed',
        ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: AppColors.divider),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.progress,
    required this.barColor,
    required this.iconBackground,
    required this.icon,
    required this.fallbackTitle,
  });

  final AchievementProgress progress;
  final Color barColor;
  final Color iconBackground;
  final Widget icon;
  final String fallbackTitle;

  @override
  Widget build(BuildContext context) {
    final title = progress.progressText.trim().isNotEmpty
        ? progress.progressText.trim()
        : '${progress.progress}/${progress.target} $fallbackTitle';
    final subtitle = progress.label.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accentFill(iconBackground),
            shape: BoxShape.circle,
          ),
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.semibold(
                    fontSize: 15,
                    color: AppColors.black,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  AppText(
                    text: subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regular(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.progressValue,
                    minHeight: 6,
                    backgroundColor: AppColors.divider,
                    color: barColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.muted,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.text,
    required this.filled,
    required this.onTap,
  });

  final String text;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.teal : AppColors.surface,
          borderRadius: BorderRadius.circular(40),
          border: filled ? null : Border.all(color: AppColors.divider),
        ),
        child: AppText(
          text: text,
          style: AppTextStyles.semibold(
            fontSize: 14,
            color: filled ? AppColors.onFill : AppColors.black,
          ).copyWith(height: 17 / 14),
        ),
      ),
    );
  }
}
