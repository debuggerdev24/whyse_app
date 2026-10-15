import 'package:redstreakapp/core/widgets/app_skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/models/home/story_models/story_topics.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';

class HomeStoryTopics extends StatefulWidget {
  const HomeStoryTopics({super.key});

  @override
  State<HomeStoryTopics> createState() => _HomeStoryTopicsState();
}

class _HomeStoryTopicsState extends State<HomeStoryTopics> {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: "Series",
                  style: AppTextStyles.bold(fontSize: 22.sp),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    context.pushNamed(AppRoutes.mySavedSeriesScreen.name);
                  },
                  child: AppText(
                    text: "See all",
                    style: AppTextStyles.semibold(
                      fontSize: 14.sp,
                      color: AppColors.orangeColor,
                    ),
                  ),
                ),
              ],
            ),
            12.h.verticalSpace,
            if (list.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  final gap = 12.w;
                  final itemWidth = (constraints.maxWidth - gap) / 2;
                  final itemCount =
                      list.length + (provider.isTopicsLoadingMore ? 2 : 0);
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (var index = 0; index < itemCount; index++)
                        SizedBox(
                          width: itemWidth,
                          height: 188.h,
                          child: index >= list.length
                              ? const _StoryCardShimmer()
                              : StoryCard(
                                  story: list[index],
                                  colorIndex: index,
                                  onTap: () {
                                    final topicId = list[index].id;
                                    provider.beginTopicStoryDetailsLoad(
                                      topicId: topicId,
                                    );
                                    provider.getTopicStoryDetails(
                                      topicId: topicId,
                                    );
                                    context
                                        .pushNamed(
                                          AppRoutes.createdStorySummaryScreen.name,
                                          extra: topicId,
                                        )
                                        .then((_) {
                                          if (!context.mounted) return;
                                          context
                                              .read<HomeProvider>()
                                              .getContinueReading(force: true);
                                        });
                                  },
                                ),
                        ),
                    ],
                  );
                },
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
            // if (list.length > 1) 16.w.verticalSpace,
            // if (provider.hasMoreTopics)
            //   Padding(
            //     padding: EdgeInsets.only(bottom: 12.w),
            //     child: _buildLoadMoreTile(provider),
            //   ),
          ],
        );
      },
    );
  }

  // Widget _buildLoadMoreTile(HomeProvider provider) {
  //   return GestureDetector(
  //     onTap: provider.hasMoreTopics && !provider.isTopicsLoadingMore
  //         ? () => provider.getMyTopicsLoadMore()
  //         : null,
  //     child: Container(
  //       width: double.infinity,
  //       padding: EdgeInsets.symmetric(vertical: 14.w),
  //       decoration: BoxDecoration(
  //         color: AppColors.black.withValues(alpha: 0.06),
  //         borderRadius: BorderRadius.circular(12.r),
  //       ),
  //       alignment: Alignment.center,
  //       child: AppText(
  //         text: provider.isTopicsLoadingMore ? "Loading..." : "Load more",
  //         style: AppTextStyles.medium(
  //           fontSize: 14.sp,
  //           color: AppColors.black.withValues(alpha: 0.6),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: "Series",
          style: AppTextStyles.semibold(fontSize: 20.sp),
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
            3.w.verticalSpace,
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
                          style: AppTextStyles.bold(fontSize: 20.sp),
                        ),
                      ),
                      22.w.verticalSpace,
                      AppText(
                        text:
                            "Read for  mins", //${recentStory.lessonDuration ?? 10}
                        style: AppTextStyles.medium(
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
                      16.w.verticalSpace,
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
                //     12.w.verticalSpace,
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
        // showModalBottomSheet(
        //   context: context,
        //   useRootNavigator: true,
        //   backgroundColor: Colors.transparent,
        //   isScrollControlled: true,
        //   builder: (sheetContext) =>
        //       addReadingBottomSheet(context: sheetContext),
        // );
        context.read<StoryProvider>().clearStoryFields();
        context.pushNamed(AppRoutes.storyGoalsScreen.name);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.w),
        margin: EdgeInsets.only(top: 14.w),
        decoration: BoxDecoration(
          color: AppColors.extealighttealcolor,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: AppText(
          text: "Add New Reading",
          style: AppTextStyles.bold(fontSize: 15.sp, color: AppColors.teal),
        ),
      ),
    );
  }
}

Widget _buildShimmerLoading() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: 4.w, bottom: 10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppSkeletonizer(child: Container(
                width: 88.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBaseColor,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
            ),
            AppSkeletonizer(child: Container(
                width: 52.w,
                height: 16.w,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBaseColor,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
            ),
          ],
        ),
      ),
      12.h.verticalSpace,
      LayoutBuilder(
        builder: (context, constraints) {
          final gap = 12.w;
          final itemWidth = (constraints.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var i = 0; i < 4; i++)
                SizedBox(
                  width: itemWidth,
                  height: 188.h,
                  child: const _StoryCardShimmer(),
                ),
            ],
          );
        },
      ),
    ],
  );
}

class _StoryCardShimmer extends StatelessWidget {
  const _StoryCardShimmer();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.shimmerBaseColor,
          borderRadius: BorderRadius.circular(22.r),
        ),
      ),
    );
  }
}

Widget _buildTopicCover(
  String rawThumbnailUrl, {
  required Widget shimmer,
  bool compact = false,
  bool iconOnly = false,
}) {
  return AppNetworkImage(
    imageUrl: rawThumbnailUrl,
    tag: 'HomeTopics.cover',
    placeholder: (_) => shimmer,
    errorCompact: compact,
    errorIconOnly: iconOnly,
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
              child: _buildTopicCover(
                story.thumbnailUrl,
                shimmer: _featuredShimmer(),
                compact: true,
              ),
            ),
          ),
        ),
        14.w.verticalSpace,
        AppText(
          text: story.topic,
          style: AppTextStyles.bold(fontSize: 22.sp),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (story.learningGoal.isNotEmpty)
          AppText(
            text: story.learningGoal,
            style: AppTextStyles.medium(
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
  return AppSkeletonizer(child: Container(
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
              style: AppTextStyles.semibold(fontSize: 14.sp),
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
              style: AppTextStyles.semibold(
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
              child: SizedBox(
                width: w,
                height: 160.w,
                child: _buildTopicCover(
                  story.thumbnailUrl,
                  shimmer: _netflixCardShimmer(w),
                  compact: true,
                  iconOnly: true,
                ),
              ),
            ),
            8.w.verticalSpace,
            Expanded(
              child: AppText(
                text: story.topic,
                style: AppTextStyles.semibold(
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

Widget _netflixCardShimmer([double? w]) {
  final width = w ?? 120.w;
  return AppSkeletonizer(
    child: Container(width: width, height: 160.w, color: Colors.grey),
  );
}

/// Home series tile: photo card when a cover exists, solid color card otherwise.
class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.story,
    this.onTap,
    this.colorIndex = 0,
  });

  final CreatedStoryTopicsModel story;
  final VoidCallback? onTap;
  final int colorIndex;

  static const _fallbackFills = <Color>[
    Color(0xFFF6E7B2),
    Color(0xFFF8CDB4),
    Color(0xFFD9EFE4),
    Color(0xFFE7DDF8),
  ];

  static const _fallbackAccents = <Color>[
    Color(0xFFC4A15A),
    Color(0xFFC47A52),
    Color(0xFF3E9A78),
    Color(0xFF7A5EA8),
  ];

  @override
  Widget build(BuildContext context) {
    final readCount = story.noOfStories;
    final totalCount = story.noOfStoriesGenerated > 0
        ? story.noOfStoriesGenerated
        : readCount;
    final hasImage = story.thumbnailUrl.trim().isNotEmpty;
    final fill = _fallbackFills[colorIndex % _fallbackFills.length];
    final accent = _fallbackAccents[colorIndex % _fallbackAccents.length];
    final titleColor = hasImage ? Colors.white : AppColors.black;
    final metaColor = hasImage
        ? Colors.white.withValues(alpha: 0.82)
        : AppColors.black.withValues(alpha: 0.45);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              _buildTopicCover(
                story.thumbnailUrl,
                shimmer: _storyImageShimmer(),
                compact: true,
                iconOnly: true,
              )
            else
              ColoredBox(color: fill),
            if (hasImage)
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x22000000),
                      Color(0x00000000),
                      Color(0xD1000000),
                    ],
                    stops: [0, 0.4, 1],
                  ),
                ),
              ),
            if (!hasImage)
              Positioned(
                top: 16.h,
                left: 0,
                right: 0,
                child: Icon(
                  colorIndex.isEven
                      ? Icons.bubble_chart_rounded
                      : Icons.confirmation_number_rounded,
                  size: 54.w,
                  color: accent.withValues(alpha: 0.9),
                ),
              ),
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 12.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: story.topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(
                      fontSize: 16.sp,
                      color: titleColor,
                    ),
                  ),
                  4.h.verticalSpace,
                  AppText(
                    text: '$totalCount out of $readCount Reading',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium(
                      fontSize: 11.sp,
                      color: metaColor,
                    ),
                  ),
                  10.h.verticalSpace,
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasImage
                          ? Colors.white.withValues(alpha: 0.2)
                          : accent,
                      border: hasImage
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.85),
                            )
                          : null,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 16.w,
                    ),
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

Widget _storyImageShimmer() {
  return AppSkeletonizer(
    child: Container(
      width: double.infinity,
      height: 132.w,
      color: AppColors.shimmerBaseColor,
    ),
  );
}
