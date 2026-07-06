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
import 'package:redstreakapp/providers/home/story_provider.dart';

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
    this.progressPercent = 37,
    this.sparksPoints = 20,
    this.fromContinueReading = false,
    this.continueReadingTopicId,
  });

  final String storyId;
  final String storyTitle;
  final String? storyImageUrl;
  final String? storyIdeaId;
  final String? seriesTitle;
  final int episodeNumber;
  final int progressPercent;
  final int sparksPoints;
  final bool fromContinueReading;
  final String? continueReadingTopicId;

  @override
  State<EpisodeCompletedScreen> createState() =>
      _EpisodeCompletedScreenState();
}

class _EpisodeCompletedScreenState extends State<EpisodeCompletedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _poppersController;
  bool _showPoppers = true;

  @override
  void initState() {
    super.initState();
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
    final safePercent = widget.progressPercent.clamp(0, 100);
    final progress = safePercent / 100.0;

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
                            text: 'Episode Completed!',
                            style: AppTextStyles.bold(
                              fontSize: 26.sp,
                              color: AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          8.h.verticalSpace,
                          AppText(
                            text: 'Great job! You completed this episode.',
                            style: AppTextStyles.medium(
                              fontSize: 14.sp,
                              color: AppColors.black.withValues(alpha: 0.55),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          24.h.verticalSpace,
                          _SparksRewardCard(points: widget.sparksPoints),
                          16.h.verticalSpace,
                          _SeriesProgressCard(
                            episodeNumber: widget.episodeNumber,
                            progress: progress,
                            percentLabel: safePercent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppFilledButton(
                    text: 'Start Quiz',
                    backgroundColor: AppColors.orangeColor,
                    fixedSize: Size(double.infinity, 50.h),
                    onTap: _onContinueReading,
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

  void _onContinueReading() {
    context.pushNamed(
      AppRoutes.startQuizScreen.name,
      extra: {
        'storyId': widget.storyId,
        'storyTitle': widget.storyTitle,
        'storyImageUrl': widget.storyImageUrl,
        'storyIdeaId': widget.storyIdeaId,
        'fromContinueReading': widget.fromContinueReading,
        if ((widget.continueReadingTopicId ?? '').isNotEmpty)
          'continueReadingTopicId': widget.continueReadingTopicId,
      },
    );
  }

  void _onBackToHome() {
    context.read<StoryProvider>().clareStoryData();
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
            child: Icon(Icons.check_rounded, size: 18.w, color: AppColors.white),
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
    required this.episodeNumber,
    required this.progress,
    required this.percentLabel,
  });

  final int episodeNumber;
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
              color: const Color(0xFFFDEBDD),
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
                  text: 'Episode $episodeNumber Completed',
                  style: AppTextStyles.bold(
                    fontSize: 14.sp,
                    color: AppColors.black,
                  ),
                ),
                2.h.verticalSpace,
                AppText(
                  text: 'Keep Going!',
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
                    valueColor: const AlwaysStoppedAnimation<Color>(
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
                    valueColor: const AlwaysStoppedAnimation<Color>(
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
