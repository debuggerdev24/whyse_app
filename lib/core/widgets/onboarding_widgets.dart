import 'package:redstreakapp/core/widgets/app_skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  const OnboardingHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: currentStep == 0 ? null : onBack,
              child: Opacity(
                opacity: currentStep == 0 ? 0.35 : 1,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 28,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Row(
                children: List.generate(totalSteps, (index) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      decoration: BoxDecoration(
                        color: index < currentStep
                            ? const Color(0xFFF6A01A)
                            : const Color(0xFFE6E6EA),
                        borderRadius: BorderRadius.circular(4),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.teal : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Row(
          children: [
            SvgIcon(iconPath, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                text: label,
                style: AppTextStyles.semibold(
                  fontSize: 16,
                  color: AppColors.black,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
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
    return AppSkeletonizer(child: Container(
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
          borderRadius: BorderRadius.circular(22),
          border: isSelected
              ? Border.all(color: AppColors.teal, width: 2)
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
                color: AppColors.surface,
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
                errorBuilder: (_, _, _) => _buildShimmerPlaceholder(),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC000000)],
                  stops: [0.45, 1],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: AppText(
                text: label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bold(
                  fontSize: 15,
                  color: Colors.white,
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
    Color borderColor = AppColors.divider;
    Color backgroundColor = AppColors.surface;
    Color textColor = AppColors.black;
    Widget? trailingIcon;

    if (isChecked) {
      if (isCorrect) {
        borderColor = AppColors.teal;
        backgroundColor = AppColors.extealighttealcolor;
        textColor = AppColors.teal;
        trailingIcon = SvgIcon(AppAssets.correctoption, size: 22);
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.redColor;
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = AppColors.redColor;
        trailingIcon = SvgIcon(AppAssets.canceloption, size: 22);
      } else {
        borderColor = AppColors.divider;
        backgroundColor = AppColors.surface;
        textColor = AppColors.black;
      }
    } else if (isSelected) {
      borderColor = AppColors.teal;
      backgroundColor = AppColors.extealighttealcolor;
      textColor = AppColors.teal;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                text: text,
                style: AppTextStyles.regular(
                  fontSize: 14,
                  color: textColor,
                ).copyWith(height: 1.3),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 12),
              trailingIcon,
            ],
          ],
        ),
      ),
    );
  }
}
