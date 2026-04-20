import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';

Widget addReadingBottomSheet({required BuildContext context}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 16.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: const Color(0xFFD1D1D1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        27.w.verticalSpace,
        AppText(
          text: "Choose Reading Type",
          style: AppTextStyles.bold(fontSize: 20.sp),
        ),
        27.w.verticalSpace,
        Divider(
          color: AppColors.black.withValues(alpha: 0.1),
          thickness: 1,
          height: 1,
        ),
        20.w.verticalSpace,

        //todo Generate Article
        _OptionCard(
          title: "Generate Article",
          subtitle:
              "Get a story made just for you by AI \n— every time it’s something new and exciting!",
          image: AppAssets.robot,
          onTap: () {
            if (!context.mounted) return;
            context.read<StoryProvider>().clearStoryFields();
            context.pop();
            context.pushNamed(AppRoutes.storyGoalsScreen.name);
          },
        ),

        16.w.verticalSpace,

        //todo Add Book
        _OptionCard(
          title: "Add a Book",
          subtitle:
              "Open your chosen book — continue your reading journey anytime!",
          image: AppAssets.book1,
          // isSelected: selectedIndex == 1,
          onTap: () {
            Navigator.pop(context);
          },
        ),

        16.w.verticalSpace,

        /// Add eBook
        _OptionCard(
          title: "Add an eBook",
          subtitle:
              "Start reading your eBook — pick up right where you left off!",
          image: AppAssets.ebook,
          // isSelected: selectedIndex == 2,
          onTap: () {
            Navigator.pop(context);
          },
        ),

        20.w.verticalSpace,
      ],
    ),
  );
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String image;

  // final bool isSelected;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.image,
    // required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200, //isSelected ? AppColors.black :
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(image, height: 80.h, width: 80.w),
            24.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: title,
                    style: AppTextStyles.semibold(fontSize: 16.sp),
                  ),
                  4.w.verticalSpace,
                  AppText(
                    text: subtitle,
                    style: AppTextStyles.regular(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReadingLevelCard extends StatelessWidget {
  final String level;
  final double progress;
  final String description;
  final VoidCallback? onTap;

  const ReadingLevelCard({
    super.key,
    required this.level,
    required this.description,
    this.onTap,
    this.progress = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.black.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ─── TOP ROW ───
            Row(
              children: [
                SvgIcon(AppAssets.readingskill, size: 50.w),

                12.w.horizontalSpace,

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: level,
                        style: AppTextStyles.textStyle16Bold,
                      ),
                      4.w.verticalSpace,
                      AppText(
                        text: description,
                        style: AppTextStyles.medium(
                          fontSize: 12.sp,
                          color: AppColors.black.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.black,
                  size: 22.sp,
                ),
              ],
            ),

            14.w.verticalSpace,

            /// ─── PROGRESS BAR ───
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8.h,
                backgroundColor: AppColors.black.withValues(alpha: 0.08),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF0E8C8A)),
              ),
            ),

            8.w.verticalSpace,

            /// ─── BEGINNER → ADVANCE ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: "Beginner",
                  style: AppTextStyles.semibold(
                    fontSize: 12.sp,
                    color: AppColors.teal,
                  ),
                ),
                AppText(
                  text: "Advance",
                  style: AppTextStyles.semibold(
                    fontSize: 12.sp,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
