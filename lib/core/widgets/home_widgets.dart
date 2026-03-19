import 'package:animate_do/animate_do.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';

import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/core/routes/app_router.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/screens/dashboard.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo / app icon (Netflix-style left)
        SvgIcon(
          AppAssets.note,
          size: 28.w,
          color: AppColors.teal,
        ),
        // Center title
        AppText(
          text: "Story Topics",
          style: AppTextStyles.sfProDisplayBold(fontSize: 18.sp),
        ),
        // Search + Profile (Netflix-style right)
        Row(
          children: [
            GestureDetector(
              onTap: () {
                tabIndex.value = 1;
                AppRouter.indexedStackNavigationShell?.goBranch(1);
              },
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: SvgIcon(AppAssets.searchIcon, size: 24.w),
              ),
            ),
            4.w.horizontalSpace,
            GestureDetector(
              onTap: () {
                showLogOutConfirmationDialog(context: context);
                // showDialog(
                //   context: context,
                //   builder: (context) => AlertDialog(
                //     title: const Text("Log Out"),
                //     content: const Text("Are you sure you want to Log Out?"),
                //     actions: [
                //       TextButton(
                //         onPressed: () => Navigator.pop(context),
                //         child: const Text("Cancel"),
                //       ),
                //       TextButton(
                //         onPressed: () {
                //           Navigator.pop(context);
                //           context.read<AuthProvider>().logOutUser(context);
                //         },
                //         child: const Text(
                //           "Log Out",
                //           style: TextStyle(color: Colors.red),
                //         ),
                //       ),
                //     ],
                //   ),
                // );
              },
              child: CircleAvatar(
                radius: 18.w,
                backgroundImage: AssetImage(AppAssets.profile),
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
        style: AppTextStyles.sfProDisplayRegular(
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
          style: AppTextStyles.sfProDisplayBold(fontSize: 12.sp),
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
                    color: AppColors.primaryColor,
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
          style: AppTextStyles.sfProDisplayBold(
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
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10.r),
                            bottomLeft: Radius.circular(10.r),
                          ),
                        ),
                      ),
                    6.w.verticalSpace,
                    AppText(
                      text: days[index],
                      style: AppTextStyles.sfProDisplaySemibold(
                        fontSize: 12.sp,
                        color: AppColors.black.withValues(alpha: 0.4),
                      ),
                    ),
                    4.w.verticalSpace,
                    AppText(
                      text: dates[index],
                      style: AppTextStyles.sfProDisplayBold(
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
                style: AppTextStyles.sfProDisplayBold(
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
                style: AppTextStyles.sfProDisplayMedium(
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


