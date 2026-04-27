import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:shimmer/shimmer.dart';

class HomeSectionShimmer {
  HomeSectionShimmer._();

  static Widget storyIdeaShimmer({int itemCount = 3}) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 10.h),
      itemCount: itemCount,
      separatorBuilder: (_, __) => 18.w.verticalSpace,
      itemBuilder: (_, __) => const _StoryIdeaCardShimmer(),
    );
  }

  static Widget generateStoryIdeasScreenShimmer() {
    return const _GenerateStoryIdeasScreenShimmer();
  }

  static Widget createdStoryIdeasLoadingShimmer() {
    return const StoryIdeasLoadingShimmer();
  }

  static Widget createdStoryIdeasLoadMoreShimmer() {
    return const StoryIdeasLoadMoreShimmer();
  }

  static Widget ideasListScreenShimmer() {
    return const _IdeasListScreenShimmer();
  }

  static Widget storyReadingScreenShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBox(width: double.infinity, height: 280.w, radius: 0),
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
          Spacer(),
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

  /// Matches [CreatedStoryReadingScreen]: hero overlays, scrollable body, bottom CTA.
  static Widget createdStoryReadingUIShimmer() {
    return const _CreatedStoryReadingScreenShimmer();
  }
}

/// Shimmer layout aligned with `CreatedStoryReadingScreen` (hero, overlays, body, CTA).
///
/// One [Shimmer.fromColors] per placeholder (same approach as the created ideas list
/// shimmer) so shapes stay visible instead of blending into one sheet.
class _CreatedStoryReadingScreenShimmer extends StatelessWidget {
  const _CreatedStoryReadingScreenShimmer();

  static Widget _block({
    required double width,
    required double height,
    double radius = 6,
    Color fill = AppColors.shimmerBaseColor,
  }) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 310.w,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Shimmer.fromColors(
                baseColor: AppColors.shimmerBaseColor,
                highlightColor: AppColors.shimmerHighlightColor,
                child: SizedBox.expand(
                  child: ColoredBox(color: AppColors.shimmerBaseColor),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 18.w, 14.w, 14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _block(
                        width: 36.w,
                        height: 36.w,
                        radius: 999,
                        fill: AppColors.white,
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _block(
                                  width: 250.w,
                                  height: 22.w,
                                  radius: 6,
                                  fill: AppColors.white,
                                ),
                                8.w.verticalSpace,
                                _block(
                                  width: 180.w,
                                  height: 22.w,
                                  radius: 6,
                                  fill: AppColors.white,
                                ),
                                10.w.verticalSpace,
                                Row(
                                  children: [
                                    _block(
                                      width: 78.w,
                                      height: 13.w,
                                      radius: 4,
                                      fill: AppColors.white,
                                    ),
                                    12.w.horizontalSpace,
                                    _block(
                                      width: 70.w,
                                      height: 13.w,
                                      radius: 4,
                                      fill: AppColors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          10.w.horizontalSpace,
                          _block(
                            width: 32.w,
                            height: 32.w,
                            radius: 999,
                            fill: AppColors.white,
                          ),
                          8.w.horizontalSpace,
                          _block(
                            width: 32.w,
                            height: 32.w,
                            radius: 999,
                            fill: AppColors.white,
                          ),
                          8.w.horizontalSpace,
                          _block(
                            width: 32.w,
                            height: 32.w,
                            radius: 999,
                            fill: AppColors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _block(width: double.infinity, height: 14.w, radius: 4),
                8.w.verticalSpace,
                _block(width: double.infinity, height: 14.w, radius: 4),
                8.w.verticalSpace,
                _block(width: 280.w, height: 14.w, radius: 4),
                8.w.verticalSpace,
                _block(width: 240.w, height: 14.w, radius: 4),
                20.w.verticalSpace,
                _block(width: double.infinity, height: 210.w, radius: 8),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, bottomInset + 15.w),
          child: _block(width: double.infinity, height: 48.w, radius: 999),
        ),
      ],
    );
  }
}

class _IdeasListScreenShimmer extends StatelessWidget {
  const _IdeasListScreenShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.w.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: _ShimmerBox(width: 180.w, height: 26.h, radius: 6),
            ),
            8.w.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: _ShimmerBox(width: 140.w, height: 18.h, radius: 5),
            ),
            20.w.verticalSpace,
            ...List.generate(4, (_) => const _IdeasListCardShimmer()),
            24.w.verticalSpace,
          ],
        ),
      ),
    );
  }
}

class _IdeasListCardShimmer extends StatelessWidget {
  const _IdeasListCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: AppColors.shimmerBaseColor,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(
              width: double.infinity,
              height: 200.w,
              radius: 0,
            ),
            Container(
              padding: EdgeInsets.all(16.w),
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: double.infinity, height: 20.h, radius: 6),
                  8.w.verticalSpace,
                  _ShimmerBox(width: double.infinity, height: 14.h, radius: 4),
                  8.w.verticalSpace,
                  _ShimmerBox(width: 120.w, height: 12.h, radius: 4),
                  14.w.verticalSpace,
                  _ShimmerBox(width: double.infinity, height: 44.h, radius: 999),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            _ShimmerBox(width: double.infinity, height: 280.w, radius: 0),
            16.w.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 220.w, height: 28.h, radius: 8),
                  12.w.verticalSpace,
                  _ShimmerBox(width: double.infinity, height: 14.h, radius: 6),
                  8.w.verticalSpace,
                  _ShimmerBox(width: 260.w, height: 14.h, radius: 6),
                  16.w.verticalSpace,
                  Row(
                    children: [
                      _ShimmerBox(width: 72.w, height: 28.h, radius: 8),
                      12.w.horizontalSpace,
                      _ShimmerBox(width: 64.w, height: 28.h, radius: 8),
                    ],
                  ),
                  20.w.verticalSpace,
                  _ShimmerBox(width: 56.w, height: 18.h, radius: 6),
                  12.w.verticalSpace,
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: List.generate(
                  3,
                  (_) => const _StoryIdeaTileShimmer(),
                ),
              ),
            ),
            24.w.verticalSpace,
          ],
        ),
      ),
    );
  }
}

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
            _ShimmerBox(width: double.infinity, height: 20.h, radius: 6),

            8.w.verticalSpace,

            _ShimmerBox(width: 100.w, height: 14.h, radius: 5),

            6.w.verticalSpace,

            _ShimmerBox(width: double.infinity, height: 14.h, radius: 5),
            5.w.verticalSpace,

            _ShimmerBox(width: double.infinity, height: 14.h, radius: 5),
            5.w.verticalSpace,

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
                _ShimmerBox(width: 58.w, height: 14.h, radius: 5),
              ],
            ),

            12.w.verticalSpace,

            Row(
              children: [
                _ShimmerBox(width: 13.w, height: 13.w, radius: 13),
                6.w.horizontalSpace,
                _ShimmerBox(width: 150.w, height: 12.h, radius: 5),
              ],
            ),

            5.w.verticalSpace,

            Row(
              children: [
                _ShimmerBox(width: 13.w, height: 13.w, radius: 4),
                6.w.horizontalSpace,
                _ShimmerBox(width: 140.w, height: 12.h, radius: 5),
              ],
            ),

            16.w.verticalSpace,

            _ShimmerBox(width: double.infinity, height: 46.h, radius: 30),
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
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StoryIdeasShimmerBox(
            width: double.infinity,
            height: 310.w,
            borderRadius: 0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                18.w.verticalSpace,
                const _StoryIdeasShimmerBox(
                  width: double.infinity,
                  height: 38,
                  borderRadius: 8,
                ),
                10.w.verticalSpace,
                Row(
                  children: const [
                    _StoryIdeasShimmerBox(
                      width: 84,
                      height: 28,
                      borderRadius: 999,
                    ),
                    SizedBox(width: 8),
                    _StoryIdeasShimmerBox(
                      width: 78,
                      height: 28,
                      borderRadius: 999,
                    ),
                  ],
                ),
                20.w.verticalSpace,
                const _StoryIdeasShimmerBox(
                  width: double.infinity,
                  height: 48,
                  borderRadius: 999,
                ),
                18.w.verticalSpace,
                Row(
                  children: const [
                    _StoryIdeasShimmerBox(
                      width: 80,
                      height: 44,
                      borderRadius: 8,
                    ),
                    SizedBox(width: 25),
                    _StoryIdeasShimmerBox(
                      width: 72,
                      height: 44,
                      borderRadius: 8,
                    ),
                  ],
                ),
                16.w.verticalSpace,
                const _StoryIdeasShimmerBox(
                  width: double.infinity,
                  height: 1,
                  borderRadius: 1,
                ),
                18.w.verticalSpace,
                const _StoryIdeasShimmerBox(
                  width: 180,
                  height: 18,
                  borderRadius: 6,
                ),
                18.w.verticalSpace,
                ...List.generate(4, (_) => const StoryIdeaEpisodeShimmer()),
              ],
            ),
          ),
        ],
      ),
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
    return Padding(
      padding: EdgeInsets.only(bottom: 18.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StoryIdeasShimmerBox(width: 122, height: 84, borderRadius: 16),
          12.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _StoryIdeasShimmerBox(
                  width: double.infinity,
                  height: 18,
                  borderRadius: 6,
                ),
                SizedBox(height: 8),
                _StoryIdeasShimmerBox(
                  width: double.infinity,
                  height: 14,
                  borderRadius: 6,
                ),
                SizedBox(height: 6),
                _StoryIdeasShimmerBox(width: 150, height: 14, borderRadius: 6),
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
