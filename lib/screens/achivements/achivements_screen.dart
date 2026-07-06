import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/achivements/widgets/achivement_tab_bar_selection.dart';
import 'package:redstreakapp/screens/achivements/widgets/achivements_friends_tab.dart';
import 'package:redstreakapp/screens/achivements/widgets/streak_calendar_widget.dart';
import 'package:redstreakapp/screens/achivements/widgets/streak_coutner_widget.dart';
import 'package:redstreakapp/screens/achivements/widgets/streak_goal_widget.dart';

class AchivementsScreen extends StatefulWidget {
  const AchivementsScreen({super.key});

  @override
  State<AchivementsScreen> createState() => _AchivementsScreenState();
}

class _AchivementsScreenState extends State<AchivementsScreen> {
  static const _streakCount = 1;
  static const weeklyGoalDays = 7;

  int _selectedTab = 0;

  Set<int> get _streakDays {
    final now = DateTime.now();
    final days = <int>{};
    for (var i = 0; i < _streakCount; i++) {
      final day = now.day - i;
      if (day >= 1) days.add(day);
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: SvgIcon(AppAssets.close, size: 22.w, color: AppColors.black),
        ),
        centerTitle: true,
        title: AppText(
          text: 'Achievements',
          style: AppTextStyles.semiBold(fontSize: 20.sp, color: AppColors.black),
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.only(right: 22.w),
              child: SvgIcon(AppAssets.shareIcon, size: 24.w),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AchivementsTabBarSelection(
            onTabSelected: (index) => setState(() => _selectedTab = index),
          ),
          Expanded(
            child: _selectedTab == 0
                ? _PersonalAchievementsTab(
                    streakDays: _streakDays,
                    streakCount: _streakCount,
                  )
                : const AchivementsFriendsTab(),
          ),
        ],
      ),
    );
  }
}

class _PersonalAchievementsTab extends StatelessWidget {
  const _PersonalAchievementsTab({
    required this.streakDays,
    required this.streakCount,
  });

  final Set<int> streakDays;
  final int streakCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 32.h),
      children: [
        StreakCoutnerWidget(streakCount: streakCount),
        32.h.verticalSpace,
        StreakCalendarWidget(streakDays: streakDays),
        28.h.verticalSpace,
        StreakGoalWidget(
          title: 'ONE WEEK',
          currentDays: streakCount,
          targetDays: _AchivementsScreenState.weeklyGoalDays,
        ),
      ],
    );
  }
}
