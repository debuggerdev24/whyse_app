import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';

class QuizCompletedScreen extends StatelessWidget {
  final int score;
  final int total;
  final String storyTitle;

  const QuizCompletedScreen({
    super.key,
    required this.score,
    required this.total,
    this.storyTitle = "",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(flex: 2),
                  // Success Image
                  Image.asset(AppAssets.quizcomplete),
                  19.h.verticalSpace,
                  AppText(
                    text: "Quiz Completed!",
                    style: AppTextStyles.sfProDisplayMedium(
                      fontSize: 12.sp,
                      color: AppColors.black.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Title
                  AppText(
                    text: storyTitle,
                    style: AppTextStyles.sfProDisplaySemibold(
                      fontSize: 20.sp,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  15.h.verticalSpace,
                  SvgIcon(AppAssets.correctoption, size: 24.w),
                  12.h.verticalSpace,
                  AppText(
                    text: "Quiz Completed!",
                    style: AppTextStyles.sfProDisplaySemibold(
                      fontSize: 32.sp,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  10.h.verticalSpace,
                  AppText(
                    text: "Your Score:",
                    style: AppTextStyles.sfProDisplayBold(
                      fontSize: 14.sp,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  8.h.verticalSpace,
                  AppText(
                    text: "$score/$total",
                    style: AppTextStyles.sfProDisplayBold(
                      fontSize: 20.sp,
                      color: AppColors.black,
                    ),
                  ),
                  24.h.verticalSpace,
                  AppText(
                    text: "Reward:",
                    style: AppTextStyles.sfProDisplayBold(
                      fontSize: 14.sp,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  20.h.verticalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.r),
                      border: Border.all(
                        color: AppColors.yellowColor,
                        width: 1.2,
                      ),
                      color: AppColors.yellowColor.withValues(alpha: 0.1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgIcon(
                          AppAssets.thunder,
                          size: 18.w,
                          color: AppColors.yellowColor,
                        ),
                        8.w.horizontalSpace,
                        AppText(
                          text: "3", // 👈 EXACT VALUE LIKE IMAGE
                          style: AppTextStyles.sfProDisplaySemibold(
                            fontSize: 16.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(flex: 2),

                  AppFilledButton(
                    text: "Continue",
                    onTap: () async {
                      await context.read<HomeProvider>().getAllStories();
                      if (!context.mounted) return;
                      context.goNamed(AppRoutes.homeScreen.name);
                    },
                    backgroundColor: AppColors.teal,
                    fixedSize: Size(348, 42.h),
                  ),
                  40.h.verticalSpace,
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/lottie/Congratulations.json',
                height: 600.h,
                repeat: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
