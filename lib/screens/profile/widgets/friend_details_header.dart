import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/friend/friend_details_model.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_friend_avatar.dart';

const Color _profileTan = Color(0xFFCFBD95);
const Color _ink = Color(0xFF1C1C1E);
const Color _muted = Color(0xFF8E8E93);

class FriendDetailsHeader extends StatelessWidget {
  const FriendDetailsHeader({
    super.key,
    required this.profile,
    required this.friendsCount,
    this.familyRole,
  });

  final FriendProfile profile;
  final int friendsCount;
  final String? familyRole;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final name = profile.displayName ?? profile.username ?? '';
    final username = profile.username;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            offset: Offset(0, 16),
            blurRadius: 32,
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
        child: Container(
          height: 286.h,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(207, 189, 149, 0),
                Color.fromRGBO(207, 189, 149, 0.4),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: top + 6),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SizedBox(
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GlassIconButton(
                            size: 44,
                            onTap: () {
                              if (context.canPop()) context.pop();
                            },
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              size: 28,
                              color: _ink,
                            ),
                          ),
                        ),
                        AppText(
                          text: 'Profile',
                          style: AppTextStyles.bold(fontSize: 18, color: _ink),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 18.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _ProfileAvatar(profile: profile),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 6.h),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bold(
                                      fontSize: 22,
                                      color: _ink,
                                    ),
                                  ),
                                  if (username != null && username.isNotEmpty)
                                    AppText(
                                      text: '@$username',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.regular(
                                        fontSize: 14,
                                        color: _muted,
                                      ),
                                    ),
                                  if (familyRole != null) ...[
                                    SizedBox(height: 8.h),
                                    _RoleChip(role: familyRole!),
                                  ],
                                  SizedBox(height: 10.h),
                                  AppText(
                                    text: '$friendsCount',
                                    style: AppTextStyles.bold(
                                      fontSize: 22,
                                      height: 1.05,
                                      color: _ink,
                                    ),
                                  ),
                                  AppText(
                                    text: 'Friends',
                                    style: AppTextStyles.regular(
                                      fontSize: 13,
                                      color: _muted,
                                    ),
                                  ),
                                ],
                              ),
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
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.extealighttealcolor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: AppText(
        text: role,
        style: AppTextStyles.semibold(fontSize: 12, color: AppColors.teal),
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
      width: 96.w,
      height: 96.w,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: ClipOval(
        child: ColoredBox(
          color: _fallbackColor,
          child: resolvedUrl != null
              ? AppNetworkImage(
                  imageUrl: resolvedUrl,
                  tag: 'FriendDetails.avatar',
                  width: 96.w,
                  height: 96.w,
                  fit: BoxFit.cover,
                  placeholder: (_) => AppSkeletonizer(
                    child: Container(
                      width: 96.w,
                      height: 96.w,
                      color: AppColors.shimmerBaseColor,
                    ),
                  ),
                  errorCompact: true,
                  errorIconOnly: true,
                  errorBuilder: (_, _, _) => _initialsLabel(),
                )
              : _initialsLabel(),
        ),
      ),
    );
  }

  Widget _initialsLabel() {
    return Center(
      child: AppText(
        text: profile.initials,
        style: AppTextStyles.bold(fontSize: 32, color: Colors.white),
      ),
    );
  }
}

class FriendDetailsHeaderShimmer extends StatelessWidget {
  const FriendDetailsHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
      child: Container(
        height: 286.h,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(207, 189, 149, 0),
              Color.fromRGBO(207, 189, 149, 0.4),
            ],
          ),
        ),
        padding: EdgeInsets.fromLTRB(16.w, top + 6, 16.w, 18.h),
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: GlassIconButton(
                  size: 44,
                  onTap: () {
                    if (context.canPop()) context.pop();
                  },
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    size: 28,
                    color: _ink,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppSkeletonizer(
                  child: Container(
                    width: 96.w,
                    height: 96.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(width: 140.w, height: 18.h),
                    SizedBox(height: 8.h),
                    _bar(width: 90.w, height: 12.h),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar({required double width, required double height}) {
    return AppSkeletonizer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

const Color friendDetailsHeaderBg = _profileTan;
