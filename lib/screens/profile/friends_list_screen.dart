import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';
import 'package:shimmer/shimmer.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      context.read<FriendProvider>().getFriends();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FriendProvider>().loadMoreFriends();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        title: const AppText(text: 'Friends'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
      ),
      body: Column(
        children: [
          Divider(color: AppColors.black.setOpacity(0.1), height: 1),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 14.w, 24.w, 0),
              child: Selector<FriendProvider, _FriendsListVM>(
                selector: (_, p) => _FriendsListVM.fromProvider(p),
                builder: (context, vm, _) {
                  if (vm.isLoading) return const _LoadingList();
                  if (vm.isError) {
                    return _ErrorState(
                      message: vm.error,
                      onRetry: () {
                        context.read<FriendProvider>().getFriends();
                      },
                    );
                  }
                  if (vm.friends.isEmpty) return const _EmptyState();

                  final itemCount =
                      vm.friends.length + (vm.hasNextPage ? 1 : 0);

                  return RefreshIndicator(
                    color: AppColors.teal,
                    onRefresh: () =>
                        context.read<FriendProvider>().getFriends(),
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                    itemCount: itemCount,
                    separatorBuilder: (_, __) => Divider(
                      height: 24.w,
                      thickness: 1,
                      color: AppColors.black.setOpacity(0.08),
                    ),
                    itemBuilder: (context, index) {
                      if (index == vm.friends.length) {
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
                      final friendResponse = vm.friends[index];
                      return _FriendTile(
                        key: ValueKey(friendResponse.friendshipId),
                        friend: friendResponse.friend,
                        friendshipId: friendResponse.friendshipId,
                      );
                    },
                  ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendsListVM {
  final DataState state;
  final List<FriendResponse> friends;
  final String? error;
  final bool hasNextPage;

  _FriendsListVM({
    required this.state,
    required this.friends,
    required this.error,
    required this.hasNextPage,
  });

  bool get isLoading => state == DataState.loading;
  bool get isError => state == DataState.failed;

  factory _FriendsListVM.fromProvider(FriendProvider p) {
    return _FriendsListVM(
      state: p.getFriendsState,
      friends: p.friendsList,
      error: p.getFriendsError,
      hasNextPage: p.hasNextPage,
    );
  }
}

class _FriendTile extends StatefulWidget {
  const _FriendTile({
    super.key,
    required this.friend,
    required this.friendshipId,
  });

  final FriendUser friend;
  final String friendshipId;

  @override
  State<_FriendTile> createState() => _FriendTileState();
}

class _FriendTileState extends State<_FriendTile> {
  bool _isRemoving = false;

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
    final hash =
        widget.friend.id.codeUnits.fold<int>(0, (prev, c) => prev + c);
    return _avatarColors[hash % _avatarColors.length];
  }

  void _showRemoveDialog() {
    if (_isRemoving) return;
    final name =
        widget.friend.displayName ?? widget.friend.username ?? 'this user';
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 28.w, 24.w, 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: Colors.red.setOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_remove_rounded,
                  size: 28.sp,
                  color: Colors.red,
                ),
              ),
              16.h.verticalSpace,
              AppText(
                text: 'Remove Friend',
                style: AppTextStyles.bold(fontSize: 18.sp),
              ),
              8.h.verticalSpace,
              AppText(
                text:
                    'Are you sure you want to remove $name from your friends?',
                textAlign: TextAlign.center,
                style: AppTextStyles.medium(
                  fontSize: 14.sp,
                  color: AppColors.black.setOpacity(0.6),
                ),
              ),
              24.h.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(
                            color: AppColors.black.setOpacity(0.15),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: AppText(
                          text: 'Cancel',
                          style: AppTextStyles.semibold(
                            fontSize: 15.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        _removeFriend();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        alignment: Alignment.center,
                        child: AppText(
                          text: 'Remove',
                          style: AppTextStyles.semibold(
                            fontSize: 15.sp,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeFriend() {
    setState(() => _isRemoving = true);
    context.read<FriendProvider>().removeFriend(
      friendshipId: widget.friendshipId,
      onSuccess: () {
        if (!mounted) return;
        setState(() => _isRemoving = false);
        AppToast.success(
          context,
          '${widget.friend.displayName ?? "Friend"} removed',
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isRemoving = false);
        AppToast.error(context, error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isRemoving ? 0.5 : 1.0,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: _avatarColor,
            child: AppText(
              text: widget.friend.initials,
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
                  text: widget.friend.displayName ??
                      widget.friend.username ??
                      '',
                  style: AppTextStyles.semibold(
                    fontSize: 16.sp,
                    color: AppColors.black,
                  ),
                ),
                if (widget.friend.username != null &&
                    widget.friend.username!.isNotEmpty) ...[
                  2.h.verticalSpace,
                  AppText(
                    text: '@${widget.friend.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium(
                      fontSize: 13.sp,
                      color: AppColors.black.setOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: _isRemoving ? null : _showRemoveDialog,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.w),
              decoration: BoxDecoration(
                color: Colors.red.setOpacity(0.08),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.red.setOpacity(0.2),
                ),
              ),
              child: _isRemoving
                  ? SizedBox(
                      width: 14.sp,
                      height: 14.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : AppText(
                      text: 'Remove',
                      style: AppTextStyles.semibold(
                        fontSize: 12.sp,
                        color: Colors.red,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: 16.w),
      itemBuilder: (_, __) => const _ShimmerTile(),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          16.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 80.w,
                  height: 11.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 70.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _ErrorState({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 40.w,
            color: AppColors.orangeColor,
          ),
          12.verticalSpace,
          AppText(
            text: message ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium(fontSize: 14.sp),
          ),
          16.verticalSpace,
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.teal.setOpacity(0.4),
                ),
              ),
              child: AppText(
                text: 'Retry',
                style: AppTextStyles.semibold(
                  fontSize: 14.sp,
                  color: AppColors.teal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 48.w,
            color: AppColors.black.setOpacity(0.3),
          ),
          12.verticalSpace,
          AppText(
            text: 'No friends yet',
            style: AppTextStyles.medium(fontSize: 16.sp),
          ),
          6.verticalSpace,
          AppText(
            text: 'Add friends to see them here',
            style: AppTextStyles.medium(
              fontSize: 13.sp,
              color: AppColors.black.setOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}
