import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import 'package:redstreakapp/models/friend/friend_details_model.dart';
import 'package:redstreakapp/screens/group/widget/group_image_widget.dart';
import 'package:redstreakapp/screens/profile/user_profile_groups_list_screen_params.dart';
import 'package:redstreakapp/services/profile/friend_api_service.dart';

class UserProfileGroupsListScreen extends StatefulWidget {
  const UserProfileGroupsListScreen({super.key, required this.params});

  final UserProfileGroupsListScreenParams params;

  @override
  State<UserProfileGroupsListScreen> createState() =>
      _UserProfileGroupsListScreenState();
}

class _UserProfileGroupsListScreenState extends State<UserProfileGroupsListScreen> {
  final ScrollController _scrollController = ScrollController();

  DataState _state = DataState.loading;
  String? _error;
  List<GroupPreviewItem> _groups = [];
  int _page = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadGroups(page: 1);
  }

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    if (_state != DataState.success || _isLoadingMore) return;
    if (_page >= _totalPages) return;
    _loadGroups(page: _page + 1);
  }

  Future<void> _loadGroups({required int page}) async {
    final isFirstPage = page == 1;

    if (isFirstPage) {
      setState(() {
        _state = DataState.loading;
        _error = null;
        _groups = [];
        _page = 1;
        _totalPages = 1;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    final result = await FriendApiService.instance.getUserProfileGroupsList(
      userId: widget.params.userId,
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
        final data = response.data;
        setState(() {
          if (isFirstPage) {
            _groups = List.of(data.items);
            _state = DataState.success;
            _error = null;
          } else {
            _groups = [..._groups, ...data.items];
          }
          _page = data.pagination.page;
          _totalPages = data.pagination.totalPages;
          _isLoadingMore = false;
        });
      },
    );
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
        title: AppText(text: widget.params.title ?? 'Groups'),
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
    if (_state == DataState.loading) return const _LoadingList();
    if (_state == DataState.failed) {
      return _ErrorState(
        message: _error,
        onRetry: () => _loadGroups(page: 1),
      );
    }
    if (_groups.isEmpty) return const _EmptyState();

    final hasNextPage = _page < _totalPages;
    final itemCount = _groups.length + (hasNextPage ? 1 : 0);

    return RefreshIndicator(
      color: AppColors.teal,
      onRefresh: () => _loadGroups(page: 1),
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
          if (index == _groups.length) {
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
          return _GroupListTile(group: _groups[index]);
        },
      ),
    );
  }
}

class _GroupListTile extends StatelessWidget {
  const _GroupListTile({required this.group});

  final GroupPreviewItem group;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: GroupImageWidget(
            imageUrl: group.thumbnailUrl,
            size: 48.w,
          ),
        ),
        16.w.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: group.title ?? 'Group',
                style: AppTextStyles.semibold(
                  fontSize: 16.sp,
                  color: AppColors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              4.h.verticalSpace,
              AppText(
                text: '${group.memberCount} members',
                style: AppTextStyles.medium(
                  fontSize: 13.sp,
                  color: AppColors.black.setOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ],
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
    return AppSkeletonizer(child: Row(
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
                  width: 140.w,
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
  const _ErrorState({this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

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
            Icons.groups_outlined,
            size: 48.w,
            color: AppColors.black.setOpacity(0.3),
          ),
          12.verticalSpace,
          AppText(
            text: 'No groups yet',
            style: AppTextStyles.medium(fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}
