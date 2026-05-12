import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/group/shareable_topic_model.dart';
import 'package:redstreakapp/providers/profile/group_provider.dart';
import 'package:shimmer/shimmer.dart';

class ShareStoriesInGroupScreen extends StatefulWidget {
  const ShareStoriesInGroupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<ShareStoriesInGroupScreen> createState() =>
      _ShareStoriesInGroupScreenState();
}

class _ShareStoriesInGroupScreenState extends State<ShareStoriesInGroupScreen> {
  final Set<String> _selectedTopicIds = <String>{};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().fetchShareableTopics(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<GroupProvider>().fetchMoreShareableTopics();
    }
  }

  void _toggleSelection(String topicId) {
    setState(() {
      if (_selectedTopicIds.contains(topicId)) {
        _selectedTopicIds.remove(topicId);
      } else {
        _selectedTopicIds.add(topicId);
      }
    });
  }

  Future<void> _shareTopics() async {
    final groupProvider = context.read<GroupProvider>();
    final message = await groupProvider.shareTopicsInGroup(
      groupId: widget.groupId,
      topicIds: _selectedTopicIds.toList(),
    );
    if (!mounted) return;
    if (message != null) {
      AppToast.success(context, message);
      context.pop();
    } else {
      AppToast.error(context, 'Failed to share. Please try again.');
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
            child: Selector<GroupProvider, bool>(
              selector: (_, gp) => gp.isSharingTopics,
              builder: (context, isSharingTopics, _) {
                final canShare =
                    _selectedTopicIds.isNotEmpty && !isSharingTopics;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: canShare ? _shareTopics : null,
                  child: Center(
                    child: isSharingTopics
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.teal,
                            ),
                          )
                        : AppText(
                            text: 'Share',
                            style: AppTextStyles.bold(
                              fontSize: 14,
                              color: canShare
                                  ? AppColors.teal
                                  : AppColors.teal.withValues(alpha: 0.45),
                            ),
                          ),
                  ),
                );
              },
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
      body: Consumer<GroupProvider>(
        builder: (context, gp, _) {
          if (gp.isShareableTopicsLoading && gp.shareableTopics.isEmpty) {
            return _buildShimmerGrid();
          }

          if (gp.shareableTopics.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      size: 48.w,
                      color: AppColors.black.withValues(alpha: 0.3),
                    ),
                    16.w.verticalSpace,
                    AppText(
                      text: "No series available to share.",
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
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 20.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.62,
            ),
            itemCount:
                gp.shareableTopics.length +
                (gp.isLoadingMoreShareableTopics ? 2 : 0),
            itemBuilder: (context, index) {
              if (index >= gp.shareableTopics.length) {
                return _buildShimmerTile();
              }
              final item = gp.shareableTopics[index];
              final selected = _selectedTopicIds.contains(item.id);
              return _SeriesTile(
                item: item,
                selected: selected,
                onTap: () => _toggleSelection(item.id),
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
        childAspectRatio: 0.62,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => _buildShimmerTile(),
    );
  }

  Widget _buildShimmerTile() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.shimmerBaseColor,
                borderRadius: BorderRadius.circular(18.r),
              ),
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
  }
}

class _SeriesTile extends StatelessWidget {
  const _SeriesTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ShareableTopicItem item;
  final bool selected;
  final VoidCallback onTap;

  String _resolveImageUrl(String? raw) =>
      resolveNullableNetworkImageUrl(raw) ?? '';

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(item.thumbnailUrl);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
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
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AppNetworkImage(
                            imageUrl: imageUrl,
                            tag: 'ShareStoriesInGroup.tile',
                            errorCompact: true,
                            errorIconOnly: true,
                          ),
                        ),
                        if (item.isSavedTopic)
                          Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: Container(
                              width: 30.w,
                              height: 30.w,
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.bookmark,
                                size: 18.sp,
                                color: AppColors.teal,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: item.title,
                          style: AppTextStyles.bold(fontSize: 16.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        3.h.verticalSpace,
                        AppText(
                          text:
                              '${item.readingProgress.totalReadings} Readings',
                          style: AppTextStyles.medium(
                            fontSize: 12.sp,
                            color: AppColors.black.setOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                    : AppColors.black.withValues(alpha: 0.12),
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
