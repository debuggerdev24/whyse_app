import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/core/utils/share_helper.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/widgets/global_widgets.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/screens/home/widgets/home_section_shimmers.dart';
import 'package:shimmer/shimmer.dart';

class MyStoryIdeasScreen extends StatefulWidget {
  const MyStoryIdeasScreen({super.key});

  @override
  State<MyStoryIdeasScreen> createState() => _MyStoryIdeasScreenState();
}

class _MyStoryIdeasScreenState extends State<MyStoryIdeasScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
          builder: (context, homeProvider, child) {
            final summary = homeProvider.storySummary;

            if (homeProvider.isStoryIdeasLoading) {
              return HomeSectionShimmer.createdStoryIdeasLoadingShimmer();
            }

            if (summary == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: AppText(
                    text:
                        homeProvider.storyIdeasError ??
                        "Unable to load stories.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                      color: AppColors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              );
            }

            if (summary.storyIdeas.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: AppText(
                    text: "No stories available.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                      color: AppColors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              );
            }

            final topicTitle = summary.topicTitle.isNotEmpty
                ? summary.topicTitle
                : 'Nature';
            final topicDescription = summary.topicLearningGoal;
            final topicThumb = summary.topicThumbnailUrl;

            return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 310.w,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (topicThumb.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: topicThumb,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: AppColors.shimmerBaseColor,
                              highlightColor: AppColors.shimmerHighlightColor,
                              child: Container(
                                color: AppColors.shimmerBaseColor,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const NoImageFound(),
                          )
                        else
                          const NoImageFound(),
                        SafeArea(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              14.w,
                              18.w,
                              14.w,
                              14.w,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _circleButton(
                                      onTap: () {
                                        if (context.canPop()) {
                                          context.pop();
                                        } else {
                                          context.goNamed(
                                            AppRoutes.homeScreen.name,
                                          );
                                        }
                                      },
                                      child: SvgIcon(
                                        AppAssets.backButton,
                                        size: 12.w,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    // _circleButton(
                                    //   onTap: () {
                                    //     context.goNamed(AppRoutes.homeScreen.name);
                                    //   },
                                    //   child: SvgIcon(
                                    //     AppAssets.homeIcon,
                                    //     size: 15.w,
                                    //     color: AppColors.black,
                                    //   ),
                                    // ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: AppText(
                                        text: topicTitle,
                                        style: AppTextStyles.bold(
                                          fontSize: 24.sp,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        18.w.verticalSpace,
                        _MyExpandableDescription(text: topicDescription),
                        10.w.verticalSpace,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _infoChip('12-15 years'),
                            8.w.horizontalSpace,
                            _infoChip('CEFR A2'),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                shareTopicLink(topicId: summary.topicId);
                              },
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  border: Border.all(
                                    color: AppColors.black.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: SvgIcon(
                                  AppAssets.shareIcon,
                                  size: 20.w,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                margin: EdgeInsets.only(left: 8.w),
                                padding: EdgeInsets.all(5.w),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  border: Border.all(
                                    color: AppColors.black.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.bookmark_border,
                                  size: 23.5.w,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        16.w.verticalSpace,
                        Divider(
                          height: 1.w,
                          thickness: 1.w,
                          color: AppColors.black.withValues(alpha: 0.1),
                        ),
                        18.w.verticalSpace,
                        AppText(
                          text:
                              "${summary.storyIdeas.length} Readings - 10 mins",
                          style: AppTextStyles.bold(
                            fontSize: 16.sp,
                            color: AppColors.black,
                          ),
                        ),
                        18.w.verticalSpace,
                        ...List.generate(
                          summary.storyIdeas.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(bottom: 18.w),
                            child: _MyReadingItemTile(
                              index: index + 1,
                              title: summary.storyIdeas[index].storyTitle,
                              description:
                                  summary.storyIdeas[index].description,
                              thumbnailUrl:
                                  summary.storyIdeas[index].thumbnailUrl,
                              topicThumbnailUrl: summary.topicThumbnailUrl,
                              onOpenStory: () {
                                final storyProvider = context
                                    .read<StoryProvider>();
                                context.pushNamed(
                                  AppRoutes.createdStoryReadingScreen.name,
                                  extra: <String, dynamic>{
                                    "storyIdeaId": summary.storyIdeas[index].id,
                                  },
                                );
                                storyProvider.fetchSingleStoryByIdea(
                                  storyIdeaId: summary.storyIdeas[index].id,
                                  context: context,
                                  insertAtIndex: 0,
                                  onStoryNotGenerated: (ctx) {
                                    AppToast.error(
                                      ctx,
                                      "Story not found. Please try again.",
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        if (homeProvider.isStoryIdeasLoadingMore) ...[
                          4.w.verticalSpace,
                          HomeSectionShimmer.createdStoryIdeasLoadMoreShimmer(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _circleButton({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
      decoration: BoxDecoration(
        color: AppColors.extealighttealcolor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: AppText(
        text: label,
        style: AppTextStyles.medium(fontSize: 12.sp, color: AppColors.teal),
      ),
    );
  }
}

class _MyReadingItemTile extends StatelessWidget {
  const _MyReadingItemTile({
    required this.onOpenStory,
    required this.index,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.topicThumbnailUrl,
  });

  final VoidCallback onOpenStory;
  final int index;
  final String title, description, thumbnailUrl, topicThumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onOpenStory,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              width: 122.w,
              height: 84.w,
              child: CachedNetworkImage(
                imageUrl: thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppColors.shimmerBaseColor,
                  highlightColor: AppColors.shimmerHighlightColor,
                  child: Container(color: AppColors.shimmerBaseColor),
                ),
                errorWidget: (_, __, ___) => CachedNetworkImage(
                  imageUrl: topicThumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.shimmerBaseColor,
                    highlightColor: AppColors.shimmerHighlightColor,
                    child: Container(color: AppColors.shimmerBaseColor),
                  ),
                  errorWidget: (_, __, ___) =>
                      const NoImageFound(compact: true),
                ),
              ),
            ),
          ),
        ),
        12.w.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onOpenStory,
                child: AppText(
                  text: '$index. $title',
                  style: AppTextStyles.bold(fontSize: 17.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              4.w.verticalSpace,
              _MyReadingDescription(
                text: description,
                onOpenStory: onOpenStory,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MyReadingDescription extends StatefulWidget {
  const _MyReadingDescription({required this.text, required this.onOpenStory});
  final String text;
  final VoidCallback onOpenStory;

  @override
  State<_MyReadingDescription> createState() => _MyReadingDescriptionState();
}

class _MyReadingDescriptionState extends State<_MyReadingDescription> {
  static const int _minCharsForToggle = 55;
  bool isExpanded = false;

  void _toggleExpanded() {
    if (!mounted) return;
    setState(() => isExpanded = !isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = widget.text.trim();
    final display = trimmed.isEmpty ? 'No description available.' : trimmed;
    final bodyStyle = AppTextStyles.regular(
      fontSize: 14.sp,
      color: AppColors.black.withValues(alpha: 0.55),
    );
    final linkStyle =
        AppTextStyles.semibold(fontSize: 14.sp, color: AppColors.teal).copyWith(
          decoration: TextDecoration.underline,
          decorationColor: AppColors.teal,
        );

    if (display.length <= _minCharsForToggle) {
      return AppText(text: display, style: bodyStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.onOpenStory,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            child: AppText(
              text: display,
              style: bodyStyle,
              maxLines: isExpanded ? null : 2,
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
          ),
        ),
        GestureDetector(
          onTap: _toggleExpanded,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  child: child,
                ),
              );
            },
            child: AppText(
              key: ValueKey(isExpanded),
              text: isExpanded ? 'Read less' : 'Read more',
              style: linkStyle,
            ),
          ),
        ),
      ],
    );
  }
}

class _MyExpandableDescription extends StatefulWidget {
  const _MyExpandableDescription({required this.text});
  final String text;

  @override
  State<_MyExpandableDescription> createState() =>
      _MyExpandableDescriptionState();
}

class _MyExpandableDescriptionState extends State<_MyExpandableDescription> {
  static const int _minCharsForToggle = 100;
  bool isExpanded = false;

  void _toggleExpanded() {
    setState(() => isExpanded = !isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final full = widget.text.trim();
    final display = full.isEmpty ? 'No description available.' : full;

    final bodyStyle = AppTextStyles.medium(
      color: AppColors.black.withValues(alpha: 0.55),
      fontSize: 14.sp,
    );
    final linkStyle =
        AppTextStyles.semibold(fontSize: 14.sp, color: AppColors.teal).copyWith(
          decoration: TextDecoration.underline,
          decorationColor: AppColors.teal,
        );

    if (display.length <= _minCharsForToggle) {
      return AppText(text: display, style: bodyStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOutCubic,
          child: AppText(
            text: display,
            style: bodyStyle,
            maxLines: isExpanded ? null : 2,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
        6.w.verticalSpace,
        GestureDetector(
          onTap: _toggleExpanded,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  child: child,
                ),
              );
            },
            child: AppText(
              key: ValueKey(isExpanded),
              text: isExpanded ? 'Read less' : 'Read more',
              style: linkStyle,
            ),
          ),
        ),
      ],
    );
  }
}
