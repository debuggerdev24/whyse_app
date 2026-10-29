import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/user_avatar_image.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';

class FriendRequestTile extends StatefulWidget {
  const FriendRequestTile({
    super.key,
    required this.request,
    this.showUnreadDot = true,
  });

  final FriendRequestResponse request;
  final bool showUnreadDot;

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

  @override
  Widget build(BuildContext context) {
    final user = widget.request.requester;
    final handle = (user.username ?? user.displayName ?? 'someone').trim();
    final name = handle.startsWith('@') ? handle : '@$handle';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: UserAvatarImage(avatarUrl: user.avatarUrl, size: 44),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: name,
                        style: AppTextStyles.bold(
                          fontSize: 15,
                          color: AppColors.black,
                        ),
                      ),
                      TextSpan(
                        text: ' sent you a friend request',
                        style: AppTextStyles.regular(
                          fontSize: 15,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                AppText(
                  text: 'Friend request',
                  style: AppTextStyles.medium(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ActionButton(
                      label: 'Decline',
                      filled: false,
                      busy: _isDeclining,
                      onTap: _decline,
                    ),
                    const SizedBox(width: 10),
                    _ActionButton(
                      label: 'Accept',
                      filled: true,
                      busy: _isAccepting,
                      onTap: _accept,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.showUnreadDot) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = filled ? Colors.white : AppColors.black;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? AppColors.black : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: filled
              ? null
              : Border.all(color: const Color(0xFFE4E4E8)),
        ),
        child: busy
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            : AppText(
                text: label,
                style: AppTextStyles.semibold(fontSize: 14, color: color),
              ),
      ),
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
              color: AppColors.surface,
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
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
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 170.w,
                  height: 11.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22.r),
            ),
          ),
          8.w.horizontalSpace,
          Container(
            width: 70.w,
            height: 34.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22.r),
            ),
          ),
        ],
      ),
    );
  }
}
