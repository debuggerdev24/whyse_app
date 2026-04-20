import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/utils/field_validator.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';

class ReadingGoalScreen extends StatefulWidget {
  const ReadingGoalScreen({super.key});

  @override
  State<ReadingGoalScreen> createState() => _ReadingGoalScreenState();
}

class _ReadingGoalScreenState extends State<ReadingGoalScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedOption = '5 mins';
  final List<String> options = ['5 mins', '10 mins', '20 mins', 'Custom'];
  final TextEditingController customGoalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Consumer<AuthProvider>(
          builder: (context, provider, child) => Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    OnboardingHeader(
                      currentStep: 2,
                      totalSteps: 5,
                      onBack: () {
                        if (context.canPop()) {
                          context.pop();
                          return;
                        }

                        context.goNamed(AppRoutes.profileInfoScreen.name);
                      },
                    ),

                    /// TITLE
                    AppText(
                      text: "Set Your Daily Reading Goal",
                      style: AppTextStyles.bold(fontSize: 32.sp),
                    ),

                    8.w.verticalSpace,

                    AppText(
                      text:
                          "Choose how much time you want to read \neach day to keep your streak alive and earn rewards.",
                      style: AppTextStyles.medium(
                        fontSize: 16.sp,
                        color: AppColors.black.withValues(alpha: 0.8),
                      ),
                    ),

                    18.w.verticalSpace,

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.black.withValues(alpha: 0.1),
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
                                  height: 22.w,
                                  color: Colors.grey.withValues(alpha: 0.3),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),

                    if (selectedOption == 'Custom') ...[
                      20.w.verticalSpace,
                      Form(
                        key: _formKey,
                        child: AppTextField(
                          hintText: "Enter minutes",
                          controller: customGoalController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) =>
                              FieldValidators().required(value, "Minutes"),
                        ),
                      ),
                    ],
                    Spacer(),

                    AppFilledButton(
                      text: "Next",
                      backgroundColor: AppColors.orangeColor,
                      margin: EdgeInsets.only(bottom: 8.h),
                      onTap: () async {
                        int goal = 0;
                        if (selectedOption == "Custom") {
                          if (!_formKey.currentState!.validate()) {
                            //customGoalController.text.trim().isEmpty
                            // Show toast
                            return;
                          }
                          goal =
                              int.tryParse(customGoalController.text.trim()) ??
                              0;
                        } else {
                          goal =
                              int.tryParse(selectedOption.split(' ')[0]) ?? 0;
                        }

                        if (goal <= 0) {
                          // Show toast
                          return;
                        }
                        final success = await provider.saveReadingGoal(
                          context,
                          dailyReadingGoal: goal,
                        );

                        if (success && context.mounted) {
                          context.pushNamed(AppRoutes.interestsScreen.name);
                        }
                      },
                    ),
                  ],
                ),
              ),
              if (provider.isSaveReadingGoal) FullPageIndicator(),
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
          style: AppTextStyles.semibold(
            fontSize: isSelected ? 15.sp : 13.sp,
            color: isSelected
                ? Colors.white
                : AppColors.black.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
