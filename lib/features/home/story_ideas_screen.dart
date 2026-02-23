import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/utils/date_formatter.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/custom_shimmer.dart';
import 'package:redstreakapp/features/home/widgets/home_section_shimmers.dart';
import 'package:redstreakapp/models/home/story_models/story_summary_model.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';

class CreatedStorySummaryScreen extends StatelessWidget {
  const CreatedStorySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (provider.storySummary == null) {
            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  18.w.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: ShimmerLoading(width: 180.w, height: 22.h, borderRadius: 8),
                  ),
                  15.h.verticalSpace,
                  Expanded(child: HomeSectionShimmer.storyIdeaShimmer()),
                ],
              ),
            );
          }
          final story = provider.storySummary!;
          return Stack(
            children:[
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    18.w.verticalSpace,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: AppText(
                        text: "Stories for ${story.topicTitle}:",
                        style: AppTextStyles.sfProDisplaySemibold(
                          fontSize: 18.sp,
                        ),
                      ),
                    ),

                    15.w.verticalSpace,
                    Expanded(
                      child: ListView.separated(
                        itemCount: story.storyIdeas.length,
                        separatorBuilder: (context, index) =>
                            18.w.verticalSpace,
                        itemBuilder: (context, index) => _StoryCard(
                          story: story.storyIdeas[index],
                          onTap: () {
                            provider.getStoryByIdea(
                              storyIdea: story.storyIdeas[index].id,
                              onSuccess: (story) {
                                context.pushNamed(
                                  AppRoutes.readingScreen.name,
                                  extra: story,
                                );
                              },
                            );
                          },

                        ),
                      ),
                    ),
                    10.w.verticalSpace,
                  ],
                ),
              ),
              if (provider.isGettingStoryLoading) FullPageIndicator(),
            ],
          );
        },
      ),
    );
  }
}

class _StoryCard extends StatefulWidget {
  final StoryIdea story;
  final VoidCallback? onTap;

  const _StoryCard({required this.story, this.onTap});

  @override
  State<_StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<_StoryCard> {
  bool _descriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final onTap = widget.onTap;
    final metaStyle = AppTextStyles.sfProDisplayBold(
      fontSize: 14.sp,
      color: AppColors.black.withValues(alpha: 0.5),
    );
    final descStyle = AppTextStyles.sfProDisplayBold(
      fontSize: 16.sp,
      color: AppColors.black.withValues(alpha: 0.65),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          child: Row(
            spacing: 10.w,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: "Title: ${story.storyTitle}",
                      style: AppTextStyles.sfProDisplaySemibold(
                        fontSize: 18.sp,
                        color: AppColors.teal,
                      ),
                    ),
                    4.w.verticalSpace,
                    AppText(
                      text: "Description: ",
                      style: descStyle.copyWith(
                        color: AppColors.black.withValues(alpha: 0.9),
                      ),
                    ),
                    _descriptionExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: story.description,
                                style: descStyle,
                              ),
                              GestureDetector(
                                onTap: () => setState(
                                  () => _descriptionExpanded = false,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(top: 2.h),
                                  child: AppText(
                                    text: 'See less',
                                    style: descStyle.copyWith(
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
                                  text: story.description,
                                  style: descStyle,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (story.description.length > 80)
                                GestureDetector(
                                  onTap: () => setState(
                                    () => _descriptionExpanded = true,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 4.w),
                                    child: AppText(
                                      text: 'See more',
                                      style: descStyle.copyWith(
                                        color: AppColors.teal,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                    10.w.verticalSpace,
                    Row(
                      spacing: 4.w,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13.sp,
                          color: AppColors.black.withValues(alpha: 0.5),
                        ),

                        Expanded(
                          child: AppText(
                            text:
                                'Created ${DateFormatter.formatDateTime(story.createdOn)}',
                            style: metaStyle,
                          ),
                        ),
                      ],
                    ),
                    2.verticalSpace,
                    Row(
                      spacing: 4.w,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 14.sp,
                          color: AppColors.black.withValues(alpha: 0.5),
                        ),

                        Expanded(
                          child: AppText(
                            text:
                                'Updated ${DateFormatter.formatDateTime(story.updatedAt)}',
                            style: metaStyle,
                          ),
                        ),
                      ],
                    ),
                    16.w.verticalSpace,
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          AppText(
                            text: "Read Story",
                            style: AppTextStyles.sfProDisplayBold(
                              fontSize: 16.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
