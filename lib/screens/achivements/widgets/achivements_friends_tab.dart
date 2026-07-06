import 'package:redstreakapp/core/utils/app_imports.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.points,
    this.isCurrentUser = false,
  });

  final int rank;
  final String name;
  final int points;
  final bool isCurrentUser;
}

const _leaderboardEntries = [
  LeaderboardEntry(rank: 1, name: 'Emma Rodriguez', points: 43),
  LeaderboardEntry(rank: 2, name: 'Liam Kumar', points: 40),
  LeaderboardEntry(rank: 3, name: 'Sofia Mendes', points: 38),
  LeaderboardEntry(rank: 4, name: 'Noah Patel', points: 35),
  LeaderboardEntry(rank: 5, name: 'You', points: 32, isCurrentUser: true),
  LeaderboardEntry(rank: 6, name: 'Ava Chen', points: 28),
  LeaderboardEntry(rank: 7, name: 'Lucas Brown', points: 24),
  LeaderboardEntry(rank: 8, name: 'Mia Johnson', points: 20),
  LeaderboardEntry(rank: 9, name: 'Ethan Davis', points: 16),
  LeaderboardEntry(rank: 10, name: 'Isla Wilson', points: 12),
];

class AchivementsFriendsTab extends StatelessWidget {
  const AchivementsFriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final podium = _leaderboardEntries.take(3).toList();
    final listEntries = _leaderboardEntries.skip(3).toList();
    final subtitleColor = AppColors.black.withValues(alpha: 0.45);

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      children: [
        AppText(
          text: 'Leaderboard',
          style: AppTextStyles.semiBold(
            fontSize: 18.sp,
            color: AppColors.black,
          ),
        ),
        20.h.verticalSpace,
        _LeaderboardPodium(
          second: podium[1],
          first: podium[0],
          third: podium[2],
        ),
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
    );
  }
}

class _LeaderboardPodium extends StatelessWidget {
  const _LeaderboardPodium({
    required this.first,
    required this.second,
    required this.third,
  });

  final LeaderboardEntry first;
  final LeaderboardEntry second;
  final LeaderboardEntry third;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _PodiumPlayer(entry: second, avatarSize: 72.w),
        ),
        Expanded(
          child: _PodiumPlayer(entry: first, avatarSize: 96.w, showCrown: true),
        ),
        Expanded(
          child: _PodiumPlayer(entry: third, avatarSize: 64.w),
        ),
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

  final LeaderboardEntry entry;
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
              child: Icon(
                Icons.person_rounded,
                color: AppColors.teal,
                size: avatarSize * 0.42,
              ),
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
          text: entry.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.semiBold(
            fontSize: 14.sp,
            color: AppColors.black,
          ),
        ),
        4.h.verticalSpace,
        _PointsLabel(points: entry.points, color: subtitleColor),
      ],
    );
  }
}

class _LeaderboardListTile extends StatelessWidget {
  const _LeaderboardListTile({
    required this.entry,
    required this.subtitleColor,
  });

  final LeaderboardEntry entry;
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
            child: Icon(
              Icons.person_rounded,
              color: AppColors.teal,
              size: 18.w,
            ),
          ),
          12.w.horizontalSpace,
          Expanded(
            child: AppText(
              text: entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiBold(
                fontSize: 15.sp,
                color: AppColors.black,
              ),
            ),
          ),
          _PointsLabel(points: entry.points, color: subtitleColor),
        ],
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
