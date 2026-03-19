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
        20.w.verticalSpace,
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
                10.w.verticalSpace,
                const _StoryIdeasShimmerBox(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 6,
                ),
                6.w.verticalSpace,
                const _StoryIdeasShimmerBox(
                  width: double.infinity,
                  height: 14,
                  borderRadius: 6,
                ),
                6.w.verticalSpace,
                const _StoryIdeasShimmerBox(
                  width: 170,
                  height: 14,
                  borderRadius: 6,
                ),
                10.w.verticalSpace,
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
                12.w.verticalSpace,
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
