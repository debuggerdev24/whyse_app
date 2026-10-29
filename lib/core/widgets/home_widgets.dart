import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/user_avatar_image.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  String _greetingName(ProfileProvider profile) {
    final first = profile.profileData?.firstName.trim() ?? '';
    if (first.isNotEmpty) return first;
    final display = profile.profileData?.displayName.trim() ?? '';
    if (display.isNotEmpty) return display.split(' ').first;
    return 'there';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pushNamed(AppRoutes.profileScreen.name),
          child: Container(
            width: 46.w,
            height: 46.w,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: Consumer<ProfileProvider>(
                builder: (context, profile, _) {
                  return UserAvatarImage(
                    avatarUrl: profile.profileData?.avatarUrl,
                    size: 46.w,
                    showPlaceholderShimmerWhenEmpty:
                        profile.getProfileState == DataState.loading,
                  );
                },
              ),
            ),
          ),
        ),
        12.w.horizontalSpace,
        Expanded(
          child: Consumer<ProfileProvider>(
            builder: (context, profile, _) {
              final name = _greetingName(profile);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hey, ',
                          style: AppTextStyles.bold(
                            fontSize: 28,
                            height: 1.05,
                            letterSpacing: -0.6,
                            color: AppColors.black,
                          ),
                        ),
                        TextSpan(
                          text: '$name!',
                          style: AppTextStyles.bold(
                            fontSize: 28,
                            height: 1.05,
                            letterSpacing: -0.6,
                            color: AppColors.highlight,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  2.h.verticalSpace,
                  AppText(
                    text: 'Ready for a new adventure?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium(
                      fontSize: 16,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        GlassIconButton(
          onTap: () =>
              context.pushNamed(AppRoutes.homeAchivementsScreen.name),
          child: const SvgIcon(AppAssets.streakFireIcon, size: 24),
        ),
        const SizedBox(width: 10),
        GlassIconButton(
          onTap: () => context.pushNamed(AppRoutes.notificationScreen.name),
          child: SvgIcon(
            AppAssets.notification,
            size: 24,
            color: AppColors.black,
          ),
        ),
      ],
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
        date.year == now.year && date.month == now.month && date.day == now.day;
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
                  ? AppColors.orangeColor.withValues(alpha: 0.25)
                  : Colors.transparent,
              border: isToday && !hasStreakHighlight
                  ? Border.all(color: AppColors.orangeColor, width: 2)
                  : null,
            ),
            child: isFrozen
                ? Icon(
                    Icons.ac_unit_rounded,
                    size: 14.w,
                    color: AppColors.onFill,
                  )
                : AppText(
                    text: date.day.toString(),
                    style: AppTextStyles.bold(
                      fontSize: 13.sp,
                      height: 1,
                      color: isCompleted
                          ? AppColors.onFill
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
                isFrozen: streakScore?.isDateFrozen(monthDates[index]) ?? false,
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
                  color: AppColors.onFill,
                  letterSpacing: 1,
                ),
              ),
              AppText(
                text: "OXFORD",
                style: AppTextStyles.textStyle16Regular.copyWith(
                  color: AppColors.onFill.withValues(alpha: 0.5),
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
                  color: AppColors.onFill,
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
