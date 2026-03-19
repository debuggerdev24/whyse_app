import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/home_widgets.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';

class PracticeZoneSection extends StatelessWidget {
  const PracticeZoneSection({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.goNamed(AppRoutes.homeScreen.name);
      },
      child: AppLayout(
        body: SafeArea(
          child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.w),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.goNamed(AppRoutes.homeScreen.name),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18.w,
                    color: AppColors.black,
                  ),
                ),
                8.w.horizontalSpace,
                AppText(
                  text: "Practice Zone",
                  style: AppTextStyles.sfProDisplayBold(fontSize: 20.sp),
                ),
              ],
            ),
            16.w.verticalSpace,
            PracticeCard(
              title: "Vocabulary\nQuizzes",
              subtitle: "Solve 10 Quiz Questions",
              icon: AppAssets.vocabulary,
              reward: "3",
            ),
            16.w.verticalSpace,
            PracticeCard(
              title: "Pronunciation\nDrills",
              subtitle: "Solve 2 Drills",
              icon: AppAssets.pronunciation,
              reward: "3",
            ),
            16.w.verticalSpace,
            PracticeCard(
              title: "Comprehension\nChecks",
              subtitle: "Solve 2 Comprehensions",
              icon: AppAssets.comprehension,
              reward: "3",
            ),
            24.w.verticalSpace,
            BottomStatsCard(),
          ],
        ),
      ),
      ),
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
                16.w.verticalSpace,
                ActionButton(text: "Start", color: AppColors.teal),
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
              22.w.verticalSpace,
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
