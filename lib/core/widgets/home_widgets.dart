import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/user_avatar_image.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  static String _streakLabel(int days) {
    if (days <= 0) return '0 days';
    if (days == 1) return '1 day';
    if (days % 7 == 0) {
      final weeks = days ~/ 7;
      return weeks == 1 ? '1 week' : '$weeks weeks';
    }
    return '$days days';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileProvider, GamificationProvider>(
      builder: (context, profile, gp, _) {
        final firstName = profile.profileData?.firstName.trim() ?? '';
        final name = firstName.isNotEmpty ? firstName : 'there';
        final streakDays = gp.streakScore?.streak.currentStreak ?? 0;
        return Row(
          children: [
            GestureDetector(
              onTap: () => context.pushNamed(AppRoutes.profileScreen.name),
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2.w),
                ),
                child: ClipOval(
                  child: UserAvatarImage(
                    avatarUrl: profile.profileData?.avatarUrl,
                    size: 44.w,
                    showPlaceholderShimmerWhenEmpty:
                        profile.getProfileState == DataState.loading,
                  ),
                ),
              ),
            ),
            10.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: 'Hey, $name!',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(
                      fontSize: 20.sp,
                      color: AppColors.black,
                    ),
                  ),
                  AppText(
                    text: 'Ready for a new adventure?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium(
                      fontSize: 12.sp,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.pushNamed(AppRoutes.achivementsScreen.name),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgIcon(
                      AppAssets.thunder,
                      size: 14.w,
                      color: AppColors.orangeColor,
                    ),
                    4.w.horizontalSpace,
                    AppText(
                      text: _streakLabel(streakDays),
                      style: AppTextStyles.semibold(
                        fontSize: 12.sp,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            8.w.horizontalSpace,
            GestureDetector(
              onTap: () => context.pushNamed(AppRoutes.notificationScreen.name),
              child: SvgIcon(
                AppAssets.notification,
                size: 22.w,
                color: AppColors.black,
              ),
            ),
            8.w.horizontalSpace,
            GestureDetector(
              onTap: () => context.pushNamed(AppRoutes.settingsScreen.name),
              child: Icon(
                Icons.settings_outlined,
                size: 22.sp,
                color: AppColors.black,
              ),
            ),
          ],
        );
      },
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
    required bool isFrozen,
    required double dayCircleSize,
  }) {
    final isToday =
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final hasStreakHighlight = isCompleted || isFrozen;

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
                  : isFrozen
                  ? AppColors.streakFreezeBlue
                  : isToday
                  ? AppColors.orangeColor.withValues(alpha: 0.25)
                  : Colors.transparent,
              border: isToday && !hasStreakHighlight
                  ? Border.all(
                      color: AppColors.orangeColor,
                      width: 2,
                    )
                  : null,
            ),
            child: isFrozen
                ? Icon(
                    Icons.ac_unit_rounded,
                    size: 14.w,
                    color: AppColors.onImage,
                  )
                : AppText(
                    text: date.day.toString(),
                    style: AppTextStyles.bold(
                      fontSize: 13.sp,
                      height: 1,
                      color: isCompleted
                          ? AppColors.onImage
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
                isFrozen:
                    streakScore?.isDateFrozen(monthDates[index]) ?? false,
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
                  color: AppColors.onImage,
                  letterSpacing: 1,
                ),
              ),
              AppText(
                text: "OXFORD",
                style: AppTextStyles.textStyle16Regular.copyWith(
                  color: AppColors.onImage.withValues(alpha: 0.5),
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
                  color: AppColors.onImage,
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
