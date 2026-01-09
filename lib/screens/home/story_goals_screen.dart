import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';

import '../../core/constants/app_color.dart';
import '../../core/constants/text_style.dart';
import '../../core/utils/custom_loader.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text.dart';
import '../../core/widgets/app_textfiled.dart';
import '../../core/widgets/custom_toast.dart';
import '../../core/widgets/onboarding_widgets.dart';
import '../../routes/user_routes.dart';

class StoryGoalsScreen extends StatefulWidget {
  const StoryGoalsScreen({super.key});

  @override
  State<StoryGoalsScreen> createState() => _StoryGoalsScreenState();
}

class _StoryGoalsScreenState extends State<StoryGoalsScreen> {
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context, provider, child) {
            if (provider.isGetGoalsLoading) {
              return Center(child: ApiLoadingIndicator());
            }
            final goalsList = provider.goalsList;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
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
                              context.goNamed(AppRoutes.topicsScreen.name);
                            }
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          provider.getInterest(
                            onFailed: (error) {
                              AppToast.error(context, error);
                            },
                          );
                          context.pushNamed(AppRoutes.storyInterestScreen.name);
                        },
                        child: Text(
                          "Skip",
                          style: AppTextStyles.textStyle16Medium.copyWith(
                            color: AppColors.yellowColor,
                          ),
                        ),
                      ),
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
                      style: AppTextStyles.sfProDisplayBold(fontSize: 32.sp),
                    ),
                  ),
                  10.h.verticalSpace,
                  AppText(
                    text:
                        "Choose what motivates you most — we'll help you reach it.",
                    style: AppTextStyles.sfProDisplayMedium(
                      fontSize: 16.sp,
                      color: AppColors.black.withValues(alpha: 0.8),
                    ),
                  ),

                  18.h.verticalSpace,

                  if (provider.isGetGoalsLoading)
                    const Expanded(child: ApiLoadingIndicator())
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: provider.goalsList.length + 1,
                        separatorBuilder: (context, index) => 8.h.verticalSpace,
                        itemBuilder: (context, index) {
                          // Custom Goal Field at the bottom
                          if (index == goalsList.length) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 20.h, top: 1.h),
                              child: Column(
                                spacing: 8.h,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (provider.selectedGoalId == "custom")
                                    AppTextField(
                                      controller: provider.goalTitleController,
                                      hintText: "Add Goal Title...",
                                      onChanged: (value) {
                                        provider.selectedGoalId = null;
                                      },
                                    ),
                                  AppTextField(
                                    onTap: () {
                                      provider.setSelectedId = "custom";
                                    },
                                    controller: provider.goalDesController,
                                    hintText:
                                        (provider.selectedGoalId == "custom")
                                        ? "Add Goal Description..."
                                        : "Add Custom Goal...",
                                    onChanged: (value) {
                                      provider.selectedGoalId = null;
                                    },
                                  ),
                                ],
                              ),
                            );
                          }

                          final goal = goalsList[index];

                          final isSelected = provider.selectedGoalId == goal.id;

                          return GestureDetector(
                            onTap: () {
                              provider.setSelectedId = goal.id;
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
                                    style: AppTextStyles.sfProDisplayBold(
                                      fontSize: 14.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  if (goal.description.isNotEmpty) ...[
                                    3.h.verticalSpace,
                                    AppText(
                                      text: goal.description,
                                      style: AppTextStyles.sfProDisplayRegular(
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
                    backgroundColor: AppColors.yellowColor,
                    onTap: () async {
                      final goalText = provider.goalTitleController.text.trim();
                      final goalDesText = provider.goalDesController.text
                          .trim();

                      List<String> ids = [];
                      List<Map<String, String>> customs = [];

                      if (provider.selectedGoalId != null) {
                        ids.add(provider.selectedGoalId!);
                      }
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
