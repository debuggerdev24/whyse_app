import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/shared_pref.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/group/group_members_model.dart';
import 'package:redstreakapp/models/group/group_shared_topic_model.dart';
import 'package:redstreakapp/providers/home/saved_series_provider.dart';
import 'package:redstreakapp/providers/profile/group_provider.dart';
import 'package:redstreakapp/screens/group/group_details_tab.dart';
import 'package:redstreakapp/screens/group/group_screen_params.dart';
import 'package:redstreakapp/screens/group/widget/group_image_widget.dart';

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

    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, top + 6, 16, 0),
            child: SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GlassIconButton(
                      size: 44,
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        size: 28,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                  AppText(
                    text: 'Groups',
                    style: AppTextStyles.bold(
                      fontSize: 18,
                      color: const Color(0xFF1C1C1E),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppText(
                      text: 'Edit',
                      style: AppTextStyles.semibold(
                        fontSize: 16,
                        color: const Color(0xFFF6A01A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28.r),
              ),
            ),
            child: Column(
              children: [
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
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.paddingOf(context).bottom + 12,
              ),
              child: GestureDetector(
                onTap: () {
                  context.pushNamed(
                    AppRoutes.shareStoriesInGroupScreen.name,
                    extra: p.id,
                  );
                },
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: AppText(
                    text: 'Share Series',
                    style: AppTextStyles.semibold(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
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
    const labels = ['Details', 'Updates', 'Streaks Ranking'];
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0) SizedBox(width: 8.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.animateTo(i),
                  child: Container(
                    height: 36,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: controller.index == i
                          ? AppColors.teal
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: controller.index == i
                          ? null
                          : Border.all(color: const Color(0xFFE4E4E4)),
                    ),
                    child: AppText(
                      text: labels[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.medium(
                        fontSize: 13,
                        color: controller.index == i
                            ? Colors.white
                            : const Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
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
      separatorBuilder: (_, _) => 20.h.verticalSpace,
      itemBuilder: (_, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonizer(
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
            child: AppSkeletonizer(
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
          separatorBuilder: (_, _) => 20.h.verticalSpace,
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
              authorAvatar: member.avatarUrl,
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
    this.authorAvatar,
  });

  final GroupSharedTopic topic;
  final String authorName;
  final String sharedTime;
  final String? authorAvatar;

  @override
  Widget build(BuildContext context) {
    final detail = topic.topic;
    final progress = detail.readingProgress;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semibold(
                      fontSize: 16,
                      color: const Color(0xFF1C1C1E),
                    ),
                  ),
                ),
                AppText(
                  text: sharedTime,
                  style: AppTextStyles.regular(
                    fontSize: 12,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: SizedBox(
                height: 150.h,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(
                      imageUrl: detail.thumbnailUrl,
                      tag: 'UnifiedGroup.detailThumbnail',
                      width: double.infinity,
                      height: 150.h,
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
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: detail.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bold(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          AppText(
                            text:
                                '${progress.completedStories} out of ${progress.totalStories} Reading',
                            style: AppTextStyles.medium(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
            child: Row(
              children: [
                ClipOval(
                  child: AppNetworkImage(
                    imageUrl: authorAvatar,
                    tag: 'UnifiedGroup.author',
                    width: 28,
                    height: 28,
                    errorCompact: true,
                    errorIconOnly: true,
                    errorBuilder: (_, _, _) => Container(
                      width: 28,
                      height: 28,
                      color: const Color(0xFFDDF4F1),
                      child: const Icon(Icons.person, size: 16, color: AppColors.teal),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final ssp = context.watch<SavedSeriesProvider>();
                      final topicId = detail.id;
                      final isToggling = ssp.isTopicListToggling(topicId);
                      final isInList =
                          ssp.topicIsInMyListOverride(topicId) ?? false;

                      return GestureDetector(
                        onTap: isToggling
                            ? null
                            : () async {
                                final result = await ssp.toggleTopic(
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
                        child: AppText(
                          text: isToggling
                              ? (isInList ? 'Removing…' : 'Adding…')
                              : (isInList
                                    ? 'Remove from list'
                                    : 'Add to my list'),
                          style: AppTextStyles.semibold(
                            fontSize: 15,
                            color: AppColors.teal,
                          ),
                        ),
                      );
                    },
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

class _GroupStreaksTab extends StatelessWidget {
  const _GroupStreaksTab();

  @override
  Widget build(BuildContext context) {
    return Selector<GroupProvider, _GroupStreaksTabVM>(
      selector: (_, p) => _GroupStreaksTabVM(
        state: p.getGroupMembersState,
        members: p.groupMembersList,
        error: p.getGroupMembersError,
      ),
      builder: (context, vm, _) {
        final myUserId = LocalStorageService.instance.getLoggedInUserId;
        final rankedMembers = vm.members.sortedByStreakDesc();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                text: 'Streaks Ranking',
                style: AppTextStyles.bold(
                  fontSize: 20,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
              SizedBox(height: 8.h),
                if (vm.isLoading)
                  Padding(
                    padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 24.h),
                    child: Column(
                      children: List.generate(
                        4,
                        (index) => Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: AppSkeletonizer(
                            child: Container(
                              height: 52.h,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else if (vm.isError)
                  Padding(
                    padding: EdgeInsets.fromLTRB(18.w, 24.h, 18.w, 24.h),
                    child: AppText(
                      text: userFacingMessage(
                        vm.error,
                        fallback: 'Unable to load streak ranking.',
                      ),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.medium(
                        fontSize: 14.sp,
                        color: AppColors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  )
                else if (rankedMembers.isEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(18.w, 24.h, 18.w, 24.h),
                    child: AppText(
                      text: 'No members yet.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.medium(
                        fontSize: 14.sp,
                        color: AppColors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 16.h),
                    itemCount: rankedMembers.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.black.withValues(alpha: 0.08),
                    ),
                    itemBuilder: (_, index) {
                      final member = rankedMembers[index];
                      final isMe =
                          myUserId.isNotEmpty && member.userId == myUserId;
                      return _StreakRankingRow(
                        rank: index + 1,
                        name: isMe ? 'You' : member.displayName,
                        streak: member.currentStreak,
                        avatarUrl: member.avatarUrl,
                      );
                    },
                  ),
              ],
            ),
        );
      },
    );
  }
}

class _GroupStreaksTabVM {
  const _GroupStreaksTabVM({
    required this.state,
    required this.members,
    required this.error,
  });

  final DataState state;
  final List<GroupMember> members;
  final String? error;

  bool get isLoading => state == DataState.loading;
  bool get isError => state == DataState.failed;
}

class _StreakRankingRow extends StatelessWidget {
  const _StreakRankingRow({
    required this.rank,
    required this.name,
    required this.streak,
    this.avatarUrl,
  });

  final int rank;
  final String name;
  final int streak;
  final String? avatarUrl;

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
              text: '$rank',
              style: AppTextStyles.semibold(
                fontSize: 13.sp,
                color: AppColors.teal,
              ),
            ),
          ),
          14.w.horizontalSpace,
          ClipOval(
            child: AppNetworkImage(
              imageUrl: avatarUrl,
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
              errorBuilder: (_, _, _) => Container(
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
              text: name,
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
                const Icon(
                  Icons.local_fire_department_rounded,
                  size: 16,
                  color: Color(0xFFF6A01A),
                ),
                const SizedBox(width: 4),
                AppText(
                  text: '$streak',
                  style: AppTextStyles.semibold(
                    fontSize: 15,
                    color: const Color(0xFF1C1C1E),
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
