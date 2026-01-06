import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';

enum AppButtonWidthType { full, half }

enum AppButtonColorType { primary, secondary, greyed }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.type = AppButtonWidthType.full,
    this.colorType = AppButtonColorType.primary,
    this.isLoading = false,
    this.elevation,
    this.radius = 16,
    this.fixedSize,
    this.icon,
    this.isVisible = true,
  });

  final VoidCallback? onPressed;
  final String text;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final AppButtonWidthType? type;
  final AppButtonColorType? colorType;
  final bool? isLoading;
  final double? radius;
  final double? elevation;
  final TextStyle? textStyle;
  final bool isVisible;
  final Size? fixedSize;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: widget.onPressed,

      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.r),
        ),

        elevation: 0,
        backgroundColor: widget.backgroundColor ?? AppColors.black,

        fixedSize: widget.fixedSize ?? Size(354.w, 50.h),

        splashFactory: NoSplash.splashFactory,
      ),

      icon: widget.isLoading ?? false
          ? Container()
          : widget.icon ?? Container(),
      label: widget.isLoading ?? false
          ? SizedBox(
              height: 25.h,
              width: 20.w,
              child: CircularProgressIndicator(strokeWidth: 4.r),
            )
          : Text(
              widget.text,
              textAlign: TextAlign.start,
              style: AppTextStyles.sfProDisplaySemibold(
                fontSize: 15.sp,
                color: AppColors.white,
              ),
            ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  const ActionButton({required this.text, required this.color});

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
                : AppColors.black.withOpacity(0.1),
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
                    : AppColors.black.withOpacity(0.4),
              ),
              8.w.horizontalSpace,
              AppText(
                text: title,
                style: AppTextStyles.sfProDisplayBold(
                  fontSize: 14.sp,
                  color: isSelected
                      ? Colors.white
                      : AppColors.black.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
