import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/gamification/achievement_progress_model.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/screens/achivements/widgets/streak_calendar_widget.dart';
import 'package:redstreakapp/screens/achivements/widgets/streak_freeze_widget.dart';

class AchivementsScreen extends StatefulWidget {
  const AchivementsScreen({super.key});

  @override
  State<AchivementsScreen> createState() => _AchivementsScreenState();
}

class _AchivementsScreenState extends State<AchivementsScreen> {
  bool _showAllBadges = false;
  bool _showAllMilestones = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GamificationProvider>().fetchStreakScore();
    });
  }

  void _openCalendar(GamificationProvider gp) {
    final days = gp.streakScore?.calendarDays ?? const [];
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            MediaQuery.paddingOf(sheetContext).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              StreakCalendarWidget(
                calendarDays: days,
                onMonthChanged: (year, month) =>
                    gp.fetchStreakScore(month: month, year: year),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer2<GamificationProvider, HomeProvider>(
        builder: (context, gp, home, _) {
          if (gp.isLoadingStreakScore && gp.streakScore == null) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            );
          }

          final data = gp.streakScore;
          if (data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      text: gp.streakScoreError ?? 'Unable to load rewards.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.regular(
                        fontSize: 14,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppFilledButton(
                      text: 'Retry',
                      backgroundColor: AppColors.teal,
                      onTap: () => gp.fetchStreakScore(force: true),
                    ),
                  ],
                ),
              ),
            );
          }

          final goals = data.achievements.allGoals;
          final earned = goals.where((a) => a.completed || a.claimed).toList();
          final locked = goals
              .where((a) => !a.completed && !a.claimed)
              .toList();
          final badges = [...earned, ...locked];
          final milestones = goals.where((a) => a.target > 0).toList();
          final visibleBadges = _showAllBadges
              ? badges
              : badges.take(6).toList();
          final visibleMilestones = _showAllMilestones
              ? milestones
              : milestones.take(4).toList();
          final pagesRead = (home.continueReadingItems ?? const []).fold<int>(
            0,
            (sum, item) => sum + item.readPages,
          );

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.paddingOf(context).top + 12,
                  16,
                  0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: 'Achievement',
                            style: AppTextStyles.semibold(
                              fontSize: 28,
                              color: const Color(0xFF1A1A1A),
                            ).copyWith(height: 1.15, letterSpacing: -0.4),
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            text:
                                'Track your progress and celebrate every spark along the way.',
                            style: AppTextStyles.regular(
                              fontSize: 14,
                              color: const Color(0xFF8E8E93),
                            ).copyWith(height: 1.35),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _openCalendar(gp),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.teal,
                  onRefresh: () => gp.fetchStreakScore(force: true),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    children: [
                      const _RewardsHero(),
                      const SizedBox(height: 8),
                      AppText(
                        text:
                            "You're making a brighter world,\none spark at a time!",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.semibold(
                          fontSize: 16,
                          color: const Color(0xFF1A1A1A),
                        ).copyWith(height: 1.3),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SvgIcon(AppAssets.streakFireIcon, size: 22),
                          const SizedBox(width: 6),
                          AppText(
                            text: '${data.scores.totalScore}',
                            style: AppTextStyles.bold(
                              fontSize: 32,
                              color: const Color(0xFF1A1A1A),
                            ).copyWith(height: 1),
                          ),
                        ],
                      ),
                      AppText(
                        text: 'Sparks Points',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.medium(
                          fontSize: 13,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              value: '${data.streak.currentStreak}',
                              label: 'Day Streaks',
                              background: const Color(0xFFFFF1E8),
                              icon: const SvgIcon(
                                AppAssets.streakFireIcon,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              value: '$pagesRead',
                              label: 'Pages Read',
                              background: const Color(0xFFEAF2FF),
                              icon: const SvgIcon(
                                AppAssets.bookOpenIcon,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              value: '${earned.length}',
                              label: 'Badges',
                              background: const Color(0xFFF3EEFF),
                              icon: const SvgIcon(
                                AppAssets.starOutlined,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const _SectionTitle('Streak Freeze'),
                      const SizedBox(height: 10),
                      StreakFreezeWidget(data: data),
                      if (badges.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        _SectionTitle(
                          'Badges',
                          trailing: badges.length > 6
                              ? _SeeAll(
                                  expanded: _showAllBadges,
                                  onTap: () => setState(
                                    () => _showAllBadges = !_showAllBadges,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _BadgeGrid(badges: visibleBadges),
                      ],
                      if (milestones.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _SectionTitle(
                          'Milestones',
                          trailing: milestones.length > 4
                              ? _SeeAll(
                                  expanded: _showAllMilestones,
                                  onTap: () => setState(
                                    () => _showAllMilestones =
                                        !_showAllMilestones,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        ...visibleMilestones.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _MilestoneRow(achievement: item),
                          ),
                        ),
                        SizedBox(height: 100.w),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RewardsHero extends StatelessWidget {
  const _RewardsHero();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.rewardsTrophy,
      height: 150,
      fit: BoxFit.contain,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.background,
    required this.icon,
  });

  final String value;
  final String label;
  final Color background;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
          const SizedBox(height: 8),
          AppText(
            text: value,
            style: AppTextStyles.bold(
              fontSize: 18,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          AppText(
            text: label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.regular(
              fontSize: 11,   
              color: const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppText(
            text: title,
            style: AppTextStyles.semibold(
              fontSize: 18,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _SeeAll extends StatelessWidget {
  const _SeeAll({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {           
    return GestureDetector(
      onTap: onTap,
      child: AppText(
        text: expanded ? 'See less' : 'See all',
        style: AppTextStyles.medium(
          fontSize: 13,
          color: const Color(0xFF8E8E93),
        ),
      ),
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.badges});

  final List<AchievementProgress> badges;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / 3;
        final rows = <Widget>[];
        for (var i = 0; i < badges.length; i += 3) {
          final slice = badges.skip(i).take(3).toList();
          if (rows.isNotEmpty) rows.add(const SizedBox(height: 16));
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final badge in slice)
                  SizedBox(
                    width: itemWidth,
                    child: _BadgeTile(achievement: badge),
                  ),
              ],
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        );
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.achievement});

  final AchievementProgress achievement;

  bool get _earned => achievement.completed || achievement.claimed;

  @override
  Widget build(BuildContext context) {
    final style = _badgeStyle(achievement.type);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _earned ? style.background : const Color(0xFFF2F2F4),
            shape: BoxShape.circle,
          ),
          child: _earned
              ? style.icon
              : const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFFC7C7CC),
                  size: 26,
                ),
        ),
        const SizedBox(height: 8),
        AppText(
          text: achievement.label.isEmpty ? 'Badge' : achievement.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.semibold(
            fontSize: 12,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 2),
        AppText(
          text: _earned ? 'Earned' : 'Locked',
          style: AppTextStyles.regular(
            fontSize: 11,
            color: const Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.achievement});

  final AchievementProgress achievement;

  @override
  Widget build(BuildContext context) {
    final style = _badgeStyle(achievement.type);
    final title = achievement.label.trim().isEmpty
        ? 'Milestone'
        : achievement.label.trim();
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: style.background,
            shape: BoxShape.circle,
          ),
          child: style.icon,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.semibold(
                  fontSize: 14,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: achievement.progressValue,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE8E8ED),
                  color: style.bar,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        AppText(
          text: '${achievement.progress}/${achievement.target}',
          style: AppTextStyles.medium(
            fontSize: 13,
            color: const Color(0xFF8E8E93),
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFFC7C7CC),
          size: 18,
        ),
      ],
    );
  }
}

class _BadgeStyle {
  const _BadgeStyle({
    required this.background,
    required this.bar,
    required this.icon,
  });

  final Color background;
  final Color bar;
  final Widget icon;
}

_BadgeStyle _badgeStyle(String type) {
  switch (type) {
    case 'series':
      return const _BadgeStyle(
        background: Color(0xFFEAF2FF),
        bar: Color(0xFF4C8DFF),
        icon: Icon(Icons.menu_book_rounded, size: 22, color: Color(0xFF4C8DFF)),
      );
    case 'interest':
      return const _BadgeStyle(
        background: Color(0xFFE7F8EF),
        bar: Color(0xFF3DDC97),
        icon: Icon(Icons.spa_outlined, size: 22, color: Color(0xFF3DDC97)),
      );
    case 'streak':
      return const _BadgeStyle(
        background: Color(0xFFF3EEFF),
        bar: Color(0xFF8B6CFF),
        icon: Icon(Icons.star_rounded, size: 22, color: Color(0xFF8B6CFF)),
      );
    default:
      return const _BadgeStyle(
        background: Color(0xFFFFF1E8),
        bar: Color(0xFFF28518),
        icon: SvgIcon(AppAssets.thunder, size: 20),
      );
  }
}
