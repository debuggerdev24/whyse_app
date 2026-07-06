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

class SeriesCompletedScreen extends StatefulWidget {
  const SeriesCompletedScreen({
    super.key,
    required this.seriesTitle,
    this.storyImageUrl,
    this.totalEpisodes = 0,
    this.completedEpisodes = 0,
    this.sparksPoints = 100,
    this.topicId,
  });

  final String seriesTitle;
  final String? storyImageUrl;
  final int totalEpisodes;
  final int completedEpisodes;
  final int sparksPoints;
  final String? topicId;

  @override
  State<SeriesCompletedScreen> createState() => _SeriesCompletedScreenState();
}

class _SeriesCompletedScreenState extends State<SeriesCompletedScreen>
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
    final total = widget.totalEpisodes > 0
        ? widget.totalEpisodes
        : widget.completedEpisodes;
    var completed = widget.completedEpisodes > 0
        ? widget.completedEpisodes
        : total;
    if (total > 0 && completed > total) completed = total;
    if (completed < 0) completed = 0;
    final percent = total > 0 ? 100 : 0;
    final progressText = total > 0
        ? '$completed/$total Episodes Completed!'
        : 'Series Completed!';
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
                          _SeriesCard(
                            imageUrl: widget.storyImageUrl,
                            seriesTitle: widget.seriesTitle,
                            episodeCount: total,
                          ),
                          28.h.verticalSpace,
                          AppText(
                            text: 'Series Completed!',
                            style: AppTextStyles.bold(
                              fontSize: 26.sp,
                              color: AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          8.h.verticalSpace,
                          AppText(
                            text:
                                'Amazing! You’ve completed the entire series.',
                            style: AppTextStyles.medium(
                              fontSize: 14.sp,
                              color: AppColors.black.withValues(alpha: 0.55),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          24.h.verticalSpace,
                          if (showPoints) ...[
                            _PointsCard(points: widget.sparksPoints),
                            16.h.verticalSpace,
                          ],
                          _ProgressCard(
                            seriesTitle: widget.seriesTitle,
                            progressText: progressText,
                            completed: completed,
                            total: total,
                            percent: percent,
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
                    text: 'Explore more series',
                    backgroundColor: AppColors.teal,
                    fixedSize: Size(double.infinity, 50.h),
                    onTap: () => context.goNamed(AppRoutes.exploreScreen.name),
                  ),
                  12.h.verticalSpace,
                  AppOutlinedButton(
                    text: 'Back to home',
                    borderColor: AppColors.teal.withValues(alpha: 0.45),
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

  void _onBackToHome() {
    context.read<StoryProvider>().clareStoryData();
    // ignore: unawaited_futures
    context.read<HomeProvider>().refreshHomeReadingData(topicId: widget.topicId);
    context.goNamed(AppRoutes.homeScreen.name);
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({
    required this.imageUrl,
    required this.seriesTitle,
    required this.episodeCount,
  });

  final String? imageUrl;
  final String seriesTitle;
  final int episodeCount;

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
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: AppNetworkImage(
                  imageUrl: imageUrl,
                  tag: 'SeriesCompleted.thumbnail',
                  width: double.infinity,
                  height: 110.h,
                  fit: BoxFit.cover,
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
                text: '$episodeCount Episodes',
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
            child: Icon(Icons.check_rounded, size: 18.w, color: AppColors.white),
          ),
        ),
      ],
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.points});
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
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

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.seriesTitle,
    required this.progressText,
    required this.completed,
    required this.total,
    required this.percent,
  });

  final String seriesTitle;
  final String progressText;
  final int completed;
  final int total;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.black.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_rounded,
              color: AppColors.orangeColor, size: 28.w),
          12.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: seriesTitle,
                  style: AppTextStyles.bold(
                    fontSize: 14.sp,
                    color: AppColors.black,
                  ),
                ),
                4.h.verticalSpace,
                AppText(
                  text: progressText,
                  style: AppTextStyles.medium(
                    fontSize: 12.sp,
                    color: AppColors.teal,
                  ),
                ),
                8.h.verticalSpace,
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: const LinearProgressIndicator(
                    value: 1,
                    minHeight: 6,
                    backgroundColor: Color(0x14000000),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.orangeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          12.w.horizontalSpace,
          AppText(
            text: '$percent%',
            style: AppTextStyles.bold(
              fontSize: 14.sp,
              color: AppColors.orangeColor,
            ),
          ),
        ],
      ),
    );
  }
}
