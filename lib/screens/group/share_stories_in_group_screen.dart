import 'package:cached_network_image/cached_network_image.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/global_widgets.dart';
import 'package:shimmer/shimmer.dart';

class ShareStoriesInGroupScreen extends StatefulWidget {
  const ShareStoriesInGroupScreen({super.key});

  @override
  State<ShareStoriesInGroupScreen> createState() =>
      _ShareStoriesInGroupScreenState();
}

class _ShareStoriesInGroupScreenState extends State<ShareStoriesInGroupScreen> {
  final Set<int> _selectedIndexes = <int>{0};

  static const List<_SeriesItem> _series = [
    _SeriesItem(
      title: 'Nature',
      progressText: '0 out of 50 Readings',
      imagePath: 'https://picsum.photos/seed/nature/200/300',
    ),
    _SeriesItem(
      title: 'Space',
      progressText: '0 out of 50 Readings',
      imagePath: 'https://picsum.photos/seed/space/200/300',
    ),
    _SeriesItem(
      title: 'Nature',
      progressText: '0 out of 50 Readings',
      imagePath: 'https://picsum.photos/seed/nature/200/300',
    ),
    _SeriesItem(
      title: 'Ocean',
      progressText: '0 out of 50 Readings',
      imagePath: 'https://picsum.photos/seed/ocean/200/300',
    ),
    _SeriesItem(
      title: 'Forest',
      progressText: '0 out of 50 Readings',
      imagePath: 'https://picsum.photos/seed/forest/200/300',
    ),
    _SeriesItem(
      title: 'Desert',
      progressText: '0 out of 50 Readings',
      imagePath: 'https://picsum.photos/seed/desert/200/300',
    ),
  ];

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: AppBar(
        leadingWidth: 95.w,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: AppText(
            text: 'Cancel',
            style: AppTextStyles.bold(fontSize: 14, color: AppColors.black),
          ),
        ),
        centerTitle: true,
        title: AppText(
          text: 'Select Series',
          style: AppTextStyles.semiBold(fontSize: 20),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _selectedIndexes.isEmpty
                  ? null
                  : () {
                      context.pop();
                    },
              child: Center(
                child: AppText(
                  text: 'Share with',
                  style: AppTextStyles.bold(
                    fontSize: 14,
                    color: _selectedIndexes.isEmpty
                        ? AppColors.teal.withValues(alpha: 0.45)
                        : AppColors.teal,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(
            height: 1.h,
            color: AppColors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 20.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.66,
        ),
        itemCount: _series.length,
        itemBuilder: (context, index) {
          final item = _series[index];
          final selected = _selectedIndexes.contains(index);
          return _SeriesTile(
            item: item,
            selected: selected,
            onTap: () => _toggleSelection(index),
          );
        },
      ),
    );
  }
}

class _SeriesItem {
  const _SeriesItem({
    required this.title,
    required this.progressText,
    required this.imagePath,
  });

  final String title;
  final String progressText;
  final String imagePath;
}

class _SeriesTile extends StatelessWidget {
  const _SeriesTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _SeriesItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 120.h,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: item.imagePath,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: AppColors.shimmerBaseColor,
                            highlightColor: AppColors.shimmerHighlightColor,
                            child: Container(
                              height: 120.h,
                              width: double.infinity,
                              color: AppColors.shimmerBaseColor,
                            ),
                          ),
                          errorWidget: (_, __, ___) =>
                              const NoImageFound(compact: true, iconOnly: true),
                        ),
                      ),
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: SvgIcon(
                            AppAssets.bookmark,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 12.h, 14.w, 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: item.title,
                        style: AppTextStyles.bold(fontSize: 20),
                      ),
                      2.h.verticalSpace,
                      AppText(
                        text: item.progressText,
                        style: AppTextStyles.semibold(
                          fontSize: 12,
                          color: AppColors.black.setOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          12.h.verticalSpace,
          Container(
            width: 30.h,
            height: 30.h,
            decoration: BoxDecoration(
              color: selected ? AppColors.teal : AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? AppColors.teal
                    : AppColors.black.withValues(alpha: 0.1),
              ),
            ),
            child: selected
                ? Icon(Icons.check, size: 18.sp, color: AppColors.white)
                : null,
          ),
        ],
      ),
    );
  }
}
