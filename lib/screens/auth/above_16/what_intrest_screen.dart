import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';

class WhatInterestScreen extends StatefulWidget {
  const WhatInterestScreen({super.key});

  @override
  State<WhatInterestScreen> createState() => _WhatInterestScreenState();
}

class _WhatInterestScreenState extends State<WhatInterestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppFilledButton(
              text: "Next",
              backgroundColor: AppColors.primaryColor,
              onTap: () async {
                context.pushNamed(AppRoutes.readingGoalScreen.name);
              },
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OnboardingHeader(
                    currentStep: 4,
                    totalSteps: 5,
                    onBack: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed(AppRoutes.topicsScreen.name);
                      }
                    },
                    onSkip: () {
                      context.pushNamed(AppRoutes.readingGoalScreen.name);
                    },
                  ),
                  AppText(
                    text: "what are you interested to read or learn about",
                    style: AppTextStyles.bold(fontSize: 32.sp),
                  ),
                  10.w.verticalSpace,

                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: AppTextField(
                      hintText: "Add Custom Interest...",
                      onSubmit: (val) {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
