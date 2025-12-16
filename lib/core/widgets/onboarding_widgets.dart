import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';

class OnboardingHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  const OnboardingHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            /// BACK BUTTON
            GestureDetector(
              onTap: currentStep == 0 ? null : (onBack ?? () => context.pop()),
              child: Opacity(
                opacity: currentStep == 0 ? 0.3 : 1,
                child: SvgIcon(
                  AppAssets.backButton,
                  size: 14.sp,
                  color: currentStep == 0 ? Colors.grey : AppColors.black,
                ),
              ),
            ),

            16.w.horizontalSpace,

            Expanded(
              child: Row(
                children: List.generate(totalSteps, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: index < currentStep
                            ? AppColors.yellowcolor
                            : AppColors.lightwhiteColor,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),

        30.h.verticalSpace,
      ],
    );
  }
}

class SelectionOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? icon;
  final String iconPath;

  const SelectionOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        margin: EdgeInsets.only(bottom: 12.h),
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
        child: Row(
          children: [
            // if (icon != null) ...[icon!, 12.w.horizontalSpace],
            SvgIcon(iconPath, size: 28.w),
            14.w.horizontalSpace,
            Expanded(
              child: AppText(
                text: label,
                style: AppTextStyles.sfProDisplaySemibold(
                  fontSize: 15.sp,
                  color: AppColors.black,
                ),
              ),
            ),
            if (isSelected) SvgIcon(AppAssets.check, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

class TopicCard extends StatelessWidget {
  final String label;
  final String assetPath;
  final bool isSelected;
  final VoidCallback onTap;

  const TopicCard({
    super.key,
    required this.label,
    required this.assetPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5), // soft black
              blurRadius: 18, // more blur = smooth shadow
              spreadRadius: -1,
              offset: const Offset(0, 8), // pushed downward
            ),
          ],

          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
          ),

          border: isSelected
              ? Border.all(color: AppColors.yellowcolor, width: 2)
              : null,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
        child: AppText(
          text: label,
          style: AppTextStyles.sfProDisplayBold(
            fontSize: 14.sp,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
