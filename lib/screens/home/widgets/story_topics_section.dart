import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/date_formatter.dart';
import 'package:redstreakapp/core/utils/share_helper.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/models/home/story_models/story_topics.dart';

import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/screens/home/widgets/add_reading_bottom_sheet.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:shimmer/shimmer.dart';

class StoryTopicsSection extends StatefulWidget {
  const StoryTopicsSection({super.key});

  @override
  State<StoryTopicsSection> createState() => _StoryTopicsSectionState();
}

class _StoryTopicsSectionState extends State<StoryTopicsSection> {
  void _showTopicInfo(BuildContext context, CreatedStoryTopicsModel story) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: story.topic,
                style: AppTextStyles.sfProDisplayBold(fontSize: 20.sp),
              ),
              12.w.verticalSpace,
              if (story.learningGoal.isNotEmpty)
                AppText(
                  text: story.learningGoal,
                  style: AppTextStyles.sfProDisplayMedium(
                    fontSize: 14.sp,
                    color: AppColors.black.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.topicsList == null && provider.isTopicsLoading) {
          return _buildShimmerLoading();
        }

        if (provider.topicsList != null && provider.topicsList!.isEmpty) {
          return buildEmptyState(context);
        }

        final list = provider.topicsList ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // OLD: Featured first topic (commented out – first topic now same as others)
            // if (list.isNotEmpty)
            //   FeaturedTopicCard(
            //     story: list.first,
            //     onPlay: () {
            //       context.pushNamed(
            //         AppRoutes.createdStorySummaryScreen.name,
            //         extra: list.first.id,
            //       );
            //     },
            //     onInfo: () {
            //       Logger.info("onInfo: ${list.first.topic}");
            //       _showTopicInfo(context, list.first);
            //     },
            //   ),
            // if (list.isNotEmpty) 20.w.verticalSpace,
            // Section title
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 12.w),
              child: AppText(
                text: list.length > 1
                    ? "Your Story Topics"
                    : "Your Story Topics",
                style: AppTextStyles.sfProDisplayBold(fontSize: 20.sp),
              ),
            ),
            // All topics as StoryCard (first same as others); add new reading after first.
            if (list.isNotEmpty)
              Column(
                children: [
                  StoryCard(
                    story: list.first,
                    onTap: () {
                      context.pushNamed(
                        AppRoutes.createdStorySummaryScreen.name,
                        extra: list.first.id,
                      );
                    },
                  ),
                  16.h.verticalSpace,
                  _addNewReadingButton(context),
                  if (list.length > 1) ...[
                    16.h.verticalSpace,
                    for (var i = 1; i < list.length; i++) ...[
                      StoryCard(
                        story: list[i],
                        onTap: () {
                          context.pushNamed(
                            AppRoutes.createdStorySummaryScreen.name,
                            extra: list[i].id,
                          );
                        },
                      ),
                      if (i < list.length - 1) 16.h.verticalSpace,
                    ],
                  ],
                ],
              ),
            // OLD: Wrap grid with NetflixStyleTopicCard (commented for now)
            // if (list.length > 1)
            //   LayoutBuilder(
            //     builder: (context, constraints) {
            //       const int crossAxisCount = 3;
            //       final gap = 12.w;
            //       final itemWidth =
            //           (constraints.maxWidth - gap * (crossAxisCount - 1)) /
            //           crossAxisCount;
            //       return Wrap(
            //         spacing: gap,
            //         runSpacing: gap,
            //         children: [
            //           for (var i = 1; i < list.length; i++)
            //             SizedBox(
            //               width: itemWidth,
            //               height: 200.w,
            //               child: NetflixStyleTopicCard(
            //                 story: list[i],
            //                 onTap: () {
            //                   context.pushNamed(
            //                     AppRoutes.createdStorySummaryScreen.name,
            //                     extra: list[i].id,
            //                   );
            //                 },
            //                 width: itemWidth,
            //               ),
            //             ),
            //         ],
            //       );
            //     },
            //   ),
            if (list.length > 1) 16.w.verticalSpace,
            if (provider.hasMoreTopics)
              Padding(
                padding: EdgeInsets.only(bottom: 12.w),
                child: _buildLoadMoreTile(provider),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLoadMoreTile(HomeProvider provider) {
    return GestureDetector(
      onTap: provider.hasMoreTopics && !provider.isTopicsLoadingMore
          ? () => provider.getMyTopicsLoadMore()
          : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.w),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: AppText(
          text: provider.isTopicsLoadingMore ? "Loading..." : "Load more",
          style: AppTextStyles.sfProDisplayMedium(
            fontSize: 14.sp,
            color: AppColors.black.withValues(alpha: 0.6),
          ),
        ),
      ),
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
        16.w.verticalSpace,
        Center(
          child: AppText(
            text: "No stories available",
            style: AppTextStyles.textStyle14Regular,
          ),
        ),
        24.w.verticalSpace,
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
          useRootNavigator: true,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (sheetContext) =>
              addReadingBottomSheet(context: sheetContext),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.w),
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
          width: double.infinity,
          height: 200.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
      16.w.verticalSpace,
      Shimmer.fromColors(
        baseColor: AppColors.shimmerBaseColor,
        highlightColor: AppColors.shimmerHighlightColor,
        child: Container(
          width: 160.w,
          height: 24.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
      12.w.verticalSpace,
      LayoutBuilder(
        builder: (context, constraints) {
          const int crossAxisCount = 3;
          final gap = 12.w;
          final itemWidth =
              (constraints.maxWidth - gap * (crossAxisCount - 1)) /
              crossAxisCount;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: List.generate(
              6,
              (_) => Shimmer.fromColors(
                baseColor: AppColors.shimmerBaseColor,
                highlightColor: AppColors.shimmerHighlightColor,
                child: Container(
                  width: itemWidth,
                  height: 200.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ],
  );
}

/// Featured main topic card (Netflix-style hero: large poster + title + tags + actions).
class FeaturedTopicCard extends StatelessWidget {
  const FeaturedTopicCard({
    super.key,
    required this.story,
    required this.onPlay,
    this.onInfo,
  });

  final CreatedStoryTopicsModel story;
  final VoidCallback onPlay;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: AspectRatio(
              aspectRatio: 16 / 11,
              child: story.thumbnailUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: story.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _featuredShimmer(),
                      errorWidget: (_, __, ___) => _featuredShimmer(),
                    )
                  : _featuredShimmer(),
            ),
          ),
        ),
        14.w.verticalSpace,
        AppText(
          text: story.topic,
          style: AppTextStyles.sfProDisplayBold(fontSize: 22.sp),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (story.learningGoal.isNotEmpty)
          AppText(
            text: story.learningGoal,
            style: AppTextStyles.sfProDisplayMedium(
              fontSize: 14.sp,
              color: AppColors.black.withValues(alpha: 0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

        16.w.verticalSpace,
        Row(
          children: [
            // _OutlineActionButton(
            //   icon: Icons.add_rounded,
            //   label: "My List",
            //   onTap: () {},
            // ),
            // 12.w.horizontalSpace,
            _FilledActionButton(
              icon: Icons.play_arrow_rounded,
              label: "Play",
              onTap: onPlay,
            ),
            12.w.horizontalSpace,
            _OutlineActionButton(
              icon: Icons.info_outline_rounded,
              label: "Info",
              onTap: onInfo ?? () {},
            ),
          ],
        ),
      ],
    );
  }
}

Widget _featuredShimmer() {
  return Shimmer.fromColors(
    baseColor: AppColors.shimmerBaseColor,
    highlightColor: AppColors.shimmerHighlightColor,
    child: Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.shimmerBaseColor,
    ),
  );
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20.sp, color: AppColors.black),
            8.w.horizontalSpace,
            AppText(
              text: label,
              style: AppTextStyles.sfProDisplaySemibold(fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledActionButton extends StatelessWidget {
  const _FilledActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22.sp, color: AppColors.white),
            8.w.horizontalSpace,
            AppText(
              text: label,
              style: AppTextStyles.sfProDisplaySemibold(
                fontSize: 14.sp,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact card for grid (poster + title). Optional [width] for Wrap grid.
class NetflixStyleTopicCard extends StatelessWidget {
  const NetflixStyleTopicCard({
    super.key,
    required this.story,
    required this.onTap,
    this.width,
  });

  final CreatedStoryTopicsModel story;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final w = width ?? 120.w;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: w,
        height: 200.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: story.thumbnailUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: story.thumbnailUrl,
                      width: w,
                      height: 160.w,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _netflixCardShimmer(w),
                      errorWidget: (_, __, ___) => _netflixCardShimmer(w),
                    )
                  : SizedBox(
                      width: w,
                      height: 160.w,
                      child: _netflixCardShimmer(w),
                    ),
            ),
            8.w.verticalSpace,
            Expanded(
              child: AppText(
                text: story.topic,
                style: AppTextStyles.sfProDisplaySemibold(
                  fontSize: 13.sp,
                  color: AppColors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Shimmer _netflixCardShimmer([double? w]) {
  final width = w ?? 120.w;
  return Shimmer.fromColors(
    baseColor: AppColors.shimmerBaseColor,
    highlightColor: AppColors.shimmerHighlightColor,
    child: Container(width: width, height: 160.w, color: Colors.grey),
  );
}

/// StoryCard used for "My topics" on home screen (topic + learning goal + See Stories button).
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
        borderRadius: BorderRadius.circular(20.r),
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
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: story.topic,
                        style: AppTextStyles.sfProDisplayBold(fontSize: 20.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => shareTopicLink(topicId: story.id),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(
                          Icons.share_outlined,
                          size: 22.sp,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
                _learningGoalExpanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: story.learningGoal,
                            style: textStyle,
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _learningGoalExpanded = false),
                            child: Padding(
                              padding: EdgeInsets.only(top: 2.h),
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
                              maxLines: 3,
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

                if (story.createdOn.isNotEmpty || story.updatedAt.isNotEmpty) ...[
                  8.h.verticalSpace,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (story.createdOn.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12.sp,
                              color: AppColors.black.withValues(alpha: 0.5),
                            ),
                            4.w.horizontalSpace,
                            Expanded(
                              child: AppText(
                                text: "Created: ${DateFormatter.formatDateTime(story.createdOn)}",
                                style: AppTextStyles.sfProDisplayRegular(
                                  fontSize: 11.sp,
                                  color: AppColors.black.withValues(alpha: 0.55),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (story.createdOn.isNotEmpty && story.updatedAt.isNotEmpty)
                        4.w.verticalSpace,
                      // if (story.updatedAt.isNotEmpty)
                      //   Row(
                      //     children: [
                      //       Icon(
                      //         Icons.update_outlined,
                      //         size: 12.sp,
                      //         color: AppColors.black.withValues(alpha: 0.5),
                      //       ),
                      //       4.w.horizontalSpace,
                      //       Expanded(
                      //         child: AppText(
                      //           text: "Updated: ${DateFormatter.formatDateTime(story.updatedAt)}",
                      //           style: AppTextStyles.sfProDisplayRegular(
                      //             fontSize: 11.sp,
                      //             color: AppColors.black.withValues(alpha: 0.55),
                      //           ),
                      //           overflow: TextOverflow.ellipsis,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                    ],
                  ),
                ],
                16.h.verticalSpace,
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    alignment: Alignment.center,
                    child: AppText(
                      text: "See Stories",
                      style: AppTextStyles.sfProDisplayBold(
                        fontSize: 15.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: story.thumbnailUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: story.thumbnailUrl,
                    width: 108.w,
                    height: 100.w,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => SizedBox(
                      width: 100.w,
                      height: 96.w,
                      child: _storyImageShimmer(),
                    ),
                    errorWidget: (_, __, ___) => SizedBox(
                      width: 100.w,
                      height: 96.w,
                      child: _storyImageShimmer(),
                    ),
                  )
                : SizedBox(
                    width: 100.w,
                    height: 96.w,
                    child: _storyImageShimmer(),
                  ),
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
    child: Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey,
    ),
  );
}
