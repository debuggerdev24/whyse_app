import 'dart:async';
import 'dart:ui';

import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/providers/home/saved_series_provider.dart';
import 'package:redstreakapp/models/home/story_models/reading_exit_snapshot.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/reading_appearance_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/models/gamification/score_award_result.dart';
import 'package:redstreakapp/services/home/story_api_service.dart';
import 'package:redstreakapp/screens/home/story/widget/font_theme_bottom_sheet.dart';
import 'package:redstreakapp/screens/home/widgets/home_section_shimmers.dart';

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
  bool _isFinishingEpisode = false;

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

  Future<void> _onChapterCompleted({
    required BuildContext context,
    required StoryProvider storyProvider,
    required String storyId,
    required String storyTitle,
    required String? storyImageUrl,
    required int episodeNumber,
    required String? seriesTitle,
    required int pageIndex,
    required int pageCount,
  }) async {
    if (_isFinishingEpisode) return;
    setState(() => _isFinishingEpisode = true);

    final storyIdeaId = widget.storyIdeaId;
    final homeProvider = context.read<HomeProvider>();
    final prevReading = storyIdeaId != null && storyIdeaId.isNotEmpty
        ? homeProvider.continueReadingForIdea(storyIdeaId)
        : null;
    final hadReadingLeft = prevReading == null
        ? true
        : !prevReading.isReadingComplete;
    final quizAlreadyDone = prevReading?.quizProgress?.isCompleted == true &&
        (prevReading?.quizProgress?.totalQuestions ?? 0) > 0;
    final shouldGrantReadingReward = hadReadingLeft && !quizAlreadyDone;

    if (storyIdeaId != null && storyIdeaId.isNotEmpty && pageCount > 0) {
      homeProvider.applyLocalReadingProgressFromReadingSession(
        storyIdeaId: storyIdeaId,
        lastPageIndex: pageIndex,
        pageCount: pageCount,
      );
    }

    final gamification = context.read<GamificationProvider>();
    ScoreAwardResult? readingAwards;
    if (storyIdeaId != null && storyIdeaId.isNotEmpty) {
      await gamification.finishReadingSession(
        storyIdeaId: storyIdeaId,
        lastPageIndex: pageIndex,
      );
      if (shouldGrantReadingReward) {
        readingAwards = await gamification.completeEpisodeAfterReading(
          storyIdeaId: storyIdeaId,
        );
      }
    }

    if (!mounted) return;
    setState(() => _isFinishingEpisode = false);

    var summary = homeProvider.storySummary;
    var resolvedTopicId = summary?.topicId ??
        homeProvider.activeStoryIdeasTopicId ??
        widget.continueReadingTopicId;

    if (resolvedTopicId != null &&
        resolvedTopicId.isNotEmpty &&
        summary == null) {
      await homeProvider.getTopicStoryDetails(
        topicId: resolvedTopicId,
        showLoadingUi: false,
      );
      summary = homeProvider.storySummary;
      resolvedTopicId = summary?.topicId ?? resolvedTopicId;
    }

    final totalEpisodes = summary?.storyIdeas.length ??
        storyProvider.storyIdeas?.storyIdeas.length ??
        summary?.overallProgress?.totalStories ??
        0;
    final topicFromIdeas = storyProvider.storyIdeas?.topic.title.trim();
    final resolvedSeries =
        (seriesTitle != null && seriesTitle.trim().isNotEmpty)
        ? seriesTitle.trim()
        : (summary?.topicTitle.trim().isNotEmpty == true
              ? summary!.topicTitle.trim()
              : (topicFromIdeas != null && topicFromIdeas.isNotEmpty
                    ? topicFromIdeas
                    : null));
    final quizExtra = {
      'storyId': storyId,
      'storyTitle': storyTitle,
      'storyImageUrl': storyImageUrl,
      'storyIdeaId': widget.storyIdeaId,
      'episodeNumber': episodeNumber,
      'seriesTitle': resolvedSeries,
      'totalEpisodes': totalEpisodes,
      'fromContinueReading': widget.fromContinueReading,
      if ((widget.continueReadingTopicId ?? '').isNotEmpty)
        'continueReadingTopicId': widget.continueReadingTopicId,
      'topicId': resolvedTopicId,
    };

    if (shouldGrantReadingReward) {
      final readingCompleted = homeProvider.countReadingCompletedEpisodes();
      final resolvedCompleted = readingCompleted > 0
          ? readingCompleted
          : episodeNumber;
      final progressPercent = totalEpisodes > 0
          ? ((resolvedCompleted / totalEpisodes) * 100).round().clamp(0, 100)
          : 0;
      final sparksPoints = gamification.resolveEpisodePoints(readingAwards);

      context.pushReplacementNamed(
        AppRoutes.episodeCompletedScreen.name,
        extra: {
          ...quizExtra,
          'completedEpisodes': resolvedCompleted,
          'totalEpisodes': totalEpisodes,
          'progressPercent': progressPercent,
          'sparksPoints': sparksPoints,
        },
      );
      return;
    }

    context.pushReplacementNamed(
      AppRoutes.startQuizScreen.name,
      extra: quizExtra,
    );
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
              if (!_hasStartedReading && pages.isNotEmpty) {
                final minutes = stories.lessonDuration ?? 10;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted || _hasStartedReading) return;
                  _startReadingTimer(minutes);
                });
              }
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
              final pageColor = appearance.selectedThemeIndex == 0
                  ? const Color(0xFFF2F2F7)
                  : theme.background;
              final bodyColor = appearance.selectedThemeIndex == 0
                  ? const Color(0xCC1A1A1A)
                  : theme.text;
              final bodyStyle = appearance.storyBodyTextStyle(
                color: bodyColor,
                height: 1.5,
              );
              final previewSeconds = ((stories.lessonDuration ?? 0) > 0
                      ? stories.lessonDuration!
                      : 10) *
                  60;
              final timerLabel = _formatDuration(
                _hasStartedReading ? _remainingSeconds : previewSeconds,
              );
              final topicId =
                  widget.continueReadingTopicId ??
                  context.read<HomeProvider>().activeStoryIdeasTopicId;

              return ColoredBox(
                color: pageColor,
                child: Column(
                children: [
                  _ReadingHero(
                    imageUrl: stories.thumbnailUrl,
                    title: heroTitle,
                    pageLabel:
                        'Page ${safePageIndex + 1} of ${pages.length}',
                    topicId: topicId,
                    onBack: () => _leaveReader(context, provider),
                    onCustomize: () => showFontThemeBottomSheet(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: bodyStyle,
                              children: _readingTextSpans(
                                story.text,
                                bodyStyle,
                              ),
                            ),
                          ),
                          18.h.verticalSpace,
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: AppNetworkImage(
                              imageUrl: story.imageUrl,
                              tag: 'CreatedStoryReading.pageImage',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      MediaQuery.paddingOf(context).bottom + 12,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _RoundBlackButton(
                              onTap: () {
                                if (!_hasStartedReading) {
                                  _startReadingTimer(
                                    stories.lessonDuration ?? 10,
                                  );
                                  return;
                                }
                                _togglePauseResume();
                              },
                              child: SvgIcon(
                                _hasStartedReading && _isTimerRunning
                                    ? AppAssets.pauseIcon
                                    : AppAssets.playIcon,
                                size: 15,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _TimerPill(label: timerLabel),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (isLastPage && isFirstPage)
                          _BottomPrimaryButton(
                            text: _isFinishingEpisode
                                ? 'Saving...'
                                : 'Take Quiz',
                            onTap: _isFinishingEpisode
                                ? null
                                : () => _onChapterCompleted(
                                    context: context,
                                    storyProvider: provider,
                                    storyId: stories.id,
                                    storyTitle: stories.title,
                                    storyImageUrl: stories.thumbnailUrl,
                                    episodeNumber: stories.sequenceIndex ?? 1,
                                    seriesTitle: stories.readingTopic,
                                    pageIndex: safePageIndex,
                                    pageCount: pages.length,
                                  ),
                          )
                        else if (isLastPage)
                          Row(
                            children: [
                              Expanded(
                                child: _BottomSecondaryButton(
                                  text: 'Previous Page',
                                  onTap: _goToPreviousPage,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _BottomPrimaryButton(
                                  text: _isFinishingEpisode
                                      ? 'Saving...'
                                      : 'Take Quiz',
                                  onTap: _isFinishingEpisode
                                      ? null
                                      : () => _onChapterCompleted(
                                          context: context,
                                          storyProvider: provider,
                                          storyId: stories.id,
                                          storyTitle: stories.title,
                                          storyImageUrl: stories.thumbnailUrl,
                                          episodeNumber:
                                              stories.sequenceIndex ?? 1,
                                          seriesTitle: stories.readingTopic,
                                          pageIndex: safePageIndex,
                                          pageCount: pages.length,
                                        ),
                                ),
                              ),
                            ],
                          )
                        else if (isFirstPage)
                          _BottomPrimaryButton(
                            text: 'Next page',
                            onTap: () => _goToNextPage(pages.length),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: _BottomSecondaryButton(
                                  text: 'Previous Page',
                                  onTap: _goToPreviousPage,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _BottomPrimaryButton(
                                  text: 'Next page',
                                  onTap: () => _goToNextPage(pages.length),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BottomPrimaryButton extends StatelessWidget {
  const _BottomPrimaryButton({required this.text, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _GlassPillButton(
      onTap: onTap,
      tint: AppColors.teal,
      shine: Color.lerp(AppColors.teal, Colors.white, 0.18)!,
      borderColor: const Color(0x33FFFFFF),
      shadowColor: const Color(0x1A000000),
      child: AppText(
        text: text,
        style: AppTextStyles.semibold(
          fontSize: 14,
          color: Colors.white,
        ).copyWith(height: 17 / 14),
      ),
    );
  }
}

class _BottomSecondaryButton extends StatelessWidget {
  const _BottomSecondaryButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _GlassPillButton(
      onTap: onTap,
      tint: const Color(0xD9FFFFFF),
      shine: const Color(0xFFFFFFFF),
      borderColor: const Color(0xFFE8E8E8),
      shadowColor: const Color(0x14000000),
      child: AppText(
        text: text,
        style: AppTextStyles.semibold(
          fontSize: 14,
          color: AppColors.onLight,
        ).copyWith(height: 17 / 14),
      ),
    );
  }
}

class _GlassPillButton extends StatelessWidget {
  const _GlassPillButton({
    required this.child,
    required this.tint,
    required this.shine,
    required this.borderColor,
    required this.shadowColor,
    this.onTap,
  });

  final Widget child;
  final Color tint;
  final Color shine;
  final Color borderColor;
  final Color shadowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(40));
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: borderColor),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [shine, tint, tint],
                  stops: const [0, 0.42, 1],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundBlackButton extends StatelessWidget {
  const _RoundBlackButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.buttonBackground,
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.buttonBackground,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SvgIcon(AppAssets.timerIcon, size: 15),
          const SizedBox(width: 2),
          AppText(
            text: label,
            style: AppTextStyles.medium(
              fontSize: 12,
              color: Colors.white,
              height: 15 / 12,
            ).copyWith(letterSpacing: -0.24),
          ),
        ],
      ),
    );
  }
}

class _ReadingHero extends StatelessWidget {
  const _ReadingHero({
    required this.imageUrl,
    required this.title,
    required this.pageLabel,
    required this.topicId,
    required this.onBack,
    required this.onCustomize,
  });

  final String? imageUrl;
  final String title;
  final String pageLabel;
  final String? topicId;
  final VoidCallback onBack;
  final VoidCallback onCustomize;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      height: 258,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 32,
            offset: Offset(0, 16),
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(
              imageUrl: imageUrl,
              tag: 'CreatedStoryReading.hero',
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0x66000000)],
                  stops: [0.62, 1],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, topInset + 8, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _FrostedPill(label: pageLabel),
                        Row(
                          children: [
                            GlassIconButton(
                              onTap: onBack,
                              child: Icon(
                                Icons.chevron_left_rounded,
                                color: AppColors.black,
                                size: 26,
                              ),
                            ),
                            const Spacer(),
                            GlassIconButton(
                              onTap: onCustomize,
                              child: AppText(
                                text: 'Aa',
                                style: AppTextStyles.semibold(
                                  fontSize: 16,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _ReadingBookmarkButton(topicId: topicId),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppText(
                      text: title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semibold(
                        fontSize: 22,
                        color: Colors.white,
                      ).copyWith(height: 1.2, letterSpacing: -0.3),
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

class _FrostedPill extends StatelessWidget {
  const _FrostedPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0x73FFFFFF),
            border: Border.all(color: const Color(0xCCFFFFFF)),
          ),
          child: AppText(
            text: label,
            style: AppTextStyles.semibold(
              fontSize: 14,
              color: AppColors.onLight,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadingBookmarkButton extends StatelessWidget {
  const _ReadingBookmarkButton({required this.topicId});

  final String? topicId;

  @override
  Widget build(BuildContext context) {
    final id = topicId?.trim() ?? '';
    if (id.isEmpty) {
      return GlassIconButton(
        onTap: _noop,
        child: Icon(
          Icons.bookmark_border_rounded,
          color: AppColors.black,
          size: 22,
        ),
      );
    }

    final saved = context.watch<SavedSeriesProvider>();
    final isInList = saved.topicIsInMyListOverride(id) ?? false;
    final isToggling = saved.isTopicListToggling(id);

    return GlassIconButton(
      onTap: isToggling
          ? () {}
          : () {
              context
                  .read<SavedSeriesProvider>()
                  .toggleTopic(
                    topicId: id,
                    onFailed: (error) {
                      if (!context.mounted) return;
                      AppToast.error(context, error);
                    },
                  )
                  .then((result) {
                    if (result == null || !context.mounted) return;
                    final msg =
                        result.message ??
                        (result.isInMyList
                            ? 'Added to My List'
                            : 'Removed from My List');
                    AppToast.success(context, msg);
                  });
            },
      child: isToggling
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.black,
              ),
            )
          : Icon(
              isInList ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: AppColors.black,
              size: 22,
            ),
    );
  }
}

void _noop() {}

List<InlineSpan> _readingTextSpans(String raw, TextStyle base) {
  final text = raw
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');
  final spans = <InlineSpan>[];
  final bold = <bool>[false];
  final underline = <bool>[false];
  final buffer = StringBuffer();
  final tags = RegExp(
    r'<(/?)(b|strong|u|p)[^>]*>',
    caseSensitive: false,
  );

  void flush() {
    if (buffer.isEmpty) return;
    final isBold = bold.last;
    final isUnderline = underline.last;
    spans.add(
      TextSpan(
        text: buffer.toString(),
        style: base.copyWith(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          decoration: isUnderline
              ? TextDecoration.underline
              : TextDecoration.none,
          decorationColor: base.color,
        ),
      ),
    );
    buffer.clear();
  }

  var index = 0;
  for (final match in tags.allMatches(text)) {
    buffer.write(text.substring(index, match.start));
    flush();
    final closing = match.group(1) == '/';
    final name = match.group(2)!.toLowerCase();
    if (name == 'b' || name == 'strong') {
      if (closing) {
        if (bold.length > 1) bold.removeLast();
      } else {
        bold.add(true);
      }
    } else if (name == 'u') {
      if (closing) {
        if (underline.length > 1) underline.removeLast();
      } else {
        underline.add(true);
      }
    } else if (closing) {
      buffer.write('\n');
    }
    index = match.end;
  }
  buffer.write(text.substring(index).replaceAll(RegExp(r'<[^>]*>'), ''));
  flush();
  if (spans.isEmpty) {
    spans.add(TextSpan(text: '', style: base));
  }
  return spans;
}
