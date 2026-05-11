import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';

class OnboardingHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  final String backIcon;
  final double backIconSize;

  const OnboardingHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    this.onSkip,
    this.backIcon = AppAssets.backButton,
    this.backIconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 16.w,
          children: [
            //todo back button
            GestureDetector(
              onTap: currentStep == 0 ? null : onBack,
              child: Opacity(
                opacity: currentStep == 0 ? 0.3 : 1,
                child: SvgIcon(
                  backIcon,
                  size: backIconSize.sp,
                  color: currentStep == 0 ? Colors.grey : AppColors.black,
                ),
              ),
            ),

            Expanded(
              child: Row(
                children: List.generate(totalSteps, (index) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 600),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: index < currentStep
                            ? AppColors.orangeColor
                            : AppColors.lightwhiteColor,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (onSkip != null) ...[
              // 16.w.horizontalSpace,
              GestureDetector(
                onTap: onSkip,
                child: AppText(
                  text: "Skip",
                  style: AppTextStyles.medium(
                    fontSize: 16.sp,
                    color: AppColors.orangeColor,
                  ),
                ),
              ),
            ],
          ],
        ),

        18.w.verticalSpace,
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
                : AppColors.black.withValues(alpha: 0.15),
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
                style: AppTextStyles.semibold(
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
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const TopicCard({
    super.key,
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  static bool _isNetworkUrl(String path) {
    final p = path.trim();
    return p.startsWith('http://') || p.startsWith('https://');
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.shimmerBaseColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 5,
              spreadRadius: -1,
              offset: const Offset(0, 8),
            ),
          ],
          border: isSelected
              ? Border.all(color: AppColors.orangeColor, width: 2)
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            if (_isNetworkUrl(imagePath))
              AppNetworkImage(
                imageUrl: imagePath,
                tag: 'Onboarding.image',
                width: double.infinity,
                height: double.infinity,
                placeholder: (_) => _buildShimmerPlaceholder(),
                errorCompact: true,
                errorIconOnly: true,
              )
            else
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => _buildShimmerPlaceholder(),
              ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 13.h,
              child: AppText(
                text: label,
                style: AppTextStyles.bold(
                  fontSize: 14.sp,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isChecked;
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.black.withValues(alpha: 0.1);
    Color backgroundColor = Colors.white;
    Color textColor = AppColors.black;
    Widget? trailingIcon;

    if (isChecked) {
      if (isCorrect) {
        borderColor = Color(0xFF4CAF50);
        backgroundColor = Color(0xFFE8F5E9);
        textColor = Color(0xFF2E7D32);
        trailingIcon = SvgIcon(AppAssets.correctoption, size: 24.w);
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.redColor;
        backgroundColor = Color(0xFFFFEBEE);
        textColor = AppColors.redColor;
        trailingIcon = SvgIcon(AppAssets.canceloption, size: 24.w);
      } else {
        borderColor = Colors.black.withValues(alpha: 0.1);
        backgroundColor = Colors.white;
        textColor = AppColors.black;
      }
    } else {
      if (isSelected) {
        borderColor = AppColors.teal;
        backgroundColor = AppColors.teal.withValues(alpha: 0.1);
        textColor = AppColors.teal;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                text: text,
                style: AppTextStyles.sfProTextBold(
                  fontSize: 14.sp,
                  color: textColor,
                ),
              ),
            ),
            if (trailingIcon != null) ...[12.w.horizontalSpace, trailingIcon],
          ],
        ),
      ),
    );
  }
}
