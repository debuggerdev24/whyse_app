import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/screens/achivements/widgets/achivement_tab_bar_selection.dart';
import 'package:redstreakapp/screens/achivements/widgets/achivements_friends_tab.dart';
import 'package:redstreakapp/screens/achivements/widgets/achievement_goal_card.dart';
import 'package:redstreakapp/screens/achivements/widgets/streak_calendar_widget.dart';
import 'package:redstreakapp/screens/achivements/widgets/streak_coutner_widget.dart';
import 'package:redstreakapp/screens/achivements/widgets/streak_freeze_widget.dart';
import 'package:redstreakapp/screens/achivements/widgets/streak_goal_widget.dart';
import 'package:redstreakapp/screens/achivements/widgets/user_points_widget.dart';

class AchivementsScreen extends StatefulWidget {
  const AchivementsScreen({super.key});

  @override
  State<AchivementsScreen> createState() => _AchivementsScreenState();
}

class _AchivementsScreenState extends State<AchivementsScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final gp = context.read<GamificationProvider>();
      gp.fetchStreakScore();
      gp.fetchLeaderboard(scope: 'friends');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   onPressed: () => context.pop(),
        //   icon: SvgIcon(AppAssets.close, size: 22.w, color: AppColors.black),
        // ),
        centerTitle: true,
        title: AppText(
          text: 'Achievements',
          style: AppTextStyles.semiBold(
            fontSize: 20.sp,
            color: AppColors.black,
          ),
        ),
        // actions: [
        //   GestureDetector(
        //     onTap: () {},
        //     child: Padding(
        //       padding: EdgeInsets.only(right: 22.w),
        //       child: SvgIcon(AppAssets.shareIcon, size: 24.w),
        //     ),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          AchivementsTabBarSelection(
            onTabSelected: (index) => setState(() => _selectedTab = index),
          ),
          Expanded(
            child: _selectedTab == 0
                ? const _PersonalAchievementsTab()
                : const AchivementsFriendsTab(),
          ),
        ],
      ),
    );
  }
}

class _PersonalAchievementsTab extends StatelessWidget {
  const _PersonalAchievementsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationProvider>(
      builder: (context, gp, _) {
        if (gp.isLoadingStreakScore && gp.streakScore == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = gp.streakScore;
        if (data == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: gp.streakScoreError ?? 'Unable to load streak data.',
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
                    onTap: () => gp.fetchStreakScore(force: true),
                  ),
                ],
              ),
            ),
          );
        }

        final achievements = data.achievements;
        final activeStreakGoal = achievements.activeStreakGoal;
        final upcomingStreakGoals = achievements.streak
            .where((a) => !a.isActiveGoal && !a.completed && !a.claimed)
            .toList();

        return RefreshIndicator(
          onRefresh: () => gp.fetchStreakScore(force: true),
          child: ListView(
            padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 32.h),
            children: [
              StreakCoutnerWidget(
                streakCount: data.streak.currentStreak,
                longestStreak: data.streak.longestStreak,
              ),
              20.h.verticalSpace,
              UserPointsWidget(totalPoints: data.scores.totalScore),
              28.h.verticalSpace,
              StreakFreezeWidget(data: data),   
              28.h.verticalSpace,
              StreakCalendarWidget(
                calendarDays: data.calendarDays,
                onMonthChanged: (year, month) =>
                    gp.fetchStreakScore(month: month, year: year),
              ),
              if (activeStreakGoal != null) ...[
                28.h.verticalSpace,
                StreakGoalWidget(achievement: activeStreakGoal),
              ],
              if (achievements.spark.isNotEmpty) ...[
                28.h.verticalSpace,
                AchievementsSectionWidget(
                  title: 'Spark Achievements',
                  achievements: achievements.spark,
                ),
              ],
              if (achievements.series.isNotEmpty) ...[
                28.h.verticalSpace,
                AchievementsSectionWidget(
                  title: 'Series Achievements',
                  achievements: achievements.series,
                ),
              ],
              if (achievements.interest.isNotEmpty) ...[
                28.h.verticalSpace,
                AchievementsSectionWidget(
                  title: 'Interest Achievements',
                  achievements: achievements.interest,
                ),
              ],
              if (upcomingStreakGoals.isNotEmpty) ...[
                28.h.verticalSpace,
                AchievementsSectionWidget(
                  title: 'Upcoming Streak Goals',
                  achievements: upcomingStreakGoals,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
