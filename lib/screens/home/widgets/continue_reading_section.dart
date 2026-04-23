import 'package:cached_network_image/cached_network_image.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:shimmer/shimmer.dart';

class ContinueReadingSection extends StatelessWidget {
  const ContinueReadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final continueReadingItems = <_ContinueReadingItem>[
      const _ContinueReadingItem(
        coverImage: 'https://picsum.photos/seed/hobbit-cover/700/900',
        category: 'Ebook',
        title: 'Hobbit',
        pagesRead: 60,
        totalPages: 350,
      ),
      const _ContinueReadingItem(
        coverImage: 'https://picsum.photos/seed/funny-bunny/700/900',
        category: 'Book',
        title: "It's Not Easy Being a Bunny",
        pagesRead: 24,
        totalPages: 128,
      ),
      const _ContinueReadingItem(
        coverImage: 'https://picsum.photos/seed/space-odyssey/700/900',
        category: 'Ebook',
        title: 'Adventure Beyond the Stars',
        pagesRead: 140,
        totalPages: 280,
      ),
      const _ContinueReadingItem(
        coverImage: 'https://picsum.photos/seed/dino-kids/700/900',
        category: 'Graphic Book',
        title: 'Dinosaur Detective Club',
        pagesRead: 91,
        totalPages: 160,
      ),
      const _ContinueReadingItem(
        coverImage: 'https://picsum.photos/seed/ocean-secrets/700/900',
        category: 'Science Reader',
        title: 'Secrets of the Deep Ocean',
        pagesRead: 33,
        totalPages: 220,
      ),
      const _ContinueReadingItem(
        coverImage: 'https://picsum.photos/seed/invention-lab/700/900',
        category: 'Non-fiction',
        title: 'Young Inventors Lab',
        pagesRead: 176,
        totalPages: 240,
      ),
    ];

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
        SizedBox(
          height: 292.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(left: 12.w, right: 20.w),
            itemCount: continueReadingItems.length,
            separatorBuilder: (_, __) => 14.w.horizontalSpace,
            itemBuilder: (_, index) {
              return _ContinueReadingCard(item: continueReadingItems[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.item});

  final _ContinueReadingItem item;

  @override
  Widget build(BuildContext context) {
    final progressValue = item.totalPages == 0
        ? 0.0
        : (item.pagesRead / item.totalPages).clamp(0.0, 1.0);
    return Container(
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
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              child: SizedBox(
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: item.coverImage,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _ImageShimmerPlaceholder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                  errorWidget: (_, __, ___) => _ImageErrorPlaceholder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
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
                  text: item.category,
                  style: AppTextStyles.semiBold(
                    fontSize: 12.sp,
                    color: AppColors.black.withValues(alpha: 0.6),
                  ),
                ),
                0.h.verticalSpace,
                AppText(
                  text: item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bold(fontSize: 20, height: 1.2),
                ),
                8.h.verticalSpace,
                AppText(
                  text: "${item.pagesRead}/${item.totalPages} Pages Read",
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
    );
  }
}

class _ContinueReadingItem {
  const _ContinueReadingItem({
    required this.coverImage,
    required this.category,
    required this.title,
    required this.pagesRead,
    required this.totalPages,
  });

  final String coverImage;
  final String category;
  final String title;
  final int pagesRead;
  final int totalPages;
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
