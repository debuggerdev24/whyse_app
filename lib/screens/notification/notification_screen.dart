import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';
import 'package:redstreakapp/screens/notification/widgets/notification_widgets.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

enum _NotificationFilter { all, unread, mentions, followers }

class _NotificationScreenState extends State<NotificationScreen> {
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
    return SettingsScaffold(
      title: 'Notifications',
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 12,
        ),
        child: GestureDetector(
          onTap: () => setState(() => _markedAllRead = true),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.buttonBackground,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, color: AppColors.onFill, size: 18),
                const SizedBox(width: 8),
                AppText(
                  text: 'Mark all as read',
                  style: AppTextStyles.semibold(fontSize: 16, color: AppColors.onFill),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    onTap: () => setState(() => _filter = filter),
                  ),
                  if (filter != _NotificationFilter.followers)
                    const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<FriendProvider>(
              builder: (context, provider, _) => _buildBody(provider),
            ),
          ),
        ],
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
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
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
                  AppText(
                    text: provider.getRequestsError ?? 'Something went wrong',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.regular(
                      fontSize: 14,
                      color: settingsMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () =>
                        context.read<FriendProvider>().getFriendRequests(),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.buttonBackground,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: AppText(
                        text: 'Retry',
                        style: AppTextStyles.semibold(
                          fontSize: 15,
                          color: AppColors.onFill,
                        ),
                      ),
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
                    AppText(
                      text: 'No notifications',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.semibold(
                        fontSize: 16,
                        color: settingsInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      text: 'You\'re all caught up.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.regular(
                        fontSize: 14,
                        color: settingsMuted,
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
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : AppColors.lightwhiteColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AppText(
          text: label,
          style: AppTextStyles.medium(
            fontSize: 14,
            color: selected ? AppColors.onFill : AppColors.black,
          ),
        ),
      ),
    );
  }
}
