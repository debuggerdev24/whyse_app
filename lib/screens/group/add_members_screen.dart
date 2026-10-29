import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/widgets/app_dropdown.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';
import 'package:redstreakapp/providers/profile/group_provider.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';

class AddMembersScreenArgs {
  const AddMembersScreenArgs({required this.groupId, this.title});

  final String groupId;
  final String? title;
}

class AddMembersScreen extends StatefulWidget {
  final String groupId;
  final String? title;
  const AddMembersScreen({super.key, required this.groupId, this.title});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String> _roles = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().clearUserSelection();
      context.read<FriendProvider>().getFriends();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FriendProvider>().loadMoreFriends();
    }
  }

  void _addTypedMember(FriendProvider friends, GroupProvider groups) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;
    final matches = friends.friendsList.where((friend) {
      final user = friend.friend;
      bool hit(String? value) =>
          value != null && value.trim().toLowerCase() == query;
      return hit(user.email) || hit(user.username) || hit(user.phone);
    }).toList();
    if (matches.isEmpty) {
      AppToast.error(context, 'No matching friend');
      return;
    }
    final user = matches.first.friend;
    if (!groups.isUserSelected(user.id)) {
      groups.toggleUserSelection(user.id);
    }
    _roles.putIfAbsent(user.id, () => 'Member');
    _searchController.clear();
    setState(() {});
  }

  Future<void> _finish(GroupProvider groups, FriendProvider friends) async {
    final selected = friends.friendsList
        .map((friend) => friend.friend)
        .where((user) => groups.isUserSelected(user.id))
        .toList();
    if (selected.isEmpty) {
      if (mounted) context.pop();
      return;
    }

    final byRole = <String, List<String>>{};
    for (final user in selected) {
      final role = _roles[user.id] == 'Admin' ? 'ADMIN' : 'MEMBER';
      byRole.putIfAbsent(role, () => []).add(user.id);
    }

    for (final entry in byRole.entries) {
      var failed = false;
      await groups.addMembersToGroup(
        groupId: widget.groupId,
        userIds: entry.value,
        role: entry.key,
        onSuccess: () {},
        onError: (error) {
          failed = true;
          AppToast.error(context, error);
        },
      );
      if (failed || !mounted) return;
    }
    if (!mounted) return;
    AppToast.success(context, 'Members added successfully');
    groups.clearUserSelection();
    groups.getGroupMembers(groupId: widget.groupId);
    context.pop();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final headerTitle = (widget.title ?? '').trim();
    final finishLabel = headerTitle.isEmpty ? 'Add Members' : 'Create Group';

    return SettingsScaffold(
      title: headerTitle.isEmpty ? 'Add Members' : headerTitle,
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 12),
        child: Consumer2<GroupProvider, FriendProvider>(
          builder: (context, groupProvider, friendProvider, _) {
            final loading = groupProvider.addMembersLoading;
            return GestureDetector(
              onTap: loading ? null : () => _finish(groupProvider, friendProvider),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : AppText(
                        text: finishLabel,
                        style: AppTextStyles.semibold(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
      body: Consumer2<GroupProvider, FriendProvider>(
        builder: (context, groupProvider, friendProvider, _) {
          final added = friendProvider.friendsList
              .where((friend) => groupProvider.isUserSelected(friend.friend.id))
              .toList();

          return Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'Add Members',
                  style: AppTextStyles.medium(fontSize: 14, color: settingsInk),
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _searchController,
                          hintText: 'Enter email/username/phone no',
                          hintStyle: AppTextStyles.regular(
                            fontSize: 14,
                            color: settingsMuted,
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                            borderSide: BorderSide.none,
                          ),
                          onSubmit: (_) =>
                              _addTypedMember(friendProvider, groupProvider),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            _addTypedMember(friendProvider, groupProvider),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: AppText(
                            text: 'Add',
                            style: AppTextStyles.semibold(
                              fontSize: 15,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
                AppText(
                  text: 'Members',
                  style: AppTextStyles.bold(fontSize: 18, color: settingsInk),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: _buildUsersList(
                    friendProvider: friendProvider,
                    groupProvider: groupProvider,
                    filteredFriends: added,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsersList({
    required FriendProvider friendProvider,
    required GroupProvider groupProvider,
    required List<FriendResponse> filteredFriends,
  }) {
    switch (friendProvider.getFriendsState) {
      case DataState.loading:
        return _buildLoadingState();
      case DataState.failed:
        return _buildErrorState(friendProvider);
      case DataState.success:
        if (filteredFriends.isEmpty) {
          if (friendProvider.friendsList.isEmpty) return _buildEmptyState();
          return Center(
            child: AppText(
              text: 'No members yet',
              style: AppTextStyles.regular(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          );
        }
        return _buildSuccessList(
          friendProvider: friendProvider,
          groupProvider: groupProvider,
          filteredFriends: filteredFriends,
        );
    }
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      separatorBuilder: (_, _) => Divider(
        height: 24.w,
        thickness: 1,
        color: AppColors.black.withValues(alpha: 0.08),
      ),
      itemBuilder: (context, index) {
        return const _ShimmerMemberTile();
      },
    );
  }

  Widget _buildErrorState(FriendProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: AppColors.black.withValues(alpha: 0.3),
            ),
            12.h.verticalSpace,
            AppText(
              text: provider.getFriendsError ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: AppColors.black.withValues(alpha: 0.55),
              ),
            ),
            16.h.verticalSpace,
            GestureDetector(
              onTap: () {
                context.read<FriendProvider>().getFriends();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.teal.withValues(alpha: 0.4),
                  ),
                ),
                child: AppText(
                  text: "Retry",
                  style: AppTextStyles.semiBold(
                    fontSize: 14.sp,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 48.sp,
            color: AppColors.black.withValues(alpha: 0.25),
          ),
          12.h.verticalSpace,
          AppText(
            text: "No friends found",
            style: AppTextStyles.semiBold(
              fontSize: 16.sp,
              color: AppColors.black.withValues(alpha: 0.45),
            ),
          ),
          4.h.verticalSpace,
          AppText(
            text: "Add friends first, then add them to groups",
            style: AppTextStyles.medium(
              fontSize: 13.sp,
              color: AppColors.black.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessList({
    required FriendProvider friendProvider,
    required GroupProvider groupProvider,
    required List<FriendResponse> filteredFriends,
  }) {
    final itemCount =
        filteredFriends.length + (friendProvider.isLoadingMore ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      itemCount: itemCount,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5EA)),
      itemBuilder: (context, index) {
        if (index == filteredFriends.length) {
          return _buildPaginationLoader();
        }
        final user = filteredFriends[index].friend;
        return _MemberTile(
          user: user,
          role: _roles[user.id] ?? 'Member',
          onRole: (role) => setState(() => _roles[user.id] = role),
        );
      },
    );
  }

  Widget _buildPaginationLoader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: SizedBox(
          width: 24.sp,
          height: 24.sp,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.teal,
          ),
        ),
      ),
    );
  }
}

// ================= MEMBER TILE =================

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.user,
    required this.role,
    required this.onRole,
  });

  final FriendUser user;
  final String role;
  final ValueChanged<String> onRole;

  static const List<Color> _avatarColors = [
    Color(0xFF53C3BF),
    Color(0xFFD7B086),
    Color(0xFF66C99D),
    Color(0xFF7B9FD4),
    Color(0xFFD48B8B),
    Color(0xFFA68BD4),
    Color(0xFFD4C36A),
    Color(0xFF6AC8D4),
  ];

  Color get _avatarColor {
    final hash = user.id.codeUnits.fold<int>(0, (prev, c) => prev + c);
    return _avatarColors[hash % _avatarColors.length];
  }

  String get _fullName {
    final display = user.displayName?.trim() ?? '';
    if (display.isNotEmpty) return display;
    final username = user.username?.trim() ?? '';
    if (username.isNotEmpty) return username;
    return 'Unknown user';
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = resolveNullableNetworkImageUrl(user.avatarUrl);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: _avatarColor,
            child: avatarUrl != null
                ? ClipOval(
                    child: AppNetworkImage(
                      imageUrl: avatarUrl,
                      width: 44.r,
                      height: 44.r,
                      fit: BoxFit.cover,
                      errorCompact: true,
                      errorIconOnly: true,
                      errorBuilder: (_, _, _) => _initials(),
                    ),
                  )
                : _initials(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: _fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.semibold(
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
                AppText(
                  text: user.email ?? user.username ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.regular(
                    fontSize: 13,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 132,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E5EA)),
            ),
            child: AppDropdown(
              filled: false,
              value: role,
              items: const ['Member', 'Admin'],
              onChanged: (value) {
                if (value != null) onRole(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _initials() {
    return AppText(
      text: user.initials,
      style: AppTextStyles.bold(fontSize: 13, color: Colors.white),
    );
  }
}

// ================= SHIMMER LOADING TILE =================

class _ShimmerMemberTile extends StatelessWidget {
  const _ShimmerMemberTile();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 20.r, backgroundColor: AppColors.shimmerBaseColor),
        16.w.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 14.h,
                width: 140.w,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBaseColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              6.h.verticalSpace,
              Container(
                height: 11.h,
                width: 190.w,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBaseColor.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
        10.w.horizontalSpace,
        Container(
          height: 34.h,
          width: 90.w,
          decoration: BoxDecoration(
            color: AppColors.shimmerBaseColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}
