import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/models/gamification/activity_rewards.dart';
import 'package:redstreakapp/screens/achivements/widgets/achievement_goal_card.dart';

/// Celebration UI shown after the user finishes reading a chapter/episode.
/// Points and progress are display-only (no API).
class EpisodeCompletedScreen extends StatefulWidget {
  const EpisodeCompletedScreen({
    super.key,
    required this.storyId,
    required this.storyTitle,
    this.storyImageUrl,
    this.storyIdeaId,
    this.seriesTitle,
    this.episodeNumber = 1,
    this.completedEpisodes = 1,
    this.totalEpisodes = 0,
    this.progressPercent = 0,
    this.sparksPoints = 20,
    this.fromContinueReading = false,
    this.continueReadingTopicId,
    this.topicId,
  });

  final String storyId;
  final String storyTitle;
  final String? storyImageUrl;
  final String? storyIdeaId;
  final String? seriesTitle;
  final int episodeNumber;
  final int completedEpisodes;
  final int totalEpisodes;
  final int progressPercent;
  final int sparksPoints;
  final bool fromContinueReading;
  final String? continueReadingTopicId;
  final String? topicId;

  @override
  State<EpisodeCompletedScreen> createState() =>
      _EpisodeCompletedScreenState();
}

class _EpisodeCompletedScreenState extends State<EpisodeCompletedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _poppersController;
  bool _showPoppers = true;
  ActivityRewards? _rewards;

  @override
  void initState() {
    super.initState();
    _rewards = context.read<GamificationProvider>().consumePendingEpisodeRewards();
    _poppersController = AnimationController(vsync: this);
    _poppersController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _showPoppers = false);
      }
    });
  }

  @override
  void dispose() {
    _poppersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displaySeries =
        (widget.seriesTitle != null && widget.seriesTitle!.trim().isNotEmpty)
        ? widget.seriesTitle!.trim()
        : (widget.storyTitle.isNotEmpty ? widget.storyTitle : 'Story');
    final totalEpisodes = widget.totalEpisodes > 0 ? widget.totalEpisodes : 0;
    var completedEpisodes = widget.completedEpisodes;
    if (totalEpisodes > 0) {
      if (completedEpisodes > totalEpisodes) completedEpisodes = totalEpisodes;
      if (completedEpisodes < 0) completedEpisodes = 0;
    }
    final safePercent = totalEpisodes > 0
        ? ((completedEpisodes / totalEpisodes) * 100).round().clamp(0, 100)
        : widget.progressPercent.clamp(0, 100);
    final progress = safePercent / 100.0;
    final episodeProgressText = totalEpisodes > 0
        ? 'Episode $completedEpisodes of $totalEpisodes Completed'
        : 'Episode ${widget.episodeNumber} Completed';
    final showPoints = widget.sparksPoints > 0;

    return AppLayout(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(top: 28.h, bottom: 16.h),
                      child: Column(
                        children: [
                          _StoryCard(
                            imageUrl: widget.storyImageUrl,
                            seriesTitle: displaySeries,
                            episodeNumber: widget.episodeNumber,
                          ),
                          28.h.verticalSpace,
                          AppText(
                            text: 'Reading Complete!',
                            style: AppTextStyles.bold(
                              fontSize: 26.sp,
                              color: AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          8.h.verticalSpace,
                          AppText(
                            text:
                                'Great job! You finished reading. Take the quiz to complete this episode.',
                            style: AppTextStyles.medium(
                              fontSize: 14.sp,
                              color: AppColors.black.withValues(alpha: 0.55),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          24.h.verticalSpace,
                          if (showPoints) ...[
                            _SparksRewardCard(points: widget.sparksPoints),
                            16.h.verticalSpace,
                          ],
                          _SeriesProgressCard(
                            episodeProgressText: episodeProgressText,
                            completedEpisodes: completedEpisodes,
                            totalEpisodes: totalEpisodes,
                            progress: progress,
                            percentLabel: safePercent,
                          ),
                          if (_rewards?.seriesAchievementProgress != null) ...[
                            16.h.verticalSpace,
                            AchievementGoalCard(
                              achievement: _rewards!.seriesAchievementProgress!,
                            ),
                          ],
                          if (_rewards?.interestAchievementProgress != null) ...[
                            16.h.verticalSpace,
                            AchievementGoalCard(
                              achievement: _rewards!.interestAchievementProgress!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  AppFilledButton(
                    text: 'Take Quiz',
                    backgroundColor: AppColors.orangeColor,
                    fixedSize: Size(double.infinity, 50.h),
                    onTap: _onTakeQuiz,
                  ),
                  12.h.verticalSpace,
                  AppOutlinedButton(
                    text: 'Back to home',
                    borderColor: AppColors.orangeColor.withValues(alpha: 0.45),
                    fixedSize: Size(double.infinity, 50.h),
                    textStyle: AppTextStyles.semibold(
                      fontSize: 16.sp,
                      color: AppColors.darkGrey,
                    ),
                    onTap: _onBackToHome,
                  ),
                  (MediaQuery.paddingOf(context).bottom + 12).h.verticalSpace,
                ],
              ),
            ),
          ),
          if (_showPoppers)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/lottie/Congratulations.json',
                  controller: _poppersController,
                  fit: BoxFit.cover,
                  onLoaded: (composition) {
                    _poppersController
                      ..duration = composition.duration
                      ..forward();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onTakeQuiz() {
    context.pushNamed(
      AppRoutes.startQuizScreen.name,
      extra: {
        'storyId': widget.storyId,
        'storyTitle': widget.storyTitle,
        'storyImageUrl': widget.storyImageUrl,
        'storyIdeaId': widget.storyIdeaId,
        'episodeNumber': widget.episodeNumber,
        'seriesTitle': widget.seriesTitle,
        'totalEpisodes': widget.totalEpisodes,
        'fromContinueReading': widget.fromContinueReading,
        if ((widget.continueReadingTopicId ?? '').isNotEmpty)
          'continueReadingTopicId': widget.continueReadingTopicId,
        if ((widget.topicId ?? '').isNotEmpty) 'topicId': widget.topicId,
      },
    );
  }

  void _onBackToHome() {
    context.read<StoryProvider>().clareStoryData();

    final topicId = widget.topicId ?? widget.continueReadingTopicId;
    // ignore: unawaited_futures
    context.read<HomeProvider>().refreshHomeReadingData(topicId: topicId);

    context.goNamed(AppRoutes.homeScreen.name);
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.imageUrl,
    required this.seriesTitle,
    required this.episodeNumber,
  });

  final String? imageUrl;
  final String seriesTitle;
  final int episodeNumber;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 200.w,
          padding: EdgeInsets.fromLTRB(12.w, 12.w, 12.w, 28.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: AppNetworkImage(
                  imageUrl: imageUrl,
                  tag: 'EpisodeCompleted.thumbnail',
                  width: double.infinity,
                  height: 110.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Image.asset(
                    AppAssets.quizcomplete,
                    width: double.infinity,
                    height: 110.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              12.h.verticalSpace,
              AppText(
                text: 'Series',
                style: AppTextStyles.semibold(
                  fontSize: 12.sp,
                  color: AppColors.orangeColor,
                ),
              ),
              4.h.verticalSpace,
              AppText(
                text: seriesTitle,
                style: AppTextStyles.bold(
                  fontSize: 18.sp,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              4.h.verticalSpace,
              AppText(
                text: 'Episode $episodeNumber',
                style: AppTextStyles.medium(
                  fontSize: 13.sp,
                  color: AppColors.black.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -14.w,
          child: Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              color: AppColors.greenColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.check_rounded, size: 18.w, color: AppColors.onImage),
          ),
        ),
      ],
    );
  }
}

class _SparksRewardCard extends StatelessWidget {
  const _SparksRewardCard({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.lightyellowcolor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
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
                text: '+$points',
                style: AppTextStyles.bold(
                  fontSize: 28.sp,
                  color: AppColors.orangeColor,
                ),
              ),
              AppText(
                text: 'Sparks Points',
                style: AppTextStyles.semibold(
                  fontSize: 13.sp,
                  color: AppColors.bluecolor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeriesProgressCard extends StatelessWidget {
  const _SeriesProgressCard({
    required this.episodeProgressText,
    required this.completedEpisodes,
    required this.totalEpisodes,
    required this.progress,
    required this.percentLabel,
  });

  final String episodeProgressText;
  final int completedEpisodes;
  final int totalEpisodes;
  final double progress;
  final int percentLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.black.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.lightyellowcolor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            alignment: Alignment.center,
            child: SvgIcon(
              AppAssets.bookOpen,
              size: 20.w,
              color: AppColors.orangeColor,
            ),
          ),
          12.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: episodeProgressText,
                  style: AppTextStyles.bold(
                    fontSize: 14.sp,
                    color: AppColors.black,
                  ),
                ),
                2.h.verticalSpace,
                AppText(
                  text: totalEpisodes > 0
                      ? '$completedEpisodes/$totalEpisodes Episodes · Keep Going!'
                      : 'Keep Going!',
                  style: AppTextStyles.medium(
                    fontSize: 12.sp,
                    color: AppColors.black.withValues(alpha: 0.5),
                  ),
                ),
                8.h.verticalSpace,
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6.h,
                    backgroundColor: AppColors.black.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.orangeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          12.w.horizontalSpace,
          SizedBox(
            width: 48.w,
            height: 48.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 48.w,
                  height: 48.w,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4.w,
                    backgroundColor: AppColors.black.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.orangeColor,
                    ),
                  ),
                ),
                AppText(
                  text: '$percentLabel%',
                  style: AppTextStyles.bold(
                    fontSize: 11.sp,
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
}
