import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';
import 'package:redstreakapp/screens/notification/widgets/notification_widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: SvgIcon(AppAssets.backButton, size: 12.w),
                  ),
                  Expanded(
                    child: Center(
                      child: AppText(
                        text: 'Notifications',
                        style: AppTextStyles.bold(fontSize: 20.sp),
                      ),
                    ),
                  ),
                  20.w.horizontalSpace,
                ],
              ),
            ),
            Divider(
              height: 1.w,
              color: AppColors.black.withValues(alpha: 0.08),
            ),
            Expanded(
              child: Consumer<FriendProvider>(
                builder: (context, provider, _) {
                  return _buildBody(provider);
                },
              ),
            ),
          ],
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
        if (provider.requestsList.isEmpty) {
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.w),
        itemCount: provider.requestsList.length + 1,
        separatorBuilder: (_, index) {
          if (index == 0) return SizedBox.shrink();
          return SizedBox(height: 16.w);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.only(bottom: 13.w),
              child: AppText(
                text: 'Friend Requests',
                style: AppTextStyles.bold(fontSize: 20.sp),
              ),
            );
          }
          final request = provider.requestsList[index - 1];
          return FriendRequestTile(
            key: ValueKey(request.friendshipId),
            request: request,
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
