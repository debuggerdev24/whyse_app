import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/text_style.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/onboarding_widgets.dart';
import '../../../providers/home/story_provider.dart';
import '../../../core/routes/user_routes.dart';

class StoryGoalsScreen extends StatefulWidget {
  const StoryGoalsScreen({
    super.key,
    this.openedFromCreatedIdeas = false,
  });

  final bool openedFromCreatedIdeas;

  @override
  State<StoryGoalsScreen> createState() => _StoryGoalsScreenState();
}

class _StoryGoalsScreenState extends State<StoryGoalsScreen> {
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SafeArea(
        child: Consumer<StoryProvider>(
          builder: (context, provider, child) {
            if (provider.isGetGoalsLoading) {
              return Center(child: ApiLoadingIndicator());
            }
            final goalsList = provider.goalsList;

            return Padding(
              padding: EdgeInsets.fromLTRB(25.w, 10.w, 25.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8.w,
                    children: [
                      Expanded(
                        //todo on boarding steps header
                        child: OnboardingHeader(
                          currentStep: 1,
                          totalSteps: 4,
                          onBack: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.goNamed(
                                widget.openedFromCreatedIdeas
                                    ? AppRoutes.createdIdeasListScreen.name
                                    : AppRoutes.homeScreen.name,
                              );
                            }
                          },
                          onSkip: () {
                            context.pushNamed(
                              AppRoutes.storyInterestScreen.name,
                            );
                          },
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     provider.getStoryInterest(
                      //       onFailed: (error) {
                      //         AppToast.error(context, error);
                      //       },
                      //     );
                      //     context.pushNamed(AppRoutes.storyInterestScreen.name);
                      //   },
                      //   child: Text(
                      //     "Skip",
                      //     style: AppTextStyles.textStyle16Medium.copyWith(
                      //       color: AppColors.yellowColor,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  GestureDetector(
                    // onTap: () {
                    //   provider.getGoals(
                    //     onFailed: (error) {
                    //       AppToast.error(context, error);
                    //     },
                    //   );
                    // },
                    child: AppText(
                      text: "What's Your Goal?",
                      style: AppTextStyles.bold(fontSize: 32.sp),
                    ),
                  ),
                  10.w.verticalSpace,
                  AppText(
                    text:
                        "Choose what motivates you most — we'll help you reach it.",
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                      color: AppColors.black.withValues(alpha: 0.8),
                    ),
                  ),

                  18.w.verticalSpace,

                  if (provider.isGetGoalsLoading)
                    const Expanded(child: ApiLoadingIndicator())
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: provider.goalsList.length, //+1
                        separatorBuilder: (context, index) => 8.w.verticalSpace,
                        itemBuilder: (context, index) {
                          // todo Custom Goal Field at the bottom
                          // if (index == goalsList.length) {
                          //   return Padding(
                          //     padding: EdgeInsets.only(bottom: 20.h, top: 1.h),
                          //     child: Column(
                          //       spacing: 8.h,
                          //       mainAxisSize: MainAxisSize.min,
                          //       children: [
                          //         if (provider.isCustomGoalSelected)
                          //           AppTextField(
                          //             controller: provider.goalTitleController,
                          //             hintText: "Add Custom Goal Title...",
                          //           ),
                          //         AppTextField(
                          //           onTap: () {
                          //             if (!provider.isCustomGoalSelected) {
                          //               provider.toggleCustomGoal();
                          //             }
                          //           },
                          //           controller: provider.goalDesController,
                          //           hintText: provider.isCustomGoalSelected
                          //               ? "Add Custom Goal Description..."
                          //               : "Add Custom Goal...",
                          //         ),
                          //       ],
                          //     ),
                          //   );
                          // }

                          final goal = goalsList[index];

                          final isSelected = provider.selectedGoalIds.contains(
                            goal.id,
                          );

                          return GestureDetector(
                            onTap: () {
                              provider.toggleGoal(goal.id);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 13.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.teal
                                      : AppColors.black.withValues(alpha: 0.15),
                                  width: 1.w,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: goal.title,
                                    style: AppTextStyles.bold(
                                      fontSize: 14.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  if (goal.description.isNotEmpty) ...[
                                    3.w.verticalSpace,
                                    AppText(
                                      text: goal.description,
                                      style: AppTextStyles.regular(
                                        fontSize: 14.sp,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  AppFilledButton(
                    text: "Next",
                    margin: EdgeInsets.only(bottom: (Platform.isIOS) ? 0.w : 18.w),
                    backgroundColor: AppColors.orangeColor,
                    onTap: () async {
                      final goalText = provider.goalTitleController.text.trim();
                      final goalDesText = provider.goalDesController.text
                          .trim();

                      List<Map<String, String>> customs = [];

                      if (provider.isCustomGoalSelected &&
                          provider.goalTitleController.text.trim().isNotEmpty) {
                        customs.add({
                          "title": provider.goalTitleController.text.trim(),
                          "description": provider.goalDesController.text.trim(),
                        });
                      }
                      Logger.info(provider.goalsList[0].id);

                      if (goalText.isNotEmpty) {
                        customs.add({
                          "title": goalText,
                          "description": goalDesText,
                        });
                      }
                      provider.customInterestsList.clear();
                      provider.selectedInterestIds.clear();
                      if (context.mounted) {
                        context.pushNamed(AppRoutes.storyInterestScreen.name);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
