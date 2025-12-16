import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';

import 'package:provider/provider.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/providers/auth_provider.dart';

class ReadingGoalScreen extends StatefulWidget {
  const ReadingGoalScreen({super.key});

  @override
  State<ReadingGoalScreen> createState() => _ReadingGoalScreenState();
}

class _ReadingGoalScreenState extends State<ReadingGoalScreen> {
  String selectedOption = '5 mins';
  final List<String> options = ['5 mins', '10 mins', '20 mins', 'Custom'];
  final TextEditingController customGoalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 40.h),
        child: AppButton(
          text: "Next",
          backgroundColor: AppColors.yellowcolor,
          onPressed: () async {
            int goal = 0;
            if (selectedOption == 'Custom') {
              if (customGoalController.text.trim().isEmpty) {
                // Show toast
                return;
              }
              goal = int.tryParse(customGoalController.text.trim()) ?? 0;
            } else {
              goal = int.tryParse(selectedOption.split(' ')[0]) ?? 0;
            }

            if (goal <= 0) {
              // Show toast
              return;
            }

            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            final success = await authProvider.saveReadingGoal(
              context,
              dailyReadingGoal: goal,
            );

            if (success && context.mounted) {
              context.pushNamed(UserAppRoutes.interestsScreen.name);
            }
          },
          isLoading: context.watch<AuthProvider>().isLoading,
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              const OnboardingHeader(currentStep: 2, totalSteps: 5),

              /// TITLE
              AppText(
                text: "Set Your Daily Reading Goal",
                style: AppTextStyles.sfProDisplayBold(fontSize: 32.sp),
              ),

              8.h.verticalSpace,

              AppText(
                text:
                    "Choose how much time you want to read \neach day to keep your streak alive and earn rewards.",
                style: AppTextStyles.sfProDisplayMedium(
                  fontSize: 16.sp,
                  color: AppColors.black.withOpacity(0.8),
                ),
              ),

              18.h.verticalSpace,

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.black.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(options.length, (index) {
                    final option = options[index];
                    final isSelected = selectedOption == option;

                    return Row(
                      children: [
                        _buildOptionButton(option, isSelected),

                        /// Divider except last
                        if (index != options.length - 1)
                          Container(
                            width: 1.w,
                            height: 22.h,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                      ],
                    );
                  }),
                ),
              ),

              if (selectedOption == 'Custom') ...[
                20.h.verticalSpace,
                AppTextField(
                  hintText: "Enter minutes",
                  controller: customGoalController,
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = text;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: AppText(
          text: text,
          style: AppTextStyles.sfProDisplaySemibold(
            fontSize: isSelected ? 16.sp : 14.sp,
            color: isSelected ? Colors.white : AppColors.black.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
