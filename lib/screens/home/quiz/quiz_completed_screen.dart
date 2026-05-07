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
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/core/routes/app_router.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/screens/home/quiz/quiz_question_screen.dart';

import '../../../providers/home/story_provider.dart';

class QuizCompletedScreen extends StatelessWidget {
  final int score;
  final int total;
  final String storyTitle;
  final String? storyImageUrl;

  const QuizCompletedScreen({
    super.key,
    required this.score,
    required this.total,
    this.storyTitle = "",
    this.storyImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StoryProvider>();
    Logger.info("Story length: ${provider.stories.length}");
    Logger.info("Current story index: ${provider.currentStoryIndex}");
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
                          child: storyImageUrl != null &&
                                  storyImageUrl!.isNotEmpty
                              ? Image.network(
                                  storyImageUrl!,
                                  width: 72.w,
                                  height: 72.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Image.asset(AppAssets.quizcomplete,
                                          width: 72.w, height: 72.w, fit: BoxFit.cover),
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
                    text: "Quiz Completed!",
                    style: AppTextStyles.semibold(
                      fontSize: 32.sp,
                      color: AppColors.black,
                    ),
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
                    text: "$score/$total",
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
                          text: score.toString(),
                          style: AppTextStyles.semibold(
                            fontSize: 16.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(flex: 2),

                  if ((provider.storyIdeas?.storyIdeas.length ?? provider.stories.length) - 1 > provider.currentStoryIndex)
                    AppFilledButton(
                      text: "See Next Story",
                      onTap: () {
                        final nextIndex = provider.currentStoryIndex + 1;

                        if (nextIndex < provider.stories.length) {
                          provider.setCurrentStoryIndex = nextIndex;
                          if (!context.mounted) return;
                          context.goNamed(AppRoutes.storyReadingScreen.name);
                        } else if (provider.storyIdeas != null && nextIndex < provider.storyIdeas!.storyIdeas.length) {
                          final nextIdeaId = provider.storyIdeas!.storyIdeas[nextIndex].id;
                          provider.setCurrentStoryIndex = nextIndex;
                          provider.generateSingleStory(
                            storyIdeaId: nextIdeaId,
                            context: context,
                          );
                          if (!context.mounted) return;
                          context.goNamed(AppRoutes.storyReadingScreen.name);
                        }
                      },
                      backgroundColor: AppColors.teal,
                      fixedSize: Size(348, 42.h),
                    )
                  else
                    AppFilledButton(
                      text: "Continue",
                      onTap: () async {
                        if (!context.mounted) return;
                        AppRouter.indexedStackNavigationShell?.goBranch(0);
                        context.read<HomeProvider>().getMyTopics();
                        provider.clareStoryData();
                        provider.setCurrentStoryIndex = 0;
                      },
                      backgroundColor: AppColors.teal,
                      fixedSize: Size(348, 42.w),
                    ),
                  40.w.verticalSpace,
                ],
              ),
            ),
          ),
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
