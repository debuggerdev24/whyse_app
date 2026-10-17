import 'package:cached_network_image/cached_network_image.dart';
import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/providers/family/family_provider.dart';
import 'package:redstreakapp/screens/profile/widgets/add_family_member_bottom_sheet.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';
import 'package:redstreakapp/services/profile/friend_api_service.dart';

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
    return SettingsScaffold(
      title: 'Add Family Member',
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        child: _buildBody(),
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
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
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
    final hasAvatar = friend.avatarUrl != null && friend.avatarUrl!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 44,
                height: 44,
                child: hasAvatar
                    ? CachedNetworkImage(
                        imageUrl: friend.avatarUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const ColoredBox(color: Colors.white),
                        errorWidget: (_, _, _) => _Initials(
                          initials: friend.initials,
                          color: _avatarColor,
                        ),
                      )
                    : _Initials(initials: friend.initials, color: _avatarColor),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: friend.displayName ?? friend.username ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semibold(
                      fontSize: 16,
                      color: settingsInk,
                    ),
                  ),
                  if (friend.username != null && friend.username!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    AppText(
                      text: '@${friend.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regular(
                        fontSize: 13,
                        color: settingsMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              height: 34,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: settingsInk,
                borderRadius: BorderRadius.circular(17),
              ),
              child: AppText(
                text: 'Add',
                style: AppTextStyles.semibold(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.initials, required this.color});

  final String initials;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Center(
        child: AppText(
          text: initials,
          style: AppTextStyles.bold(fontSize: 14, color: Colors.white),
        ),
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
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (_, _) => const _ShimmerTile(),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
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
            AppText(
              text: 'No friends available to add',
              textAlign: TextAlign.center,
              style: AppTextStyles.semibold(
                fontSize: 16,
                color: settingsInk,
              ),
            ),
            SizedBox(height: 6.h),
            AppText(
              text:
                  'All your friends are already in your family, or you have no friends yet.',
              textAlign: TextAlign.center,
              style: AppTextStyles.regular(fontSize: 14, color: settingsMuted),
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
            AppText(
              text: message ?? 'Failed to load friends',
              textAlign: TextAlign.center,
              style: AppTextStyles.regular(fontSize: 14, color: settingsMuted),
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                height: 44,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: settingsInk,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: AppText(
                  text: 'Retry',
                  style: AppTextStyles.semibold(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
