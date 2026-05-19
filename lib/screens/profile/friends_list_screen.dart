import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/friend/friend_details_model.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';
import 'package:redstreakapp/screens/profile/friend_details_screen.dart';
import 'package:redstreakapp/screens/profile/friends_list_screen_params.dart';
import 'package:redstreakapp/services/profile/friend_api_service.dart';
import 'package:shimmer/shimmer.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key, this.params});

  final FriendsListScreenParams? params;

  bool get _isUserProfileMode => params?.isUserProfileFriendsList ?? false;

  bool get _isPreviewMode =>
      params != null && !(params!.isUserProfileFriendsList);

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final ScrollController _scrollController = ScrollController();

  bool get _isUserProfileMode => widget._isUserProfileMode;
  bool get _isPreviewMode => widget._isPreviewMode;

  // User profile friends list state
  DataState _userFriendsState = DataState.loading;
  String? _userFriendsError;
  List<FriendProfileListItem> _userFriends = [];
  int _userFriendsPage = 1;
  int _userFriendsTotalPages = 1;
  bool _isLoadingMoreUserFriends = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (_isUserProfileMode) {
      _loadUserProfileFriends(page: 1);
    } else if (!_isPreviewMode) {
      Future.microtask(() {
        context.read<FriendProvider>().getFriends();
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    if (_isUserProfileMode) {
      _loadMoreUserProfileFriends();
    } else if (!_isPreviewMode) {
      context.read<FriendProvider>().loadMoreFriends();
    }
  }

  Future<void> _loadUserProfileFriends({required int page}) async {
    final userId = widget.params!.userId!;
    final isFirstPage = page == 1;

    if (isFirstPage) {
      setState(() {
        _userFriendsState = DataState.loading;
        _userFriendsError = null;
        _userFriends = [];
        _userFriendsPage = 1;
        _userFriendsTotalPages = 1;
      });
    } else {
      if (_isLoadingMoreUserFriends) return;
      setState(() => _isLoadingMoreUserFriends = true);
    }

    final result = await FriendApiService.instance.getUserProfileFriendsList(
      userId: userId,
      page: page,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          if (isFirstPage) {
            _userFriendsState = DataState.failed;
            _userFriendsError = userFacingMessage(failure.errorMsg);
          }
          _isLoadingMoreUserFriends = false;
        });
      },
      (response) {
        final data = response.data;
        setState(() {
          if (isFirstPage) {
            _userFriends = List.of(data.items);
            _userFriendsState = DataState.success;
            _userFriendsError = null;
          } else {
            _userFriends = [..._userFriends, ...data.items];
          }
          _userFriendsPage = data.pagination.page;
          _userFriendsTotalPages = data.pagination.totalPages;
          _isLoadingMoreUserFriends = false;
        });
      },
    );
  }

  void _loadMoreUserProfileFriends() {
    if (_userFriendsState != DataState.success) return;
    if (_isLoadingMoreUserFriends) return;
    if (_userFriendsPage >= _userFriendsTotalPages) return;
    _loadUserProfileFriends(page: _userFriendsPage + 1);
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
        title: AppText(text: widget.params?.title ?? 'Friends'),
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
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isUserProfileMode) return _buildUserProfileFriendsList();
    if (_isPreviewMode) return _buildPreviewList();
    return Selector<FriendProvider, _FriendsListVM>(
      selector: (_, p) => _FriendsListVM.fromProvider(p),
      builder: (context, vm, _) {
        if (vm.isLoading) return const _LoadingList();
        if (vm.isError) {
          return _ErrorState(
            message: vm.error,
            onRetry: () => context.read<FriendProvider>().getFriends(),
          );
        }
        if (vm.friends.isEmpty) return const _EmptyState();

        final itemCount = vm.friends.length + (vm.hasNextPage ? 1 : 0);

        return RefreshIndicator(
          color: AppColors.teal,
          onRefresh: () => context.read<FriendProvider>().getFriends(),
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
    );
  }

  Widget _buildUserProfileFriendsList() {
    if (_userFriendsState == DataState.loading) {
      return const _LoadingList();
    }
    if (_userFriendsState == DataState.failed) {
      return _ErrorState(
        message: _userFriendsError,
        onRetry: () => _loadUserProfileFriends(page: 1),
      );
    }
    if (_userFriends.isEmpty) return const _EmptyState();

    final hasNextPage = _userFriendsPage < _userFriendsTotalPages;
    final itemCount = _userFriends.length + (hasNextPage ? 1 : 0);

    return RefreshIndicator(
      color: AppColors.teal,
      onRefresh: () => _loadUserProfileFriends(page: 1),
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
          if (index == _userFriends.length) {
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
          final friend = _userFriends[index];
          return _UserProfileFriendTile(
            key: ValueKey(friend.id),
            friend: friend,
          );
        },
      ),
    );
  }

  Widget _buildPreviewList() {
    final params = widget.params!;
    if (params.usesPreviews) {
      final previews = params.friendPreviews!;
      if (previews.isEmpty) return const _EmptyState();

      return ListView.separated(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: previews.length,
        separatorBuilder: (_, __) => Divider(
          height: 24.w,
          thickness: 1,
          color: AppColors.black.setOpacity(0.08),
        ),
        itemBuilder: (context, index) {
          final preview = previews[index];
          return _PreviewFriendTile(
            key: ValueKey(preview.id),
            friend: preview,
          );
        },
      );
    }

    final friends = params.friends!;
    if (friends.isEmpty) return const _EmptyState();

    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: friends.length,
      separatorBuilder: (_, __) => Divider(
        height: 24.w,
        thickness: 1,
        color: AppColors.black.setOpacity(0.08),
      ),
      itemBuilder: (context, index) {
        final friendUser = friends[index];
        return _FriendTile(
          key: ValueKey(friendUser.id),
          friend: friendUser,
          friendshipId: friendUser.id,
          viewOnly: widget.params!.viewOnly,
        );
      },
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

class _UserProfileFriendTile extends StatelessWidget {
  const _UserProfileFriendTile({super.key, required this.friend});

  final FriendProfileListItem friend;

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
    final hash = friend.id.codeUnits.fold<int>(0, (prev, c) => prev + c);
    return _avatarColors[hash % _avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = resolveNullableNetworkImageUrl(friend.avatarUrl);

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoutes.friendDetailsScreen.name,
        extra: FriendDetailsScreenParams(friendId: friend.id),
      ),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _avatarColor,
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: avatarUrl != null
                ? AppNetworkImage(
                    imageUrl: avatarUrl,
                    tag: 'UserProfileFriendsList.avatar',
                    width: 48.w,
                    height: 48.w,
                    fit: BoxFit.cover,
                    errorCompact: true,
                    errorIconOnly: true,
                    errorBuilder: (_, __, ___) => _initials(),
                  )
                : _initials(),
          ),
          16.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: friend.displayLabel,
                  style: AppTextStyles.semibold(
                    fontSize: 16.sp,
                    color: AppColors.black,
                  ),
                ),
                if (friend.username != null &&
                    friend.username!.isNotEmpty) ...[
                  2.h.verticalSpace,
                  AppText(
                    text: '@${friend.username}',
                    style: AppTextStyles.medium(
                      fontSize: 13.sp,
                      color: AppColors.black.setOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _initials() {
    return AppText(
      text: friend.initials,
      style: AppTextStyles.bold(
        fontSize: 14.sp,
        color: AppColors.white,
      ),
    );
  }
}

class _PreviewFriendTile extends StatelessWidget {
  const _PreviewFriendTile({super.key, required this.friend});

  final FriendPreviewItem friend;

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
    final hash = friend.id.codeUnits.fold<int>(0, (prev, c) => prev + c);
    return _avatarColors[hash % _avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoutes.friendDetailsScreen.name,
        extra: FriendDetailsScreenParams(friendId: friend.id),
      ),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: _avatarColor,
            child: AppText(
              text: friend.initials,
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
                  text: friend.displayLabel,
                  style: AppTextStyles.semibold(
                    fontSize: 16.sp,
                    color: AppColors.black,
                  ),
                ),
                if (friend.username != null && friend.username!.isNotEmpty) ...[
                  2.h.verticalSpace,
                  AppText(
                    text: '@${friend.username}',
                    style: AppTextStyles.medium(
                      fontSize: 13.sp,
                      color: AppColors.black.setOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendTile extends StatefulWidget {
  const _FriendTile({
    super.key,
    required this.friend,
    required this.friendshipId,
    this.viewOnly = false,
  });

  final FriendUser friend;
  final String friendshipId;
  final bool viewOnly;

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

  void _openFriendDetails() {
    context.pushNamed(
      AppRoutes.friendDetailsScreen.name,
      extra: FriendDetailsScreenParams(friendId: widget.friend.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isRemoving ? 0.5 : 1.0,
      child: Row(
        children: [
          GestureDetector(
            onTap: _isRemoving ? null : _openFriendDetails,
            behavior: HitTestBehavior.opaque,
            child: CircleAvatar(
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
          ),
          16.w.horizontalSpace,
          Expanded(
            child: GestureDetector(
              onTap: _isRemoving ? null : _openFriendDetails,
              behavior: HitTestBehavior.opaque,
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
          ),
          if (!widget.viewOnly)
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
