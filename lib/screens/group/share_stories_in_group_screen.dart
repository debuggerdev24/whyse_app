import 'package:cached_network_image/cached_network_image.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/global_widgets.dart';
import 'package:redstreakapp/models/home/saved_series_model.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:shimmer/shimmer.dart';

class ShareStoriesInGroupScreen extends StatefulWidget {
  const ShareStoriesInGroupScreen({super.key});

  @override
  State<ShareStoriesInGroupScreen> createState() =>
      _ShareStoriesInGroupScreenState();
}

class _ShareStoriesInGroupScreenState extends State<ShareStoriesInGroupScreen> {
  final Set<String> _selectedTopicIds = <String>{};

  void _toggleSelection(String topicId) {
    setState(() {
      if (_selectedTopicIds.contains(topicId)) {
        _selectedTopicIds.remove(topicId);
      } else {
        _selectedTopicIds.add(topicId);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final homeProvider = context.read<HomeProvider>();
    if (homeProvider.savedSeriesList == null) {
      homeProvider.getMySeriesList();
    }
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
              onTap: _selectedTopicIds.isEmpty
                  ? null
                  : () {
                      context.pop();
                    },
              child: Center(
                child: AppText(
                  text: 'Share with',
                  style: AppTextStyles.bold(
                    fontSize: 14,
                    color: _selectedTopicIds.isEmpty
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
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          final list = homeProvider.savedSeriesList;
          final isLoading = homeProvider.isSavedSeriesLoading;

          if (isLoading && list == null) {
            return _buildShimmerGrid();
          }

          if (list == null || list.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_border_rounded,
                      size: 48.w,
                      color: AppColors.black.withValues(alpha: 0.3),
                    ),
                    16.w.verticalSpace,
                    AppText(
                      text: "No saved series yet.\nAdd series to your list to share them.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.medium(
                        fontSize: 16.sp,
                        color: AppColors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 20.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.66,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final selected = _selectedTopicIds.contains(item.topic.id);
              return _SeriesTile(
                item: item,
                selected: selected,
                onTap: () => _toggleSelection(item.topic.id),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 20.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.66,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.shimmerBaseColor,
          highlightColor: AppColors.shimmerHighlightColor,
          child: Column(
            children: [
              Container(
                height: 200.h,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBaseColor,
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              12.h.verticalSpace,
              Container(
                width: 30.h,
                height: 30.h,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBaseColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeriesTile extends StatelessWidget {
  const _SeriesTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final SavedSeriesItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final topic = item.topic;
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
                        child: topic.thumbnailUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: topic.thumbnailUrl,
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
                              )
                            : const NoImageFound(compact: true, iconOnly: true),
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
                        text: topic.title,
                        style: AppTextStyles.bold(fontSize: 20),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      2.h.verticalSpace,
                      AppText(
                        text: '${topic.storiesCount} Readings',
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
