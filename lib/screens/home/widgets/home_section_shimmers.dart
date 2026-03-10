import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:shimmer/shimmer.dart';

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

  static Widget createdStoryIdeasLoadingShimmer() {
    return const StoryIdeasLoadingShimmer();
  }

  static Widget createdStoryIdeasLoadMoreShimmer() {
    return const StoryIdeasLoadMoreShimmer();
  }

  static Widget storyReadingScreenShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image area with "Page x of y" badge overlay (matches story_reading_screen)
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              _ShimmerBox(
                width: double.infinity,
                height: 280.w,
                radius: 0,
              ),
              Positioned(
                left: 12.w,
                bottom: 12.w,
                child: _ShimmerBox(
                  width: 72.w,
                  height: 28.w,
                  radius: 8,
                ),
              ),
            ],
          ),
          // Title, meta, page label, body, and single Start button (matches real UI)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.w, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(width: double.infinity, height: 28.w, radius: 6),
                8.w.verticalSpace,
                Row(
                  children: [
                    _ShimmerBox(width: 64.w, height: 15.w, radius: 5),
                    14.w.horizontalSpace,
                    _ShimmerBox(width: 56.w, height: 15.w, radius: 5),
                  ],
                ),
                12.w.verticalSpace,
                _ShimmerBox(width: 48.w, height: 14.w, radius: 4),
                10.w.verticalSpace,
                _ShimmerBox(width: double.infinity, height: 16.w, radius: 4),
                8.w.verticalSpace,
                _ShimmerBox(width: double.infinity, height: 16.w, radius: 4),
                8.w.verticalSpace,
                _ShimmerBox(width: 260.w, height: 16.w, radius: 4),
                24.w.verticalSpace,
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 20.w),
            child: _ShimmerBox(
              width: double.infinity,
              height: 52.w,
              radius: 999,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer layout matching generate_story StoryIdeasScreen UI.
class _GenerateStoryIdeasScreenShimmer extends StatelessWidget {
  const _GenerateStoryIdeasScreenShimmer();

  @override
  Widget build(BuildContext context) {
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
              height: 240.w,
              radius: 0,
            ),
            //* Story content block below hero: title + meta + nav buttons
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 150.w, height: 26.h, radius: 6),
                  SizedBox(height: 8.w),
                  Row(
                    children: [
                      _ShimmerBox(width: 100.w, height: 20.h, radius: 5),
                      const Spacer(),
                      _ShimmerBox(width: 80.w, height: 20.h, radius: 5),
                    ],
                  ),
                  SizedBox(height: 20.w),
                  _ShimmerBox(width: double.infinity, height: 16.h, radius: 4),
                  SizedBox(height: 6.w),
                  _ShimmerBox(width: double.infinity, height: 16.h, radius: 4),
                  SizedBox(height: 6.w),
                  _ShimmerBox(width: 200.w, height: 16.h, radius: 4),
                  SizedBox(height: 20.w),
                  Row(
                    children: [
                      Expanded(
                        child: _ShimmerBox(
                          width: double.infinity,
                          height: 44.h,
                          radius: 12,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _ShimmerBox(
                          width: double.infinity,
                          height: 44.h,
                          radius: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            10.w.verticalSpace,
            //* Topic section: title, chips, Start Reading/More, Ideas tab
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
                  8.w.verticalSpace,
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

class StoryIdeasLoadingShimmer extends StatelessWidget {
  const StoryIdeasLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Container(
          margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.w),
          child: _StoryIdeasShimmerBox(
            width: double.infinity,
            height: 260.h,
            borderRadius: 28,
          ),
        ),
        20.h.verticalSpace,
        ...List.generate(3, (_) => const StoryIdeaEpisodeShimmer()),
      ],
    );
  }
}

class StoryIdeasLoadMoreShimmer extends StatelessWidget {
  const StoryIdeasLoadMoreShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [StoryIdeaEpisodeShimmer(), StoryIdeaEpisodeShimmer()],
    );
  }
}

class StoryIdeaEpisodeShimmer extends StatelessWidget {
  const StoryIdeaEpisodeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _StoryIdeasShimmerBox(width: 118, height: 78, borderRadius: 18),
            ],
          ),
          14.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _StoryIdeasShimmerBox(
                  width: 64,
                  height: 12,
                  borderRadius: 999,
                ),
                10.h.verticalSpace,
                const _StoryIdeasShimmerBox(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 6,
                ),
                6.h.verticalSpace,
                const _StoryIdeasShimmerBox(
                  width: double.infinity,
                  height: 14,
                  borderRadius: 6,
                ),
                6.h.verticalSpace,
                const _StoryIdeasShimmerBox(
                  width: 170,
                  height: 14,
                  borderRadius: 6,
                ),
                10.h.verticalSpace,
                Row(
                  children: const [
                    Expanded(
                      child: _StoryIdeasShimmerBox(
                        width: double.infinity,
                        height: 28,
                        borderRadius: 999,
                      ),
                    ),
                  ],
                ),
                12.h.verticalSpace,
                const _StoryIdeasShimmerBox(
                  width: double.infinity,
                  height: 42,
                  borderRadius: 999,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoryIdeasImageShimmer extends StatelessWidget {
  const StoryIdeasImageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: const ColoredBox(color: AppColors.lightwhiteColor),
    );
  }
}

class _StoryIdeasShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _StoryIdeasShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
