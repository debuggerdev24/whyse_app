import 'package:cached_network_image/cached_network_image.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/screens/home/widgets/story_ui_components.dart';
import 'package:shimmer/shimmer.dart';

class CreatedIdeasList extends StatelessWidget {
  const CreatedIdeasList({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Consumer<StoryProvider>(
        builder: (context, provider, child) {
          final storyIdeas = provider.storyIdeas;
          if (storyIdeas == null) {
            return const _CreatedIdeasListShimmer();
          }
          final topic = provider.storyIdeas?.topic;
          final title = topic?.title.isNotEmpty == true
              ? topic!.title
              : 'Nature';
          final description = topic?.learningGoal ?? '';
          final thumb = topic?.thumbnailUrl ?? '';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //*Top Image
                StoryHeroHeader(
                  imageUrl: thumb,
                  title: title,
                  topLeft: StoryCircleButton(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed(AppRoutes.homeScreen.name);
                      }
                    },
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 19.w,
                      color: AppColors.black,
                    ),
                  ),
                  bottomRight: StoryCircleButton(
                    onTap: () {
                      showMoreOptionsBottomSheet(
                        context,
                        onRegenerateTopic: () {
                          provider.clearStoryFields();
                          context.pushNamed(
                            AppRoutes.storyGoalsScreen.name,
                            extra: const {'openedFromCreatedIdeas': true},
                          );
                        },
                      );
                    },
                    child: Icon(
                      Icons.more_vert,
                      size: 17.w,
                      color: AppColors.black,
                    ),
                  ),
                  titleStyle: AppTextStyles.bold(
                    fontSize: 24.sp,
                    color: AppColors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      18.w.verticalSpace,
                      //* Topic Description
                      _ExpandableDescription(text: description),
                      10.w.verticalSpace,
                      //* meta chips
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _infoChip('12-15 years'),
                          8.w.horizontalSpace,
                          _infoChip('CEFR A2'),
                        ],
                      ),
                      20.w.verticalSpace,
                      GestureDetector(
                        onTap: () {
                          if (storyIdeas.storyIdeas.isEmpty) return;
                          context.pushNamed(AppRoutes.storyReadingScreen.name);
                          provider.createStory(
                            onFailed: (error) {
                              AppToast.error(context, error);
                            },
                            onSuccess: () {},
                            selectedIdeaIndex: 0,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          alignment: Alignment.center,
                          child: AppText(
                            text: 'Continue Reading',
                            style: AppTextStyles.bold(
                              fontSize: 18.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      18.w.verticalSpace,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Row(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {},
                              child: Column(
                                children: [
                                  SvgIcon(
                                    AppAssets.add,
                                    size: 24.w,
                                    color: AppColors.black,
                                  ),
                                  2.w.verticalSpace,
                                  AppText(
                                    text: 'Add to List',
                                    style: AppTextStyles.semibold(
                                      fontSize: 16.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            25.w.horizontalSpace,
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {},
                              child: Column(
                                children: [
                                  SvgIcon(
                                    AppAssets.shareIcon,
                                    size: 22.w,
                                    color: AppColors.black,
                                  ),
                                  4.w.verticalSpace,
                                  AppText(
                                    text: 'Share',
                                    style: AppTextStyles.semibold(
                                      fontSize: 16.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                            "${storyIdeas.storyIdeas.length} Readings • 10 mins",
                        style: AppTextStyles.bold(
                          fontSize: 16.sp,
                          color: AppColors.black,
                        ),
                      ),
                      18.w.verticalSpace,
                      //* Readings List
                      ...List.generate(
                        storyIdeas.storyIdeas.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(bottom: 18.w),
                          child: _ReadingItemTile(
                            onOpenStory: () {
                              context.pushNamed(
                                AppRoutes.storyReadingScreen.name,
                              );
                              provider.createStory(
                                onFailed: (error) {
                                  AppToast.error(context, error);
                                },
                                onSuccess: () {},
                                selectedIdeaIndex: index,
                              );
                            },
                            topicThumbnailUrl: topic?.thumbnailUrl ?? '',
                            index: index + 1,
                            isSelected: index == 0,
                            title: storyIdeas.storyIdeas[index].title,
                            description:
                                storyIdeas.storyIdeas[index].description,
                            thumbnailUrl:
                                storyIdeas.storyIdeas[index].thumbnailUrl
                                    ?.toString() ??
                                '',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  showMoreOptionsBottomSheet(
    BuildContext context, {
    required VoidCallback onRegenerateTopic,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: .fromLTRB(
                20,
                25,
                20,
                MediaQuery.paddingOf(context).bottom + 15,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        text: "More Options",
                        style: AppTextStyles.bold(fontSize: 18.sp),
                      ),
                      StoryCircleButton(
                        onTap: () => context.pop(),
                        child: Icon(
                          Icons.close,
                          size: 15.w,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  20.w.verticalSpace,
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.extealighttealcolor,
                      foregroundColor: AppColors.teal,
                      minimumSize: Size(double.infinity, 48.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () {
                      context.pop();
                      onRegenerateTopic.call();
                    },
                    child: AppText(
                      text: "Regenerate Topic",
                      style: AppTextStyles.semiBold(fontSize: 16.sp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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

class _ReadingItemTile extends StatelessWidget {
  const _ReadingItemTile({
    required this.onOpenStory,
    required this.index,
    required this.isSelected,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.topicThumbnailUrl,
  });

  final VoidCallback onOpenStory;
  final int index;
  final bool isSelected;
  final String title, description, thumbnailUrl, topicThumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onOpenStory,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
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
                    ),
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: -8.w,
                  right: -8.w,
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2.w),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14.w,
                      color: AppColors.white,
                    ),
                  ),
                ),
            ],
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
              _ReadingDescription(text: description, onOpenStory: onOpenStory),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadingDescription extends StatefulWidget {
  const _ReadingDescription({required this.text, required this.onOpenStory});
  final String text;
  final VoidCallback onOpenStory;
  @override
  State<_ReadingDescription> createState() => _ReadingDescriptionState();
}

class _ReadingDescriptionState extends State<_ReadingDescription> {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: display, style: bodyStyle),
          maxLines: 2,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final hasOverflow = textPainter.didExceedMaxLines;
        if (!hasOverflow) return AppText(text: display, style: bodyStyle);

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
                  text: isExpanded ? 'Read less' : 'more',
                  style: linkStyle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  const _ExpandableDescription({required this.text});

  final String text;

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
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
            overflow: isExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
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

//*Shimmers
class _CreatedIdeasListShimmer extends StatelessWidget {
  const _CreatedIdeasListShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.shimmerBaseColor,
            highlightColor: AppColors.shimmerHighlightColor,
            child: Container(
              height: 310.w,
              width: double.infinity,
              color: AppColors.shimmerBaseColor,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                18.w.verticalSpace,
                Shimmer.fromColors(
                  baseColor: AppColors.shimmerBaseColor,
                  highlightColor: AppColors.shimmerHighlightColor,
                  child: Container(
                    height: 36.w,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBaseColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                10.w.verticalSpace,
                Shimmer.fromColors(
                  baseColor: AppColors.shimmerBaseColor,
                  highlightColor: AppColors.shimmerHighlightColor,
                  child: Container(
                    height: 34.w,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBaseColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
                18.w.verticalSpace,
                Shimmer.fromColors(
                  baseColor: AppColors.shimmerBaseColor,
                  highlightColor: AppColors.shimmerHighlightColor,
                  child: Container(
                    height: 18.w,
                    width: 150.w,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBaseColor,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                ),
                18.w.verticalSpace,
                ...List.generate(
                  6,
                  (_) => Padding(
                    padding: EdgeInsets.only(bottom: 18.w),
                    child: const _ReadingItemTileShimmer(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingItemTileShimmer extends StatelessWidget {
  const _ReadingItemTileShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 122.w,
            height: 84.w,
            decoration: BoxDecoration(
              color: AppColors.shimmerBaseColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          12.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18.w,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBaseColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                8.w.verticalSpace,
                Container(
                  height: 14.w,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBaseColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                6.w.verticalSpace,
                Container(
                  height: 14.w,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBaseColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
