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

class WhatGoalScreen extends StatefulWidget {
  // final bool? isFromHome;
  const WhatGoalScreen({super.key});

  @override
  State<WhatGoalScreen> createState() => _WhatGoalScreenState();
}

class _WhatGoalScreenState extends State<WhatGoalScreen> {
  String? selectedGoalId;
  final TextEditingController customGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().getGoals(context);
    });
  }

  void _onGoalSelected(String id) {
    setState(() {
      selectedGoalId = id;
      customGoalController.clear();
    });
  }

  void _onCustomGoalChanged(String? val) {
    if (val != null && val.isNotEmpty) {
      setState(() {
        selectedGoalId = null;
      });
    }
  }

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
                              currentStep: (isStoryCreation) ? 1 : 5,
                              totalSteps: (isStoryCreation) ? 4 : 5,
                              onSkip: (isStoryCreation)
                                  ? () {
                                      context.pushNamed(
                                        AppRoutes.interestsScreen.name,
                                      );
                                    }
                                  : null,
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
                              if (index == goalsList.length &&
                                  !isStoryCreation) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 20.h,
                                    top: 1.h,
                                  ),
                                  child: AppTextField(
                                    controller: customGoalController,
                                    hintText: "Add Custom Goal...",
                                    onChanged: _onCustomGoalChanged,
                                  ),
                                );
                              }

                              final goal = goalsList[index];
                              final id = goal['id']; // Assuming ID exists
                              final title = goal['title'] ?? '';
                              final description = goal['description'] ?? '';

                              final isSelected = selectedGoalId == id;

                              return GestureDetector(
                                onTap: () => _onGoalSelected(id),
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
                          final customGoalText = customGoalController.text
                              .trim();

                          if (selectedGoalId == null &&
                              customGoalText.isEmpty &&
                              !isStoryCreation) {
                            AppToast.error(
                              context,
                              "Please select at least one goal",
                            );
                            return;
                          }

                          List<String> ids = [];
                          List<Map<String, String>> customs = [];

                          if (selectedGoalId != null) {
                            ids.add(selectedGoalId!);
                          }
                          if (customGoalText.isNotEmpty) {
                            customs.add({
                              "title": customGoalText,
                              "description": "",
                            });
                          }

                          final success = await provider.saveGoals(
                            context,
                            goalIds: ids,
                            customGoals: customs,
                          );

                          if (success && context.mounted) {
                            context.pushNamed(
                              (isStoryCreation)
                                  ? AppRoutes.interestsScreen.name
                                  : AppRoutes.successScreen.name,
                            );
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
