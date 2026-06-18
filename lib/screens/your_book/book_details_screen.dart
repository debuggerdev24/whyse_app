import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const book = _BookDetailsData(
      title: 'The Legend of the Last Library',
      author: 'Frank L. Cole',
      pages: 356,
      lessons: 4,
      summary:
          "After a devastating Blight killed off all the trees, paper is worth more than just about anything. Juni's parents died when she was young, so now it's just her and Grandpa Edgar.",
      longestStreak: '2 days',
      coverUrl: 'https://picsum.photos/seed/last-library/700/1000',
      learnings: [
        'Pick up fun new words.',
        'Build awesome sentences.',
        'Discover cool new ways people write.',
        'Step into characters\' shoes and feel what they feel.',
      ],
      trackingItems: [
        _TrackingRow(minutes: 20, pages: 10, dateText: 'Sept 2, Tue'),
        _TrackingRow(minutes: 15, pages: 20, dateText: 'Sept 1, Mon'),
        _TrackingRow(minutes: 10, pages: 5, dateText: 'Aug 30, Sat'),
        _TrackingRow(minutes: 25, pages: 15, dateText: 'Aug 28, Thu'),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _SectionDivider(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    30.h.verticalSpace,
                    _BookHeaderSection(book: book),
                    _SectionDivider(),
                    _SummarySection(summary: book.summary),
                    _SectionDivider(),
                    _LearningSection(points: book.learnings),
                    _SectionDivider(),
                    _TrackingHistorySection(
                      longestStreak: book.longestStreak,
                      items: book.trackingItems,
                    ),
                    26.h.verticalSpace,
                  ],
                ),
              ),
            ),
            _BottomContinueButton(),
          ],
        ),
      ),
    );
  }
}

class _BookHeaderSection extends StatelessWidget {
  const _BookHeaderSection({required this.book});

  final _BookDetailsData book;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          10.h.verticalSpace,
          Container(
            width: 210.h,
            height: 300.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 16,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: AppNetworkImage(
              imageUrl: book.coverUrl,
              tag: 'BookDetails.cover',
              borderRadius: BorderRadius.circular(14.r),
              placeholder: (_) => const _ImageShimmer(
                radius: BorderRadius.all(Radius.circular(14)),
              ),
              errorBuilder: (_, __, ___) => const _ImageError(
                radius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
          ),
          24.h.verticalSpace,
          AppText(
            text: book.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.bold(fontSize: 24),
          ),
          4.h.verticalSpace,
          AppText(
            text: book.author,
            textAlign: TextAlign.center,
            style: AppTextStyles.semiBold(
              fontSize: 14,
              color: AppColors.black.setOpacity(0.40),
            ),
          ),
          16.h.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SvgIcon(AppAssets.pages, size: 16.sp, color: AppColors.black),
              Icon(
                Icons.description_outlined,
                size: 16.sp,
                color: AppColors.black,
              ),
              5.w.horizontalSpace,
              AppText(
                text: '${book.pages} Pages',
                style: AppTextStyles.semiBold(
                  fontSize: 12,
                  color: AppColors.black.setOpacity(0.8),
                ),
              ),
              20.w.horizontalSpace,
              Icon(Icons.school_outlined, size: 16.sp, color: AppColors.black),
              5.w.horizontalSpace,
              AppText(
                text: '${book.lessons} Key Lessons',
                style: AppTextStyles.semiBold(
                  fontSize: 12,
                  color: AppColors.black.setOpacity(0.8),
                ),
              ),
            ],
          ),
          20.h.verticalSpace,
          _BookHeaderActionRow(),
          8.h.verticalSpace,
        ],
      ),
    );
  }
}

class _BookHeaderActionRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _BookHeaderActionChip(
          iconPath: AppAssets.add,
          label: 'Add to list',
          onTap: () {},
        ),
        25.w.horizontalSpace,
        _BookHeaderActionChip(
          iconPath: AppAssets.shareIcon,
          label: 'Share',
          onTap: () {},
        ),
        25.w.horizontalSpace,
        _BookHeaderActionChip(
          iconPath: AppAssets.like,
          label: 'Rate',
          onTap: () {},
        ),
      ],
    );
  }
}

class _BookHeaderActionChip extends StatelessWidget {
  const _BookHeaderActionChip({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(iconPath, size: 24.sp, color: AppColors.black),
            6.h.verticalSpace,
            AppText(
              text: label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bold(fontSize: 12, color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(text: 'Summary', style: AppTextStyles.semiBold(fontSize: 20)),
          10.h.verticalSpace,
          AppText(
            text: summary,
            style: AppTextStyles.regular(fontSize: 14, color: AppColors.black),
          ),
        ],
      ),
    );
  }
}

class _LearningSection extends StatelessWidget {
  const _LearningSection({required this.points});

  final List<String> points;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_outlined, size: 24.sp, color: AppColors.teal),
              8.w.horizontalSpace,
              AppText(
                text: "What you’ll learn",
                style: AppTextStyles.semiBold(fontSize: 20),
              ),
            ],
          ),
          12.h.verticalSpace,
          ...points.map(
            (point) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16.sp,
                      color: AppColors.black,
                    ),
                  ),
                  8.w.horizontalSpace,
                  Expanded(
                    child: AppText(
                      text: point,
                      style: AppTextStyles.medium(
                        fontSize: 14,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingHistorySection extends StatelessWidget {
  const _TrackingHistorySection({
    required this.longestStreak,
    required this.items,
  });

  final String longestStreak;
  final List<_TrackingRow> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText(
                text: 'Tracking History',
                style: AppTextStyles.semiBold(fontSize: 20),
              ),
              const Spacer(),
              AppText(
                text: 'Longest Streak: ',
                style: AppTextStyles.medium(
                  fontSize: 14,
                  color: AppColors.black.setOpacity(0.8),
                ),
              ),
              AppText(
                text: longestStreak,
                style: AppTextStyles.bold(
                  fontSize: 14,
                  color: AppColors.orangeColor,
                ),
              ),
            ],
          ),
          20.h.verticalSpace,
          _SectionDivider(),
          20.h.verticalSpace,
          ListView.separated(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => Divider(
              height: 30.h,
              thickness: 1,
              color: AppColors.black.setOpacity(0.08),
            ),
            itemBuilder: (_, index) {
              final item = items[index];
              return Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 20.sp,
                    color: AppColors.black,
                  ),
                  6.w.horizontalSpace,
                  AppText(
                    text: '${item.minutes} mins',
                    style: AppTextStyles.semiBold(fontSize: 14),
                  ),
                  16.w.horizontalSpace,
                  Icon(
                    Icons.description_outlined,
                    size: 20.sp,
                    color: AppColors.black,
                  ),
                  6.w.horizontalSpace,
                  AppText(
                    text: '${item.pages} Pages',
                    style: AppTextStyles.semiBold(fontSize: 14),
                  ),
                  const Spacer(),
                  AppText(
                    text: item.dateText,
                    style: AppTextStyles.semiBold(
                      fontSize: 12,
                      color: AppColors.black.setOpacity(0.4),
                    ),
                  ),
                ],
              );
            },
          ),
          20.h.verticalSpace,
          _SectionDivider(),
          20.h.verticalSpace,
        ],
      ),
    );
  }
}

class _BottomContinueButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 12.h),
        child: SizedBox(
          width: double.infinity,
          height: 44.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: () {},
            child: AppText(
              text: 'Start Reading',
              style: AppTextStyles.semiBold(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.black.setOpacity(0.1),
    );
  }
}

class _ImageShimmer extends StatelessWidget {
  const _ImageShimmer({required this.radius});

  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.shimmerBaseColor,
          borderRadius: radius,
        ),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError({required this.radius});

  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF3),
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_outlined,
        color: AppColors.black.setOpacity(0.35),
      ),
    );
  }
}

class _BookDetailsData {
  const _BookDetailsData({
    required this.title,
    required this.author,
    required this.pages,
    required this.lessons,
    required this.summary,
    required this.longestStreak,
    required this.coverUrl,
    required this.learnings,
    required this.trackingItems,
  });

  final String title;
  final String author;
  final int pages;
  final int lessons;
  final String summary;
  final String longestStreak;
  final String coverUrl;
  final List<String> learnings;
  final List<_TrackingRow> trackingItems;
}

class _TrackingRow {
  const _TrackingRow({
    required this.minutes,
    required this.pages,
    required this.dateText,
  });

  final int minutes;
  final int pages;
  final String dateText;
}
