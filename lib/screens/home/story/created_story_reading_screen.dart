import 'dart:async';

import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:redstreakapp/core/utils/share_helper.dart';

import 'package:redstreakapp/core/widgets/global_widgets.dart';

import 'package:redstreakapp/models/home/story_models/reading_exit_snapshot.dart';
import 'package:redstreakapp/providers/home/reading_appearance_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/services/home/story_api_service.dart';
import 'package:redstreakapp/screens/home/story/widget/font_theme_bottom_sheet.dart';
import 'package:redstreakapp/screens/home/widgets/home_section_shimmers.dart';
import 'package:redstreakapp/screens/home/widgets/story_ui_components.dart';

import 'package:shimmer/shimmer.dart';

class CreatedStoryReadingScreen extends StatefulWidget {
  const CreatedStoryReadingScreen({
    super.key,
    this.initialPageIndex = 0,
    this.initialConfirmedPageIndex,
    this.storyIdeaId,
  });

  final int initialPageIndex;
  /// The last page index that was already confirmed as read (saved on server).
  /// This prevents counting the currently shown page as read just by viewing it.
  final int? initialConfirmedPageIndex;
  final String? storyIdeaId;

  @override
  State<CreatedStoryReadingScreen> createState() =>
      _CreatedStoryReadingScreenState();
}

class _CreatedStoryReadingScreenState extends State<CreatedStoryReadingScreen> {
  /// Batches rapid "Next Page" taps into one API call (latest page wins).
  static const _progressDebounce = Duration(milliseconds: 450);

  late int _currentPageIndex;
  Timer? _readingTimer;
  Timer? _progressDebounceTimer;
  int _queuedProgressPageIndex = -1;
  int _maxConfirmedPageIndex = -1;
  int _remainingSeconds = 0;
  bool _hasStartedReading = false;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPageIndex;
    final initialConfirmed = widget.initialConfirmedPageIndex ??
        (widget.initialPageIndex - 1);
    _maxConfirmedPageIndex = initialConfirmed;
  }

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
    final completedPageIndex = _currentPageIndex;
    setState(() => _currentPageIndex++);
    // Mark the page we are leaving as read (not the page we are navigating to).
    _schedulePageProgressReport(completedPageIndex);
  }

  void _goToPreviousPage() {
    if (_currentPageIndex <= 0) return;
    setState(() => _currentPageIndex--);
  }

  void _schedulePageProgressReport(int pageIndex) {
    final storyIdeaId = widget.storyIdeaId;
    if (storyIdeaId == null || storyIdeaId.isEmpty) return;
    if (pageIndex < 0) return;
    _queuedProgressPageIndex = pageIndex;
    if (pageIndex > _maxConfirmedPageIndex) {
      _maxConfirmedPageIndex = pageIndex;
    }
    _progressDebounceTimer?.cancel();
    _progressDebounceTimer = Timer(_progressDebounce, _flushQueuedPageProgress);
  }

  void _flushQueuedPageProgress() {
    _progressDebounceTimer?.cancel();
    final storyIdeaId = widget.storyIdeaId;
    if (storyIdeaId == null || storyIdeaId.isEmpty) return;
    if (_queuedProgressPageIndex < 0) return;
    StoryApiService.instance.updatePageProgress(
      storyIdeaId: storyIdeaId,
      pageIndex: _queuedProgressPageIndex,
    );
    _queuedProgressPageIndex = -1;
  }

  void _syncPageProgressImmediately(int pageIndex) {
    final storyIdeaId = widget.storyIdeaId;
    if (storyIdeaId == null || storyIdeaId.isEmpty) return;
    if (pageIndex < 0) return;
    _progressDebounceTimer?.cancel();
    _queuedProgressPageIndex = -1;
    if (pageIndex > _maxConfirmedPageIndex) {
      _maxConfirmedPageIndex = pageIndex;
    }
    StoryApiService.instance.updatePageProgress(
      storyIdeaId: storyIdeaId,
      pageIndex: pageIndex,
    );
  }

  ReadingExitSnapshot? _snapshotForPop(StoryProvider storyProvider) {
    final id = widget.storyIdeaId;
    if (id == null || id.isEmpty) return null;
    final pages = storyProvider.stories.isEmpty
        ? null
        : storyProvider.stories.first.pages;
    final pageCount = pages?.length ?? 0;
    if (pageCount <= 0) return null;
    final confirmed = _maxConfirmedPageIndex.clamp(-1, pageCount - 1);
    if (confirmed < 0) return null;
    return ReadingExitSnapshot(
      storyIdeaId: id,
      lastPageIndex: confirmed,
      pageCount: pageCount,
    );
  }

  void _leaveReader(BuildContext context, StoryProvider storyProvider) {
    _flushQueuedPageProgress();
    final snap = _snapshotForPop(storyProvider);
    if (!context.mounted) return;
    if (context.canPop()) {
      context.pop(snap);
    } else {
      context.goNamed(AppRoutes.homeScreen.name);
    }
  }

  @override
  void dispose() {
    _readingTimer?.cancel();
    _progressDebounceTimer?.cancel();
    _flushQueuedPageProgress();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (!mounted) return;
          final sp = context.read<StoryProvider>();
          _leaveReader(context, sp);
        },
        child: AppLayout(
          body: Consumer2<StoryProvider, ReadingAppearanceProvider>(
          builder: (context, provider, appearance, child) {
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
            final theme = appearance.activeTheme;
            return Column(
              children: [
                //*top image content
                StoryHeroHeader(
                  imageUrl: stories.thumbnailUrl,
                  title:
                      '${safePageIndex + 1}. ${stories.title.isNotEmpty ? stories.title : 'Exploring the wonders of Nature'}',
                  topLeft: StoryCircleButton(
                    onTap: () => _leaveReader(context, provider),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 19.w,
                      color: AppColors.black,
                    ),
                  ),
                  titleStyle: AppTextStyles.bold(
                    fontSize: 20,
                    height: 1.2,
                    color: AppColors.white,
                  ),
                  titleBottomSpacing: 10.w,
                  bottomWidget: !_hasStartedReading
                      ? Row(
                          children: [
                            SvgIcon(
                              AppAssets.page,
                              size: 16.sp,
                              color: AppColors.white,
                            ),
                            6.w.horizontalSpace,
                            AppText(
                              text: '${pages.length} Pages',
                              style: AppTextStyles.semiBold(
                                fontSize: 12,
                                color: AppColors.white,
                              ),
                            ),
                            14.w.horizontalSpace,
                            SvgIcon(
                              AppAssets.clock,
                              size: 16.sp,
                              color: AppColors.white,
                            ),
                            6.w.horizontalSpace,
                            AppText(
                              text: '${stories.lessonDuration ?? 0} min',
                              style: AppTextStyles.semiBold(
                                fontSize: 12,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            AppText(
                              text:
                                  'Page ${safePageIndex + 1} of ${pages.length}',
                              style: AppTextStyles.bold(
                                fontSize: 13.sp,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                  bottomRight: _hasStartedReading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StoryCircleButton(
                              onTap: () {
                                showFontThemeBottomSheet(context);
                              },
                              child: AppText(
                                text: 'Aa',
                                style: AppTextStyles.bold(
                                  fontSize: 13.sp,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            8.w.horizontalSpace,
                            StoryCircleButton(
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
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.w,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 17.sp,
                                    color: AppColors.black,
                                  ),
                                  6.w.horizontalSpace,
                                  AppText(
                                    text: _formatDuration(_remainingSeconds),
                                    style: AppTextStyles.bold(
                                      fontSize: 15.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StoryCircleButton(
                              onTap: () {
                                showFontThemeBottomSheet(context);
                              },
                              child: AppText(
                                text: 'Aa',
                                style: AppTextStyles.bold(
                                  fontSize: 13.sp,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            8.w.horizontalSpace,
                            StoryCircleButton(
                              onTap: () {
                                shareSingleStory(storyIdeaId: stories.id);
                              },
                              child: SvgIcon(
                                AppAssets.shareIcon,
                                size: 18.w,
                                color: AppColors.black,
                              ),
                            ),
                            8.w.horizontalSpace,
                            StoryCircleButton(
                              onTap: () {},
                              child: Icon(
                                Icons.more_vert_rounded,
                                size: 19.w,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                ),
                //*story content
                Expanded(
                  child: ColoredBox(
                    color: theme.background,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 14.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            text: story.text,
                            style: appearance.storyBodyTextStyle(
                              color: theme.text,
                              height: 1.6,
                            ),
                          ),
                          20.w.verticalSpace,
                          CachedNetworkImage(
                            imageUrl: story.imageUrl,
                            height: 210.w,
                            width: double.infinity,
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_hasStartedReading)
                        _BottomPrimaryButton(
                          text: 'Start Reading',
                          onTap: () =>
                              _startReadingTimer(stories.lessonDuration ?? 10),
                        )
                      else ...[
                        if (isLastPage)
                          _BottomPrimaryButton(
                            text: "Take Quiz",
                            onTap: () {
                              _syncPageProgressImmediately(safePageIndex);
                              context.pushNamed(
                                AppRoutes.startQuizScreen.name,
                                extra: {
                                  'storyId': stories.id,
                                  'storyTitle': stories.title,
                                  'storyImageUrl': stories.thumbnailUrl,
                                },
                              );
                            },
                          )
                        else
                          _BottomPrimaryButton(
                            text: "Next Page",
                            onTap: () => _goToNextPage(pages.length),
                          ),
                        if (!isFirstPage) ...[
                          12.w.verticalSpace,
                          GestureDetector(
                            onTap: _goToPreviousPage,
                            child: AppText(
                              text: "Previous Page",
                              style: AppTextStyles.semibold(
                                fontSize: 15.sp,
                                color: AppColors.teal,
                              ),
                            ),
                          ),
                        ],
                      ],
                      (MediaQuery.paddingOf(context).bottom + 15)
                          .w
                          .verticalSpace,
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      ),
    );
  }
}

class _BottomPrimaryButton extends StatelessWidget {
  const _BottomPrimaryButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48.w,
        decoration: BoxDecoration(
          color: AppColors.teal,
          borderRadius: BorderRadius.circular(30.r),
        ),
        alignment: Alignment.center,
        child: AppText(
          text: text,
          style: AppTextStyles.bold(fontSize: 18.sp, color: AppColors.white),
        ),
      ),
    );
  }
}
