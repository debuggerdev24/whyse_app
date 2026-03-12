import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/screens/home/widgets/home_section_shimmers.dart';
import 'package:redstreakapp/screens/home/widgets/story_ideas_widgets.dart';

class CreatedStorySummaryScreen extends StatefulWidget {
  const CreatedStorySummaryScreen({super.key, this.topicId});

  final String? topicId;

  @override
  State<CreatedStorySummaryScreen> createState() =>
      _CreatedStorySummaryScreenState();
}

class _CreatedStorySummaryScreenState extends State<CreatedStorySummaryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final topicId = widget.topicId;
    if (topicId != null && topicId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<HomeProvider>().getStoryIdeasByTopicId(topicId: topicId);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final provider = context.read<HomeProvider>();
    final topicId = provider.activeStoryIdeasTopicId;
    if (topicId == null ||
        provider.isStoryIdeasLoading ||
        provider.isStoryIdeasLoadingMore ||
        !provider.hasMoreStoryIdeas) {
      return;
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 280) {
      provider.getStoryIdeasByTopicId(topicId: topicId, loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context, provider, child) {
            final summary = provider.storySummary;
        
            if (provider.isStoryIdeasLoading) {
              return HomeSectionShimmer.createdStoryIdeasLoadingShimmer();
            }
        
            if (summary == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: AppText(
                    text: provider.storyIdeasError ?? "Unable to load stories.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sfProDisplayMedium(
                      fontSize: 16.sp,
                      color: AppColors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              );
            }
        
            if (summary.storyIdeas.isEmpty) {
              return const SafeArea(child: StoryIdeasEmptyState());
            }
        
            return Stack(
              children: [
                SafeArea(
                  child: ListView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(top: 14.h, bottom: 18.h),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: AppText(
                          text: "Stories for ${summary.topicTitle}",
                          style: AppTextStyles.sfProDisplaySemibold(
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      14.w.verticalSpace,
                      StoryIdeasHeaderCard(summary: summary),
                      20.w.verticalSpace,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: AppText(
                          text: "Stories",
                          style: AppTextStyles.sfProDisplayBold(fontSize: 22.sp),
                        ),
                      ),
                      8.w.verticalSpace,
                      ...List.generate(summary.storyIdeas.length, (index) {
                        final storyIdea = summary.storyIdeas[index];
                        return StoryIdeaEpisodeCard(
                          story: storyIdea,
                          index: index + 1,
                          topicImageUrl: summary.topicThumbnailUrl,
                          onTap: () {
                            // Reading screen will call getStoryByIdea first: if generated shows story, else generates then shows
                            context.pushNamed(
                              AppRoutes.createdStoryReadingScreen.name,
                              extra: <String, dynamic>{"storyIdeaId": storyIdea.id},
                            );
                          },
                        );
                      }),
                      if (provider.isStoryIdeasLoadingMore) ...[
                        4.h.verticalSpace,
                        HomeSectionShimmer.createdStoryIdeasLoadMoreShimmer(),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
