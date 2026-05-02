import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/user_avatar_image.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: AppColors.black.withValues(alpha: 0.12)),
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
                text: "2",
                style: AppTextStyles.bold(
                  fontSize: 20.sp,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: AppText(
              text: "Your Readings",
              style: AppTextStyles.bold(fontSize: 21.sp),
            ),
          ),
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
              // onTap: () => showLogOutConfirmationDialog(context: context),
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

class CalendarStrip extends StatelessWidget {
  const CalendarStrip({super.key});

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

  // String _monthName(int month) {
  //   const months = [
  //     'January',
  //     'February',
  //     'March',
  //     'April',
  //     'May',
  //     'June',
  //     'July',
  //     'August',
  //     'September',
  //     'October',
  //     'November',
  //     'December',
  //   ];
  //   return months[month - 1];
  // }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthDates = _getCurrentMonthDates();
    // final monthTitle = "${_monthName(now.month)} ${now.year}";
    final todayIndex = monthDates.indexWhere(
      (date) =>
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day,
    );
    final scrollController = ScrollController(
      initialScrollOffset: todayIndex > 0 ? (todayIndex - 1) * 57.w : 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AppText(
        //   text: monthTitle,
        //   style: AppTextStyles.bold(
        //     fontSize: 12.sp,
        //     color: AppColors.black.withValues(alpha: 0.6),
        //   ),
        // ),
        // AppText(
        //   text: "Weekly goal",
        //   style: AppTextStyles.bold(fontSize: 12.sp),
        // ),
        // 5.w.verticalSpace,

        // SizedBox(
        //   width: double.infinity,
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: Container(
        //           height: 4.h,
        //           decoration: BoxDecoration(
        //             color: AppColors.orangeColor,
        //             borderRadius: BorderRadius.circular(2.r),
        //           ),
        //         ),
        //       ),
        //       4.w.horizontalSpace,
        //       Expanded(
        //         child: Container(
        //           height: 4.h,
        //           decoration: BoxDecoration(
        //             color: Colors.grey.shade200,
        //             borderRadius: BorderRadius.circular(2.r),
        //           ),
        //         ),
        //       ),
        //       4.w.horizontalSpace,
        //       Expanded(
        //         child: Container(
        //           height: 4.h,
        //           decoration: BoxDecoration(
        //             color: Colors.grey.shade200,
        //             borderRadius: BorderRadius.circular(2.r),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // 6.w.verticalSpace,
        // AppText(
        //   text: "1/3 Exercises",
        //   style: AppTextStyles.bold(
        //     fontSize: 12.sp,
        //     color: AppColors.black.withValues(alpha: 0.4),
        //   ),
        // ),
        13.w.verticalSpace,
        Container(
          height: 85.h,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.black.withValues(alpha: 0.12)),
          ),
          padding: EdgeInsets.only(top: 10.w, bottom: 10.w),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: monthDates.length,
            separatorBuilder: (_, __) => 5.w.horizontalSpace,
            itemBuilder: (context, index) {
              final date = monthDates[index];
              final isToday =
                  date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              return SizedBox(
                width: 52.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AppText(
                      text: _weekdayShort(date),
                      style: AppTextStyles.bold(
                        fontSize: 14.sp,
                        color: AppColors.black.withValues(alpha: 0.35),
                      ),
                    ),
                    5.h.verticalSpace,
                    Container(
                      width: 35.h,
                      height: 35.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday
                            ? AppColors.orangeColor
                            : Colors.transparent,
                      ),
                      child: AppText(
                        text: date.day.toString(),
                        style: AppTextStyles.bold(
                          fontSize: 14,
                          color: isToday
                              ? AppColors.black
                              : AppColors.black.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
