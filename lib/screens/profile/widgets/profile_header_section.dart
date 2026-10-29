import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/user_avatar_image.dart';
import 'package:redstreakapp/models/profile/profile_data_model.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:share_plus/share_plus.dart';

const Color _profileTan = Color(0xFFCFBD95);

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

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
                            child: Icon(
                              Icons.chevron_left_rounded,
                              size: 28,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        AppText(
                          text: 'Your Profile',
                          style: AppTextStyles.bold(
                            fontSize: 18,
                            color: AppColors.black,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GlassIconButton(
                                size: 44,
                                onTap: () => context.pushNamed(
                                  AppRoutes.notificationScreen.name,
                                ),
                                child: Icon(
                                  Icons.notifications_none_rounded,
                                  size: 22,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GlassIconButton(
                                size: 44,
                                onTap: () => context.pushNamed(
                                  AppRoutes.settingsScreen.name,
                                ),
                                child: Icon(
                                  Icons.settings_outlined,
                                  size: 22,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer2<ProfileProvider, GamificationProvider>(
                    builder: (context, profile, gamification, _) {
                      return _IdentityRow(
                        profile: profile.profileData,
                        loading:
                            profile.getProfileState == DataState.loading &&
                            profile.profileData == null,
                        rank: _rankFrom(gamification),
                      );
                    },
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

int? _rankFrom(GamificationProvider gamification) {
  final global = gamification.globalLeaderboard?.yourRank?.rank;
  if (global != null && global > 0) return global;
  final friends = gamification.friendsLeaderboard?.yourRank?.rank;
  if (friends != null && friends > 0) return friends;
  return null;
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({
    required this.profile,
    required this.loading,
    required this.rank,
  });

  final ProfileDataModel? profile;
  final bool loading;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final joinedYear = profile?.createdAt?.year;
    final joined = joinedYear == null ? 'Joined —' : 'Joined $joinedYear';
    final username = profile?.username.trim() ?? '';
    final handle = username.isEmpty ? joined : '@$username • $joined';

    const avatarSize = 104.0;
    return Align(
      alignment: const Alignment(-1, 0.25),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 0, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: avatarSize.w,
              height: avatarSize.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.surface, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: UserAvatarImage(
                  avatarUrl: profile?.avatarUrl,
                  size: avatarSize.w,
                  showPlaceholderShimmerWhenEmpty: loading,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 20.w, 0),
                child: loading
                    ? const _IdentityShimmer()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: AppText(
                                  text: profile?.displayName.isNotEmpty == true
                                      ? profile!.displayName
                                      : '—',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bold(
                                    fontSize: 22,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: username.isEmpty
                                    ? null
                                    : () => SharePlus.instance.share(
                                        ShareParams(text: '@$username'),
                                      ),
                                child: SvgIcon(
                                  AppAssets.shareIcon,
                                  size: 18,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          AppText(
                            text: handle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.regular(
                              fontSize: 14,
                              color: AppColors.muted,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              _Stat(
                                value: rank == null ? '—' : '#$rank',
                                label: 'Your Rank',
                              ),
                              Container(
                                width: 1,
                                height: 36,
                                margin: EdgeInsets.symmetric(horizontal: 16.w),
                                color: _profileTan.withValues(alpha: 0.7),
                              ),
                              _Stat(
                                value: '${profile?.counts.friendCount ?? 0}',
                                label: 'Friends',
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: value,
          style: AppTextStyles.bold(
            fontSize: 22,
            color: AppColors.black,
          ),
        ),
        AppText(
          text: label,
          style: AppTextStyles.regular(
            fontSize: 14,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _IdentityShimmer extends StatelessWidget {
  const _IdentityShimmer();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 140, height: 22, color: AppColors.surface),
          const SizedBox(height: 8),
          Container(width: 160, height: 14, color: AppColors.surface),
          const SizedBox(height: 16),
          Container(width: 120, height: 36, color: AppColors.surface),
        ],
      ),
    );
  }
}
