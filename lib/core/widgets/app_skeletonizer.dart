import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// App-wide skeleton loading wrapper around [Skeletonizer].
class AppSkeletonizer extends StatelessWidget {
  const AppSkeletonizer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  static ShimmerEffect effect = ShimmerEffect(
    baseColor: AppColors.shimmerBaseColor,
    highlightColor: AppColors.shimmerHighlightColor,
  );

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      effect: effect,
      child: child,
    );
  }
}

/// Placeholder block for skeleton layouts (use inside [AppSkeletonizer]).
class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.isInfinite ? null : width.w,
      height: height.h,
      decoration: BoxDecoration(
        color: AppColors.shimmerBaseColor,
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
    );
  }
}

/// Full-area image placeholder for network image loading states.
class AppSkeletonImagePlaceholder extends StatelessWidget {
  const AppSkeletonImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSkeletonizer(
      child: ColoredBox(
        color: AppColors.lightwhiteColor,
        child: SizedBox.expand(),
      ),
    );
  }
}
