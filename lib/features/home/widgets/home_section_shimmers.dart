import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:redstreakapp/core/constants/app_color.dart';

class HomeSectionShimmer {
  HomeSectionShimmer._();

  /// Shimmer placeholder matching the [_StoryCard] layout in
  /// [CreatedStorySummaryScreen]. Shows 3 skeleton cards by default.
  static Widget storyIdeaShimmer({int itemCount = 3}) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 10.h),
      itemCount: itemCount,
      separatorBuilder: (_, __) => 18.h.verticalSpace,
      itemBuilder: (_, __) => const _StoryIdeaCardShimmer(),
    );
  }
}

class _StoryIdeaCardShimmer extends StatelessWidget {
  const _StoryIdeaCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 18.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title: "Title: The Secret Garden Quest" ──
            // Full-width, teal, ~20sp bold
            _ShimmerBox(width: double.infinity, height: 20.h, radius: 6),

            8.h.verticalSpace,

            // ── "Description:" label ──
            _ShimmerBox(width: 100.w, height: 14.h, radius: 5),

            6.h.verticalSpace,

            // ── Description body line 1 (full width) ──
            _ShimmerBox(width: double.infinity, height: 14.h, radius: 5),
            5.h.verticalSpace,

            // ── Description body line 2 (full width) ──
            _ShimmerBox(width: double.infinity, height: 14.h, radius: 5),
            5.h.verticalSpace,

            // ── Description body line 3 + "See more" stub ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _ShimmerBox(
                    width: double.infinity,
                    height: 14.h,
                    radius: 5,
                  ),
                ),
                10.w.horizontalSpace,
                // "See more" pill
                _ShimmerBox(width: 58.w, height: 14.h, radius: 5),
              ],
            ),

            12.h.verticalSpace,

            // ── Created row: clock icon + date text ──
            Row(
              children: [
                _ShimmerBox(width: 13.w, height: 13.w, radius: 13),
                6.w.horizontalSpace,
                _ShimmerBox(width: 150.w, height: 12.h, radius: 5),
              ],
            ),

            5.h.verticalSpace,

            // ── Updated row: pencil icon + date text ──
            Row(
              children: [
                _ShimmerBox(width: 13.w, height: 13.w, radius: 4),
                6.w.horizontalSpace,
                _ShimmerBox(width: 140.w, height: 12.h, radius: 5),
              ],
            ),

            16.h.verticalSpace,

            // ── "Read Story" button ──
            _ShimmerBox(
              width: double.infinity,
              height: 46.h,
              radius: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
