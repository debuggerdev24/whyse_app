import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';

class FriendRequestTile extends StatefulWidget {
  const FriendRequestTile({super.key, required this.request});

  final FriendRequestResponse request;

  @override
  State<FriendRequestTile> createState() => _FriendRequestTileState();
}

class _FriendRequestTileState extends State<FriendRequestTile> {
  bool _isAccepting = false;
  bool _isDeclining = false;

  bool get _isBusy => _isAccepting || _isDeclining;

  void _accept() {
    if (_isBusy) return;
    setState(() => _isAccepting = true);
    context.read<FriendProvider>().acceptFriendRequest(
      friendshipId: widget.request.friendshipId,
      onSuccess: () {
        if (!mounted) return;
        setState(() => _isAccepting = false);
        AppToast.success(context, 'Friend request accepted');
        context.read<FriendProvider>().getFriends();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isAccepting = false);
        AppToast.error(context, error);
      },
    );
  }

  void _decline() {
    if (_isBusy) return;
    setState(() => _isDeclining = true);
    context.read<FriendProvider>().declineFriendRequest(
      friendshipId: widget.request.friendshipId,
      onSuccess: () {
        if (!mounted) return;
        setState(() => _isDeclining = false);
        AppToast.success(context, 'Friend request declined');
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isDeclining = false);
        AppToast.error(context, error);
      },
    );
  }

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
    final hash = widget.request.requester.id.codeUnits
        .fold<int>(0, (prev, c) => prev + c);
    return _avatarColors[hash % _avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.request.requester;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 26.r,
          backgroundColor: _avatarColor,
          child: AppText(
            text: user.initials,
            style: AppTextStyles.bold(
              fontSize: 16.sp,
              color: AppColors.white,
            ),
          ),
        ),
        12.w.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: user.displayName ?? user.username ?? '',
                style: AppTextStyles.bold(fontSize: 16.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              2.w.verticalSpace,
              AppText(
                text: 'sent you a friend request',
                style: AppTextStyles.regular(
                  fontSize: 12.sp,
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        8.w.horizontalSpace,
        GestureDetector(
          onTap: _accept,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: _isAccepting
                ? SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : AppText(
                    text: 'Accept',
                    style: AppTextStyles.bold(
                      fontSize: 14.sp,
                      color: AppColors.white,
                    ),
                  ),
          ),
        ),
        8.w.horizontalSpace,
        GestureDetector(
          onTap: _decline,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: AppColors.black.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: _isDeclining
                ? SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.black,
                    ),
                  )
                : AppText(
                    text: 'Decline',
                    style: AppTextStyles.bold(
                      fontSize: 14.sp,
                      color: AppColors.black,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class NotificationShimmerList extends StatelessWidget {
  const NotificationShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeletonizer(child: Container(
            width: 80.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
        16.w.verticalSpace,
        for (var i = 0; i < 5; i++) ...[
          if (i > 0) 16.w.verticalSpace,
          _ShimmerTile(),
        ],
      ],
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          12.w.horizontalSpace,
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
                SizedBox(height: 6.h),
                Container(
                  width: 170.w,
                  height: 11.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
          8.w.horizontalSpace,
          Container(
            width: 70.w,
            height: 34.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.r),
            ),
          ),
          8.w.horizontalSpace,
          Container(
            width: 70.w,
            height: 34.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.r),
            ),
          ),
        ],
      ),
    );
  }
}
