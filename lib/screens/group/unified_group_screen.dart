import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/group/group_members_model.dart';
import 'package:redstreakapp/models/group/group_shared_topic_model.dart';
import 'package:redstreakapp/providers/home/saved_series_provider.dart';
import 'package:redstreakapp/providers/profile/group_provider.dart';
import 'package:redstreakapp/screens/group/group_details_tab.dart';
import 'package:redstreakapp/screens/group/group_screen_params.dart';
import 'package:redstreakapp/screens/group/widget/group_image_widget.dart';
import 'package:shimmer/shimmer.dart';

class UnifiedGroupScreen extends StatefulWidget {
  const UnifiedGroupScreen({super.key, required this.params});

  final GroupDetailsScreenParams params;

  @override
  State<UnifiedGroupScreen> createState() => _UnifiedGroupScreenState();
}

class _UnifiedGroupScreenState extends State<UnifiedGroupScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initial = widget.params.initialTab.clamp(0, 2);
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initial,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final groupProvider = context.read<GroupProvider>();
      groupProvider.getGroupMembers(groupId: widget.params.id);
      groupProvider.getGroupSharedTopics(groupId: widget.params.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.params;
    final showShareCta = _tabController.index == 1;

    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: AppText(
          text: p.groupName,
          style: AppTextStyles.semibold(fontSize: 20, color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: AppText(
              text: 'Edit',
              style: AppTextStyles.bold(fontSize: 14, color: AppColors.teal),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                8.h.verticalSpace,
                GroupImageWidget(imageUrl: p.thumbnail, size: 112.w),
                12.h.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      text: 'Code - ${p.displayInviteCode.trim()}',
                      style: AppTextStyles.semibold(
                        fontSize: 16,
                        color: AppColors.black,
                      ),
                    ),
                    6.w.horizontalSpace,
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        var code = p.displayInviteCode.trim();
                        if (code.startsWith('#')) {
                          code = code.substring(1);
                        }
                        code = code.trim();
                        if (code.isEmpty) {
                          if (context.mounted) {
                            AppToast.error(context, 'No invite code to copy');
                          }
                          return;
                        }
                        await Clipboard.setData(ClipboardData(text: code));
                        if (!context.mounted) return;
                        HapticFeedback.selectionClick();
                        AppToast.success(context, 'Invite code copied');
                      },
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: SvgIcon(
                          AppAssets.copy,
                          size: 16.sp,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                // 6.h.verticalSpace,
                Selector<
                  GroupProvider,
                  ({DataState state, int count, String? err})
                >(
                  selector: (_, gp) => (
                    state: gp.getGroupMembersState,
                    count: gp.groupMembersList.length,
                    err: gp.getGroupMembersError,
                  ),
                  builder: (context, vm, _) {
                    if (vm.state == DataState.loading) {
                      return AppText(
                        text: '…',
                        style: AppTextStyles.semibold(
                          fontSize: 14.sp,
                          color: AppColors.orangeColor,
                        ),
                      );
                    }
                    if (vm.state == DataState.failed) {
                      return AppText(
                        text: userFacingMessage(
                          vm.err,
                          fallback: 'Members unavailable',
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.medium(
                          fontSize: 12.sp,
                          color: AppColors.black.withValues(alpha: 0.5),
                        ),
                      );
                    }
                    return AppText(
                      text: '${vm.count} Members',
                      style: AppTextStyles.semibold(
                        fontSize: 14,
                        color: AppColors.orangeColor,
                      ),
                    );
                  },
                ),
                16.h.verticalSpace,
                _GroupTabBar(controller: _tabController),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.black.withValues(alpha: 0.1)),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                GroupDetailsTabBody(params: p),
                _GroupUpdatesTab(groupId: p.id),
                const _GroupStreaksTab(),
              ],
            ),
          ),
          if (showShareCta)
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 14.h),
              child: AppFilledButton(
                backgroundColor: AppColors.black,
                text: ' Share Series',
                icon: SvgIcon(
                  AppAssets.shareIcon,
                  size: 20.sp,
                  color: AppColors.white,
                ),
                onTap: () {
                  context.pushNamed(
                    AppRoutes.shareStoriesInGroupScreen.name,
                    extra: p.id,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupTabBar extends StatelessWidget {
  const _GroupTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final grey = AppColors.black.withValues(alpha: 0.45);
    return TabBar(
      controller: controller,
      isScrollable: true,
      indicatorColor: AppColors.teal,
      indicatorWeight: 3,
      labelColor: AppColors.teal,
      unselectedLabelColor: grey,
      dividerColor: Colors.transparent,
      labelStyle: AppTextStyles.semibold(fontSize: 14.sp),
      unselectedLabelStyle: AppTextStyles.medium(fontSize: 14.sp),
      tabs: const [
        Tab(text: 'Details'),
        Tab(text: 'Updates'),
        Tab(text: 'Streaks Ranking'),
      ],
    );
  }
}

class _GroupUpdatesTab extends StatelessWidget {
  const _GroupUpdatesTab({required this.groupId});

  final String groupId;

  Widget _buildShimmer() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 20.h),
      itemCount: 3,
      separatorBuilder: (_, __) => 20.h.verticalSpace,
      itemBuilder: (_, __) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.shimmerBaseColor,
            highlightColor: AppColors.shimmerHighlightColor,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
          10.w.horizontalSpace,
          Expanded(
            child: Shimmer.fromColors(
              baseColor: AppColors.shimmerBaseColor,
              highlightColor: AppColors.shimmerHighlightColor,
              child: Container(
                height: 200.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, _) {
        final isLoading = groupProvider.isGroupSharedTopicsLoading;
        final list = groupProvider.groupSharedTopics;

        if (isLoading && list == null) return _buildShimmer();

        if (list == null || list.isEmpty) {
          return Center(
            child: AppText(
              text: 'No series shared in this group yet.',
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: AppColors.black.withValues(alpha: 0.45),
              ),
            ),
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 20.h),
          itemCount: list.length,
          separatorBuilder: (_, __) => 20.h.verticalSpace,
          itemBuilder: (_, index) {
            final item = list[index];
            final member = groupProvider.groupMembersList.firstWhere(
              (m) => m.userId == item.sharedBy,
              orElse: () => GroupMember(
                id: '',
                groupId: '',
                userId: '',
                role: GroupMemberRole.member,
                joinedAt: DateTime.now(),
                displayName: 'Unknown',
                email: '',
                firstName: 'Unknown',
                lastName: '',
              ),
            );
            return _GroupFeedCard(
              topic: item,
              authorName: member.displayName,
              sharedTime: DateFormatter.formatTimeFrom(item.sharedAt),
            );
          },
        );
      },
    );
  }
}

class _GroupFeedCard extends StatelessWidget {
  const _GroupFeedCard({
    required this.topic,
    required this.authorName,
    required this.sharedTime,
  });

  final GroupSharedTopic topic;
  final String authorName;
  final String sharedTime;

  @override
  Widget build(BuildContext context) {
    final detail = topic.topic;
    final progress = detail.readingProgress;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lighttealcolor,
          ),
          child: Icon(Icons.person, size: 18.sp, color: AppColors.teal),
        ),
        10.w.horizontalSpace,
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: authorName,
                          style: AppTextStyles.semibold(
                            fontSize: 15.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      AppText(
                        text: sharedTime,
                        style: AppTextStyles.medium(
                          fontSize: 12.sp,
                          color: AppColors.black.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: AppNetworkImage(
                    imageUrl: detail.thumbnailUrl,
                    tag: 'UnifiedGroup.detailThumbnail',
                    width: double.infinity,
                    height: 120.h,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                10.h.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.searchBackgroundColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: detail.title,
                          style: AppTextStyles.bold(
                            fontSize: 16.sp,
                            color: AppColors.black,
                          ),
                        ),
                        4.h.verticalSpace,
                        AppText(
                          text:
                              '${progress.completedStories} out of ${progress.totalStories} Readings',
                          style: AppTextStyles.medium(
                            fontSize: 13.sp,
                            color: AppColors.black.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                10.h.verticalSpace,
                Padding(
                  padding: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    bottom: 12.h,
                  ),
                  child: Builder(
                    builder: (context) {
                      final ssp = context.watch<SavedSeriesProvider>();
                      final topicId = detail.id;
                      final isToggling =
                          ssp.isTopicListToggling(topicId);
                      final isInList =
                          ssp.topicIsInMyListOverride(topicId) ??
                          false;

                      return GestureDetector(
                        onTap: isToggling
                            ? null
                            : () async {
                                final result =
                                    await ssp.toggleTopic(
                                  topicId: topicId,
                                  onFailed: (err) {
                                    if (context.mounted) {
                                      AppToast.error(context, err);
                                    }
                                  },
                                );
                                if (result != null && context.mounted) {
                                  AppToast.success(
                                    context,
                                    result.isInMyList
                                        ? 'Added to your list'
                                        : 'Removed from your list',
                                  );
                                }
                              },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isToggling)
                              SizedBox(
                                width: 14.w,
                                height: 14.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.teal,
                                ),
                              )
                            else
                              Icon(
                                isInList
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 16.sp,
                                color: AppColors.teal,
                              ),
                            6.w.horizontalSpace,
                            AppText(
                              text: isToggling
                                  ? (isInList ? 'Removing…' : 'Adding…')
                                  : (isInList
                                      ? 'Remove from List'
                                      : 'Add to My List'),
                              style: AppTextStyles.semibold(
                                fontSize: 14.sp,
                                color: AppColors.teal,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupStreaksTab extends StatelessWidget {
  const _GroupStreaksTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 0),
              child: Row(
                children: [
                  SvgIcon(
                    AppAssets.thunder,
                    size: 22.sp,
                    color: AppColors.orangeColor,
                  ),
                  10.w.horizontalSpace,
                  AppText(
                    text: 'Streaks Ranking',
                    style: AppTextStyles.bold(
                      fontSize: 18.sp,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            14.h.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Divider(
                height: 1,
                thickness: 1,
                color: AppColors.black.withValues(alpha: 0.08),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 16.h),
              itemCount: _kStreakRankingEntries.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 1,
                color: AppColors.black.withValues(alpha: 0.08),
              ),
              itemBuilder: (_, index) {
                return _StreakRankingRow(entry: _kStreakRankingEntries[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakRankingEntry {
  const _StreakRankingEntry({
    required this.rank,
    required this.name,
    required this.score,
    required this.avatarUrl,
  });

  final int rank;
  final String name;
  final int score;
  final String avatarUrl;
}

const List<_StreakRankingEntry> _kStreakRankingEntries = [
  _StreakRankingEntry(
    rank: 1,
    name: 'Emma Rodriguez',
    score: 10,
    avatarUrl: 'https://picsum.photos/seed/streak-avatar-1/128/128',
  ),
  _StreakRankingEntry(
    rank: 2,
    name: 'Liam Kumar',
    score: 6,
    avatarUrl: 'https://picsum.photos/seed/streak-avatar-2/128/128',
  ),
  _StreakRankingEntry(
    rank: 3,
    name: 'Sofia Mendes',
    score: 4,
    avatarUrl: 'https://picsum.photos/seed/streak-avatar-3/128/128',
  ),
  _StreakRankingEntry(
    rank: 4,
    name: 'Noah Patel',
    score: 1,
    avatarUrl: 'https://picsum.photos/seed/streak-avatar-4/128/128',
  ),
  _StreakRankingEntry(
    rank: 5,
    name: 'You',
    score: 1,
    avatarUrl: 'https://picsum.photos/seed/streak-avatar-5/128/128',
  ),
];

class _StreakRankingRow extends StatelessWidget {
  const _StreakRankingRow({required this.entry});

  final _StreakRankingEntry entry;

  @override
  Widget build(BuildContext context) {
    final avatarSize = 44.w;
    final rankSize = 30.w;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: rankSize,
            height: rankSize,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.extealighttealcolor,
            ),
            child: AppText(
              text: '${entry.rank}',
              style: AppTextStyles.semibold(
                fontSize: 13.sp,
                color: AppColors.teal,
              ),
            ),
          ),
          14.w.horizontalSpace,
          ClipOval(
            child: AppNetworkImage(
              imageUrl: entry.avatarUrl,
              tag: 'UnifiedGroup.memberAvatar',
              width: avatarSize,
              height: avatarSize,
              placeholder: (_) => Container(
                color: AppColors.lighttealcolor,
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_rounded,
                  size: 22.sp,
                  color: AppColors.teal,
                ),
              ),
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.lighttealcolor,
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_rounded,
                  size: 22.sp,
                  color: AppColors.teal,
                ),
              ),
            ),
          ),
          12.w.horizontalSpace,
          Expanded(
            child: AppText(
              text: entry.name,
              style: AppTextStyles.medium(
                fontSize: 16.sp,
                color: AppColors.black,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.black.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgIcon(
                  AppAssets.thunder,
                  size: 14.sp,
                  color: AppColors.orangeColor,
                ),
                6.w.horizontalSpace,
                AppText(
                  text: '${entry.score}',
                  style: AppTextStyles.bold(
                    fontSize: 16.sp,
                    color: AppColors.black,
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
