import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HomeHeader(),
              24.h.verticalSpace,
              const _CalendarStrip(),
              24.h.verticalSpace,
              const _YourPlanSection(),
              24.h.verticalSpace,
              const _PracticeZoneSection(),
              24.h.verticalSpace,
              const _BottomStatsCard(),
              80.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Streak Counter
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              SvgIcon(
                AppAssets.thunder,
                size: 18.w,
                color: AppColors.yellowcolor,
              ),
              10.w.horizontalSpace,
              AppText(
                text: "2",
                style: AppTextStyles.sfProDisplayBold(
                  fontSize: 14.sp,
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
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Log Out"),
                    content: const Text("Are you sure you want to Log Out?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<AuthProvider>().logOut(context);
                        },
                        child: const Text(
                          "Log Out",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
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
}

class _CalendarStrip extends StatelessWidget {
  const _CalendarStrip();

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dates = ['18', '19', '20', '21', '22', '23', '24'];
    final status = [null, null, 'check', 'check', 'today', null, null];

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
                    color: AppColors.yellowcolor,
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

        8.h.verticalSpace,
        AppText(
          text: "1/3 Exercises",
          style: AppTextStyles.textStyle14Regular.copyWith(color: Colors.grey),
        ),
        16.h.verticalSpace,
        SizedBox(
          height: 90.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: days.length,
            separatorBuilder: (_, __) => 14.w.horizontalSpace,
            itemBuilder: (context, index) {
              final isChecked = status[index] == 'check';
              final isToday = status[index] == 'today';

              return Column(
                children: [
                  AppText(
                    text: days[index],
                    style: AppTextStyles.textStyle14Medium.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  8.h.verticalSpace,
                  Container(
                    width: 46.w,
                    height: 58.h,
                    decoration: BoxDecoration(
                      color: isToday
                          ? const Color(0xFFD4EAE8)
                          : isChecked
                          ? const Color(0xFFFBEAD9)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          text: dates[index],
                          style: AppTextStyles.textStyle16Bold,
                        ),
                        if (isChecked) ...[
                          4.h.verticalSpace,
                          Icon(
                            Icons.check,
                            size: 16.sp,
                            color: AppColors.yellowcolor,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DateItem extends StatelessWidget {
  final String day;
  final String date;
  final bool isSelected;
  final bool isChecked;
  final bool isToday;

  const _DateItem({
    required this.day,
    required this.date,
    this.isSelected = false,
    this.isChecked = false,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(
          text: day,
          style: AppTextStyles.textStyle14Medium.copyWith(
            color: isToday || isSelected ? AppColors.black : Colors.grey,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        8.h.verticalSpace,
        Container(
          height: 40.w,
          width: 36.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isToday
                ? const Color(0xFFD0EBEB)
                : (isSelected ? const Color(0xFFFFF2E5) : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: isChecked
              ? Icon(Icons.check, size: 20.sp, color: AppColors.yellowcolor)
              : AppText(
                  text: date,
                  style: AppTextStyles.textStyle14Bold.copyWith(
                    color: isToday ? AppColors.teal : AppColors.black,
                  ),
                ),
        ),
      ],
    );
  }
}

class _YourPlanSection extends StatelessWidget {
  const _YourPlanSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: "Today's Reading",
                style: AppTextStyles.textStyle14Semibold.copyWith(
                  color: AppColors.teal,
                ),
              ),
              3.h.verticalSpace,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: "The Hobbit",
                          style: AppTextStyles.sfProDisplayBold(
                            fontSize: 20.sp,
                          ),
                        ),
                        29.h.verticalSpace,
                        Row(
                          children: [
                            AppText(
                              text: "Read for 15 mins",
                              style: AppTextStyles.textStyle14Medium,
                            ),
                          ],
                        ),
                        21.h.verticalSpace,
                        Row(
                          children: [
                            _ActionButton(text: "Start", color: AppColors.teal),
                            8.w.horizontalSpace,
                            Container(
                              height: 42.h,
                              width: 132.w,
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: AppText(
                                text: "Re-generate",
                                style: AppTextStyles.textStyle14Semibold
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            SvgIcon(
                              AppAssets.thunder,
                              size: 16.w,
                              color: AppColors.yellowcolor,
                            ),
                            4.w.horizontalSpace,
                            AppText(
                              text: "3",
                              style: AppTextStyles.sfProDisplayBold(
                                color: AppColors.yellowcolor,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  16.w.horizontalSpace,
                  // Image placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      AppAssets.story3,
                      width: 96.w,
                      height: 96.w,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey,
                        width: 96.w,
                        height: 96.w,
                      ),
                    ),
                  ),
                ],
              ),
              12.h.verticalSpace,
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                 
                ],
              ),
            ],
          ),
        ),

        16.h.verticalSpace,
        // Add New Reading Button
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: Color(0xFFE0F2F2),
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: AppText(
            text: "Add New Reading",
            style: AppTextStyles.textStyle16Medium.copyWith(
              color: AppColors.teal,
            ),
          ),
        ),

        16.h.verticalSpace,
        // Other books
        _BookCard(
          category: "Books",
          title: "The Legend of the...",
          subtitle: "Read for 15 mins",
          imageUrl: AppAssets.story1,
          reward: "3",
        ),
        16.h.verticalSpace,
        // Ebooks
        _BookCard(
          category: "eBooks",
          title: "Harry Potter",
          subtitle: "Read for 15 mins",
          imageUrl: AppAssets.story2,
          reward: "3",
        ),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final String category;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String reward;

  const _BookCard({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  text: category,
                  style: AppTextStyles.textStyle14Medium.copyWith(
                    color: AppColors.teal,
                  ),
                ),
                4.h.verticalSpace,
                AppText(
                  text: title,
                  style: AppTextStyles.sfProDisplayBold(fontSize: 16.sp),
                  maxLines: 1,
                ),
                8.h.verticalSpace,
                Row(
                  children: [
                    AppText(
                      text: subtitle,
                      style: AppTextStyles.textStyle14Regular,
                    ),
                    Spacer(),
                    Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                    ),
                  ],
                ),
                12.h.verticalSpace,
                Row(
                  children: [
                    SizedBox(
                      width: 120.w,
                      child: _ActionButton(
                        text: "Start Reading",
                        color: AppColors.teal,
                      ),
                    ),
                    Spacer(),
                    SvgIcon(
                      AppAssets.thunder,
                      size: 16.w,
                      color: AppColors.yellowcolor,
                    ),
                    4.w.horizontalSpace,
                    AppText(
                      text: reward,
                      style: AppTextStyles.sfProDisplayBold(
                        color: AppColors.yellowcolor,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          12.w.horizontalSpace,
          // Image placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imageUrl,
              width: 96.w,
              height: 96.w,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  Container(color: Colors.grey, width: 60.w, height: 80.w),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeZoneSection extends StatelessWidget {
  const _PracticeZoneSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: "Practice Zone",
          style: AppTextStyles.sfProDisplayBold(fontSize: 18.sp),
        ),
        16.h.verticalSpace,
        _PracticeCard(
          title: "Vocabulary\nQuizzes",
          subtitle: "Solve 10 Quiz Questions",
          iconWidget: SvgIcon(
            AppAssets.book,
            size: 28.w,
            color: AppColors.teal,
          ),
          reward: "3",
          colorHex: 0xFFE0F7FA,
        ),
        16.h.verticalSpace,
        _PracticeCard(
          title: "Pronunciation\nDrills",
          subtitle: "Solve 2 Drills",
          iconWidget: ClipOval(
            child: Image.asset(
              AppAssets.profile,
              width: 38.w,
              height: 38.w,
              fit: BoxFit.cover,
            ),
          ),
          reward: "3",
          colorHex: 0xFFE8F5E9,
        ),
        16.h.verticalSpace,
        _PracticeCard(
          title: "Comprehension\nChecks",
          subtitle: "Solve 2 Comprehensions",
          iconWidget: SvgIcon(AppAssets.note, size: 28.w, color: Colors.orange),
          reward: "3",
          colorHex: 0xFFFFF3E0,
        ),
      ],
    );
  }
}

class _PracticeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget iconWidget;
  final String reward;
  final int colorHex;

  const _PracticeCard({
    required this.title,
    required this.subtitle,
    required this.iconWidget,
    required this.reward,
    required this.colorHex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Increased radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  style: AppTextStyles.sfProDisplayBold(fontSize: 16.sp),
                ),
                8.h.verticalSpace,
                Row(
                  children: [
                    AppText(
                      text: subtitle,
                      style: AppTextStyles.textStyle14Regular.copyWith(
                        color: Colors.grey[600],
                        fontSize: 13.sp,
                      ),
                    ),
                    8.w.horizontalSpace,
                    Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                16.h.verticalSpace,
                Row(
                  children: [
                    _ActionButton(
                      text: "Start",
                      color: AppColors.teal,
                      // Smaller button for this card
                    ),
                    Spacer(),
                    SvgIcon(
                      AppAssets.thunder,
                      size: 16.w,
                      color: AppColors.yellowcolor,
                    ),
                    4.w.horizontalSpace,
                    AppText(
                      text: reward,
                      style: AppTextStyles.sfProDisplayBold(
                        color: AppColors.yellowcolor,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          12.w.horizontalSpace,
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: Color(colorHex),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: iconWidget,
          ),
        ],
      ),
    );
  }
}

class _BottomStatsCard extends StatelessWidget {
  const _BottomStatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A), // Dark Navy
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
                style: AppTextStyles.textStyle14Medium.copyWith(
                  color: Colors.white,
                ),
              ),
              AppText(
                text: "OXFORD",
                style: AppTextStyles.textStyle14Semibold.copyWith(
                  color: Colors.grey,
                  fontSize: 10.sp,
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
                style: AppTextStyles.textStyle14Regular.copyWith(
                  color: Colors.grey,
                ),
              ),
              AppText(
                text: "60%",
                style: AppTextStyles.textStyle14Bold.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          8.h.verticalSpace,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(AppColors.greenColor),
              minHeight: 6.h,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  const _ActionButton({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      width: 82.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: AppText(
        text: text,
        style: AppTextStyles.textStyle14Semibold.copyWith(color: Colors.white),
      ),
    );
  }
}
