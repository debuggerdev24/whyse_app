import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';
import 'package:redstreakapp/screens/notification/widgets/notification_widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

enum _NotificationFilter { all, unread, mentions, followers }

class _NotificationScreenState extends State<NotificationScreen> {
  static const _pageColor = Color(0xFFF2F2F7);
  static const _accent = Color(0xFF1A9B86);

  _NotificationFilter _filter = _NotificationFilter.all;
  bool _markedAllRead = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FriendProvider>().getFriendRequests();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<FriendProvider>().getFriendRequests();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: ColoredBox(
        color: _pageColor,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                child: SizedBox(
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                        ),
                      ),
                      AppText(
                        text: 'Notifications',
                        style: AppTextStyles.bold(fontSize: 20.sp),
                      ),
                    ],
                  ),
                ),
              ),
              16.h.verticalSpace,
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    for (final filter in _NotificationFilter.values) ...[
                      _FilterChip(
                        label: switch (filter) {
                          _NotificationFilter.all => 'All',
                          _NotificationFilter.unread => 'Unread',
                          _NotificationFilter.mentions => 'Mentions',
                          _NotificationFilter.followers => 'Followers',
                        },
                        selected: _filter == filter,
                        accent: _accent,
                        onTap: () => setState(() => _filter = filter),
                      ),
                      if (filter != _NotificationFilter.followers)
                        const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              8.h.verticalSpace,
              Expanded(
                child: Consumer<FriendProvider>(
                  builder: (context, provider, _) {
                    return _buildBody(provider);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                child: GestureDetector(
                  onTap: () => setState(() => _markedAllRead = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          text: 'Mark all as read',
                          style: AppTextStyles.semibold(
                            fontSize: 15.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(FriendProvider provider) {
    switch (provider.getRequestsState) {
      case DataState.loading:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.w),
          child: const NotificationShimmerList(),
        );
      case DataState.failed:
        return _buildErrorState(provider);
      case DataState.success:
        final showRequests =
            _filter == _NotificationFilter.all ||
            _filter == _NotificationFilter.unread;
        if (!showRequests || provider.requestsList.isEmpty) {
          return _buildEmptyState();
        }
        return _buildRequestsList(provider);
    }
  }

  Widget _buildRequestsList(FriendProvider provider) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.teal,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
        itemCount: provider.requestsList.length,
        separatorBuilder: (_, _) => SizedBox(height: 18.h),
        itemBuilder: (context, index) {
          final request = provider.requestsList[index];
          return FriendRequestTile(
            key: ValueKey(request.friendshipId),
            request: request,
            showUnreadDot: !_markedAllRead,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(FriendProvider provider) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.teal,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          SizedBox(height: 160.h),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 48.w,
                    color: AppColors.black.withValues(alpha: 0.25),
                  ),
                  12.h.verticalSpace,
                  AppText(
                    text: provider.getRequestsError ?? 'Something went wrong',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.medium(
                      fontSize: 14.sp,
                      color: AppColors.black.withValues(alpha: 0.55),
                    ),
                  ),
                  16.h.verticalSpace,
                  GestureDetector(
                    onTap: () =>
                        context.read<FriendProvider>().getFriendRequests(),
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
                        text: 'Retry',
                        style: AppTextStyles.semibold(
                          fontSize: 14.sp,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                  ),
                  12.h.verticalSpace,
                  AppText(
                    text: 'Pull down to refresh',
                    style: AppTextStyles.medium(
                      fontSize: 12.sp,
                      color: AppColors.black.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.teal,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 52.w,
                      color: AppColors.black.withValues(alpha: 0.2),
                    ),
                    12.h.verticalSpace,
                    AppText(
                      text: 'No notifications',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.semibold(
                        fontSize: 18.sp,
                        color: AppColors.black.withValues(alpha: 0.45),
                      ),
                    ),
                    6.h.verticalSpace,
                    AppText(
                      text: 'You\'re all caught up! Pull down to refresh.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.medium(
                        fontSize: 13.sp,
                        color: AppColors.black.withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accent : const Color(0xFFE4E4E8),
          ),
        ),
        child: AppText(
          text: label,
          style: AppTextStyles.medium(
            fontSize: 14.sp,
            color: selected ? Colors.white : const Color(0xFF8E8E93),
          ),
        ),
      ),
    );
  }
}
