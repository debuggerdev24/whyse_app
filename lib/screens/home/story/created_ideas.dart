import 'package:cached_network_image/cached_network_image.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/global_widgets.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
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
                SizedBox(
                  height: 310.w,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (thumb.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: thumb,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: AppColors.shimmerBaseColor,
                            highlightColor: AppColors.shimmerHighlightColor,
                            child: Container(color: AppColors.shimmerBaseColor),
                          ),
                          errorWidget: (context, url, error) =>
                              const NoImageFound(),
                        )
                      else
                        const NoImageFound(),
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(14.w, 18.w, 14.w, 14.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //* Home and close button
                              Row(
                                children: [
                                  _circleButton(
                                    onTap: () {
                                      context.goNamed(AppRoutes.homeScreen.name);
                                    },
                                    child: SvgIcon(
                                      AppAssets.homeIcon,
                                      size: 15.w,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  _circleButton(
                                    child: Icon(
                                      Icons.close,
                                      size: 15.w,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              //* title and more button
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: AppText(
                                      text: title,
                                      style: AppTextStyles.bold(
                                        fontSize: 24.sp,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                  _circleButton(
                                    child: Icon(
                                      Icons.more_vert,
                                      size: 17.w,
                                      color: AppColors.black,
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
                      //* Topic Description
                      _ExpandableDescription(text: description),
                      10.w.verticalSpace,
                      //* share and bookmark button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _infoChip('12-15 years'),
                          8.w.horizontalSpace,
                          _infoChip('CEFR A2'),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(
                                  color: AppColors.black.withValues(alpha: 0.1),
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
                                  color: AppColors.black.withValues(alpha: 0.1),
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
                            "${storyIdeas!.storyIdeas.length} Readings - 10 mins",
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
                                onSuccess: () {
                                 
                                },
                                selectedIdeaIndex: index,
                              );
                            },
                            topicThumbnailUrl: topic?.thumbnailUrl ?? '',
                            index: index + 1,
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
        style: AppTextStyles.medium(
          fontSize: 12.sp,
          color: AppColors.teal,
        ),
      ),
    );
  }
}

class _ReadingItemTile extends StatelessWidget {
  const _ReadingItemTile({
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
  static const int _minCharsForToggle = 55;

  bool isExpanded = false;

  void _toggleExpanded() {
    // Avoid mutating widget tree during pointer/mouse tracker update cycle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => isExpanded = !isExpanded);
    });
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
        AppTextStyles.semibold(fontSize: 14.sp  , color: AppColors.teal).copyWith(
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
          child: AppText(
            text: display,
            style: bodyStyle,
            maxLines: isExpanded ? null : 2,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: _toggleExpanded,
          child: AppText(
            text: isExpanded ? 'Read less' : 'Read more',
            style: linkStyle,
          ),
        ),
      ],
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
    // Avoid mutating widget tree during pointer/mouse tracker update cycle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => isExpanded = !isExpanded);
    });
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

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _toggleExpanded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: display,
            style: bodyStyle,
            maxLines: isExpanded ? null : 2,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),

          6.w.verticalSpace,
          AppText(
            text: isExpanded ? 'Read less' : 'Read more',
            style: linkStyle,
          ),
        ],
      ),
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
