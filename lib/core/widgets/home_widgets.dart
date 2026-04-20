import 'package:flutter_svg/svg.dart';

import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';

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
                  border: Border.all(color: const Color(0xFFE5D9B8), width: 3.w),
                ),
                child: ClipOval(
                  child: Image.asset(
                    AppAssets.profile,
                    fit: BoxFit.cover,
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

                  //    onSuccess: () {
                  //                       AppToast.showSuccess(
                  //
                  //                          context,
                  //                         "Log Out Successfully",
                  //                       );
                  //                       context.goNamed(UserAppRoutes.loginScreen.name);
                  //                     },
                  //                     onFailed: (error) {
                  //                       AppToast.showError( context,"Log out failed");
                  //                     },
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

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dates = ['18', '19', '20', '21', '22', '23', '24'];
    final status = ["check", null, 'check', 'check', 'today', null, null];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: "Weekly goal",
          style: AppTextStyles.bold(fontSize: 12.sp),
        ),
        5.w.verticalSpace,

        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.orangeColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              4.w.horizontalSpace,
              Expanded(
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              4.w.horizontalSpace,
              Expanded(
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ],
          ),
        ),

        6.w.verticalSpace,
        AppText(
          text: "1/3 Exercises",
          style: AppTextStyles.bold(
            fontSize: 12.sp,
            color: AppColors.black.withValues(alpha: 0.4),
          ),
        ),
        13.w.verticalSpace,
        SizedBox(
          height: 76.h,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: days.length,
            separatorBuilder: (_, __) => 9.w.horizontalSpace,
            itemBuilder: (context, index) {
              final isChecked = status[index] == 'check';
              final isToday = status[index] == 'today';

              return Container(
                width: 50.w,
                height: 68.h,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.lighttealcolor
                      : isChecked
                      ? AppColors.lightyellowcolor
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10.r),
                    bottomLeft: Radius.circular(10.r),
                  ),
                ),

                child: Column(
                  children: [
                    if (isChecked)
                      Container(
                        height: 3.w,
                        decoration: BoxDecoration(
                          color: AppColors.orangeColor,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10.r),
                            bottomLeft: Radius.circular(10.r),
                          ),
                        ),
                      ),
                    6.w.verticalSpace,
                    AppText(
                      text: days[index],
                      style: AppTextStyles.semibold(
                        fontSize: 12.sp,
                        color: AppColors.black.withValues(alpha: 0.4),
                      ),
                    ),
                    4.w.verticalSpace,
                    AppText(
                      text: dates[index],
                      style: AppTextStyles.bold(
                        fontSize: 14.sp,
                        color: AppColors.black,
                      ),
                    ),
                    if (isChecked) ...[
                      4.w.verticalSpace,
                      SvgPicture.asset(AppAssets.check1),
                    ],
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


