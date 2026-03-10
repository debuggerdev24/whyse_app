import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/models/home/story_models/story_topics.dart';

import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/screens/home/widgets/add_reading_bottom_sheet.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:shimmer/shimmer.dart';

class StoryTopicsSection extends StatelessWidget {
  const StoryTopicsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.topicsList == null) {
          return _buildShimmerLoading();
        }

        //todo ---------------- EMPTY STATE ----------------
        if (provider.topicsList!.isEmpty) {
          return buildEmptyState(context);
        }
        //todo ---------------- DATA AVAILABLE ----------------
        final recentStory = provider.topicsList!.first;
        final otherStories = provider.topicsList!
            .skip(1)
            .take(provider.topicsList!.length)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //todo ----------- TODAY'S READING CARD -----------
            StoryCard(
              story: recentStory,
              onTap: () {
                context.pushNamed(AppRoutes.createdStorySummaryScreen.name);
                provider.getStoryIdeasByTopicId(topicId: recentStory.id);
              },
            ),
            // todayReadingCard(
            //   context: context,
            //   recentStory: recentStory,
            //   onTap: () {
            //     context.pushNamed(AppRoutes.createdStorySummaryScreen.name);
            //     provider.getStoryIdeasByTopicId(topicId: recentStory.id);
            //   },
            // ),
            16.w.verticalSpace,
            //todo ALWAYS SHOW BUTTON
            _addNewReadingButton(context),

            24.w.verticalSpace,

            //todo ----------- OTHER STORIES -----------
            ...otherStories.map(
              (story) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: StoryCard(
                  story: story,
                  onTap: () {
                    context.pushNamed(AppRoutes.createdStorySummaryScreen.name);

                    provider.getStoryIdeasByTopicId(topicId: story.id);
                    // context.pushNamed(
                    //   AppRoutes.readingScreen.name,
                    //   extra: story,
                    // );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Column buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          text: "Your Story Topics",
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

  Widget todayReadingCard({
    required BuildContext context,
    required CreatedStoryTopicsModel recentStory,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: AppText(
                          text: recentStory.topic,
                          style: AppTextStyles.sfProDisplayBold(
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                      22.h.verticalSpace,
                      AppText(
                        text:
                            "Read for  mins", //${recentStory.lessonDuration ?? 10}
                        style: AppTextStyles.sfProDisplayMedium(
                          fontSize: 14.sp,
                          color: AppColors.black.withValues(alpha: 0.8),
                        ),
                      ),
                      // Row(
                      //   children: [
                      //     AppText(
                      //       text:
                      //           "Read for ${recentStory.lessonDuration ?? 10} mins",
                      //       style: AppTextStyles.sfProDisplayMedium(
                      //         fontSize: 14.sp,
                      //         color: AppColors.black.withValues(
                      //           alpha: 0.8,
                      //         ),
                      //       ),
                      //     ),
                      //     const Spacer(),
                      //     Container(
                      //       width: 16.w,
                      //       height: 16.w,
                      //       decoration: BoxDecoration(
                      //         shape: BoxShape.circle,
                      //         border: Border.all(
                      //           color: Colors.grey[300]!,
                      //         ),
                      //       ),
                      //     ),
                      //     10.w.horizontalSpace,
                      //   ],
                      // ),
                      16.h.verticalSpace,
                      Row(
                        spacing: 8.w,
                        children: [
                          ActionButton(text: "Start", color: AppColors.teal),
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
                              style: AppTextStyles.textStyle14Semibold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Column(
                //   children: [
                //     ClipRRect(
                //       borderRadius: BorderRadius.circular(8),
                //       child: recentStory.image != null && recentStory.image!.isNotEmpty
                //           ? CachedNetworkImage(
                //               imageUrl: DioClient.baseUrl + recentStory.image!,
                //               width: 100.w,
                //               height: 96.w,
                //               fit: BoxFit.cover,
                //               placeholder: (context, url) => _storyImageShimmer(),
                //               errorWidget: (c, e, s) => _storyImageShimmer(),
                //             )
                //           : SizedBox(
                //               width: 100.w,
                //               height: 96.w,
                //               child: _storyImageShimmer(),
                //             ),
                //     ),
                //     12.h.verticalSpace,
                //     Row(
                //       children: [
                //         SvgIcon(
                //           AppAssets.thunder,
                //           size: 16.w,
                //           color: AppColors.primaryColor,
                //         ),
                //         4.w.horizontalSpace,
                //         AppText(
                //           text: "3",
                //           style: AppTextStyles.sfProDisplayBold(
                //             color: AppColors.primaryColor,
                //             fontSize: 16.sp,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
              ],
            ),
          ],
        ),
      ),
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
          builder: (sheetContext) =>
              addReadingBottomSheet(context: sheetContext),
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

Widget _buildShimmerLoading() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Shimmer.fromColors(
        baseColor: AppColors.shimmerBaseColor,
        highlightColor: AppColors.shimmerHighlightColor,
        child: Container(
          width: 120.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
      16.h.verticalSpace,
      Shimmer.fromColors(
        baseColor: AppColors.shimmerBaseColor,
        highlightColor: AppColors.shimmerHighlightColor,
        child: Container(
          width: double.infinity,
          height: 180.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
      24.h.verticalSpace,
      Shimmer.fromColors(
        baseColor: AppColors.shimmerBaseColor,
        highlightColor: AppColors.shimmerHighlightColor,
        child: Container(
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
      16.h.verticalSpace,
      Shimmer.fromColors(
        baseColor: AppColors.shimmerBaseColor,
        highlightColor: AppColors.shimmerHighlightColor,
        child: Container(
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    ],
  );
}

class StoryCard extends StatefulWidget {
  final CreatedStoryTopicsModel story;
  final VoidCallback? onTap;

  const StoryCard({super.key, required this.story, this.onTap});

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  bool _learningGoalExpanded = false;

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final onTap = widget.onTap;
    final textStyle = AppTextStyles.sfProDisplayMedium(
      fontSize: 14.sp,
      color: AppColors.black.withValues(alpha: 0.8),
    );

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
        spacing: 10.w,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: story.topic,
                  style: AppTextStyles.sfProDisplayBold(fontSize: 20.sp),
                  maxLines: 1,
                ),
                
                Row(
                  spacing: 10.w,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _learningGoalExpanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(text: story.learningGoal, style: textStyle),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _learningGoalExpanded = false),
                            child: Padding(
                              padding: EdgeInsets.only(top: 2.w),
                              child: AppText(
                                text: 'See less',
                                style: textStyle.copyWith(
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                      
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: AppText(
                              text: story.learningGoal,
                              style: textStyle,
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (story.learningGoal.length > 80)
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _learningGoalExpanded = true),
                              child: Padding(
                                padding: EdgeInsets.only(left: 4.w),
                                child: AppText(
                                  text: 'See more',
                                  style: textStyle.copyWith(
                                    color: AppColors.teal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: story.thumbnailUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: story.thumbnailUrl,
                                width: 100.w,
                                height: 96.w,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    _storyImageShimmer(),
                                errorWidget: (c, e, s) => _storyImageShimmer(),
                              )
                            : SizedBox(
                                width: 100.w,
                                height: 96.w,
                                child: _storyImageShimmer(),
                              ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    margin: EdgeInsets.only(top: 10.w),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 11.w),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: AppText(
                      text: "See Stories",
                      style: AppTextStyles.sfProDisplayBold(
                        fontSize: 14.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(8),
              //   child: story.thumbnailUrl.isNotEmpty
              //       ? CachedNetworkImage(
              //           imageUrl: story.thumbnailUrl,
              //           width: 100.w,
              //           height: 96.w,
              //           fit: BoxFit.cover,
              //           placeholder: (context, url) => _storyImageShimmer(),
              //           errorWidget: (c, e, s) => _storyImageShimmer(),
              //         )
              //       : SizedBox(
              //           width: 100.w,
              //           height: 96.w,
              //           child: _storyImageShimmer(),
              //         ),
              // ),
              // 20.h.verticalSpace,
              // Row(
              //   children: [
              //     SvgIcon(
              //       AppAssets.thunder,
              //       size: 16.w,
              //       color: AppColors.primaryColor,
              //     ),
              //     4.w.horizontalSpace,
              //     AppText(
              //       text: "3",
              //       style: AppTextStyles.sfProDisplayBold(
              //         color: AppColors.primaryColor,
              //         fontSize: 16.sp,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

Shimmer _storyImageShimmer() {
  return Shimmer.fromColors(
    baseColor: AppColors.shimmerBaseColor,
    highlightColor: AppColors.shimmerHighlightColor,
    child: Container(color: Colors.grey, width: 96.w, height: 96.w),
  );
}
