import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';

enum AppButtonWidthType { full, half }

enum AppButtonColorType { primary, secondary, greyed }

class AppFilledButton extends StatelessWidget {
  const AppFilledButton({
    super.key,
    required this.onTap,
    required this.text,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.type = AppButtonWidthType.full,
    this.colorType,
    this.isLoading = false,
    this.elevation,
    this.radius = 16,
    this.fixedSize,
    this.icon,
    this.isVisible = true,
    this.margin,
  });

  final VoidCallback? onTap;
  final String text;
  final Widget? icon;
  final Color? backgroundColor, foregroundColor;
  final AppButtonWidthType? type, colorType;
  final bool? isLoading;
  final double? radius, elevation;
  final TextStyle? textStyle;
  final bool isVisible;
  final Size? fixedSize;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsetsGeometry.zero,
      child: ElevatedButton.icon(
        
        onPressed: onTap,

        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.r),
          ),

          elevation: 0,
          backgroundColor: backgroundColor ?? AppColors.black,

          fixedSize: fixedSize ?? Size(354.w, 50.h),
          splashFactory: NoSplash.splashFactory,
        ),

        icon: isLoading ?? false ? Container() : icon ?? Container(),
        label: isLoading ?? false
            ? SizedBox(
                height: 25.h,
                width: 20.w,
                child: CircularProgressIndicator(strokeWidth: 4.r),
              )
            : Text(
                text,
                textAlign: TextAlign.start,
                style:
                    textStyle ??
                    AppTextStyles.sfProDisplaySemibold(
                      fontSize: 16.5.sp,
                      color: AppColors.white,
                    ),
              ),
      ),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.onTap,
    required this.text,
    this.textStyle,
    this.borderColor,
    this.foregroundColor,
    this.type = AppButtonWidthType.full,
    this.isLoading = false,
    this.elevation,
    this.radius = 50,
    this.fixedSize,
    this.icon,
    this.isVisible = true,
    this.margin,
    this.borderWidth = 1.5,
  });

  final VoidCallback? onTap;
  final String text;
  final Widget? icon;

  final Color? borderColor;
  final Color? foregroundColor;

  final AppButtonWidthType? type;
  final bool? isLoading;
  final double? radius, elevation, borderWidth;
  final TextStyle? textStyle;
  final bool isVisible;
  final Size? fixedSize;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          fixedSize: fixedSize ?? Size(354.w, 50.h),
          foregroundColor: foregroundColor ?? AppColors.black,
          side: BorderSide(
            color: borderColor ?? AppColors.black,
            width: borderWidth ?? 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius!.r),
          ),
          splashFactory: NoSplash.splashFactory,
        ),
        icon: isLoading ?? false ? const SizedBox() : icon ?? const SizedBox(),
        label: isLoading ?? false
            ? SizedBox(
                height: 25.h,
                width: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 4.r,
                  color: foregroundColor ?? AppColors.black,
                ),
              )
            : Text(
                text,
                style:
                    textStyle ??
                    AppTextStyles.sfProDisplaySemibold(
                      fontSize: 16.sp,
                      color: foregroundColor ?? AppColors.black,
                    ),
              ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  const ActionButton({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      width: 82.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: AppText(
        text: text,
        style: AppTextStyles.textStyle14Semibold.copyWith(color: Colors.white),
      ),
    );
  }
}

class ReadingSkillButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ReadingSkillButton({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        width: 170.w,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.black.withValues(alpha: 0.1),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isSelected
                    ? Colors.white
                    : AppColors.black.withValues(alpha: 0.4),
              ),
              8.w.horizontalSpace,
              AppText(
                text: title,
                style: AppTextStyles.sfProDisplayBold(
                  fontSize: 14.sp,
                  color: isSelected
                      ? Colors.white
                      : AppColors.black.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
