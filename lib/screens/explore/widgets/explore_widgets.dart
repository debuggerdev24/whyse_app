import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/curiosity_reading/curiosity_reading_model.dart';
import 'package:redstreakapp/models/home/browse_topic_model.dart';
import 'package:redstreakapp/models/home/interest_model.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/screens/explore/explore_constants.dart';
import 'package:redstreakapp/screens/explore/explore_spark_dummy_data.dart';
import 'package:redstreakapp/screens/search/widgets/search_widgets.dart';

class ExploreSearchField extends StatefulWidget {
  const ExploreSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  State<ExploreSearchField> createState() => _ExploreSearchFieldState();
}

class _ExploreSearchFieldState extends State<ExploreSearchField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleStateChanged);
    widget.controller.addListener(_handleStateChanged);
  }

  @override
  void didUpdateWidget(covariant ExploreSearchField oldWidget) {
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
        : AppColors.black.setOpacity(0.4);

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      cursorColor: AppColors.black,
      style: AppTextStyles.medium(fontSize: 14.sp, color: AppColors.black),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        hintText: 'What book are you looking for?',
        hintStyle: AppTextStyles.medium(
          fontSize: 14.sp,
          color: AppColors.black.setOpacity(0.4),
        ),
        filled: true,
        fillColor: AppColors.searchBackgroundColor,
        suffixIcon: widget.controller.text.trim().isEmpty
            ? Padding(
                padding: EdgeInsets.only(right: 15.w, top: 10.w, bottom: 10.w),
                child: SvgIcon(
                  AppAssets.searchIcon,
                  color: iconColor,
                  size: 24.sp,
                ),
              )
            : GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.onChanged('');
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 15.w,
                    top: 10.w,
                    bottom: 10.w,
                  ),
                  child: SvgIcon(AppAssets.closeFilled, size: 20.sp),
                ),
              ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: AppColors.searchBackgroundColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: AppColors.black, width: 1.2),
        ),
      ),
    );
  }
}

class ExploreTabBar extends StatelessWidget {
  const ExploreTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final ExploreMainTab selectedTab;
  final ValueChanged<ExploreMainTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _ExploreTabItem(
              label: 'Series',
              isSelected: selectedTab == ExploreMainTab.series,
              onTap: () => onTabChanged(ExploreMainTab.series),
            ),
            28.w.horizontalSpace,
            _ExploreTabItem(
              label: 'Spark',
              isSelected: selectedTab == ExploreMainTab.spark,
              onTap: () => onTabChanged(ExploreMainTab.spark),
            ),
          ],
        ),
        10.w.verticalSpace,
        Container(
          height: 1,
          width: double.infinity,
          color: AppColors.black.withValues(alpha: 0.1),
        ),
      ],
    );
  }
}

class _ExploreTabItem extends StatelessWidget {
  const _ExploreTabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: label,
            style: AppTextStyles.bold(
              fontSize: 18.sp,
              color: isSelected
                  ? AppColors.teal
                  : AppColors.black.withValues(alpha: 0.35),
            ),
          ),
          8.w.verticalSpace,
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3.h,
            width: isSelected ? 52.w : 0,
            decoration: BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreDiscoverByInterest extends StatelessWidget {
  const ExploreDiscoverByInterest({
    super.key,
    required this.selectedInterests,
    required this.onInterestToggled,
  });

  final Set<String> selectedInterests;
  final ValueChanged<String> onInterestToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Discover by interest',
          style: AppTextStyles.bold(fontSize: 20.sp),
        ),
        14.w.verticalSpace,
        Consumer<StoryProvider>(
          builder: (context, provider, _) {
            if (provider.isGetInterestLoading && provider.interestsList.isEmpty) {
              return const ExploreInterestTwoRowShimmer();
            }

            final interests = provider.interestsList;
            if (interests.isEmpty) {
              return AppText(
                text: 'No interests available',
                style: AppTextStyles.medium(
                  fontSize: 14.sp,
                  color: AppColors.black.withValues(alpha: 0.5),
                ),
              );
            }

            return ExploreInterestTwoRowScroller(
              interests: interests,
              selectedInterests: selectedInterests,
              onInterestToggled: onInterestToggled,
            );
          },
        ),
      ],
    );
  }
}

class ExploreInterestTwoRowScroller extends StatelessWidget {
  const ExploreInterestTwoRowScroller({
    super.key,
    required this.interests,
    required this.selectedInterests,
    required this.onInterestToggled,
  });

  final List<InterestModel> interests;
  final Set<String> selectedInterests;
  final ValueChanged<String> onInterestToggled;

  @override
  Widget build(BuildContext context) {
    final topRow = <InterestModel>[
      for (var i = 0; i < interests.length; i += 2) interests[i],
    ];
    final bottomRow = <InterestModel>[
      for (var i = 1; i < interests.length; i += 2) interests[i],
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InterestRow(
            interests: topRow,
            selectedInterests: selectedInterests,
            onInterestToggled: onInterestToggled,
          ),
          if (bottomRow.isNotEmpty) ...[
            10.h.verticalSpace,
            _InterestRow(
              interests: bottomRow,
              selectedInterests: selectedInterests,
              onInterestToggled: onInterestToggled,
            ),
          ],
        ],
      ),
    );
  }
}

class _InterestRow extends StatelessWidget {
  const _InterestRow({
    required this.interests,
    required this.selectedInterests,
    required this.onInterestToggled,
  });

  final List<InterestModel> interests;
  final Set<String> selectedInterests;
  final ValueChanged<String> onInterestToggled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < interests.length; i++) ...[
          if (i > 0) 10.w.horizontalSpace,
          ExploreInterestTile(
            label: interests[i].name,
            iconPath: iconForInterestName(interests[i].name),
            isSelected: selectedInterests.contains(interests[i].name),
            onTap: () => onInterestToggled(interests[i].name),
          ),
        ],
      ],
    );
  }
}

class ExploreInterestTile extends StatelessWidget {
  const ExploreInterestTile({
    super.key,
    required this.label,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.teal.withValues(alpha: 0.12)
              : AppColors.extealighttealcolor,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? AppColors.teal
                : AppColors.extealighttealcolor,
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(iconPath, size: 24.w),
            8.w.horizontalSpace,
            AppText(
              text: label,
              style: AppTextStyles.semibold(
                fontSize: 14.sp,
                color: AppColors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreInterestTwoRowShimmer extends StatelessWidget {
  const ExploreInterestTwoRowShimmer({super.key});

  static const _pillWidths = [148.0, 120.0, 164.0, 132.0];

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) 10.w.horizontalSpace,
                  AppSkeletonBox(
                    width: _pillWidths[i],
                    height: 40,
                    borderRadius: 9999,
                  ),
                ],
              ],
            ),
            10.h.verticalSpace,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) 10.w.horizontalSpace,
                  AppSkeletonBox(
                    width: _pillWidths[i + 1],
                    height: 40,
                    borderRadius: 9999,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreFilteredEmptyState extends StatelessWidget {
  const ExploreFilteredEmptyState({
    super.key,
    required this.interestLabels,
    required this.onClearFilter,
  });

  final List<String> interestLabels;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    final query = interestLabels.join(', ');

    return Column(
      children: [
        BrowseEmptyState(query: query),
        12.w.verticalSpace,
        GestureDetector(
          onTap: onClearFilter,
          child: AppText(
            text: 'Show all interests',
            style: AppTextStyles.semibold(
              fontSize: 15.sp,
              color: AppColors.teal,
            ),
          ),
        ),
      ],
    );
  }
}

class ExploreHorizontalSection extends StatelessWidget {
  const ExploreHorizontalSection({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: title,
          style: AppTextStyles.bold(fontSize: 20.sp),
        ),
        14.w.verticalSpace,
        child,
      ],
    );
  }
}

class ExploreSeriesCard extends StatelessWidget {
  const ExploreSeriesCard({
    super.key,
    required this.topic,
    required this.onTap,
  });

  final BrowseTopicModel topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitleColor = AppColors.black.withValues(alpha: 0.45);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220.w,
        margin: EdgeInsets.all( 5.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 5,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150.w,
              child: topic.hasThumbnail
                  ? AppNetworkImage(
                      imageUrl: topic.thumbnailUrl,
                      tag: 'Explore.seriesCard',
                      placeholder: (_) => const AppSkeletonImagePlaceholder(),
                      errorCompact: true,
                    )
                  : FallbackTopicArt(
                      topic: topic,
                      colors: const [AppColors.teal, AppColors.bluecolor],
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.w, 16.w, 4.w),
              child: AppText(
                text: topic.topic,
                style: AppTextStyles.bold(fontSize: 17.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
              child: AppText(
                text: seriesReadingsLabel(topic),
                style: AppTextStyles.medium(
                  fontSize: 13.sp,
                  color: subtitleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreSparkArticleCard extends StatelessWidget {
  const ExploreSparkArticleCard({
    super.key,
    required this.item,
    required this.onTap,
    this.cardWidth,
    this.cardHeight,
  });

  final ExploreSparkItem item;
  final VoidCallback onTap;
  final double? cardWidth;
  final double? cardHeight;

  @override
  Widget build(BuildContext context) {
    final width = cardWidth ?? 260.w;
    final height = cardHeight ?? 280.w;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.only(right: 14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.setOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(
                imageUrl: item.imageUrl,
                tag: 'Explore.sparkArticle',
                placeholder: (_) => const AppSkeletonImagePlaceholder(),
                errorCompact: true,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.setOpacity(0.65),
                    ],
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: Colors.black.setOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(4.w),
                  child: SvgIcon(
                    AppAssets.brain,
                    size: 22.w,
                    color: AppColors.white,
                  ),
                ),
              ),
              Positioned(
                left: 14.w,
                right: 14.w,
                bottom: 14.h,
                child: AppText(
                  text: item.question,
                  style: AppTextStyles.bold(
                    fontSize: 16.sp,
                    height: 1.3,
                    color: AppColors.white,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExploreSparkCard extends StatelessWidget {
  const ExploreSparkCard({
    super.key,
    required this.reading,
    required this.onTap,
  });

  final Reading reading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150.w,
              child: AppNetworkImage(
                imageUrl: reading.imgUrl,
                tag: 'Explore.sparkCard',
                placeholder: (_) => const AppSkeletonImagePlaceholder(),
                errorCompact: true,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.w, 16.w, 4.w),
              child: AppText(
                text: reading.title,
                style: AppTextStyles.bold(fontSize: 17.sp),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
              child: AppText(
                text: reading.interestName,
                style: AppTextStyles.medium(
                  fontSize: 13.sp,
                  color: AppColors.black.withValues(alpha: 0.45),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreSeriesRow extends StatelessWidget {
  const ExploreSeriesRow({
    super.key,
    required this.topics,
    required this.onTopicTap,
  });

  final List<BrowseTopicModel> topics;
  final ValueChanged<BrowseTopicModel> onTopicTap;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 232.w,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return ExploreSeriesCard(
            topic: topic,
            onTap: () => onTopicTap(topic),
          );
        },
      ),
    );
  }
}

class ExploreSparkItemsRow extends StatelessWidget {
  const ExploreSparkItemsRow({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  final List<ExploreSparkItem> items;
  final ValueChanged<ExploreSparkItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 280.w,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ExploreSparkArticleCard(
            item: item,
            onTap: () => onItemTap(item),
          );
        },
      ),
    );
  }
}

class ExploreSparkRow extends StatelessWidget {
  const ExploreSparkRow({
    super.key,
    required this.readings,
    required this.onReadingTap,
  });

  final List<Reading> readings;
  final void Function(Reading reading, int index) onReadingTap;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 232.w,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: readings.length,
        itemBuilder: (context, index) {
          final reading = readings[index];
          return ExploreSparkCard(
            reading: reading,
            onTap: () => onReadingTap(reading, index),
          );
        },
      ),
    );
  }
}

class ExploreSparkContentShimmer extends StatelessWidget {
  const ExploreSparkContentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeletonBox(width: 90, height: 20),
          14.w.verticalSpace,
          SizedBox(
            height: 280.w,
            child: Row(
              children: [
                AppSkeletonBox(width: 260, height: 280, borderRadius: 24),
                14.w.horizontalSpace,
                AppSkeletonBox(width: 260, height: 280, borderRadius: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreContentShimmer extends StatelessWidget {
  const ExploreContentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeletonBox(width: 180, height: 20),
          14.w.verticalSpace,
          const ExploreInterestTwoRowShimmer(),
          28.w.verticalSpace,
          const AppSkeletonBox(width: 90, height: 20),
          14.w.verticalSpace,
          SizedBox(
            height: 232.w,
            child: Row(
              children: [
                Expanded(
                  child: AppSkeletonBox(
                    width: double.infinity,
                    height: 232,
                    borderRadius: 24,
                  ),
                ),
                16.w.horizontalSpace,
                Expanded(
                  child: AppSkeletonBox(
                    width: double.infinity,
                    height: 232,
                    borderRadius: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
