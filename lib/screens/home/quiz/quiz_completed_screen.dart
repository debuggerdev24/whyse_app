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
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/screens/home/quiz/quiz_question_screen.dart';

import 'package:redstreakapp/models/home/story_models/quiz_exit_snapshot.dart';
import '../../../providers/home/story_provider.dart';

class QuizCompletedScreen extends StatelessWidget {
  final int score;
  final int total;
  final String storyTitle;
  final String? storyImageUrl;
  final String? storyIdeaId;
  final String? storyId;

  const QuizCompletedScreen({
    super.key,
    required this.score,
    required this.total,
    this.storyTitle = "",
    this.storyImageUrl,
    this.storyIdeaId,
    this.storyId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StoryProvider>();
    Logger.info("Story length: ${provider.stories.length}");
    Logger.info("Current story index: ${provider.currentStoryIndex}");
    final safeTotal = total <= 0 ? 0 : total;
    final safeScore = score.clamp(0, safeTotal == 0 ? score : safeTotal);
    final percent = safeTotal == 0 ? 0 : (safeScore / safeTotal);
    final shouldCelebrate = safeTotal > 0 && percent >= 0.6;
    final headline = percent >= 0.8
        ? "Amazing job!"
        : percent >= 0.5
        ? "Nice work!"
        : percent > 0
        ? "Good try!"
        : "Let’s try again!";
    final subText = percent >= 0.8
        ? "You really understood the story."
        : percent >= 0.5
        ? "You’re getting the hang of it."
        : percent > 0
        ? "Read once more and you’ll score higher."
        : "Read the story once more, then retake the quiz.";
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

                  // Story thumbnail card
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
                          child:
                              storyImageUrl != null && storyImageUrl!.isNotEmpty
                              ? Image.network(
                                  storyImageUrl!,
                                  width: 72.w,
                                  height: 72.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset(
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
                          text: "AI Generated Text",
                          style: AppTextStyles.regular(
                            fontSize: 10.sp,
                            color: AppColors.black.withValues(alpha: 0.5),
                          ),
                        ),
                        4.w.verticalSpace,
                        AppText(
                          text: storyTitle.isNotEmpty ? storyTitle : "Story",
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
                  20.w.verticalSpace,
                  AppText(
                    text: "Your Score:",
                    style: AppTextStyles.bold(
                      fontSize: 14.sp,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  8.w.verticalSpace,
                  AppText(
                    text: "$safeScore/$safeTotal",
                    style: AppTextStyles.bold(
                      fontSize: 24.sp,
                      color: AppColors.black,
                    ),
                  ),
                  24.w.verticalSpace,
                  AppText(
                    text: "Reward:",
                    style: AppTextStyles.bold(
                      fontSize: 14.sp,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  12.w.verticalSpace,
                  safeScore == 0
                      ? AppText(
                          text:
                              "No reward this time. You’ll earn rewards when you score points.",
                          style: AppTextStyles.semiBold(
                            fontSize: 12.sp,
                            color: AppColors.black.withValues(alpha: 0.6),
                          ).copyWith(height: 1.35),
                          textAlign: TextAlign.center,
                        )
                      : Container(
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
                                text: safeScore.toString(),
                                style: AppTextStyles.semibold(
                                  fontSize: 16.sp,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                  Spacer(flex: 2),

                  Consumer<StoryProvider>(
                    builder: (context, sp, _) {
                      final isSubmitting = sp.isSubmitQuizLoading;
                      final hasNext =
                          (sp.storyIdeas?.storyIdeas.length ?? sp.stories.length) -
                                  1 >
                              sp.currentStoryIndex;
                      return AppFilledButton(
                        text: hasNext ? "See Next Story" : "Continue",
                        onTap: isSubmitting
                            ? null
                            : () async {
                                if (!context.mounted) return;
                                await _submitAndPop(
                                  context,
                                  sp,
                                  safeScore,
                                  safeTotal,
                                );
                              },
                        backgroundColor: AppColors.teal,
                        fixedSize: Size(348, 42.w),
                        isLoading: isSubmitting,
                      );
                    },
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
              child: Lottie.asset(
                'assets/lottie/Congratulations.json',
                // repeat: false,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submitAndPop(
    BuildContext context,
    StoryProvider provider,
    int correctAnswers,
    int totalQuestions,
  ) async {
    if (provider.isSubmitQuizLoading) return;
    final sId = storyId ?? (provider.stories.isNotEmpty ? provider.stories.first.id : null);
    final ideaId = storyIdeaId;
    if (sId == null || sId.isEmpty || ideaId == null || ideaId.isEmpty) {
      if (!context.mounted) return;
      context.pop(  
        QuizExitSnapshot(
          storyIdeaId: ideaId ?? '',
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
          isCompleted: true,
          completedAt: DateTime.now().toUtc().toIso8601String(),
        ),
      );
      return;
    }

    final data = await provider.submitQuizResult(
      storyId: sId,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
    );
    if (!context.mounted) return;
    if (data == null) {
      AppToast.error(context, provider.quizError ?? "Unable to submit quiz.");
      return;
    }
    final qp = data["quizProgress"] is Map ? Map<String, dynamic>.from(data["quizProgress"]) : const <String, dynamic>{};
    final snap = QuizExitSnapshot(
      storyIdeaId: (data["storyIdeaId"]?.toString() ?? ideaId),
      totalQuestions: qp["totalQuestions"] is int
          ? qp["totalQuestions"] as int
          : int.tryParse(qp["totalQuestions"]?.toString() ?? "") ??
              totalQuestions,
      correctAnswers: qp["correctAnswers"] is int
          ? qp["correctAnswers"] as int
          : int.tryParse(qp["correctAnswers"]?.toString() ?? "") ??
              correctAnswers,
      isCompleted: qp["isCompleted"] == true,
      completedAt: qp["completedAt"]?.toString(),
    );

    // Apply immediately so MyStoryIdeas reflects completion without waiting.
    final hp = context.read<HomeProvider>();
    hp.applyLocalQuizProgress(
      storyIdeaId: snap.storyIdeaId,
      totalQuestions: snap.totalQuestions,
      correctAnswers: snap.correctAnswers,
      isCompleted: snap.isCompleted,
      completedAt: snap.completedAt,
    );

    final topicId = hp.activeStoryIdeasTopicId;
    if (topicId != null) {
      // Silent refresh for any derived fields.
      // ignore: unawaited_futures
      hp.getTopicStoryDetails(topicId: topicId, showLoadingUi: false);
    }

    if (!context.mounted) return;
    // Navigate back to the story ideas screen (instead of the reader).
    context.goNamed(AppRoutes.createdStorySummaryScreen.name);
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
