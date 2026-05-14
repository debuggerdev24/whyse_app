import 'dart:async';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/share_helper.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/home/story_models/reading_exit_snapshot.dart';
import 'package:redstreakapp/providers/home/reading_appearance_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/services/home/story_api_service.dart';
import 'package:redstreakapp/screens/home/story/widget/font_theme_bottom_sheet.dart';
import 'package:redstreakapp/screens/home/widgets/home_section_shimmers.dart';
import 'package:redstreakapp/screens/home/widgets/story_ui_components.dart';

class CreatedStoryReadingScreen extends StatefulWidget {
  const CreatedStoryReadingScreen({
    super.key,
    this.initialPageIndex = 0,
    this.initialConfirmedPageIndex,
    this.storyIdeaId,
    this.fromContinueReading = false,
    this.continueReadingTopicId,
    this.resumeStoryIsGenerated,
  });

  final int initialPageIndex;

  /// The last page index that was already confirmed as read (saved on server).
  /// This prevents counting the currently shown page as read just by viewing it.
  final int? initialConfirmedPageIndex;
  final String? storyIdeaId;

  /// When true, user opened this reader from the home Continue Reading shelf (not My Stories).
  final bool fromContinueReading;

  /// Topic id for returning to [MyStoryIdeasScreen] after quiz when "See Next Story".
  final String? continueReadingTopicId;

  /// From Continue Reading API: resume target story's `isGenerated`. When false,
  /// [getStoryByIdea] runs generation; when null, only fetch (legacy / other entry).
  final bool? resumeStoryIsGenerated;

  @override
  State<CreatedStoryReadingScreen> createState() =>
      _CreatedStoryReadingScreenState();
}

class _CreatedStoryReadingScreenState extends State<CreatedStoryReadingScreen> {
  /// Batches rapid "Next Page" taps into one API call (latest page wins).
  static const _progressDebounce = Duration(milliseconds: 450);

  String? _prefetchedMcqQuizForStoryId;

  late int _currentPageIndex;
  Timer? _readingTimer;
  Timer? _progressDebounceTimer;
  int _queuedProgressPageIndex = -1;
  int _maxConfirmedPageIndex = -1;
  int _remainingSeconds = 0;
  bool _hasStartedReading = false;
  bool _isTimerRunning = false;
  bool _timeUpDialogShown = false;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPageIndex;
    final initialConfirmed =
        widget.initialConfirmedPageIndex ?? (widget.initialPageIndex - 1);
    _maxConfirmedPageIndex = initialConfirmed;

    // If we navigated here before fetching the story (Continue Reading),
    // kick off a fetch in the background. UI already shows shimmer while loading.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sp = context.read<StoryProvider>();
      if (sp.stories.isNotEmpty) return;
      final id = widget.storyIdeaId;
      if (id == null || id.isEmpty) return;
      context.read<StoryProvider>().getStoryByIdea(
        context: context,
        storyIdea: id,
        fetchOnly: widget.resumeStoryIsGenerated != false,
        onStoryNotGenerated: () {},
        onSuccess: (payload) {
          if (!mounted) return;
          context.read<StoryProvider>().addStoryFromGetStoryByIdeaData(
            payload,
            0,
          );
        },
      );
    });
  }

  @override
  void didUpdateWidget(covariant CreatedStoryReadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.storyIdeaId != oldWidget.storyIdeaId) {
      _prefetchedMcqQuizForStoryId = null;
    }
  }

  void _scheduleMcqQuizPrefetch(String storyId) {
    if (storyId.isEmpty || _prefetchedMcqQuizForStoryId == storyId) return;
    _prefetchedMcqQuizForStoryId = storyId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StoryProvider>().prefetchMcqQuizForReading(storyId: storyId);
    });
  }

  String _friendlyErrorMessage(String? raw) {
    final msg = (raw ?? '').trim();
    if (msg.isEmpty) return "We couldn’t load this story right now.";
    final lower = msg.toLowerCase();
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return "This is taking longer than expected. Please try again.";
    }
    if (lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('internet') ||
        lower.contains('connection')) {
      return "No internet connection. Please check your network and try again.";
    }
    return "We couldn’t load this story right now. Please try again.";
  }

  Widget _storyLoadErrorView({
    required String message,
    required VoidCallback onRetry,
    required VoidCallback onBack,
  }) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 56.w,
                color: AppColors.black.withValues(alpha: 0.35),
              ),
              14.w.verticalSpace,
              AppText(
                text: message,
                textAlign: TextAlign.center,
                style: AppTextStyles.medium(
                  fontSize: 16.sp,
                  color: AppColors.black.withValues(alpha: 0.75),
                ),
              ),
              20.w.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: AppFilledButton(
                      text: "Back",
                      onTap: onBack,
                      backgroundColor: AppColors.black.withValues(alpha: 0.08),
                      textStyle: AppTextStyles.semibold(
                        fontSize: 16.sp,
                        color: AppColors.black,
                      ),
                      fixedSize: Size(double.infinity, 44.h),
                    ),
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: AppFilledButton(
                      text: "Retry",
                      onTap: onRetry,
                      backgroundColor: AppColors.teal,
                      fixedSize: Size(double.infinity, 44.h),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _retryLoadStory() {
    final id = widget.storyIdeaId;
    if (id == null || id.isEmpty) return;
    context.read<StoryProvider>().getStoryByIdea(
      context: context,
      storyIdea: id,
      fetchOnly: widget.resumeStoryIsGenerated != false,
      onStoryNotGenerated: () {},
      onSuccess: (payload) {
        if (!mounted) return;
        context.read<StoryProvider>().addStoryFromGetStoryByIdeaData(
          payload,
          0,
        );
      },
    );
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
        _showTimeUpDialog();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _showTimeUpDialog() {
    if (!mounted) return;
    if (_timeUpDialogShown) return;
    _timeUpDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(20.w, 18.w, 20.w, 0),
          contentPadding: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 0),
          actionsPadding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 20.w),
          title: AppText(
            text: "Time’s up",
            style: AppTextStyles.bold(fontSize: 18.sp, color: AppColors.black),
          ),
          content: AppText(
            text: "We’ll save your progress and take you back.",
            style: AppTextStyles.medium(
              fontSize: 14.sp,
              color: AppColors.black.withValues(alpha: 0.7),
            ),
          ),
          actions: [
            AppFilledButton(
              text: "Save & exit",
              onTap: () {
                dialogContext.pop();
                if (!mounted) return;
                final sp = context.read<StoryProvider>();
                _leaveReader(context, sp);
              },
              backgroundColor: AppColors.teal,
              fixedSize: Size(double.infinity, 44.h),
            ),
          ],
        );
      },
    );
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
    // Progress is saved only when the user taps "Next Page" (leaving a page) or
    // "Take Quiz" on the last page — not when opening a page or closing the reader.
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
                  provider.isGettingStoryByIdeaLoading ||
                  provider.isCreateStoryLoading ||
                  provider.isGenerateSingleStoryLoading;
              if (storyLoading) {
                return HomeSectionShimmer.createdStoryReadingUIShimmer();
              }
              if (provider.stories.isEmpty) {
                final msg = _friendlyErrorMessage(provider.getStoryByIdeaError);
                return _storyLoadErrorView(
                  message: msg,
                  onRetry: _retryLoadStory,
                  onBack: () {
                    if (!context.mounted) return;
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(AppRoutes.homeScreen.name);
                    }
                  },
                );
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

              final safePageIndex = _currentPageIndex.clamp(
                0,
                pages.length - 1,
              );
              final story = pages[safePageIndex];
              final isFirstPage = safePageIndex == 0;
              final isLastPage = safePageIndex == pages.length - 1;
              final theme = appearance.activeTheme;
              final storyOrder = stories.sequenceIndex;
              final titlePrefix = storyOrder != null && storyOrder > 0
                  ? '$storyOrder. '
                  : '';
              final heroTitle =
                  '$titlePrefix${stories.title.isNotEmpty ? stories.title : ''}';
              _scheduleMcqQuizPrefetch(stories.id);
              return Column(
                children: [
                  //*top image content
                  StoryHeroHeader(
                    contentBottomPadding: 18.h,
                    imageUrl: stories.thumbnailUrl,
                    title: heroTitle,
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
                            AppNetworkImage(
                              imageUrl: story.imageUrl,
                              tag: 'CreatedStoryReading.pageImage',
                              height: 210.w,
                              width: double.infinity,
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
                        12.w.verticalSpace,
                        if (!_hasStartedReading)
                          _BottomPrimaryButton(
                            text: 'Start Reading',
                            onTap: () => _startReadingTimer(
                              stories.lessonDuration ?? 10,
                            ),
                          )
                        else ...[
                          if (isLastPage)
                            _BottomPrimaryButton(
                              text: "Take Quiz",
                              onTap: () {
                                // Do NOT mark the last page as read just by opening the quiz.
                                // The server will finalize completion when quiz is submitted.
                                _schedulePageProgressReport(safePageIndex);
                                context.pushNamed(
                                  AppRoutes.startQuizScreen.name,
                                  extra: {
                                    'storyId': stories.id,
                                    'storyTitle': stories.title,
                                    'storyImageUrl': stories.thumbnailUrl,
                                    'storyIdeaId': widget.storyIdeaId,
                                    'fromContinueReading':
                                        widget.fromContinueReading,
                                    if ((widget.continueReadingTopicId ?? '')
                                        .isNotEmpty)
                                      'continueReadingTopicId':
                                          widget.continueReadingTopicId,
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
