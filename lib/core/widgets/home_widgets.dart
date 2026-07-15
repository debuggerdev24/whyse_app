import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/user_avatar_image.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  static String _formatSparkPoints(int points) {
    if (points >= 1000000) {
      return '${(points / 1000000).toStringAsFixed(1)}M';
    }
    if (points >= 10000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    }
    return '$points';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Consumer<GamificationProvider>(
                builder: (context, gp, _) {
                  final sparkPoints =
                      gp.streakScore?.scores.totalScore ?? 0;
                  return GestureDetector(
                    onTap: () =>
                        context.pushNamed(AppRoutes.achivementsScreen.name),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(
                          color: AppColors.black.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10.w,
                        children: [
                          SvgIcon(
                            AppAssets.thunder,
                            size: 17.w,
                            color: AppColors.orangeColor,
                          ),
                          AppText(
                            text: _formatSparkPoints(sparkPoints),
                            style: AppTextStyles.bold(
                              fontSize: 20.sp,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(AppRoutes.notificationScreen.name);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: SvgIcon(
                        AppAssets.notification,
                        size: 25.w,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(AppRoutes.profileScreen.name);
                    },
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5D9B8),
                          width: 3.w,
                        ),
                      ),
                      child: ClipOval(
                        child: Consumer<ProfileProvider>(
                          builder: (context, profile, _) {
                            return UserAvatarImage(
                              avatarUrl: profile.profileData?.avatarUrl,
                              size: 40.w,
                              showPlaceholderShimmerWhenEmpty:
                                  profile.getProfileState == DataState.loading,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          IgnorePointer(
            child: AppText(
              text: "Home",
              style: AppTextStyles.bold(fontSize: 21.sp),
            ),
          ),
        ],
      ),
    );
  }

  void showLogOutConfirmationDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ZoomIn(
          child: AlertDialog(
            title: Text(
              "Are you sure you want to Log Out?",
              style: AppTextStyles
                  .textStyle20Regular, //regular(color: AppColors.black, fontSize: 19.sp),
            ),
            actions: [
              myActionButtonTheme(
                onPressed: () async {
                  await context.read<AuthProvider>().logOutUser(
                    onSuccess: () {
                      AppToast.success(context, "Log out successfully");
                      context.goNamed(AppRoutes.loginScreen.name);
                    },
                  );
                },
                title: "Yes",
              ),
              myActionButtonTheme(
                onPressed: () {
                  context.pop();
                },
                title: "Cancel",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget myActionButtonTheme({
    required VoidCallback onPressed,
    required String title,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: AppTextStyles.regular(
          color: (title == "Yes") ? AppColors.redColor : AppColors.black,
          fontSize: 17.sp,
        ),
      ),
    );
  }
}

class CalendarStrip extends StatefulWidget {
  const CalendarStrip({super.key});

  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  late final ScrollController _scrollController;

  List<DateTime> _getCurrentMonthDates() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    return List<DateTime>.generate(
      end.day,
      (index) => start.add(Duration(days: index)),
    );
  }

  String _weekdayShort(DateTime date) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[date.weekday - 1];
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
  }

  void _scrollToToday() {
    if (!mounted || !_scrollController.hasClients) return;
    final now = DateTime.now();
    final monthDates = _getCurrentMonthDates();
    final todayIndex = monthDates.indexWhere(
      (date) =>
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day,
    );
    if (todayIndex <= 0) return;
    _scrollController.jumpTo((todayIndex - 1) * 57.w);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildDayItem({
    required DateTime date,
    required DateTime now,
    required bool isCompleted,
    required double dayCircleSize,
  }) {
    final isToday =
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    return SizedBox(
      width: 52.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: _weekdayShort(date),
            style: AppTextStyles.bold(
              fontSize: 11.sp,
              height: 1.1,
              color: AppColors.black.withValues(alpha: 0.35),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.w),
          Container(
            width: dayCircleSize,
            height: dayCircleSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppColors.orangeColor
                  : isToday
                  ? AppColors.orangeColor.withValues(alpha: 0.25)
                  : Colors.transparent,
              border: isToday && !isCompleted
                  ? Border.all(
                      color: AppColors.orangeColor,
                      width: 2,
                    )
                  : null,
            ),
            child: AppText(
              text: date.day.toString(),
              style: AppTextStyles.bold(
                fontSize: 13.sp,
                height: 1,
                color: isCompleted
                    ? AppColors.white
                    : isToday
                    ? AppColors.black
                    : AppColors.black.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthDates = _getCurrentMonthDates();
    final dayCircleSize = 30.w;
    final streakScore = context.watch<GamificationProvider>().streakScore;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.black.withValues(alpha: 0.12)),
      ),
      padding: EdgeInsets.symmetric(vertical: 10.w),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (var index = 0; index < monthDates.length; index++) ...[
              if (index > 0) 5.w.horizontalSpace,
              _buildDayItem(
                date: monthDates[index],
                now: now,
                isCompleted:
                    streakScore?.isDateCompleted(monthDates[index]) ?? false,
                dayCircleSize: dayCircleSize,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BottomStatsCard extends StatelessWidget {
  const BottomStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.bluecolor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: "Oxford Vocabulary",
                style: AppTextStyles.bold(
                  fontSize: 16.sp,
                  color: AppColors.white,
                  letterSpacing: 1,
                ),
              ),
              AppText(
                text: "OXFORD",
                style: AppTextStyles.textStyle16Regular.copyWith(
                  color: AppColors.white.withValues(alpha: 0.5),
                  fontSize: 14.sp,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          12.w.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: "3,500/5,000",
                style: AppTextStyles.medium(
                  fontSize: 12.sp,
                  color: AppColors.white,
                ),
              ),
              AppText(
                text: "60%",
                style: AppTextStyles.textStyle14Bold.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          8.w.verticalSpace,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(AppColors.darkgreenColor),
              minHeight: 6.h,
              borderRadius: BorderRadius.circular(42.r),
            ),
          ),
        ],
      ),
    );
  }
}
