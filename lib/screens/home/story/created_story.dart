import 'dart:async';

import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:redstreakapp/core/utils/share_helper.dart';

import 'package:redstreakapp/core/widgets/global_widgets.dart';

import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/screens/home/widgets/home_section_shimmers.dart';

import 'package:shimmer/shimmer.dart';

class CreatedStoryReadingScreen extends StatefulWidget {
  const CreatedStoryReadingScreen({super.key});

  @override
  State<CreatedStoryReadingScreen> createState() =>
      _CreatedStoryReadingScreenState();
}

class _CreatedStoryReadingScreenState extends State<CreatedStoryReadingScreen> {
  int _currentPageIndex = 0;
  Timer? _readingTimer;
  int _remainingSeconds = 0;
  bool _hasStartedReading = false;
  bool _isTimerRunning = false;

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startReadingTimer(int lessonDurationMinutes) {
    _readingTimer?.cancel();
    final initialMinutes = lessonDurationMinutes > 0
        ? lessonDurationMinutes
        : 10;
    setState(() {
      _hasStartedReading = true;
      _isTimerRunning = true;
      _remainingSeconds = initialMinutes * 60;
    });

    _readingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_isTimerRunning) return;
      if (_remainingSeconds <= 1) {
        _readingTimer?.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isTimerRunning = false;
        });
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _togglePauseResume() {
    if (!_hasStartedReading) return;
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });
  }

  void _goToNextPage(int totalPages) {
    if (_currentPageIndex >= totalPages - 1) return;
    setState(() => _currentPageIndex++);
  }

  void _goToPreviousPage() {
    if (_currentPageIndex <= 0) return;
    setState(() => _currentPageIndex--);
  }

  @override
  void dispose() {
    _readingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: AppLayout(
        body: Consumer<StoryProvider>(
          builder: (context, provider, child) {
            final storyLoading =
                provider.isCreateStoryLoading ||
                    provider.isGenerateSingleStoryLoading;
            if (storyLoading) {
              return HomeSectionShimmer.createdStoryReadingUIShimmer();
            }
            if (provider.stories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final stories = provider.stories.first;
            final pages = stories.pages;
            if (pages.isEmpty) {
              return Center(
                child: AppText(
                  text: "No pages available",
                  style: AppTextStyles.medium(
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
              );
            }

            final safePageIndex = _currentPageIndex.clamp(0, pages.length - 1);
            final story = pages[safePageIndex];
            final isFirstPage = safePageIndex == 0;
            final isLastPage = safePageIndex == pages.length - 1;
            return Column(
              children: [
                //*top image content
                SizedBox(
                  height: 310.w,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: stories.thumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.shimmerBaseColor,
                          highlightColor: AppColors.shimmerHighlightColor,
                          child: Container(),
                        ),
                        errorWidget: (context, url, error) =>
                            const NoImageFound(),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(14.w, 18.w, 14.w, 14.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _StoryCircleButton(
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
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: AppText(
                                      text:
                                          'Page ${safePageIndex + 1} of ${pages.length}',
                                      style: AppTextStyles.bold(
                                        fontSize: 12.sp,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AppText(
                                          text:
                                              '${safePageIndex + 1}. ${stories.title.isNotEmpty ? stories.title : 'Exploring the wonders of Nature'}',
                                          style: AppTextStyles.bold(
                                            fontSize: 24,
                                            height: 1.2,
                                            color: AppColors.white,
                                          ),
                                        ),
                                        10.w.verticalSpace,
                                        if (!_hasStartedReading) ...[
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.menu_book_outlined,
                                                size: 16.sp,
                                                color: AppColors.white,
                                              ),
                                              6.w.horizontalSpace,
                                              AppText(
                                                text: '${pages.length} Pages',
                                                style: AppTextStyles.medium(
                                                  fontSize: 14,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                              14.w.horizontalSpace,
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 16.sp,
                                                color: AppColors.white,
                                              ),
                                              6.w.horizontalSpace,
                                              AppText(
                                                text:
                                                    '${stories.lessonDuration ?? 0} min',
                                                style: AppTextStyles.medium(
                                                  fontSize: 14,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  10.w.horizontalSpace,
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_hasStartedReading) ...[
                                        //* Pause/Play Button
                                        _StoryCircleButton(
                                          onTap: _togglePauseResume,
                                          child: Icon(
                                            _isTimerRunning
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded,
                                            size: 18.w,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        8.w.horizontalSpace,
                                        //* Timer Text
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 6.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: .min,
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 17.sp,
                                                color: AppColors.black,
                                              ),
                                              6.w.horizontalSpace,
                                              AppText(
                                                text: _formatDuration(
                                                  _remainingSeconds,
                                                ),
                                                style: AppTextStyles.bold(
                                                  fontSize: 15.sp,
                                                  color: AppColors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ] else ...[
                                        //* Share Button
                                        _StoryCircleButton(
                                          onTap: () {
                                            shareSingleStory(
                                              storyIdeaId: stories.id,
                                            );
                                          },
                                          child: SvgIcon(
                                            AppAssets.shareIcon,
                                            size: 18.w,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        8.w.horizontalSpace,
                                        //* More Options Button
                                        _StoryCircleButton(
                                          onTap: () {},
                                          child: Icon(
                                            Icons.more_vert_rounded,
                                            size: 19.w,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ],
                                    ],
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
                //*story content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsetsGeometry.fromLTRB(
                      16.w,
                      12.w,
                      16.w,
                      10.w,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          text: story.text,
                          style: AppTextStyles.medium(
                            fontSize: 14,
                            color: AppColors.black,
                          ),
                        ),
                        16.w.verticalSpace,
                        CachedNetworkImage(
                          imageUrl: story.imageUrl,
                          height: 210.w,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: AppColors.shimmerBaseColor,
                            highlightColor: AppColors.shimmerHighlightColor,
                            child: Container(color: AppColors.shimmerBaseColor),
                          ),
                          errorWidget: (context, url, error) =>
                              const NoImageFound(),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_hasStartedReading)
                        AppButton(
                          text: "Start Reading",
                          onTap: () =>
                              _startReadingTimer(stories.lessonDuration ?? 10),
                          fontSize: 14.sp,
                        )
                      else ...[
                        if (isLastPage)
                          AppButton(
                            text: "Take Quiz",
                            onTap: () {
                              context.pushNamed(
                                AppRoutes.enterQuizNumbersScreen.name,
                                extra: {'storyId': stories.id},
                              );
                            },
                            fontSize: 14.sp,
                          )
                        else
                          AppButton(
                            text: "Next Page",
                            onTap: () => _goToNextPage(pages.length),
                            fontSize: 14.sp,
                          ),
                        if (!isFirstPage) ...[
                          8.w.verticalSpace,
                          GestureDetector(
                            onTap: _goToPreviousPage,
                            child: AppText(
                              text: "Previous Page",
                              style: AppTextStyles.medium(
                                fontSize: 12,
                                color: AppColors.teal,
                              ),
                            ),
                          ),
                        ],
                      ],
                      8.w.verticalSpace,
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

class _StoryCircleButton extends StatelessWidget {
  const _StoryCircleButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
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
      ),
    );
  }
}
