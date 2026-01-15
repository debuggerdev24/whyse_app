import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';

class GoalScreen extends StatefulWidget {
  // final bool? isFromHome;
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().getGoals(context);
    });
  }

  // void _onGoalSelected(String id) {
  //   setState(() {
  //     selectedGoalId = id;
  //     customGoalController.clear();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, provider, child) {
            final goalsList = provider.goalsList;
            final isStoryCreation = provider.isStoryCreation;
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: provider.isStoryCreation ? 8.w : 0,
                        children: [
                          Expanded(
                            //todo on boarding steps header
                            child: OnboardingHeader(
                              currentStep: 5,
                              totalSteps: 5,
                              onBack: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.goNamed(AppRoutes.topicsScreen.name);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      AppText(
                        text: "What's Your Goal?",
                        style: AppTextStyles.sfProDisplayBold(fontSize: 32.sp),
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

                      if (provider.isLoadingGoals)
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.teal,
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            itemCount:
                                goalsList.length + ((isStoryCreation) ? 0 : 1),
                            separatorBuilder: (context, index) =>
                                8.h.verticalSpace,
                            itemBuilder: (context, index) {
                              // Custom Goal Field at the bottom
                              if (index == goalsList.length) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 20.h,
                                    top: 1.h,
                                  ),
                                  child: Column(
                                    spacing: 8.h,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (provider.isCustomGoalSelected)
                                        AppTextField(
                                          controller:
                                              provider.customGoalTitleCtr,
                                          hintText: "Add Custom Goal Title...",
                                        ),
                                      AppTextField(
                                        onTap: () {
                                          if (!provider.isCustomGoalSelected) {
                                            provider.toggleCustomGoal();
                                          }
                                        },
                                        controller: provider.customGoalDesCtr,
                                        hintText: provider.isCustomGoalSelected
                                            ? "Add Custom Goal Description..."
                                            : "Add Custom Goal...",
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final goal = goalsList[index];
                              final id = goal['id']; // Assuming ID exists
                              final title = goal['title'] ?? '';
                              final description = goal['description'] ?? '';

                              final isSelected = provider.selectedGoalId == id;

                              return GestureDetector(
                                onTap: () {
                                  provider.updateGoalId(id);
                                }, //_onGoalSelected(id),
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
                                          : AppColors.black.withValues(
                                              alpha: 0.15,
                                            ),
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppText(
                                        text: title,
                                        style: AppTextStyles.sfProDisplayBold(
                                          fontSize: 14.sp,
                                          color: AppColors.black,
                                        ),
                                      ),
                                      if (description.isNotEmpty) ...[
                                        3.h.verticalSpace,
                                        AppText(
                                          text: description,
                                          style:
                                              AppTextStyles.sfProDisplayRegular(
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
                          final customGoalTitle = provider
                              .customGoalTitleCtr
                              .text
                              .trim();
                          final customGoalDes = provider.customGoalDesCtr.text
                              .trim();

                          if (provider.selectedGoalId.isEmpty &&
                              !provider.isCustomGoalSelected) {
                            AppToast.error(
                              context,
                              "Please select at least one goal",
                            );
                            return;
                          } else if (provider.isCustomGoalSelected) {
                            if (customGoalTitle.isEmpty) {
                              AppToast.error(context, "Please add goal title");
                              return;
                            } else if (customGoalDes.isEmpty) {
                              AppToast.error(
                                context,
                                "Please add goal Description",
                              );
                            }
                          }

                          List<String> ids = [];
                          List<Map<String, String>> customs = [];

                          if (provider.selectedGoalId.isNotEmpty) {
                            ids.add(provider.selectedGoalId);
                          }
                          if (customGoalTitle.isNotEmpty &&
                              customGoalDes.isNotEmpty) {
                            customs.add({
                              "title": customGoalTitle,
                              "description": customGoalDes,
                            });
                          }

                          final success = await provider.saveGoals(
                            context,
                            goalIds: ids,
                            customGoals: customs,
                          );

                          if (success && context.mounted) {
                            context.pushNamed(AppRoutes.successScreen.name);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                if (provider.isSaveGoalsLoading) FullPageIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }
}
