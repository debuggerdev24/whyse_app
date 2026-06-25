import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/home/continue_reading_item_model.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';

/// Card width (matches Series [StoryCard]) + trailing gap between slots.
double _continueReadingSlotExtent() => 210.w + 10.w;

class ContinueReadingSection extends StatefulWidget {
  const ContinueReadingSection({super.key});

  @override
  State<ContinueReadingSection> createState() => _ContinueReadingSectionState();
}

class _ContinueReadingSectionState extends State<ContinueReadingSection>
    with RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeProvider>().getContinueReading();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      AppRouter.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AppRouter.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // We returned to Home from another screen (reader / ideas etc).
    // Re-fetch to keep the shelf fresh.
    if (!mounted) return;
    context.read<HomeProvider>().getContinueReading(force: true);
  }

  Future<void> _openContinueReading(
    BuildContext context,
    ContinueReadingItemModel item,
  ) async {
    final storyProvider = context.read<StoryProvider>();

    // Navigate immediately; the reading screen already shows a shimmer while
    // story data is loading.
    storyProvider.clareStoryData();
    if (!context.mounted) return;
    context
        .pushNamed(
          AppRoutes.createdStoryReadingScreen.name,
          extra: <String, dynamic>{
            "storyIdeaId": item.storyIdeaId,
            "initialPageIndex": item.continueFromPageIndex,
            "initialConfirmedPageIndex": item.lastPageIndex,
            "fromContinueReading": true,
            "continueReadingTopicId": item.topic.id,
            "resumeStoryIsGenerated": item.isGenerated,
          },
        )
        .then((_) {
          if (!mounted) return;
          context.read<HomeProvider>().getContinueReading(force: true);
        });
  }

  void _openTopicDetails(BuildContext context, ContinueReadingItemModel item) {
    final topicId = item.topic.id;
    if (topicId.isEmpty) return;
    final hp = context.read<HomeProvider>();
    hp.beginTopicStoryDetailsLoad(topicId: topicId);
    hp.getTopicStoryDetails(topicId: topicId);
    if (!context.mounted) return;
    context
        .pushNamed(AppRoutes.createdStorySummaryScreen.name, extra: topicId)
        .then((_) {
          if (!context.mounted) return;
          hp.getContinueReading(force: true);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: AppText(
            text: "Continue Reading...",
            style: AppTextStyles.bold(fontSize: 20.sp),
          ),
        ),
        6.w.verticalSpace,
        Consumer<HomeProvider>(
          builder: (context, provider, _) {
            final isLoading =
                provider.isContinueReadingLoading &&
                provider.continueReadingItems == null;
            final items = provider.continueReadingItems ?? const [];
            final error = provider.continueReadingError;

            if (isLoading) {
              return const _ContinueReadingShimmer();
            }

            if ((error != null && error.isNotEmpty) && items.isEmpty) {
              return _ContinueReadingErrorState(
                message: error,
                onRetry: () => provider.getContinueReading(force: true),
              );
            }

            if (items.isEmpty) {
              return const _ContinueReadingEmptyState();
            }

            final tailShimmer =
                provider.isContinueReadingLoadingMore &&
                    provider.hasMoreContinueReading
                ? 2
                : 0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                height: 280.w,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if (!provider.hasMoreContinueReading ||
                        provider.isContinueReadingLoadingMore ||
                        provider.isContinueReadingLoading) {
                      return false;
                    }
                    final m = notification.metrics;
                    if (m.axis != Axis.horizontal || m.maxScrollExtent <= 0) {
                      return false;
                    }
                    if (m.pixels >= m.maxScrollExtent - 160.w) {
                      provider.getContinueReadingLoadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemExtent: _continueReadingSlotExtent(),
                    itemCount: items.length + tailShimmer,
                    itemBuilder: (_, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 18.w),
                        child: SizedBox(
                          width: 210.w,
                          child: index >= items.length
                              ? const _ContinueReadingCardShimmer()
                              : _ContinueReadingCard(
                                  item: items[index],
                                  onOpenDetails: () =>
                                      _openTopicDetails(context, items[index]),
                                  onContinueReading: () => _openContinueReading(
                                    context,
                                    items[index],
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({
    required this.item,
    required this.onOpenDetails,
    required this.onContinueReading,
  });

  final ContinueReadingItemModel item;
  final VoidCallback onOpenDetails;
  final VoidCallback onContinueReading;

  @override
  Widget build(BuildContext context) {
    final subtitleColor = AppColors.black.withValues(alpha: 0.45);
    final useTopicShelfCounts = item.displayReadingsDen != null &&
        item.displayReadingsDen! > 0;
    final pageCount = useTopicShelfCounts
        ? item.displayReadingsDen!
        : (item.pageCount <= 0 ? 0 : item.pageCount);
    final readPages = useTopicShelfCounts
        ? (item.displayReadingsNum ?? 0)
        : item.readPages;
    final displayTitle = item.topic.title.isEmpty
        ? item.storyIdeaTitle.isEmpty
            ? item.storyTitle
            : item.storyIdeaTitle
        : item.topic.title;

    return SizedBox(
      width: 210.w, 
      height: 268.w,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onOpenDetails,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      return AppNetworkImage(
                        imageUrl: item.topic.thumbnailUrl.isEmpty
                            ? item.thumbnailUrl
                            : item.topic.thumbnailUrl,
                        tag: 'ContinueReading.card',
                        width: w,
                        height: h,
                        fit: BoxFit.cover,
                        placeholder: (_) => AppSkeletonizer(child: ColoredBox(
                            color: AppColors.shimmerBaseColor,
                            child: SizedBox(width: w, height: h),
                          ),
                        ),
                        errorCompact: true,
                        errorIconOnly: true,
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.w, 14.w, 12.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onOpenDetails,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: AppText(
                            text: displayTitle.isNotEmpty
                                ? displayTitle
                                : 'Story',
                            style: AppTextStyles.bold(
                              fontSize: 16.sp,
                              height: 1.22,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 6.w),
                        SizedBox(
                          height: 16.sp,
                          width: double.infinity,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AppText(
                              text: pageCount > 0
                                  ? '$readPages out of $pageCount Readings'
                                  : '0 out of 0 Readings',
                              style: AppTextStyles.medium(
                                fontSize: 12.sp,
                                height: 1.2,
                                color: subtitleColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.w),
                  AppButton(
                    margin: EdgeInsets.zero,
                    onTap: onContinueReading,
                    text: "Continue Reading",
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

class _ContinueReadingShimmer extends StatelessWidget {
  const _ContinueReadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SizedBox(
        height: 280.w,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemExtent: _continueReadingSlotExtent(),
          itemCount: 3,
          itemBuilder: (_, __) => Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: SizedBox(width: 210.w, child: _ContinueReadingCardShimmer()),
          ),
        ),
      ),
    );
  }
}

/// Shimmer matching Series [StoryCard] layout.
class _ContinueReadingCardShimmer extends StatelessWidget {
  const _ContinueReadingCardShimmer();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(child: SizedBox(
        width: 210.w,
        height: 268.w,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ColoredBox(
                  color: AppColors.shimmerBaseColor,
                  child: const SizedBox.expand(),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 10.w, 14.w, 12.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 54.w,
                      width: 140.w,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBaseColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 6.w),
                    Container(
                      height: 16.sp,
                      width: 120.w,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBaseColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 10.w),
                    Container(
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBaseColor,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
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

class _ContinueReadingEmptyState extends StatelessWidget {
  const _ContinueReadingEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              height: 42.w,
              width: 42.w,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.menu_book_outlined,
                color: AppColors.teal,
                size: 22.w,
              ),
            ),
            12.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: "No stories in progress",
                    style: AppTextStyles.bold(fontSize: 15.sp),
                  ),
                  4.h.verticalSpace,
                  AppText(
                    text: "Start a story and it will show up here.",
                    style: AppTextStyles.semiBold(
                      fontSize: 12.sp,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
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

class _ContinueReadingErrorState extends StatelessWidget {
  const _ContinueReadingErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6F6),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFFFD6D6)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.redColor,
              size: 22.w,
            ),
            10.w.horizontalSpace,
            Expanded(
              child: AppText(
                text: message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.semiBold(
                  fontSize: 12.sp,
                  color: AppColors.black.withValues(alpha: 0.8),
                ),
              ),
            ),
            10.w.horizontalSpace,
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.redColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: AppText(
                  text: "Retry",
                  style: AppTextStyles.bold(
                    fontSize: 12.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
