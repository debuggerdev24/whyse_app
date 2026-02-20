import 'package:animate_do/animate_do.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';

import 'package:redstreakapp/providers/auth/auth_provider.dart';

import 'package:redstreakapp/routes/user_routes.dart';


class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              SvgIcon(
                AppAssets.thunder,
                size: 20.w,
                color: AppColors.primaryColor,
              ),
              10.w.horizontalSpace,
              AppText(
                text: "2",
                style: AppTextStyles.sfProDisplaySemibold(
                  fontSize: 16.sp,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),

        // Title
        AppText(
          text: "Your Plan",
          style: AppTextStyles.sfProDisplaySemibold(fontSize: 20.sp),
        ),

        // Notification & Profile
        Row(
          children: [
            SvgIcon(AppAssets.notification, size: 24.w),
            12.w.horizontalSpace,
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
        5.h.verticalSpace,

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

        6.h.verticalSpace,
        AppText(
          text: "1/3 Exercises",
          style: AppTextStyles.sfProDisplayBold(
            fontSize: 12.sp,
            color: AppColors.black.withValues(alpha: 0.4),
          ),
        ),
        13.h.verticalSpace,
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
                    6.h.verticalSpace,
                    AppText(
                      text: days[index],
                      style: AppTextStyles.sfProDisplaySemibold(
                        fontSize: 12.sp,
                        color: AppColors.black.withValues(alpha: 0.4),
                      ),
                    ),
                    4.h.verticalSpace,
                    AppText(
                      text: dates[index],
                      style: AppTextStyles.sfProDisplayBold(
                        fontSize: 14.sp,
                        color: AppColors.black,
                      ),
                    ),
                    if (isChecked) ...[
                      4.h.verticalSpace,
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



class PracticeZoneSection extends StatelessWidget {
  const PracticeZoneSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: "Practice Zone",
          style: AppTextStyles.sfProDisplayBold(fontSize: 20.sp),
        ),
        16.h.verticalSpace,
        PracticeCard(
          title: "Vocabulary\nQuizzes",
          subtitle: "Solve 10 Quiz Questions",
          icon: AppAssets.vocabulary,
          reward: "3",
        ),
        16.h.verticalSpace,
        PracticeCard(
          title: "Pronunciation\nDrills",
          subtitle: "Solve 2 Drills",
          icon: AppAssets.pronunciation,
          reward: "3",
        ),
        16.h.verticalSpace,
        PracticeCard(
          title: "Comprehension\nChecks",
          subtitle: "Solve 2 Comprehensions",
          icon: AppAssets.comprehension,
          reward: "3",
        ),
      ],
    );
  }
}

class PracticeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final String reward;

  const PracticeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  style: AppTextStyles.sfProDisplayBold(fontSize: 20.sp),
                ),
                Divider(
                  color: AppColors.black.withValues(alpha: 0.1),
                  thickness: 0,
                ),

                Row(
                  children: [
                    AppText(
                      text: subtitle,
                      style: AppTextStyles.textStyle14Regular.copyWith(
                        color: Colors.grey[600],
                        fontSize: 13.sp,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.black.withValues(alpha: 0.1),
                          width: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                16.h.verticalSpace,
                Row(
                  children: [
                    ActionButton(text: "Start", color: AppColors.teal),
                  ],
                ),
              ],
            ),
          ),
          12.w.horizontalSpace,
          Column(
            children: [
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: SvgIcon(icon, size: 72.w),
              ),
              22.h.verticalSpace,
              Row(
                children: [
                  SvgIcon(
                    AppAssets.thunder,
                    size: 16.w,
                    color: AppColors.primaryColor,
                  ),
                  4.w.horizontalSpace,
                  AppText(
                    text: "3",
                    style: AppTextStyles.sfProDisplayBold(
                      color: AppColors.primaryColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
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
          12.h.verticalSpace,
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
          8.h.verticalSpace,
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


