import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/models/curiosity_reading/curiosity_reading_model.dart';
import 'package:redstreakapp/models/explore/explore_models.dart';
import 'package:redstreakapp/models/home/browse_topic_model.dart';
import 'package:redstreakapp/providers/explore/explore_provider.dart';
import 'package:redstreakapp/screens/explore/explore_constants.dart';
import 'package:redstreakapp/screens/search/widgets/search_widgets.dart';

double exploreSeriesCardHeight(BuildContext context) {
  final textScaler = MediaQuery.textScalerOf(context);
  final titleLine = textScaler.scale(17.sp) * 1.2;
  final subtitleLine = textScaler.scale(13.sp) * 1.2;
  return 150.w + 12.h + 4.h + titleLine + 14.h + subtitleLine + 6.h;
}

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
    required this.selectedInterestIds,
    required this.onInterestToggled,
  });

  final Set<String> selectedInterestIds;
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
        Consumer<ExploreProvider>(
          builder: (context, provider, _) {
            if (provider.interestsState == DataState.loading &&
                provider.interests.isEmpty) {
              return const ExploreInterestTwoRowShimmer();
            }

            if (provider.interestsState == DataState.failed &&
                provider.interests.isEmpty) {
              return ExploreInlineError(
                message: provider.interestsError ??
                    'Could not load interests. Please try again.',
                onRetry: () => provider.loadDiscoverInterests(force: true),
              );
            }

            final interests = provider.interests;
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
              selectedInterestIds: selectedInterestIds,
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
    required this.selectedInterestIds,
    required this.onInterestToggled,
  });

  final List<ExploreDiscoverInterest> interests;
  final Set<String> selectedInterestIds;
  final ValueChanged<String> onInterestToggled;

  @override
  Widget build(BuildContext context) {
    final topRow = <ExploreDiscoverInterest>[
      for (var i = 0; i < interests.length; i += 2) interests[i],
    ];
    final bottomRow = <ExploreDiscoverInterest>[
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
            selectedInterestIds: selectedInterestIds,
            onInterestToggled: onInterestToggled,
          ),
          if (bottomRow.isNotEmpty) ...[
            10.h.verticalSpace,
            _InterestRow(
              interests: bottomRow,
              selectedInterestIds: selectedInterestIds,
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
    required this.selectedInterestIds,
    required this.onInterestToggled,
  });

  final List<ExploreDiscoverInterest> interests;
  final Set<String> selectedInterestIds;
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
            isSelected: selectedInterestIds.contains(interests[i].id),
            onTap: () => onInterestToggled(interests[i].id),
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

class ExploreInlineError extends StatelessWidget {
  const ExploreInlineError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.searchBackgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          AppText(
            text: message,
            textAlign: TextAlign.center,
            style: AppTextStyles.medium(
              fontSize: 14.sp,
              color: AppColors.black.withValues(alpha: 0.65),
            ),
          ),
          12.w.verticalSpace,
          GestureDetector(
            onTap: onRetry,
            child: AppText(
              text: 'Retry',
              style: AppTextStyles.semibold(
                fontSize: 15.sp,
                color: AppColors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreSectionEmpty extends StatelessWidget {
  const ExploreSectionEmpty({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.searchBackgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: AppText(
        text: 'No $title items yet',
        textAlign: TextAlign.center,
        style: AppTextStyles.medium(
          fontSize: 14.sp,
          color: AppColors.black.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class ExploreSeriesSectionView extends StatelessWidget {
  const ExploreSeriesSectionView({
    super.key,
    required this.section,
    required this.onTopicTap,
    required this.onRetry,
    required this.onLoadMore,
  });

  final ExplorePagedSection<BrowseTopicModel> section;
  final ValueChanged<BrowseTopicModel> onTopicTap;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return ExploreHorizontalSection(
      title: section.title,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (section.state == DataState.loading && section.items.isEmpty) {
      return const ExploreSeriesRowShimmer();
    }

    if (section.state == DataState.failed && section.items.isEmpty) {
      return ExploreInlineError(
        message: section.error ?? 'Something went wrong. Please try again.',
        onRetry: onRetry,
      );
    }

    if (section.items.isEmpty) {
      return ExploreSectionEmpty(title: section.title);
    }

    return ExploreSeriesRow(
      topics: section.items,
      onTopicTap: onTopicTap,
      isLoadingMore: section.isLoadingMore,
      hasMore: section.hasMore,
      onLoadMore: onLoadMore,
    );
  }
}

class ExploreSparkSectionView extends StatelessWidget {
  const ExploreSparkSectionView({
    super.key,
    required this.section,
    required this.onItemTap,
    required this.onRetry,
    required this.onLoadMore,
  });

  final ExplorePagedSection<ExploreSparkItem> section;
  final void Function(ExploreSparkItem item, int index) onItemTap;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return ExploreHorizontalSection(
      title: section.title,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (section.state == DataState.loading && section.items.isEmpty) {
      return const ExploreSparkRowShimmer();
    }

    if (section.state == DataState.failed && section.items.isEmpty) {
      return ExploreInlineError(
        message: section.error ?? 'Something went wrong. Please try again.',
        onRetry: onRetry,
      );
    }

    if (section.items.isEmpty) {
      return ExploreSectionEmpty(title: section.title);
    }

    return ExploreSparkItemsRow(
      items: section.items,
      onItemTap: onItemTap,
      isLoadingMore: section.isLoadingMore,
      hasMore: section.hasMore,
      onLoadMore: onLoadMore,
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
        margin: EdgeInsets.only(right: 14.w),
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
          mainAxisSize: MainAxisSize.min,
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
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
              child: AppText(
                text: topic.topic,
                style: AppTextStyles.bold(fontSize: 17.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
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

class ExploreSeriesRow extends StatefulWidget {
  const ExploreSeriesRow({
    super.key,
    required this.topics,
    required this.onTopicTap,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.onLoadMore,
  });

  final List<BrowseTopicModel> topics;
  final ValueChanged<BrowseTopicModel> onTopicTap;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  @override
  State<ExploreSeriesRow> createState() => _ExploreSeriesRowState();
}

class _ExploreSeriesRowState extends State<ExploreSeriesRow> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!widget.hasMore || widget.isLoadingMore || widget.onLoadMore == null) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.topics.isEmpty) return const SizedBox.shrink();

    final itemCount =
        widget.topics.length + (widget.isLoadingMore ? 1 : 0);
    final rowHeight = exploreSeriesCardHeight(context);

    return SizedBox(
      height: rowHeight,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index >= widget.topics.length) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.teal,
                  ),
                ),
              ),
            );
          }

          final topic = widget.topics[index];
          return ExploreSeriesCard(
            topic: topic,
            onTap: () => widget.onTopicTap(topic),
          );
        },
      ),
    );
  }
}

class ExploreSparkItemsRow extends StatefulWidget {
  const ExploreSparkItemsRow({
    super.key,
    required this.items,
    required this.onItemTap,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.onLoadMore,
  });

  final List<ExploreSparkItem> items;
  final void Function(ExploreSparkItem item, int index) onItemTap;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  @override
  State<ExploreSparkItemsRow> createState() => _ExploreSparkItemsRowState();
}

class _ExploreSparkItemsRowState extends State<ExploreSparkItemsRow> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!widget.hasMore || widget.isLoadingMore || widget.onLoadMore == null) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final itemCount = widget.items.length + (widget.isLoadingMore ? 1 : 0);

    return SizedBox(
      height: 280.w,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            return Padding(
              padding: EdgeInsets.only(right: 14.w),
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.teal,
                  ),
                ),
              ),
            );
          }

          final item = widget.items[index];
          return ExploreSparkArticleCard(
            item: item,
            onTap: () => widget.onItemTap(item, index),
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

class ExploreSparkRowShimmer extends StatelessWidget {
  const ExploreSparkRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: SizedBox(
        height: 280.w,
        child: Row(
          children: [
            AppSkeletonBox(width: 260, height: 280, borderRadius: 24),
            14.w.horizontalSpace,
            AppSkeletonBox(width: 260, height: 280, borderRadius: 24),
          ],
        ),
      ),
    );
  }
}

class ExploreSeriesRowShimmer extends StatelessWidget {
  const ExploreSeriesRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final rowHeight = exploreSeriesCardHeight(context);

    return AppSkeletonizer(
      child: SizedBox(
        height: rowHeight,
        child: Row(
          children: [
            AppSkeletonBox(width: 220, height: rowHeight, borderRadius: 24),
            16.w.horizontalSpace,
            AppSkeletonBox(width: 220, height: rowHeight, borderRadius: 24),
          ],
        ),
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
          const ExploreSeriesRowShimmer(),
          28.w.verticalSpace,
          const AppSkeletonBox(width: 90, height: 20),
          14.w.verticalSpace,
          const ExploreSeriesRowShimmer(),
        ],
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
          const ExploreSparkRowShimmer(),
        ],
      ),
    );
  }
}
