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

  /// Shimmer for [StoryIdeasScreen] (generate_story) when opening from
  /// reading goal Generate flow. Matches hero + topic title + chips +
  /// Start Reading/More + Ideas tab + idea tiles list.
  static Widget generateStoryIdeasScreenShimmer() {
    return const _GenerateStoryIdeasScreenShimmer();
  }
}

/// Shimmer layout matching generate_story StoryIdeasScreen UI.
class _GenerateStoryIdeasScreenShimmer extends StatelessWidget {
  const _GenerateStoryIdeasScreenShimmer();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero placeholder (story viewer area)
            _ShimmerBox(
              width: double.infinity,
              height: 108.w,

              radius: 0,
            ),
            // Story content block below hero: title + meta + nav buttons
            Container(
              color: AppColors.backgroundColor,
              padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: double.infinity, height: 22.h, radius: 6),
                  SizedBox(height: 8.w),
                  Row(
                    children: [
                      _ShimmerBox(width: 80.w, height: 14.h, radius: 5),
                      SizedBox(width: 12.w),
                      _ShimmerBox(width: 70.w, height: 14.h, radius: 5),
                    ],
                  ),
                  SizedBox(height: 14.w),
                  Row(
                    children: [
                      Expanded(
                        child: _ShimmerBox(
                          width: double.infinity,
                          height: 44.h,
                          radius: 12,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _ShimmerBox(width: 80.w, height: 44.h, radius: 12),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.w),
            // Topic section: title, chips, Start Reading/More, Ideas tab
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(
                    width: 180.w,
                    height: 24.h,
                    radius: 6,
                  ),
                  SizedBox(height: 8.w),
                  Row(
                    children: [
                      _ShimmerBox(width: 72.w, height: 16.h, radius: 5),
                      SizedBox(width: 12.w),
                      _ShimmerBox(width: 64.w, height: 16.h, radius: 5),
                    ],
                  ),
                  SizedBox(height: 20.w),
                  Row(
                    children: [
                      Expanded(
                        child: _ShimmerBox(
                          width: double.infinity,
                          height: 48.h,
                          radius: 12,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _ShimmerBox(width: 90.w, height: 44.h, radius: 12),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _ShimmerBox(width: 56.w, height: 20.h, radius: 4),
                ],
              ),
            ),
            // Idea tiles list
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: List.generate(4, (_) => const _StoryIdeaTileShimmer()),
              ),
            ),
            SizedBox(height: 24.w),
          ],
        ),
      ),
    );
  }
}

/// Single idea row: thumb + content + icons (matches _StoryIdeaTile).
class _StoryIdeaTileShimmer extends StatelessWidget {
  const _StoryIdeaTileShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBox(width: 120.w, height: 80.h, radius: 8),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(width: double.infinity, height: 18.h, radius: 5),
                SizedBox(height: 4.h),
                _ShimmerBox(width: double.infinity, height: 14.h, radius: 5),
                SizedBox(height: 6.h),
                _ShimmerBox(width: 80.w, height: 12.h, radius: 4),
              ],
            ),
          ),
          SizedBox(width: 5.w),
          Column(
            children: [
              _ShimmerBox(width: 22.w, height: 22.w, radius: 4),
              SizedBox(height: 8.h),
              _ShimmerBox(width: 28.w, height: 28.w, radius: 14),
            ],
          ),
        ],
      ),
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
