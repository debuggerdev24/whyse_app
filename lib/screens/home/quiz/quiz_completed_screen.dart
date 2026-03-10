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
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/screens/home/quiz/quiz_question_screen.dart';

import '../../../providers/home/story_provider.dart';

class QuizCompletedScreen extends StatelessWidget {
  final int score;
  final int total;
  final String storyTitle;

  const QuizCompletedScreen({
    super.key,
    required this.score,
    required this.total,
    this.storyTitle = "",
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StoryProvider>();
    Logger.info("Story length: ${provider.stories.length}");
    Logger.info("Current story index: ${provider.currentStoryIndex}");
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          showLeaveStoryConfirmation(context: context);
        });
      },

      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            showLeaveStoryConfirmation(context: context);
          });
        },
        child: AppLayout(
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(flex: 2),
                      // Success Image
                      Image.asset(AppAssets.quizcomplete),
                      19.h.verticalSpace,
                      AppText(
                        text: "Quiz Completed!",
                        style: AppTextStyles.sfProDisplayMedium(
                          fontSize: 12.sp,
                          color: AppColors.black.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Title
                      AppText(
                        text: storyTitle,
                        style: AppTextStyles.sfProDisplaySemibold(
                          fontSize: 20.sp,
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      15.h.verticalSpace,
                      SvgIcon(AppAssets.correctoption, size: 24.w),
                      12.h.verticalSpace,
                      AppText(
                        text: "Quiz Completed!",
                        style: AppTextStyles.sfProDisplaySemibold(
                          fontSize: 32.sp,
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      10.h.verticalSpace,
                      AppText(
                        text: "Your Score:",
                        style: AppTextStyles.sfProDisplayBold(
                          fontSize: 14.sp,
                          color: AppColors.black.withValues(alpha: 0.6),
                        ),
                      ),
                      8.h.verticalSpace,
                      AppText(
                        text: "$score/$total",
                        style: AppTextStyles.sfProDisplayBold(
                          fontSize: 20.sp,
                          color: AppColors.black,
                        ),
                      ),
                      24.h.verticalSpace,
                      AppText(
                        text: "Reward:",
                        style: AppTextStyles.sfProDisplayBold(
                          fontSize: 14.sp,
                          color: AppColors.black.withValues(alpha: 0.6),
                        ),
                      ),
                      20.h.verticalSpace,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.r),
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1.2,
                          ),
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgIcon(
                              AppAssets.thunder,
                              size: 18.w,
                              color: AppColors.primaryColor,
                            ),
                            8.w.horizontalSpace,
                            AppText(
                              text: score.toString(),
                              style: AppTextStyles.sfProDisplaySemibold(
                                fontSize: 16.sp,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(flex: 2),
        
                      if ((provider.storyIdea?.storyIdeas.length ?? provider.stories.length) - 1 > provider.currentStoryIndex)
                        AppFilledButton(
                          text: "See Next Story",
                          onTap: () {
                            final nextIndex = provider.currentStoryIndex + 1;
                            
                            if (nextIndex < provider.stories.length) {
                              provider.setCurrentStoryIndex = nextIndex;
                              if (!context.mounted) return;
                              context.goNamed(AppRoutes.storyIdeasScreen.name);
                            } else if (provider.storyIdea != null && nextIndex < provider.storyIdea!.storyIdeas.length) {
                              final nextIdeaId = provider.storyIdea!.storyIdeas[nextIndex].id;
                              provider.setCurrentStoryIndex = nextIndex;
                              provider.generateSingleStory(
                                storyIdeaId: nextIdeaId,
                                context: context,
                                onSuccess: () {},
                              );
                              if (!context.mounted) return;
                              context.goNamed(AppRoutes.storyIdeasScreen.name);
                            }
                          },
                          backgroundColor: AppColors.teal,
                          fixedSize: Size(348, 42.h),
                        )
                      else
                      //
                        AppFilledButton(
                          text: "Home",
                          onTap: () async {
                            if (!context.mounted) return;
                            context.goNamed(AppRoutes.homeScreen.name);
                            context.read<StoryProvider>().clareStoryData();
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
        ),
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
