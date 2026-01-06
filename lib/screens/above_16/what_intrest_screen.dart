import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/routes/user_routes.dart';

class WhatInatestScreen extends StatefulWidget {
  const WhatInatestScreen({super.key});

  @override
  State<WhatInatestScreen> createState() => _WhatInatestScreenState();
}

class _WhatInatestScreenState extends State<WhatInatestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              text: "Next",
              backgroundColor: AppColors.yellowcolor,
              onPressed: () async {
                context.pushNamed(UserAppRoutes.readingGoalScreen.name);
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
                        context.goNamed(UserAppRoutes.topicsScreen.name);
                      }
                    },
                    onSkip: () {
                      context.pushNamed(UserAppRoutes.readingGoalScreen.name);
                    },
                  ),
                  AppText(
                    text: "what are you interested to read or learn about",
                    style: AppTextStyles.sfProDisplayBold(fontSize: 32.sp),
                  ),
                  10.h.verticalSpace,

                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: AppTextField(
                      hintText: "Add Custom Interest...",
                      onFieldSubmitted: (val) {},
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
