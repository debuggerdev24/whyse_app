import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/providers/family/family_provider.dart';
import 'package:redstreakapp/screens/profile/widgets/add_family_member_bottom_sheet.dart';
import 'package:redstreakapp/services/profile/friend_api_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final ScrollController _scrollController = ScrollController();

  DataState _state = DataState.loading;
  String? _error;
  List<FriendResponse> _friends = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  bool get _hasNextPage => _currentPage < _totalPages;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyProvider>().getFamilyRoles();
    });
    _loadFriends(page: 1);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    _loadMoreFriends();
  }

  Future<void> _loadFriends({required int page}) async {
    final isFirstPage = page == 1;

    if (isFirstPage) {
      setState(() {
        _state = DataState.loading;
        _error = null;
        _friends = [];
        _currentPage = 1;
        _totalPages = 1;
      });
    } else {
      if (_isLoadingMore || !_hasNextPage) return;
      setState(() => _isLoadingMore = true);
    }

    final result = await FriendApiService.instance.getFriendsExcludingFamily(
      page: page,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          if (isFirstPage) {
            _state = DataState.failed;
            _error = userFacingMessage(failure.errorMsg);
          }
          _isLoadingMore = false;
        });
      },
      (response) {
        final data = response['data'] as Map<String, dynamic>;
        final friends = (data['friends'] as List)
            .map((e) => FriendResponse.fromJson(e as Map<String, dynamic>))
            .toList();
        final pagination = data['pagination'] as Map<String, dynamic>;

        setState(() {
          if (isFirstPage) {
            _friends = friends;
            _state = DataState.success;
            _error = null;
          } else {
            _friends = [..._friends, ...friends];
          }
          _currentPage = pagination['page'] as int;
          _totalPages = pagination['totalPages'] as int;
          _isLoadingMore = false;
        });
      },
    );
  }

  void _loadMoreFriends() {
    if (_state != DataState.success || _isLoadingMore || !_hasNextPage) {
      return;
    }
    _loadFriends(page: _currentPage + 1);
  }

  void _onFriendTap(FriendResponse friendResponse) {
    final friend = friendResponse.friend;
    final memberName = friend.displayName ?? friend.username ?? 'this user';

    showAddFamilyMemberBottomSheet(
      context,
      memberName: memberName,
      memberGender: friend.gender,
      onConfirm: (role) async {
        final error = await context.read<FamilyProvider>().addFamilyMemberToFamily(
          member: friend,
          role: role.value,
          roleLabel: role.label,
        );
        if (!mounted) return error;
        if (error == null) {
          AppToast.success(context, '$memberName added as ${role.label}');
          setState(() {
            _friends =
                _friends.where((f) => f.friend.id != friend.id).toList();
          });
          context.pop();
        }
        return error;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        title: const AppText(text: 'Add Family Member'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: _buildBody())],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case DataState.loading:
        return const _LoadingList();
      case DataState.failed:
        return _ErrorState(
          message: _error,
          onRetry: () => _loadFriends(page: 1),
        );
      case DataState.success:
        if (_friends.isEmpty) return const _EmptyState();
        return RefreshIndicator(
          color: AppColors.teal,
          onRefresh: () => _loadFriends(page: 1),
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: _friends.length + (_hasNextPage ? 1 : 0),
            separatorBuilder: (_, __) => Divider(
              height: 24.w,
              thickness: 1,
              color: AppColors.black.setOpacity(0.08),
            ),
            itemBuilder: (context, index) {
              if (index == _friends.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Center(
                    child: SizedBox(
                      width: 24.sp,
                      height: 24.sp,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                );
              }
              final friendResponse = _friends[index];
              return _FriendSelectTile(
                key: ValueKey(friendResponse.friendshipId),
                friend: friendResponse.friend,
                onTap: () => _onFriendTap(friendResponse),
              );
            },
          ),
        );
    }
  }
}

class _FriendSelectTile extends StatelessWidget {
  const _FriendSelectTile({
    super.key,
    required this.friend,
    required this.onTap,
  });

  final FriendUser friend;
  final VoidCallback onTap;

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
    Logger.debug('friend.avatarUrl: ${friend.avatarUrl}');
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: CircleAvatar(
              radius: 24.r,
              backgroundColor: _avatarColor,
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: friend.avatarUrl == null || friend.avatarUrl!.isEmpty
                      ? _avatarColor
                      : AppColors.white,
                ),
                child: friend.avatarUrl == null || friend.avatarUrl!.isEmpty
                    ? Center(
                        child: AppText(
                          text: friend.initials,
                          style: AppTextStyles.bold(
                            fontSize: 16.sp,
                            color: AppColors.white,
                          ),
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: friend.avatarUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.shimmerBaseColor,
                          highlightColor: AppColors.shimmerHighlightColor,
                          child: Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _avatarColor,
                          ),
                          alignment: Alignment.center,
                          child: AppText(
                            text: friend.initials,
                            style: AppTextStyles.bold(
                              fontSize: 16.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          16.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: friend.displayName ?? friend.username ?? '',
                  style: AppTextStyles.semibold(
                    fontSize: 16.sp,
                    color: AppColors.black,
                  ),
                ),
                if (friend.username != null && friend.username!.isNotEmpty) ...[
                  2.h.verticalSpace,
                  AppText(
                    text: '@${friend.username}',
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppColors.teal.setOpacity(0.1),
              borderRadius: BorderRadius.circular(9999.r),
              border: Border.all(color: AppColors.teal),
            ),
            child: AppText(
              text: 'Add',
              style: AppTextStyles.semibold(
                fontSize: 13.sp,
                color: AppColors.teal,
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
                8.h.verticalSpace,
                Container(
                  width: 80.w,
                  height: 12.h,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 48.sp,
              color: AppColors.black.setOpacity(0.3),
            ),
            12.h.verticalSpace,
            AppText(
              text: 'No friends available to add',
              textAlign: TextAlign.center,
              style: AppTextStyles.semibold(
                fontSize: 16.sp,
                color: AppColors.black,
              ),
            ),
            6.h.verticalSpace,
            AppText(
              text:
                  'All your friends are already in your family, or you have no friends yet.',
              textAlign: TextAlign.center,
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: AppColors.black.setOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: AppColors.black.setOpacity(0.3),
            ),
            12.h.verticalSpace,
            AppText(
              text: message ?? 'Failed to load friends',
              textAlign: TextAlign.center,
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: AppColors.black.setOpacity(0.55),
              ),
            ),
            16.h.verticalSpace,
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.teal.setOpacity(0.4)),
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
      ),
    );
  }
}
