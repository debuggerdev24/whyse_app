import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:shimmer/shimmer.dart';

class SearchSectionShimmer {
  SearchSectionShimmer._();

  /// Single row shimmer for [SearchScreen] vertical list (thumbnail + title + play).
  static Widget searchResultRowShimmer() {
    return const SearchResultRowShimmer();
  }

  /// Vertical list of row shimmers for [SearchScreen] loading state.
  static Widget searchResultListShimmer({int itemCount = 8}) {
    return SearchResultListShimmer(itemCount: itemCount);
  }
}

/// Single row shimmer for [SearchScreen] vertical list (thumbnail + title + play).
class SearchResultRowShimmer extends StatelessWidget {
  const SearchResultRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.shimmerBaseColor,
            highlightColor: AppColors.shimmerHighlightColor,
            child: Container(
              width: 112.w,
              height: 84.w,
              decoration: BoxDecoration(
                color: AppColors.shimmerBaseColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          14.w.horizontalSpace,
          Expanded(
            child: Shimmer.fromColors(
              baseColor: AppColors.shimmerBaseColor,
              highlightColor: AppColors.shimmerHighlightColor,
              child: Container(
                height: 18.w,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBaseColor,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
            ),
          ),
          12.w.horizontalSpace,
          Shimmer.fromColors(
            baseColor: AppColors.shimmerBaseColor,
            highlightColor: AppColors.shimmerHighlightColor,
            child: Container(
              width: 44.r,
              height: 44.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.shimmerBaseColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical list of [SearchResultRowShimmer] for [SearchScreen] loading state.
class SearchResultListShimmer extends StatelessWidget {
  final int itemCount;

  const SearchResultListShimmer({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        itemCount,
        (_) => const SearchResultRowShimmer(),
      ),
    );
  }
}
