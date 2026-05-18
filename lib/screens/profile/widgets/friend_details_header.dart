import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_friend_avatar.dart';

const Color friendDetailsHeaderBg = Color(0xFFE8D9C4);

class FriendDetailsHeader extends StatelessWidget {
  const FriendDetailsHeader({super.key, required this.friend});

  final FriendUser friend;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: friendDetailsHeaderBg,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 10.w, 14.w, 0.w),
        child: Column(
          children: [
            SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: _CircleOutlineIconButton(
                      onTap: () {
                        if (context.canPop()) context.pop();
                      },
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 25.sp,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            ProfileFriendAvatar.avatarColors[friend.id.codeUnits
                                    .fold<int>(0, (prev, c) => prev + c) %
                                ProfileFriendAvatar.avatarColors.length],
                        border: Border.all(
                          color: AppColors.black.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: AppText(
                        text: friend.initials,
                        style: AppTextStyles.bold(
                          fontSize: 40.sp,
                          color: AppColors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleOutlineIconButton extends StatelessWidget {
  const _CircleOutlineIconButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40.w,
          height: 40.w,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
