import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/models/home/browse_topic_model.dart';
import 'package:shimmer/shimmer.dart';

class BrowseSearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const BrowseSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<BrowseSearchField> createState() => _BrowseSearchFieldState();
}

class _BrowseSearchFieldState extends State<BrowseSearchField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleStateChanged);
    widget.controller.addListener(_handleStateChanged);
  }

  @override
  void didUpdateWidget(covariant BrowseSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleStateChanged);
      widget.controller.addListener(_handleStateChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleStateChanged);
    _focusNode
      ..removeListener(_handleStateChanged)
      ..dispose();
    super.dispose();
  }

  void _handleStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFocus = _focusNode.hasFocus;
    final Color iconColor = hasFocus
        ? AppColors.black
        : AppColors.black.withValues(alpha: 0.45);

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      cursorColor: AppColors.black,
      style: AppTextStyles.sfProDisplayRegular(
        color: AppColors.black,
        fontSize: 16.sp,
      ),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        hintText: "Search topics, animals, science, nature...",
        hintStyle: AppTextStyles.sfProDisplayMedium(
          fontSize: 15.sp,
          color: AppColors.black.withValues(alpha: 0.35),
        ),
        filled: true,
        fillColor: AppColors.white,
        prefixIcon: Icon(Icons.search_rounded, color: iconColor, size: 22.sp),
        suffixIcon: widget.controller.text.trim().isEmpty
            ? null
            : GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.onChanged("");
                  FocusScope.of(context).unfocus();
                },
                child: Icon(
                  Icons.close_rounded,
                  color: iconColor,
                  size: 20.sp,
                ),
              ),
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide(
            color: AppColors.black.withValues(alpha: 0.12),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide(color: AppColors.black, width: 1.4),
        ),
      ),
    );
  }
}

class FeaturedTopicCard extends StatelessWidget {
  final BrowseTopicModel topic;
  final VoidCallback onTap;
  final VoidCallback? onToggleMyList;
  final bool isToggleLoading;

  const FeaturedTopicCard({
    super.key,
    required this.topic,
    required this.onTap,
    this.onToggleMyList,
    this.isToggleLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: SizedBox(
          height: 310.h,
          child: Stack(
            children: [
              Positioned.fill(child: TopicArt(topic: topic)),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.82),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16.h,
                left: 16.w,
                child: TopBadge(label: topic.creatorLabel),
              ),
              Positioned(
                top: 16.h,
                right: 16.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: AppText(
                        text: topic.storiesCountLabel,
                        style: AppTextStyles.sfProDisplaySemibold(
                          fontSize: 12.sp,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    if (onToggleMyList != null) ...[
                      10.h.verticalSpace,
                      TopicListToggleButton(
                        isInMyList: topic.isInMyList,
                        isLoading: isToggleLoading,
                        onTap: onToggleMyList,
                        darkMode: true,
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 18.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: topic.topic,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sfProDisplayBold(
                        fontSize: 28.sp,
                        height: 1.1,
                        color: AppColors.white,
                      ),
                    ),
                    10.h.verticalSpace,
                    AppText(
                      text: topic.learningGoal,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sfProDisplayMedium(
                        fontSize: 14.sp,
                        height: 1.4,
                        color: AppColors.white.withValues(alpha: 0.84),
                      ),
                    ),
                    14.h.verticalSpace,
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: topic.interests
                          .take(3)
                          .map(
                            (interest) => GlassChip(
                              label: interest,
                              textColor: AppColors.white,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PosterTopicCard extends StatelessWidget {
  final BrowseTopicModel topic;
  final VoidCallback onTap;
  final VoidCallback? onToggleMyList;
  final bool isToggleLoading;

  const PosterTopicCard({
    super.key,
    required this.topic,
    required this.onTap,
    this.onToggleMyList,
    this.isToggleLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children:[
            Positioned.fill(child: TopicArt(topic: topic)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.20),
                      Colors.black.withValues(alpha: 0.86),
                    ],
                  ),
                ),
              ),
            ),
            if (onToggleMyList != null)
              Positioned(
                top: 12.h,
                right: 12.w,
                child: TopicListToggleButton(
                  isInMyList: topic.isInMyList,
                  isLoading: isToggleLoading,
                  onTap: onToggleMyList,
                  compact: true,
                  darkMode: true,
                ),
              ),
            Positioned(
              left: 14.w,
              right: 14.w,
              bottom: 16.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: topic.topic,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sfProDisplayBold(
                      fontSize: 18.sp,
                      height: 1.15,
                      color: AppColors.white,
                    ),
                  ),
                  10.h.verticalSpace,
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      GlassChip(
                        label: topic.storiesCountLabel,
                        textColor: AppColors.white,
                      ),
                      if (topic.interests.isNotEmpty)
                        GlassChip(
                          label: topic.interests.first,
                          textColor: AppColors.white,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrowseTopicDetailsSheet extends StatelessWidget {
  final BrowseTopicModel topic;

  const BrowseTopicDetailsSheet({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            18.h.verticalSpace,
            AppText(
              text: topic.topic,
              style: AppTextStyles.sfProDisplayBold(fontSize: 24.sp),
            ),
            8.h.verticalSpace,
            AppText(
              text: topic.learningGoal,
              style: AppTextStyles.sfProDisplayMedium(
                fontSize: 15.sp,
                height: 1.5,
                color: AppColors.black.withValues(alpha: 0.78),
              ),
            ),
            18.h.verticalSpace,
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                InfoPill(label: topic.creatorLabel),
                InfoPill(label: topic.storiesCountLabel),
                InfoPill(label: topic.generatedCountLabel),
              ],
            ),
            if (topic.interests.isNotEmpty) ...[
              18.h.verticalSpace,
              AppText(
                text: "Categories",
                style: AppTextStyles.sfProDisplaySemibold(fontSize: 16.sp),
              ),
              10.h.verticalSpace,
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: topic.interests
                    .map((interest) => InterestChip(label: interest))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TopicArt extends StatelessWidget {
  final BrowseTopicModel topic;

  const TopicArt({super.key, required this.topic});

  List<Color> _paletteForTopic() {
    final palettes = [
      [AppColors.black, AppColors.teal],
      [AppColors.bluecolor, AppColors.teal],
      [AppColors.primaryColor, AppColors.teal],
      [AppColors.black, AppColors.primaryColor],
    ];

    return palettes[topic.topic.hashCode.abs() % palettes.length];
  }

  @override
  Widget build(BuildContext context) {
    if (topic.hasThumbnail) {
      return CachedNetworkImage(
        imageUrl: topic.thumbnailUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const ImageShimmer(),
        errorWidget: (context, url, error) => FallbackTopicArt(
          topic: topic,
          colors: _paletteForTopic(),
        ),
      );
    }

    return FallbackTopicArt(topic: topic, colors: _paletteForTopic());
  }
}

class FallbackTopicArt extends StatelessWidget {
  final BrowseTopicModel topic;
  final List<Color> colors;

  const FallbackTopicArt({
    super.key,
    required this.topic,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_stories_rounded,
          color: AppColors.white.withValues(alpha: 0.85),
          size: 42.sp,
        ),
      ),
    );
  }
}

class TopBadge extends StatelessWidget {
  final String label;

  const TopBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.15)),
      ),
      child: AppText(
        text: label,
        style: AppTextStyles.sfProDisplaySemibold(
          fontSize: 12.sp,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class TopicListToggleButton extends StatelessWidget {
  final bool isInMyList;
  final bool isLoading;
  final VoidCallback? onTap;
  final bool compact;
  final bool darkMode;

  const TopicListToggleButton({
    super.key,
    required this.isInMyList,
    required this.isLoading,
    required this.onTap,
    this.compact = false,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isInMyList
        ? AppColors.teal
        : darkMode
        ? AppColors.white.withValues(alpha: 0.16)
        : AppColors.white;
    final Color borderColor = isInMyList
        ? AppColors.teal
        : darkMode
        ? AppColors.white.withValues(alpha: 0.20)
        : AppColors.black.withValues(alpha: 0.12);
    final Color foregroundColor = isInMyList
        ? AppColors.white
        : darkMode
        ? AppColors.white
        : AppColors.black;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9.w : 10.w,
          vertical: compact ? 6.w : 7.w,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: isLoading
            ? SizedBox(
                width: compact ? 16.w : 18.w,
                height: compact ? 16.w : 18.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isInMyList
                        ? Icons.check_rounded
                        : Icons.add_rounded,
                    size: compact ? 16.sp : 18.sp,
                    color: foregroundColor,
                  ),
                  if (!compact) ...[
                    6.w.horizontalSpace,
                    AppText(
                      text: isInMyList ? "Added" : "Add",
                      style: AppTextStyles.sfProDisplaySemibold(
                        fontSize: 12.sp,
                        color: foregroundColor,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class GlassChip extends StatelessWidget {
  final String label;
  final Color textColor;

  const GlassChip({
    super.key,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
      ),
      child: AppText(
        text: '${label.split(' ')[0]} Stories',

        style: AppTextStyles.sfProDisplaySemibold(
          fontSize: 12.sp,
          color: textColor,
        ),
      ),
    );
  }
}

class InterestChip extends StatelessWidget {
  final String label;

  const InterestChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.extealighttealcolor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: AppText(
        text: label,
        style: AppTextStyles.sfProDisplaySemibold(
          fontSize: 12.sp,
          color: AppColors.teal,
        ),
      ),
    );
  }
}

class InfoPill extends StatelessWidget {
  final String label;

  const InfoPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: AppText(
        text: label,
        style: AppTextStyles.sfProDisplaySemibold(
          fontSize: 13.sp,
          color: AppColors.black.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

class BrowseEmptyState extends StatelessWidget {
  final String query;

  const BrowseEmptyState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 44.sp,
            color: AppColors.teal,
          ),
          14.h.verticalSpace,
          AppText(
            text: "No topics found",
            style: AppTextStyles.sfProDisplayBold(fontSize: 20.sp),
          ),
          8.h.verticalSpace,
          AppText(
            text: query.isEmpty
                ? "There are no topics to show right now. Pull to refresh and try again."
                : 'No matches found for "$query". Try a different keyword.',
            textAlign: TextAlign.center,
            style: AppTextStyles.sfProDisplayMedium(
              fontSize: 14.sp,
              height: 1.45,
              color: AppColors.black.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

class BrowseErrorState extends StatelessWidget {
  final Future<void> Function({bool showLoader}) onRetry;

  const BrowseErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 42.sp,
            color: AppColors.primaryColor,
          ),
          14.h.verticalSpace,
          AppText(
            text: "Something went wrong",
            style: AppTextStyles.sfProDisplayBold(fontSize: 20.sp),
          ),
          8.h.verticalSpace,
          AppText(
            text: "Please check your connection and try again.",
            textAlign: TextAlign.center,
            style: AppTextStyles.sfProDisplayMedium(
              fontSize: 14.sp,
              height: 1.45,
              color: AppColors.black.withValues(alpha: 0.65),
            ),
          ),
          18.h.verticalSpace,
          GestureDetector(
            onTap: () => onRetry(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(999),
              ),
              child: AppText(
                text: "Try Again",
                style: AppTextStyles.sfProDisplaySemibold(
                  fontSize: 14.sp,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BrowseSearchShimmer extends StatelessWidget {
  const BrowseSearchShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BrowseShimmerBox(width: 130, height: 18, borderRadius: 999),
        12.h.verticalSpace,
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: const [
            _BrowseShimmerBox(width: 78, height: 36, borderRadius: 999),
            _BrowseShimmerBox(width: 112, height: 36, borderRadius: 999),
            _BrowseShimmerBox(width: 96, height: 36, borderRadius: 999),
          ],
        ),
        20.h.verticalSpace,
        _BrowseShimmerBox(
          width: double.infinity,
          height: 310.h,
          borderRadius: 28,
        ),
        24.h.verticalSpace,
        const _BrowseShimmerBox(width: 142, height: 18, borderRadius: 999),
        14.h.verticalSpace,
        SizedBox(
          height: 248.h,
          child: Row(
            children: [
              Expanded(
                child: _BrowseShimmerBox(
                  width: double.infinity,
                  height: 248.h,
                  borderRadius: 24,
                ),
              ),
              14.w.horizontalSpace,
              Expanded(
                child: _BrowseShimmerBox(
                  width: double.infinity,
                  height: 248.h,
                  borderRadius: 24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BrowsePaginationShimmer extends StatelessWidget {
  const BrowsePaginationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 14.h,
        childAspectRatio: 0.75,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _BrowseShimmerBox(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 24,
        );
      },
    );
  }
}

class BrowsePosterShimmerTile extends StatelessWidget {
  const BrowsePosterShimmerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BrowseShimmerBox(
      width: double.infinity,
      height: double.infinity,
      borderRadius: 24,
    );
  }
}

class ImageShimmer extends StatelessWidget {
  const ImageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: const ColoredBox(color: AppColors.lightwhiteColor),
    );
  }
}

class _BrowseShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _BrowseShimmerBox({
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
