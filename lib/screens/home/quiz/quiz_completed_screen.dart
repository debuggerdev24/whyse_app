import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/models/gamification/activity_rewards.dart';
import 'package:redstreakapp/models/gamification/score_award_result.dart';
import 'package:redstreakapp/models/gamification/score_event_config.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/screens/achivements/widgets/achievement_goal_card.dart';
import 'package:redstreakapp/screens/home/quiz/quiz_question_screen.dart';

import '../../../providers/home/story_provider.dart';

class QuizCompletedScreen extends StatefulWidget {
  final int score;
  final int total;
  final String storyTitle;
  final String? storyImageUrl;
  final String? storyIdeaId;
  final String? storyId;
  final bool fromContinueReading;
  final String? continueReadingTopicId;
  final int episodeNumber;
  final String? seriesTitle;
  final int totalEpisodes;
  final String? topicId;

  const QuizCompletedScreen({
    super.key,
    required this.score,
    required this.total,
    this.storyTitle = "",
    this.storyImageUrl,
    this.storyIdeaId,
    this.storyId,
    this.fromContinueReading = false,
    this.continueReadingTopicId,
    this.episodeNumber = 1,
    this.seriesTitle,
    this.totalEpisodes = 0,
    this.topicId,
  });

  @override
  State<QuizCompletedScreen> createState() => _QuizCompletedScreenState();
}

class _QuizCompletedScreenState extends State<QuizCompletedScreen> {
  bool _isSubmitting = true;
  bool _submitFailed = false;
  ScoreAwardResult? _awards;
  ActivityRewards? _rewards;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _submitQuiz());
  }

  Future<void> _submitQuiz() async {
    if (!mounted) return;
    setState(() {
      _isSubmitting = true;
      _submitFailed = false;
    });

    final provider = context.read<StoryProvider>();
    final sId =
        widget.storyId ??
        (provider.stories.isNotEmpty ? provider.stories.first.id : null);
    final ideaId = widget.storyIdeaId;
    final safeTotal = widget.total <= 0 ? 0 : widget.total;
    final safeScore = widget.score.clamp(0, safeTotal == 0 ? widget.score : safeTotal);

    if (sId == null || sId.isEmpty || ideaId == null || ideaId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitFailed = true;
      });
      return;
    }

    final data = await provider.submitQuizResult(
      storyId: sId,
      correctAnswers: safeScore,
      totalQuestions: safeTotal,
    );
    if (!mounted) return;

    if (data == null) {
      setState(() {
        _isSubmitting = false;
        _submitFailed = true;
      });
      AppToast.error(context, provider.quizError ?? "Unable to submit quiz.");
      return;
    }

    final gamification = context.read<GamificationProvider>();
    final awards = await gamification.handleActivityResponse({'data': data});
    final qp = data["quizProgress"] is Map
        ? Map<String, dynamic>.from(data["quizProgress"])
        : const <String, dynamic>{};

    final hp = context.read<HomeProvider>();
    hp.applyLocalQuizProgress(
      storyIdeaId: (data["storyIdeaId"]?.toString() ?? ideaId),
      totalQuestions: qp["totalQuestions"] is int
          ? qp["totalQuestions"] as int
          : int.tryParse(qp["totalQuestions"]?.toString() ?? "") ?? safeTotal,
      correctAnswers: qp["correctAnswers"] is int
          ? qp["correctAnswers"] as int
          : int.tryParse(qp["correctAnswers"]?.toString() ?? "") ?? safeScore,
      isCompleted: qp["isCompleted"] == true,
      completedAt: qp["completedAt"]?.toString(),
    );

    final topicId = hp.activeStoryIdeasTopicId;
    if (!widget.fromContinueReading && topicId != null) {
      // ignore: unawaited_futures
      hp.getTopicStoryDetails(topicId: topicId, showLoadingUi: false);
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _awards = awards;
      _rewards = awards?.rewards;
    });
  }

  Future<void> _onContinue() async {
    final hp = context.read<HomeProvider>();
    final gamification = context.read<GamificationProvider>();
    final resolvedTopicId =
        widget.topicId ??
        widget.continueReadingTopicId ??
        hp.activeStoryIdeasTopicId;

    await hp.refreshHomeReadingData(topicId: resolvedTopicId);
    if (!mounted) return;

    final totalEpisodes = widget.totalEpisodes > 0
        ? widget.totalEpisodes
        : (hp.storySummary?.storyIdeas.length ?? 0);
    final completedEpisodes = hp.countFullyCompletedEpisodes();
    final seriesComplete = hp.isSeriesFullyComplete(
          totalEpisodes: totalEpisodes,
        ) ||
        _awards?.hasSeriesCompleted == true;

    context.read<StoryProvider>().clareStoryData();

    if (seriesComplete) {
      if (_rewards != null) {
        gamification.stashPendingEpisodeRewards(_rewards);
      }
      final sparksPoints = gamification.resolveQuizCompletionPoints(_awards);
      context.pushReplacementNamed(
        AppRoutes.seriesCompletedScreen.name,
        extra: {
          'seriesTitle': (widget.seriesTitle?.trim().isNotEmpty == true)
              ? widget.seriesTitle!.trim()
              : (widget.storyTitle.isNotEmpty ? widget.storyTitle : 'Series'),
          'storyImageUrl': widget.storyImageUrl,
          'totalEpisodes': totalEpisodes > 0 ? totalEpisodes : completedEpisodes,
          'completedEpisodes':
              completedEpisodes > 0 ? completedEpisodes : widget.episodeNumber,
          'sparksPoints': sparksPoints > 0
              ? sparksPoints
              : (_awards?.pointsFor(ScoreEventConfig.seriesCompleted) ?? 0),
          'topicId': resolvedTopicId,
        },
      );
      return;
    }

    if (widget.fromContinueReading) {
      final tid = widget.continueReadingTopicId ?? widget.topicId;
      if (tid != null && tid.isNotEmpty) {
        context.goNamed(AppRoutes.createdStorySummaryScreen.name, extra: tid);
        return;
      }
      context.goNamed(AppRoutes.homeScreen.name);
      return;
    }

    if (resolvedTopicId != null && resolvedTopicId.isNotEmpty) {
      context.goNamed(
        AppRoutes.createdStorySummaryScreen.name,
        extra: resolvedTopicId,
      );
    } else {
      context.goNamed(AppRoutes.homeScreen.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StoryProvider>();
    Logger.info("Story length: ${provider.stories.length}");
    final safeTotal = widget.total <= 0 ? 0 : widget.total;
    final safeScore = widget.score.clamp(0, safeTotal == 0 ? widget.score : safeTotal);
    final percent = safeTotal == 0 ? 0 : (safeScore / safeTotal);
    final shouldCelebrate = !_isSubmitting && safeTotal > 0 && percent >= 0.6;
    final gamification = context.read<GamificationProvider>();
    final sparksReward = gamification.resolveQuizCompletionPoints(_awards);
    final showPoints = sparksReward > 0;

    final headline = _isSubmitting
        ? 'Submitting quiz...'
        : percent >= 0.8
        ? 'Amazing job!'
        : percent >= 0.5
        ? 'Nice work!'
        : percent > 0
        ? 'Good try!'
        : 'Let’s try again!';
    final subText = _isSubmitting
        ? 'Saving your results and rewards.'
        : percent >= 0.8
        ? 'You really understood the story.'
        : percent >= 0.5
        ? 'You’re getting the hang of it.'
        : percent > 0
        ? 'Read once more and you’ll score higher.'
        : 'Read the story once more, then retake the quiz.';

    return AppLayout(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(flex: 2),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: widget.storyImageUrl != null &&
                                  widget.storyImageUrl!.isNotEmpty
                              ? Image.network(
                                  widget.storyImageUrl!,
                                  width: 72.w,
                                  height: 72.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Image.asset(
                                    AppAssets.quizcomplete,
                                    width: 72.w,
                                    height: 72.w,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  AppAssets.quizcomplete,
                                  width: 72.w,
                                  height: 72.w,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        8.w.verticalSpace,
                        AppText(
                          text: widget.storyTitle.isNotEmpty
                              ? widget.storyTitle
                              : 'Story',
                          style: AppTextStyles.semibold(
                            fontSize: 14.sp,
                            color: AppColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  16.w.verticalSpace,
                  SvgIcon(AppAssets.correctoption, size: 28.w),
                  20.w.verticalSpace,
                  AppText(
                    text: headline,
                    style: AppTextStyles.semibold(
                      fontSize: 32.sp,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  8.w.verticalSpace,
                  AppText(
                    text: subText,
                    style: AppTextStyles.medium(
                      fontSize: 14.sp,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ).copyWith(height: 1.35),
                    textAlign: TextAlign.center,
                  ),
                  if (!_isSubmitting) ...[
                    20.w.verticalSpace,
                    AppText(
                      text: 'Your Score:',
                      style: AppTextStyles.bold(
                        fontSize: 14.sp,
                        color: AppColors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    8.w.verticalSpace,
                    AppText(
                      text: '$safeScore/$safeTotal',
                      style: AppTextStyles.bold(
                        fontSize: 24.sp,
                        color: AppColors.black,
                      ),
                    ),
                    24.w.verticalSpace,
                    AppText(
                      text: 'Reward:',
                      style: AppTextStyles.bold(
                        fontSize: 14.sp,
                        color: AppColors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    12.w.verticalSpace,
                    if (!showPoints)
                      AppText(
                        text: 'Quiz completed!',
                        style: AppTextStyles.semiBold(
                          fontSize: 12.sp,
                          color: AppColors.black.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.r),
                          border: Border.all(
                            color: AppColors.orangeColor,
                            width: 1.2,
                          ),
                          color: AppColors.orangeColor.withValues(alpha: 0.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgIcon(
                              AppAssets.thunder,
                              size: 18.w,
                              color: AppColors.orangeColor,
                            ),
                            8.w.horizontalSpace,
                            AppText(
                              text: '+$sparksReward',
                              style: AppTextStyles.semibold(
                                fontSize: 16.sp,
                                color: AppColors.black,
                              ),
                            ),
                            4.w.horizontalSpace,
                            AppText(
                              text: 'Sparks Points',
                              style: AppTextStyles.medium(
                                fontSize: 12.sp,
                                color: AppColors.bluecolor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_rewards?.interestAchievementProgress != null) ...[
                      16.h.verticalSpace,
                      AchievementGoalCard(
                        achievement: _rewards!.interestAchievementProgress!,
                      ),
                    ],
                  ],
                  Spacer(flex: 2),
                  AppFilledButton(
                    text: _submitFailed ? 'Retry' : 'Continue',
                    onTap: _isSubmitting
                        ? null
                        : () {
                            if (_submitFailed) {
                              _submitQuiz();
                              return;
                            }
                            _onContinue();
                          },
                    backgroundColor: AppColors.teal,
                    fixedSize: Size(348, 42.w),
                    isLoading: _isSubmitting,
                  ),
                  40.w.verticalSpace,
                ],
              ),
            ),
          ),
          if (shouldCelebrate)
            Positioned(
              bottom: 150.h,
              left: 0,
              right: 0,
              child: Lottie.asset('assets/lottie/Congratulations.json'),
            ),
        ],
      ),
    );
  }
}

void showLeaveStoryConfirmation({required BuildContext context}) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return ZoomIn(
        child: AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          title: Text(
            "Are you sure you want to quit the current story session?",
            style: AppTextStyles.textStyle20Regular,
          ),
          actions: [
            myActionButtonTheme(
              onPressed: () {
                context.pop(dialogContext);
                context.goNamed(AppRoutes.homeScreen.name);
                context.read<StoryProvider>().clareStoryData();
              },
              title: "Yes",
            ),
            myActionButtonTheme(
              onPressed: () {
                context.pop();
              },
              title: "Cancel",
            ),
          ],
        ),
      );
    },
  );
}
