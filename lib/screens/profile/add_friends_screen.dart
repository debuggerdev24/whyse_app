import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';

class AddFriendsScreen extends StatefulWidget {
  const AddFriendsScreen({super.key});

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final DeBouncer _searchDebouncer = DeBouncer(milliSecond: 400);

  final Set<String> _sentRequests = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendProvider>().searchUsers();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FriendProvider>().loadMoreSearchUsers();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebouncer.run(() {
      context.read<FriendProvider>().searchUsers(query: value);
    });
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
        title: const AppText(text: 'Add Friends'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
      ),
      body: Consumer<FriendProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Divider(
                color: AppColors.black.withValues(alpha: 0.1),
                height: 1,
              ),
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
                        text: "Find Friends",
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
                        text: "People",
                        style: AppTextStyles.semiBold(fontSize: 14.sp),
                      ),
                      8.w.verticalSpace,
                      Expanded(child: _buildUsersList(provider)),
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

  Widget _buildUsersList(FriendProvider provider) {
    switch (provider.searchUsersState) {
      case DataState.loading:
        return _buildLoadingState();
      case DataState.failed:
        return _buildErrorState(provider);
      case DataState.success:
        if (provider.searchUsersList.isEmpty) {
          return _buildEmptyState();
        }
        return _buildSuccessList(provider);
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
        return const _ShimmerUserTile();
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
              text: provider.searchUsersError ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: AppColors.black.withValues(alpha: 0.55),
              ),
            ),
            16.h.verticalSpace,
            GestureDetector(
              onTap: () {
                context.read<FriendProvider>().searchUsers(
                  query: _searchController.text,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 10.h,
                ),
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
            text: "No users found",
            style: AppTextStyles.semiBold(
              fontSize: 16.sp,
              color: AppColors.black.withValues(alpha: 0.45),
            ),
          ),
          4.h.verticalSpace,
          AppText(
            text: "Try searching with a different keyword",
            style: AppTextStyles.medium(
              fontSize: 13.sp,
              color: AppColors.black.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessList(FriendProvider provider) {
    final users = provider.searchUsersList;
    final itemCount = users.length + (provider.searchHasNextPage ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      itemCount: itemCount,
      separatorBuilder: (_, _) => Divider(
        height: 24.w,
        thickness: 1,
        color: AppColors.black.withValues(alpha: 0.08),
      ),
      itemBuilder: (context, index) {
        if (index == users.length) {
          return _buildPaginationLoader();
        }
        final user = users[index];
        final isSent = _sentRequests.contains(user.id);
        return _UserTile(
          user: user,
          isSent: isSent,
          onAdd: () => _sendFriendRequest(user),
        );
      },
    );
  }

  void _sendFriendRequest(FriendUser user) {
    if (user.email == null || user.email!.isEmpty) {
      AppToast.error(context, 'User does not have an email address');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36.sp,
                height: 36.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.teal,
                ),
              ),
              16.h.verticalSpace,
              AppText(
                text: 'Sending request...',
                style: AppTextStyles.medium(
                  fontSize: 14.sp,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    context.read<FriendProvider>().sendFriendRequest(
      email: user.email!,
      onSuccess: () {
        if (!mounted) return;
        Navigator.of(context).pop();
        setState(() => _sentRequests.add(user.id));
        AppToast.success(
          context,
          'Friend request sent to ${user.displayName ?? "user"}',
        );
        context.read<FriendProvider>().getFriends();
        context.pop();
      },
      onError: (error) {
        if (!mounted) return;
        Navigator.of(context).pop();
        AppToast.error(context, error);
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

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isSent,
    required this.onAdd,
  });

  final FriendUser user;
  final bool isSent;
  final VoidCallback onAdd;

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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: _avatarColor,
          child: AppText(
            text: user.initials,
            style: AppTextStyles.bold(
              fontSize: 14.sp,
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
                text: user.displayName ?? user.username ?? '',
                style: AppTextStyles.semibold(
                  fontSize: 16.sp,
                  color: AppColors.black,
                ),
              ),
              if (user.email != null && user.email!.isNotEmpty) ...[
                2.h.verticalSpace,
                AppText(
                  text: user.email!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.medium(
                    fontSize: 13.sp,
                    color: AppColors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
        10.w.horizontalSpace,
        GestureDetector(
          onTap: isSent ? null : onAdd,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
            decoration: BoxDecoration(
              color: isSent ? AppColors.extealighttealcolor : AppColors.teal,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: AppText(
              text: isSent ? 'Sent' : 'Add',
              style: AppTextStyles.semibold(
                fontSize: 13.sp,
                color: isSent ? AppColors.teal : AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerUserTile extends StatelessWidget {
  const _ShimmerUserTile();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: AppColors.shimmerBaseColor,
        ),
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
          width: 70.w,
          decoration: BoxDecoration(
            color: AppColors.shimmerBaseColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ],
    );
  }
}
