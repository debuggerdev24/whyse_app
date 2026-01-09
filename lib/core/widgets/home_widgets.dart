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
import 'package:redstreakapp/core/widgets/custom_shimmer.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/screens/home/widgets/add_reading_bottom_sheet.dart';

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
                color: AppColors.yellowColor,
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
                  .textStyle22Regular, //regular(color: AppColors.black, fontSize: 19.sp),
            ),
            actions: [
              myActionButtonTheme(
                onPressed: () async {
                  context.pop(dialogContext);
                  await context.read<AuthProvider>().logOutUser(
                    onSuccess: () {
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
          color: (title == "Yes") ? AppColors.redcolor : AppColors.black,
          fontSize: 18.sp,
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
                    color: AppColors.yellowColor,
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

              return Column(
                children: [
                  Container(
                    width: 50.w,
                    height: 76.h,
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
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: AppColors.yellowColor,
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
                        6.h.verticalSpace,
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

class YourPlanSection extends StatelessWidget {
  const YourPlanSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildShimmerLoading();
        }

        //todo ---------------- EMPTY STATE ----------------
        if (provider.stories.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: "Your Plan",
                style: AppTextStyles.sfProDisplaySemibold(fontSize: 20.sp),
              ),
              16.h.verticalSpace,
              Center(
                child: AppText(
                  text: "No stories available",
                  style: AppTextStyles.textStyle14Regular,
                ),
              ),
              24.h.verticalSpace,

              //todo ✅ ALWAYS SHOW BUTTON
              _addNewReadingButton(context),
            ],
          );
        }

        //todo ---------------- DATA AVAILABLE ----------------
        final recentStory = provider.stories.first;
        final otherStories = provider.stories
            .skip(1)
            .take(provider.stories.length)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //todo ----------- TODAY'S READING CARD -----------
            Container(
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
                  InkWell(
                    onTap: () {
                      context.pushNamed(
                        AppRoutes.readingScreen.name,
                        extra: recentStory,
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: recentStory.title,
                                style: AppTextStyles.sfProDisplayBold(
                                  fontSize: 20.sp,
                                ),
                              ),
                              29.h.verticalSpace,
                              Row(
                                children: [
                                  AppText(
                                    text:
                                        "Read for ${recentStory.lessonDuration ?? 10} mins",
                                    style: AppTextStyles.sfProDisplayMedium(
                                      fontSize: 14.sp,
                                      color: AppColors.black.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: 16.w,
                                    height: 16.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                  10.w.horizontalSpace,
                                ],
                              ),
                              21.h.verticalSpace,
                              Row(
                                children: [
                                  ActionButton(
                                    text: "Start",
                                    color: AppColors.teal,
                                  ),
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
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildStoryImage(recentStory.image),
                            ),
                            12.h.verticalSpace,
                            Row(
                              children: [
                                SvgIcon(
                                  AppAssets.thunder,
                                  size: 16.w,
                                  color: AppColors.yellowColor,
                                ),
                                4.w.horizontalSpace,
                                AppText(
                                  text: "3",
                                  style: AppTextStyles.sfProDisplayBold(
                                    color: AppColors.yellowColor,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            16.h.verticalSpace,

            /// ✅ ALWAYS SHOW BUTTON
            _addNewReadingButton(context),

            24.h.verticalSpace,

            //todo ----------- OTHER STORIES -----------
            ...otherStories.map(
              (story) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: BookCard(
                  category: story.readingTopic ?? "General",
                  title: story.title,
                  subtitle: "Read for ${story.lessonDuration ?? 10} mins",
                  imageUrl: story.image ?? "",
                  reward: "3",
                  onTap: () {
                    context.pushNamed(
                      AppRoutes.readingScreen.name,
                      extra: story,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// ---------------- ADD NEW READING BUTTON ----------------
  Widget _addNewReadingButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (sheetContext) => const AddReadingBottomSheet(),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.extealighttealcolor,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: AppText(
          text: "Add New Reading",
          style: AppTextStyles.sfProDisplayBold(
            fontSize: 15.sp,
            color: AppColors.teal,
          ),
        ),
      ),
    );
  }
}

Widget _buildStoryImage(String? imageUrl) {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    final fullUrl = imageUrl.startsWith('http')
        ? imageUrl
        : "http://167.172.45.71$imageUrl";

    return Image.network(
      fullUrl,
      width: 100.w,
      height: 96.w,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) =>
          Container(color: Colors.grey, width: 96.w, height: 96.w),
    );
  }
  return Container(color: Colors.grey, width: 100.w, height: 96.w);
}

Widget _buildShimmerLoading() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ShimmerLoading(width: 120.w, height: 20.h),
      16.h.verticalSpace,
      ShimmerLoading(width: double.infinity, height: 180.h, borderRadius: 20),
      24.h.verticalSpace,
      ShimmerLoading(width: double.infinity, height: 120.h, borderRadius: 20),
      16.h.verticalSpace,
      ShimmerLoading(width: double.infinity, height: 120.h, borderRadius: 20),
    ],
  );
}

class BookCard extends StatelessWidget {
  final String category;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String reward;
  final VoidCallback? onTap;

  const BookCard({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.reward,
    this.onTap,
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
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: category,
                    style: AppTextStyles.sfProDisplaySemibold(
                      fontSize: 14.sp,
                      color: AppColors.teal,
                    ),
                  ),
                  4.h.verticalSpace,
                  AppText(
                    text: title,
                    style: AppTextStyles.sfProDisplayBold(fontSize: 20.sp),
                    maxLines: 1,
                  ),
                  29.h.verticalSpace,
                  Row(
                    children: [
                      AppText(
                        text: subtitle,
                        style: AppTextStyles.sfProDisplayMedium(
                          fontSize: 14.sp,
                          color: AppColors.black.withValues(alpha: 0.8),
                        ),
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
                        width: 140.w,
                        child: ActionButton(
                          text: "Start Reading",
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            12.w.horizontalSpace,
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isEmpty
                      ? Container(
                          color: Colors.grey,
                          width: 100.w,
                          height: 96.w,
                        )
                      : (imageUrl.startsWith('http') || imageUrl.startsWith('/')
                            ? Image.network(
                                imageUrl.startsWith('http')
                                    ? imageUrl
                                    : "http://167.172.45.71$imageUrl",
                                width: 100.w,
                                height: 96.w,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: Colors.grey,
                                  width: 96.w,
                                  height: 96.w,
                                ),
                              )
                            : Image.asset(
                                imageUrl,
                                width: 100.w,
                                height: 96.w,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: Colors.grey,
                                  width: 96.w,
                                  height: 96.w,
                                ),
                              )),
                ),
                20.h.verticalSpace,
                Row(
                  children: [
                    SvgIcon(
                      AppAssets.thunder,
                      size: 16.w,
                      color: AppColors.yellowColor,
                    ),
                    4.w.horizontalSpace,
                    AppText(
                      text: "3",
                      style: AppTextStyles.sfProDisplayBold(
                        color: AppColors.yellowColor,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
                    color: AppColors.yellowColor,
                  ),
                  4.w.horizontalSpace,
                  AppText(
                    text: "3",
                    style: AppTextStyles.sfProDisplayBold(
                      color: AppColors.yellowColor,
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
