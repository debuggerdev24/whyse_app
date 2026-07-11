import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';
import 'package:redstreakapp/providers/profile/group_provider.dart';

class AddMembersScreen extends StatefulWidget {
  final String groupId;
  const AddMembersScreen({super.key, required this.groupId});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  void _onSearchChanged(String value) {
    if (!mounted) return;
    setState(() => _searchQuery = value.trim().toLowerCase());
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
    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        title: AppText(text: 'Add Members'),
      ),
      body: Consumer2<GroupProvider, FriendProvider>(
        builder: (context, groupProvider, friendProvider, _) {
          final filteredFriends = friendProvider.friendsList.where((friend) {
            if (_searchQuery.isEmpty) return true;
            final name = (friend.friend.displayName ?? '').toLowerCase();
            final email = (friend.friend.email ?? '').toLowerCase();
            final username = (friend.friend.username ?? '').toLowerCase();
            return name.contains(_searchQuery) ||
                email.contains(_searchQuery) ||
                username.contains(_searchQuery);
          }).toList();

          return Column(
            children: [
              Divider(color: AppColors.black.withValues(alpha: 0.1), height: 1),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "Add Members",
                        style: AppTextStyles.semiBold(fontSize: 14.sp),
                      ),
                      8.w.verticalSpace,
                      AppTextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        hintText: "Search by name or email",
                        hintStyle: AppTextStyles.medium(
                          fontSize: 14.sp,
                          color: AppColors.black.withValues(alpha: 0.25),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 14.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: AppColors.black.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 12.w),
                          child: Icon(
                            Icons.search_rounded,
                            size: 20.sp,
                            color: AppColors.black.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      18.w.verticalSpace,
                      AppText(
                        text: "Members",
                        style: AppTextStyles.semiBold(fontSize: 14.sp),
                      ),
                      8.w.verticalSpace,
                      Expanded(
                        child: _buildUsersList(
                          friendProvider: friendProvider,
                          groupProvider: groupProvider,
                          filteredFriends: filteredFriends,
                        ),
                      ),
                      12.w.verticalSpace,
                      AppFilledButton(
                        text: groupProvider.selectedUsersCount > 0
                            ? "Add Members (${groupProvider.selectedUsersCount})"
                            : "Add Members",
                        isLoading: groupProvider.addMembersLoading,
                        onTap: groupProvider.selectedUsersCount > 0
                            ? () {
                                groupProvider.addMembersToGroup(
                                  groupId: widget.groupId,
                                  onSuccess: () {
                                    AppToast.success(
                                      context,
                                      'Members added successfully',
                                    );
                                    groupProvider.clearUserSelection();
                                    groupProvider.getGroupMembers(
                                      groupId: widget.groupId,
                                    );
                                    context.pop();
                                  },
                                  onError: (error) {
                                    AppToast.error(context, error);
                                  },
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
          return _buildEmptyState();
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
            text: _searchQuery.isEmpty
                ? "Add friends first, then add them to groups"
                : "Try searching with a different keyword",
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
    final itemCount = filteredFriends.length + (friendProvider.isLoadingMore ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      itemCount: itemCount,
      separatorBuilder: (_, _) => Divider(
        height: 24.w,
        thickness: 1,
        color: AppColors.black.withValues(alpha: 0.08),
      ),
      itemBuilder: (context, index) {
        if (index == filteredFriends.length) {
          return _buildPaginationLoader();
        }
        final user = filteredFriends[index].friend;
        return _MemberTile(
          user: user,
          isSelected: groupProvider.isUserSelected(user.id),
          onToggle: () => groupProvider.toggleUserSelection(user.id),
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
    required this.isSelected,
    required this.onToggle,
  });

  final FriendUser user;
  final bool isSelected;
  final VoidCallback onToggle;

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
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: _avatarColor,
            child: AppText(
              text: user.initials,
              style: AppTextStyles.bold(
                fontSize: 13.sp,
                color: AppColors.white,
              ),
            ),
          ),
          16.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: _fullName,
                  style: AppTextStyles.bold(
                    fontSize: 18.sp,
                    color: AppColors.black,
                  ),
                ),
                2.h.verticalSpace,
                AppText(
                  text: user.email ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.medium(
                    fontSize: 13.sp,
                    color: AppColors.black.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          10.w.horizontalSpace,
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24.sp,
            height: 24.sp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.teal : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? AppColors.teal
                    : AppColors.black.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: isSelected
                ? Icon(Icons.check, size: 14.sp, color: AppColors.white)
                : null,
          ),
        ],
      ),
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
