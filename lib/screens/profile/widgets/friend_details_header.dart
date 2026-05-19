import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/friend/friend_details_model.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_friend_avatar.dart';
import 'package:shimmer/shimmer.dart';

const Color friendDetailsHeaderBg = Color(0xFFE8D9C4);

class FriendDetailsHeader extends StatelessWidget {
  const FriendDetailsHeader({super.key, required this.profile});

  final FriendProfile profile;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: friendDetailsHeaderBg,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 15.w, 14.w, 20.w),
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
                    child: _ProfileAvatar(profile: profile),
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile});

  final FriendProfile profile;

  Color get _fallbackColor {
    return ProfileFriendAvatar.avatarColors[profile.userId.codeUnits.fold<int>(
          0,
          (prev, c) => prev + c,
        ) %
        ProfileFriendAvatar.avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveNullableNetworkImageUrl(profile.avatarUrl);

    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _fallbackColor,
        border: Border.all(
          color: AppColors.black.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: resolvedUrl != null
          ? AppNetworkImage(
              imageUrl: resolvedUrl,
              tag: 'FriendDetails.avatar',
              width: 120.w,
              height: 120.w,
              fit: BoxFit.cover,
              placeholder: (_) => _initialsLabel(),
              errorCompact: true,
              errorIconOnly: true,
              errorBuilder: (_, __, ___) => _initialsLabel(),
            )
          : _initialsLabel(),
    );
  }

  Widget _initialsLabel() {
    return AppText(
      text: profile.initials,
      style: AppTextStyles.bold(
        fontSize: 40.sp,
        color: AppColors.white.withValues(alpha: 0.92),
      ),
    );
  }
}

class FriendDetailsHeaderShimmer extends StatelessWidget {
  const FriendDetailsHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: friendDetailsHeaderBg,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 10.w, 14.w, 0.w),
        child: SafeArea(
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
              Shimmer.fromColors(
                baseColor: AppColors.shimmerBaseColor,
                highlightColor: AppColors.shimmerHighlightColor,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.shimmerBaseColor,
                    border: Border.all(
                      color: AppColors.black.withValues(alpha: 0.12),
                      width: 1.2,
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
