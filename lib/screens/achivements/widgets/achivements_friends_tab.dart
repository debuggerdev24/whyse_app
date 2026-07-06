import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/gamification/leaderboard_model.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';

class AchivementsFriendsTab extends StatelessWidget {
  const AchivementsFriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationProvider>(
      builder: (context, gp, _) {
        if (gp.isLoadingLeaderboard && gp.friendsLeaderboard == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final board = gp.friendsLeaderboard;
        if (board == null || board.entries.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: gp.leaderboardError ??
                        'No leaderboard data yet. Complete Sparks or Episodes to earn points.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.medium(
                      fontSize: 14.sp,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  16.h.verticalSpace,
                  AppFilledButton(
                    text: 'Retry',
                    backgroundColor: AppColors.teal,
                    onTap: () => gp.fetchLeaderboard(scope: 'friends'),
                  ),
                ],
              ),
            ),
          );
        }

        final entries = board.entries;
        final podium = entries.take(3).toList();
        final listEntries = entries.length > 3 ? entries.skip(3).toList() : <LeaderboardEntryModel>[];
        final subtitleColor = AppColors.black.withValues(alpha: 0.45);

        return RefreshIndicator(
          onRefresh: () => gp.fetchLeaderboard(scope: 'friends'),
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
            children: [
              AppText(
                text: 'Leaderboard',
                style: AppTextStyles.semiBold(
                  fontSize: 18.sp,
                  color: AppColors.black,
                ),
              ),
              if (board.yourRank != null) ...[
                8.h.verticalSpace,
                AppText(
                  text:
                      'Your rank: #${board.yourRank!.rank} · ${board.yourRank!.totalScore} pts',
                  style: AppTextStyles.medium(
                    fontSize: 13.sp,
                    color: subtitleColor,
                  ),
                ),
              ],
              20.h.verticalSpace,
              if (podium.length >= 3)
                _LeaderboardPodium(
                  second: podium[1],
                  first: podium[0],
                  third: podium[2],
                )
              else if (podium.isNotEmpty)
                ...podium.map(
                  (e) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _LeaderboardListTile(
                      entry: e,
                      subtitleColor: subtitleColor,
                    ),
                  ),
                ),
              if (listEntries.isNotEmpty) ...[
                24.h.verticalSpace,
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listEntries.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.black.withValues(alpha: 0.06),
                      indent: 16.w,
                      endIndent: 16.w,
                    ),
                    itemBuilder: (context, index) {
                      return _LeaderboardListTile(
                        entry: listEntries[index],
                        subtitleColor: subtitleColor,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _LeaderboardPodium extends StatelessWidget {
  const _LeaderboardPodium({
    required this.first,
    required this.second,
    required this.third,
  });

  final LeaderboardEntryModel first;
  final LeaderboardEntryModel second;
  final LeaderboardEntryModel third;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _PodiumPlayer(entry: second, avatarSize: 72.w)),
        Expanded(
          child: _PodiumPlayer(entry: first, avatarSize: 96.w, showCrown: true),
        ),
        Expanded(child: _PodiumPlayer(entry: third, avatarSize: 64.w)),
      ],
    );
  }
}

class _PodiumPlayer extends StatelessWidget {
  const _PodiumPlayer({
    required this.entry,
    required this.avatarSize,
    this.showCrown = false,
  });

  final LeaderboardEntryModel entry;
  final double avatarSize;
  final bool showCrown;

  @override
  Widget build(BuildContext context) {
    final subtitleColor = AppColors.black.withValues(alpha: 0.45);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCrown) ...[
          Icon(
            Icons.emoji_events_rounded,
            color: AppColors.orangeColor,
            size: 28.w,
          ),
          6.h.verticalSpace,
        ] else
          SizedBox(height: 34.h),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: const BoxDecoration(
                color: AppColors.lighttealcolor,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: _LeaderboardAvatar(entry: entry, size: avatarSize),
            ),
            Positioned(
              bottom: -8.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: AppText(
                  text: '${entry.rank}',
                  style: AppTextStyles.semiBold(
                    fontSize: 12.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        18.h.verticalSpace,
        AppText(
          text: entry.displayName,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.semiBold(
            fontSize: 14.sp,
            color: AppColors.black,
          ),
        ),
        4.h.verticalSpace,
        _PointsLabel(points: entry.totalScore, color: subtitleColor),
      ],
    );
  }
}

class _LeaderboardListTile extends StatelessWidget {
  const _LeaderboardListTile({
    required this.entry,
    required this.subtitleColor,
  });

  final LeaderboardEntryModel entry;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = entry.isCurrentUser;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.extealighttealcolor
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        border: isHighlighted
            ? Border.all(color: AppColors.teal.withValues(alpha: 0.25))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.extealighttealcolor,
            ),
            alignment: Alignment.center,
            child: AppText(
              text: '${entry.rank}',
              style: AppTextStyles.semiBold(
                fontSize: 12.sp,
                color: AppColors.teal,
              ),
            ),
          ),
          12.w.horizontalSpace,
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              color: AppColors.lighttealcolor,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: _LeaderboardAvatar(entry: entry, size: 36.w),
          ),
          12.w.horizontalSpace,
          Expanded(
            child: AppText(
              text: entry.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiBold(
                fontSize: 15.sp,
                color: AppColors.black,
              ),
            ),
          ),
          _PointsLabel(points: entry.totalScore, color: subtitleColor),
        ],
      ),
    );
  }
}

class _LeaderboardAvatar extends StatelessWidget {
  const _LeaderboardAvatar({required this.entry, required this.size});

  final LeaderboardEntryModel entry;
  final double size;

  static const _avatarColors = [
    AppColors.teal,
    Color(0xFFE8D9C4),
    Color(0xFFFFB37A),
    Color(0xFFFFA8C5),
    Color(0xFF6B8E9B),
  ];

  Color get _fallbackColor {
    final hash = entry.userId.codeUnits.fold<int>(0, (prev, c) => prev + c);
    return _avatarColors[hash % _avatarColors.length];
  }

  String get _initials {
    final name = entry.displayName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'[\s\-_]+')).where((p) => p.isNotEmpty);
    final letters = parts.map((p) => p[0].toUpperCase()).take(2);
    final result = letters.join();
    return result.isEmpty ? name[0].toUpperCase() : result;
  }

  @override
  Widget build(BuildContext context) {
    final url = entry.avatarUrl;
    if (url != null && url.isNotEmpty) {
      return AppNetworkImage(
        imageUrl: url,
        tag: 'Leaderboard.avatar.${entry.userId}',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorIconOnly: true,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      color: _fallbackColor,
      alignment: Alignment.center,
      child: AppText(
        text: _initials,
        style: AppTextStyles.bold(
          fontSize: (size * 0.34).sp,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _PointsLabel extends StatelessWidget {
  const _PointsLabel({required this.points, required this.color});

  final int points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgIcon(AppAssets.thunder, size: 14.w, color: AppColors.orangeColor),
        4.w.horizontalSpace,
        AppText(
          text: '$points pts',
          style: AppTextStyles.medium(fontSize: 13.sp, color: color),
        ),
      ],
    );
  }
}
