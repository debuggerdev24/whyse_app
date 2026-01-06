import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/constants/thumpaint.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/dropdown_textfiled.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/providers/auth_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';

class ReadingGoalScreen extends StatefulWidget {
  const ReadingGoalScreen({super.key});

  @override
  State<ReadingGoalScreen> createState() => _ReadingGoalScreenState();
}

class _ReadingGoalScreenState extends State<ReadingGoalScreen> {
  String selectedOption = '5 mins';
  String? _selectedAgSchedule;
  String? selectedLanguage;
  String? selectedTextType;
  String? selectedAge;

  final List<String> options = ['5 mins', '10 mins', '20 mins', 'Custom'];
  final TextEditingController customGoalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      /// -------------------- BOTTOM BUTTON --------------------
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 40.h),
        child: AppButton(
          text: "Next",
          backgroundColor: AppColors.yellowcolor,
          isLoading: context.watch<AuthProvider>().isLoading,
          onPressed: () async {
            int goal = 0;

            if (selectedOption == 'Custom') {
              if (customGoalController.text.trim().isEmpty) return;
              goal = int.tryParse(customGoalController.text.trim()) ?? 0;
            } else {
              goal = int.tryParse(selectedOption.split(' ')[0]) ?? 0;
            }

            if (goal <= 0) return;

            // final authProvider = Provider.of<AuthProvider>(
            //   context,
            //   listen: false,
            // );

            // final success = await authProvider.saveReadingGoal(
            //   context,
            //   dailyReadingGoal: goal,
            // );

            // if (success && context.mounted) {
            context.pushNamed(UserAppRoutes.readingScreen.name);
            // }
          },
        ),
      ),

      /// -------------------- BODY --------------------
      body: SafeArea(
        child: Column(
          children: [
            /// 🔒 FIXED HEADER (NON-SCROLLABLE)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: OnboardingHeader(
                currentStep: 5,
                totalSteps: 5,
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.goNamed(UserAppRoutes.profileInfoScreen.name);
                  }
                },
                // onSkip: () {
                //   context.pushNamed(UserAppRoutes.readingScreen.name);
                // },
              ),
            ),

            /// 🔽 SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    /// OPTIONS
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.black.withOpacity(0.1),
                        ),
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

                    10.h.verticalSpace,

                    if (selectedOption == 'Custom')
                      AppTextField(
                        hintText: "Enter minutes",
                        controller: customGoalController,
                        keyboardType: TextInputType.number,
                      ),

                    15.h.verticalSpace,
                    _sectionTitle("Schedule Reading"),

                    CustomDropDown(
                      // label: "Schedule Reading",
                      value: _selectedAgSchedule,
                      hint: "only 1 Reading/many readings",
                      items: const ["only 1 Reading", "many readings"],
                      onChanged: (value) {
                        setState(() => _selectedAgSchedule = value!);
                      },
                    ),
                    15.h.verticalSpace,

                    /// LANGUAGE
                    _sectionTitle("Language"),

                    CustomDropDown(
                      hint: "Preferred Reading Language",
                      value: selectedLanguage,
                      items: const ["English", "Hindi", "Arabic", "French"],
                      onChanged: (value) {
                        setState(() => selectedLanguage = value!);
                      },
                    ),

                    15.h.verticalSpace,
                    _sectionTitle("Text Type"),
                    CustomDropDown(
                      // label: "Text Type"
                      hint: "Select text type",
                      value: selectedTextType,
                      items: const ["Story", "Story Facts", "Facts"],
                      onChanged: (value) {
                        setState(() => selectedTextType = value!);
                      },
                    ),

                    15.h.verticalSpace,
                    _sectionTitle("Age"),
                    15.h.verticalSpace,

                    CustomDropDown(
                      // label: "Age",
                      hint: "Select age",
                      items: const [
                        "0 - 10",
                        "10 - 20",
                        "20 - 30",
                        "30 - 40",
                        "40 - 50",
                        "50 to above",
                      ],
                      value: selectedAge,
                      onChanged: (value) {
                        setState(() => selectedAge = value!);
                      },
                    ),

                    15.h.verticalSpace,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// -------------------- OPTION BUTTON --------------------
  Widget _buildOptionButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedOption = text),
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

  /// -------------------- SECTION TITLE --------------------
  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: AppColors.yellowcolor,
                shape: BoxShape.circle,
              ),
            ),
            8.w.horizontalSpace,
            AppText(text: title, style: AppTextStyles.textStyle16Semibold),
          ],
        ),
        Divider(color: AppColors.black.withOpacity(0.1)),
        10.h.verticalSpace,
      ],
    );
  }
}
