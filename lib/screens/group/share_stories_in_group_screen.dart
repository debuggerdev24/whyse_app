import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/group/shareable_topic_model.dart';
import 'package:redstreakapp/providers/profile/group_provider.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';

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
    return SettingsScaffold(
      title: 'Select Series',
      trailing: Selector<GroupProvider, bool>(
        selector: (_, gp) => gp.isSharingTopics,
        builder: (context, isSharingTopics, _) {
          final canShare = _selectedTopicIds.isNotEmpty && !isSharingTopics;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: canShare ? _shareTopics : null,
            child: isSharingTopics
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFF6A01A),
                    ),
                  )
                : AppText(
                    text: 'Share with',
                    style: AppTextStyles.semibold(
                      fontSize: 15,
                      color: canShare
                          ? const Color(0xFFF6A01A)
                          : const Color(0xFFF6A01A).withValues(alpha: 0.4),
                    ),
                  ),
          );
        },
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
              mainAxisSpacing: 14.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.78,
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
      itemBuilder: (_, _) => _buildShimmerTile(),
    );
  }

  Widget _buildShimmerTile() {
    return AppSkeletonizer(child: Column(
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
    final progress = item.readingProgress;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(
              imageUrl: imageUrl,
              tag: 'ShareStoriesInGroup.tile',
              errorCompact: true,
              errorIconOnly: true,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                  stops: [0.45, 1],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFF6A01A)
                      : Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: selected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.28),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isSavedTopic
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(fontSize: 16, color: Colors.white),
                  ),
                  AppText(
                    text:
                        '${progress.completedReadings} out of ${progress.totalReadings} Reading',
                    style: AppTextStyles.medium(
                      fontSize: 12,
                      color: Colors.white,
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
