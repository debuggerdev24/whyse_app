import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/home/continue_reading_item_model.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:shimmer/shimmer.dart';

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
          },
        )
        .then((_) {
          if (!mounted) return;
          context.read<HomeProvider>().getContinueReading(force: true);
        });

    // Fire-and-forget fetch; reader will rebuild when StoryProvider updates.
    // ignore: unawaited_futures
    storyProvider.getStoryByIdea(
      context: context,
      storyIdea: item.storyIdeaId,
      fetchOnly: true,
      onStoryNotGenerated: () {
        if (!context.mounted) return;
        AppToast.info(
          context: context,
          durationSecond: 3,
          message: "Story is not ready yet. Please try again in a moment.",
        );
      },
      onSuccess: (payload) {
        storyProvider.addStoryFromGetStoryByIdeaData(payload, 0);
      },
    );
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

            return SizedBox(
              height: 292.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(left: 12.w, right: 20.w),
                itemCount: items.length,
                separatorBuilder: (_, __) => 14.w.horizontalSpace,
                itemBuilder: (_, index) {
                  return _ContinueReadingCard(
                    item: items[index],
                    onTap: () => _openContinueReading(context, items[index]),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.item, required this.onTap});

  final ContinueReadingItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progressValue = item.progressValue;
    final pageCount = item.pageCount <= 0 ? 0 : item.pageCount;
    final readPages = item.readPages;

    Logger.info('continue reading image home screen: ${item.thumbnailUrl}');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 200.w,
        margin: EdgeInsets.all(6),
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: AppNetworkImage(
                  imageUrl: item.thumbnailUrl,
                  tag: 'ContinueReading.card',
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                  placeholder: (_) => _ImageShimmerPlaceholder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                  errorBuilder: (_, __, ___) => _ImageErrorPlaceholder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: item.topic.title.isNotEmpty
                        ? item.topic.title
                        : 'Story',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semiBold(
                      fontSize: 12.sp,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  0.h.verticalSpace,
                  AppText(
                    text: item.storyTitle.isNotEmpty
                        ? item.storyTitle
                        : item.storyIdeaTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(fontSize: 20, height: 1.2),
                  ),
                  8.h.verticalSpace,
                  AppText(
                    text: "$readPages/$pageCount Pages Read",
                    style: AppTextStyles.semiBold(
                      fontSize: 12.sp,
                      color: AppColors.black.withValues(alpha: 0.8),
                    ),
                  ),
                  5.h.verticalSpace,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 5.h,
                      backgroundColor: const Color(0xFFEBEBEB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.orangeColor,
                      ),
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
    return SizedBox(
      height: 292.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 12.w, right: 20.w),
        itemCount: 3,
        separatorBuilder: (_, __) => 14.w.horizontalSpace,
        itemBuilder: (_, __) => Container(
          width: 200.w,
          margin: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            children: [
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: const Color(0xFFE7E9EC),
                  highlightColor: const Color(0xFFF5F6F8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7E9EC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13),
                child: Shimmer.fromColors(
                  baseColor: const Color(0xFFE7E9EC),
                  highlightColor: const Color(0xFFF5F6F8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12.h, width: 90.w, color: Colors.white),
                      10.h.verticalSpace,
                      Container(
                        height: 18.h,
                        width: 140.w,
                        color: Colors.white,
                      ),
                      12.h.verticalSpace,
                      Container(
                        height: 12.h,
                        width: 120.w,
                        color: Colors.white,
                      ),
                      10.h.verticalSpace,
                      Container(
                        height: 5.h,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ],
                  ),
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

class _ImageShimmerPlaceholder extends StatelessWidget {
  const _ImageShimmerPlaceholder({required this.borderRadius});

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE7E9EC),
      highlightColor: const Color(0xFFF5F6F8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE7E9EC),
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder({required this.borderRadius});

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF3),
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: AppColors.black.withValues(alpha: 0.4),
            size: 30.w,
          ),
          6.h.verticalSpace,
          AppText(
            text: 'Image unavailable',
            style: AppTextStyles.semiBold(
              fontSize: 11.sp,
              color: AppColors.black.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
