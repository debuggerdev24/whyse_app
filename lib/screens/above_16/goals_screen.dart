import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';

import 'package:provider/provider.dart';
import 'package:redstreakapp/providers/auth_provider.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  String? selectedGoalId;
  final TextEditingController customGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchDefaultGoals(context);
    });
  }

  void _onGoalSelected(String id) {
    setState(() {
      selectedGoalId = id;
      customGoalController.clear(); // Clear custom if list item selected
    });
  }

  void _onCustomGoalChanged(String? val) {
    if (val != null && val.isNotEmpty) {
      setState(() {
        selectedGoalId = null; // Clear list selection if typing custom
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final goalsList = authProvider.goalsList;
    final isLoading = authProvider.isLoadingGoals;
    final isSaving = authProvider.isLoading;

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 40.h),
        child: AppButton(
          text: "Next",
          backgroundColor: AppColors.yellowcolor,
          isLoading: isSaving,
          onPressed: () async {
            final customGoalText = customGoalController.text.trim();

            if (selectedGoalId == null && customGoalText.isEmpty) {
              CustomToast.showError(context, "Please select at least one goal");
              return;
            }

            List<String> ids = [];
            List<Map<String, String>> customs = [];

            if (selectedGoalId != null) {
              ids.add(selectedGoalId!);
            }
            if (customGoalText.isNotEmpty) {
              customs.add({"title": customGoalText, "description": ""});
            }

            final success = await authProvider.saveGoals(
              context,
              goalIds: ids,
              customGoals: customs,
            );

            if (success && context.mounted) {
              context.pushNamed(UserAppRoutes.successScreen.name);
            }
          },
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingHeader(currentStep: 5, totalSteps: 5),

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
                  color: AppColors.black.withOpacity(0.8),
                ),
              ),

              18.h.verticalSpace,

              if (isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.teal),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: goalsList.length + 1,
                    separatorBuilder: (context, index) => 8.h.verticalSpace,
                    itemBuilder: (context, index) {
                      // Custom Goal Field at the bottom
                      if (index == goalsList.length) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 20.h, top: 1.h),
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
                                  : AppColors.black.withOpacity(0.15),
                              width: 1.w,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
            ],
          ),
        ),
      ),
    );
  }
}
