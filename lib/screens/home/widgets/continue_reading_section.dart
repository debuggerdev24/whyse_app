import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/home/continue_reading_item_model.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';

double _continueReadingCardWidth(BuildContext context) {
  final screen = MediaQuery.sizeOf(context).width;
  return (screen - 20.w * 2 - 12.w) / 2;
}

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

  void _openContinueReading(
    BuildContext context,
    ContinueReadingItemModel item,
  ) {
    final topicId = item.topic.id;
    if (topicId.isEmpty) return;
    final homeProvider = context.read<HomeProvider>();
    homeProvider.beginTopicStoryDetailsLoad(topicId: topicId);
    homeProvider.getTopicStoryDetails(topicId: topicId);
    context
        .pushNamed(AppRoutes.createdStorySummaryScreen.name, extra: topicId)
        .then((_) {
          if (!mounted) return;
          context.read<HomeProvider>().getContinueReading(force: true);
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
            style: AppTextStyles.bold(fontSize: 22.sp),
          ),
        ),
        12.h.verticalSpace,
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

            final cardWidth = _continueReadingCardWidth(context);
            return SizedBox(
              height: 176.h,
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
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: items.length + tailShimmer,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (_, index) {
                    return SizedBox(
                      width: cardWidth,
                      child: index >= items.length
                          ? const _ContinueReadingCardShimmer()
                          : _ContinueReadingCard(
                              item: items[index],
                              onOpen: () => _openContinueReading(
                                context,
                                items[index],
                              ),
                            ),
                    );
                  },
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
  const _ContinueReadingCard({required this.item, required this.onOpen});

  final ContinueReadingItemModel item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final useTopicShelfCounts =
        item.displayReadingsDen != null && item.displayReadingsDen! > 0;
    final pageCount = useTopicShelfCounts
        ? item.displayReadingsDen!
        : (item.pageCount <= 0 ? 0 : item.pageCount);
    final readPages = useTopicShelfCounts
        ? (item.displayReadingsNum ?? 0)
        : item.readPages;
    final progress = pageCount <= 0
        ? 0.0
        : (readPages / pageCount).clamp(0.0, 1.0);
    final displayTitle = item.topic.title.isEmpty
        ? item.storyIdeaTitle.isEmpty
            ? item.storyTitle
            : item.storyIdeaTitle
        : item.topic.title;
    final imageUrl = item.topic.thumbnailUrl.isEmpty
        ? item.thumbnailUrl
        : item.topic.thumbnailUrl;

    return GestureDetector(
      onTap: onOpen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(
              imageUrl: imageUrl,
              tag: 'ContinueReading.card',
              fit: BoxFit.cover,
              placeholder: (_) => AppSkeletonizer(
                child: const ColoredBox(color: Color(0xFFE6E8EC)),
              ),
              errorCompact: true,
              errorIconOnly: true,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x00000000),
                    Color(0xCC000000),
                  ],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
            Positioned(
              top: 10.h,
              left: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.38),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: AppText(
                  text: 'Story',
                  style: AppTextStyles.medium(
                    fontSize: 11.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 10.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: displayTitle.isNotEmpty ? displayTitle : 'Story',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                  4.h.verticalSpace,
                  AppText(
                    text: pageCount > 0
                        ? '$readPages/$pageCount Readings'
                        : '0/0 Readings',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium(
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  8.h.verticalSpace,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4.h,
                      backgroundColor: Colors.white.withValues(alpha: 0.35),
                      color: AppColors.orangeColor,
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

class _ContinueReadingShimmer extends StatelessWidget {
  const _ContinueReadingShimmer();

  @override
  Widget build(BuildContext context) {
    final cardWidth = _continueReadingCardWidth(context);
    return SizedBox(
      height: 176.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: 2,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (_, _) => SizedBox(
          width: cardWidth,
          child: const _ContinueReadingCardShimmer(),
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
    return AppSkeletonizer(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.shimmerBaseColor,
          borderRadius: BorderRadius.circular(22.r),
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
          color: AppColors.accentFill(const Color(0xFFF7F8FA)),
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
          color: AppColors.accentFill(const Color(0xFFFFF6F6)),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.accentFill(const Color(0xFFFFD6D6)),
          ),
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
                  color: AppColors.black.withValues(alpha: 0.85),
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
                    color: AppColors.onFill,
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
