import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';

/// Full-bleed fallback when a network (or other) image fails to load.
///
/// Use [compact] + [iconOnly] for small thumbnails; default is hero / card size.
class NoImageFound extends StatelessWidget {
  const NoImageFound({
    super.key,
    this.title = 'No image found',
    this.subtitle,
    this.compact = false,
    this.iconOnly = false,
  });

  final String title;
  final String? subtitle;
  final bool compact;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final iconSize = iconOnly
        ? 22.sp
        : (compact ? 28.sp : 40.sp);
    final circlePad = iconOnly
        ? 10.w
        : (compact ? 14.w : 22.w);
    final titleSize = compact ? 11.sp : 15.sp;
    final subtitleSize = compact ? 10.sp : 12.sp;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.extealighttealcolor,
            AppColors.lighttealcolor,
            AppColors.teal.withValues(alpha: 0.22),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -24.w,
            top: -18.h,
            child: IgnorePointer(
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
          Positioned(
            left: -20.w,
            bottom: -12.h,
            child: IgnorePointer(
              child: Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(circlePad),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withValues(alpha: 0.94),
                      border: Border.all(
                        color: AppColors.teal.withValues(alpha: 0.28),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.teal.withValues(alpha: 0.18),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.hide_image_outlined,
                      size: iconSize,
                      color: AppColors.teal,
                    ),
                  ),
                  if (!iconOnly) ...[
                    SizedBox(height: compact ? 8.h : 14.h),
                    AppText(
                      text: title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bold(
                        fontSize: titleSize,
                        color: AppColors.teal,
                        height: 1.15,
                      ),
                    ),
                    if (subtitle != null &&
                        subtitle!.trim().isNotEmpty &&
                        !compact) ...[
                      SizedBox(height: 6.h),
                      AppText(
                        text: subtitle!.trim(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.regular(
                          fontSize: subtitleSize,
                          color: AppColors.black.withValues(alpha: 0.55),
                        ).copyWith(height: 1.2),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
