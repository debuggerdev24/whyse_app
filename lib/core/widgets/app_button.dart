import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';

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

        fixedSize: Size(354.w, 50.h),

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
              style: AppTextStyles.sfProDisplayBold(
                fontSize: 14.sp,
                color: AppColors.white,
              ),
            ),
    );
  }
}
