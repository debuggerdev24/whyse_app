import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/core/utils/share_helper.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/core/widgets/glass_icon_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/models/home/story_models/story_idea_model.dart'
    as generated_models;
import 'package:redstreakapp/models/home/story_models/story_summary_model.dart'
    as summary_models;
import 'package:redstreakapp/models/home/story_models/reading_exit_snapshot.dart';
import 'package:redstreakapp/models/home/story_models/quiz_exit_snapshot.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/saved_series_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/screens/home/widgets/home_section_shimmers.dart';

class MyStoryIdeasScreen extends StatefulWidget {
  const MyStoryIdeasScreen({
    super.key,
    this.preferGeneratedData = false,
    this.initialTopicId,
  });

  final bool preferGeneratedData;
  final String? initialTopicId;

  @override
  State<MyStoryIdeasScreen> createState() => _MyStoryIdeasScreenState();
}

class _MyStoryIdeasScreenState extends State<MyStoryIdeasScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _waitingForGeneratedFirstResponse = true;
  bool _showTopicDetailsShimmer = false;
  String? _topicIdForScreen;

  // Local progress overlay used in the generation flow before the API summary
  // (with continueReading) comes back. Keyed by storyIdeaId.
  final Map<String, summary_models.ContinueReading> _localContinueReading =
      <String, summary_models.ContinueReading>{};

  // Set to true after the user has returned from the reading screen at least
  // once, so we switch to showing fresh API data (which includes read progress)
  // rather than the stale generated snapshot.
  bool _hasReadAStory = false;

  int _resumePageIndex(summary_models.ContinueReading? cr) {
    if (cr == null) return 0;
    final pageCount = cr.pageCount;
    if (pageCount <= 0) return 0;

    // If backend mistakenly sends a non-zero continueFromPageIndex while
    // readPages is 0, always start at page 0.
    if (cr.readPages <= 0) return 0;

    final last = cr.lastPageIndex;
    if (last != null) {
      return (last + 1).clamp(0, pageCount - 1);
    }
    return cr.continueFromPageIndex.clamp(0, pageCount - 1);
  }

  summary_models.StoryIdeaModel? _mapGeneratedIdeasToSummary(
    generated_models.StoryIdeasModel? storyIdeas,
  ) {
    if (storyIdeas == null) return null;

    // Convert topic interests to summary model type.
    final topicInterests = storyIdeas.topic.interests
        .map((i) => summary_models.TopicInterest(id: i.id, name: i.name))
        .toList();

    // Convert subjects list to summary SubjectsData.
    final summarySubjectItems = storyIdeas.subjects
        .map((s) => summary_models.SubjectItem(id: s.id, name: s.name))
        .toList();
    final subjectsData = summarySubjectItems.isNotEmpty
        ? summary_models.SubjectsData(
            all: summarySubjectItems,
            allIds: summarySubjectItems.map((s) => s.id).toList(),
            type: 'primary',
          )
        : null;

    return summary_models.StoryIdeaModel(
      topicId: storyIdeas.topic.id,
      topicTitle: storyIdeas.topic.title,
      topicType: storyIdeas.promptType,
      isOwnTopic: true,
      topicLearningGoal: storyIdeas.topic.learningGoal,
      topicThumbnailUrl: storyIdeas.topic.thumbnailUrl,
      topicInterests: topicInterests,
      subjects: subjectsData,
      storyIdeas: storyIdeas.storyIdeas
          .map(
            (idea) => summary_models.StoryIdea(
              id: idea.id,
              storyTitle: idea.title,
              description: idea.description,
              thumbnailUrl: (idea.thumbnailUrl ?? '').toString(),
              sequenceIndex: idea.sequenceIndex,
              grade: '',
              tags: idea.tags,
              age: '',
              language: '',
              topic: storyIdeas.topic.title,
              topicType: storyIdeas.promptType,
              source: '',
              isGenerated: idea.isGenerated,
              hasStory: idea.isGenerated,
              createdOn: idea.createdAt.toIso8601String(),
              updatedAt: idea.createdAt.toIso8601String(),
            ),
          )
          .toList(),
    );
  }

  summary_models.StoryIdeaModel _applyLocalReadingOverlay(
    summary_models.StoryIdeaModel base,
  ) {
    if (_localContinueReading.isEmpty) return base;

    final nextIdeas = base.storyIdeas.map((idea) {
      final local = _localContinueReading[idea.id];
      if (local == null) return idea;

      final existing = idea.continueReading;
      final shouldOverride =
          existing == null || local.readPages > existing.readPages;
      if (!shouldOverride) return idea;

      return summary_models.StoryIdea(
        id: idea.id,
        storyTitle: idea.storyTitle,
        description: idea.description,
        thumbnailUrl: idea.thumbnailUrl,
        sequenceIndex: idea.sequenceIndex,
        grade: idea.grade,
        tags: idea.tags,
        age: idea.age,
        language: idea.language,
        topic: idea.topic,
        topicType: idea.topicType,
        source: idea.source,
        isGenerated: idea.isGenerated,
        hasStory: idea.hasStory,
        createdOn: idea.createdOn,
        updatedAt: idea.updatedAt,
        continueReading: local,
        sampleQuestion: idea.sampleQuestion,
        subjectIds: idea.subjectIds,
        extraSubjectTags: idea.extraSubjectTags,
        thumbnailSource: idea.thumbnailSource,
        thumbnailLicense: idea.thumbnailLicense,
        thumbnailAttribution: idea.thumbnailAttribution,
        thumbnailSearchEntity: idea.thumbnailSearchEntity,
      );
    }).toList();

    return summary_models.StoryIdeaModel(
      topicId: base.topicId,
      topicTitle: base.topicTitle,
      topicType: base.topicType,
      isOwnTopic: base.isOwnTopic,
      topicLearningGoal: base.topicLearningGoal,
      topicThumbnailUrl: base.topicThumbnailUrl,
      topicInterests: base.topicInterests,
      subjects: base.subjects,
      overallProgress: base.overallProgress,
      storyIdeas: nextIdeas,
    );
  }

  @override
  void initState() {
    super.initState();
    _waitingForGeneratedFirstResponse = widget.preferGeneratedData;
    _showTopicDetailsShimmer = !widget.preferGeneratedData;
    _topicIdForScreen = widget.initialTopicId;
    _scrollController.addListener(_onScroll);

    final initialTopicId = widget.initialTopicId;
    if (!widget.preferGeneratedData && initialTopicId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final homeProvider = context.read<HomeProvider>();
        if (homeProvider.isRefreshingStoryIdeas) return;
        if (homeProvider.storySummary?.topicId == initialTopicId) return;
        homeProvider.getTopicStoryDetails(topicId: initialTopicId);
      });
    }
  }

  bool _isTopicDetailsReady(HomeProvider homeProvider) {
    final expectedTopicId =
        widget.initialTopicId ??
        _topicIdForScreen ??
        homeProvider.activeStoryIdeasTopicId;
    if (expectedTopicId == null || expectedTopicId.isEmpty) return false;
    return homeProvider.storySummary?.topicId == expectedTopicId &&
        !homeProvider.isRefreshingStoryIdeas &&
        !homeProvider.isStoryIdeasLoading;
  }

  void _clearTopicDetailsShimmerIfReady(HomeProvider homeProvider) {
    if (!_showTopicDetailsShimmer || !_isTopicDetailsReady(homeProvider)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _showTopicDetailsShimmer = false);
    });
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

  // When opened from the generation flow (preferGeneratedData == true), the
  // back button should always go home, not back to the 4 input screens.
  void _handleBack() {
    final hp = context.read<HomeProvider>();
    if (widget.preferGeneratedData) {
      // After generating a new series, ensure Home shelves (Continue Reading)
      // are refreshed immediately when we return.
      //
      // Schedule the refresh on a microtask so it still runs even if this route
      // is disposed immediately by goNamed().
      context.goNamed(AppRoutes.homeScreen.name);
      Future.microtask(() => hp.getContinueReading(force: true));
    } else if (context.canPop()) {
      context.pop();
      // Returning back to Home: refresh Continue Reading list.
      Future.microtask(() => hp.getContinueReading(force: true));
    } else {
      context.goNamed(AppRoutes.homeScreen.name);
      Future.microtask(() => hp.getContinueReading(force: true));
    }
  }

  // Push the reading screen, then refresh story ideas (with progress) on return.
  void _openReading({
    required summary_models.StoryIdeaModel summary,
    required String storyIdeaId,
    required int ideaIndex,
    required int initialPageIndex,
    int? initialConfirmedPageIndex,
  }) {
    final storyProvider = context.read<StoryProvider>();
    storyProvider.setFromStorySummary(summary);
    storyProvider.createStory(
      selectedIdeaIndex: ideaIndex,
      onSuccess: () {},
      onFailed: (error) {
        if (!mounted) return;
        AppToast.error(context, error);
      },
    );
    context
        .pushNamed(
          AppRoutes.createdStoryReadingScreen.name,
          extra: <String, dynamic>{
            "storyIdeaId": storyIdeaId,
            "initialPageIndex": initialPageIndex,
            "initialConfirmedPageIndex": initialConfirmedPageIndex,
          },
        )
        .then((result) {
          if (!mounted) return;
          setState(() => _hasReadAStory = true);
          final hp = context.read<HomeProvider>();
          final topicId = _topicIdForScreen ?? hp.activeStoryIdeasTopicId;
          if (topicId != null) {
            if (result is ReadingExitSnapshot && result.hasValidCounts) {
              // Optimistic local progress update (especially important for the
              // generation flow where the initial summary snapshot has no
              // continueReading info until the API refresh completes).
              final readPages = (result.lastPageIndex + 1).clamp(
                0,
                result.pageCount,
              );
              final remainingPages = (result.pageCount - readPages).clamp(
                0,
                result.pageCount,
              );
              final percent = result.pageCount > 0
                  ? ((readPages / result.pageCount) * 100).round().clamp(0, 100)
                  : 0;
              setState(() {
                _localContinueReading[result.storyIdeaId] =
                    summary_models.ContinueReading(
                      pageCount: result.pageCount,
                      readPages: readPages,
                      remainingPages: remainingPages,
                      lastPageIndex: result.lastPageIndex,
                      continueFromPageIndex: result.lastPageIndex.clamp(
                        0,
                        result.pageCount - 1,
                      ),
                      percentComplete: percent,
                      lastReadAt: DateTime.now().toIso8601String(),
                      completedAt: null,
                      isCompleted: false,
                      quizProgress: null,
                    );
              });

              hp.applyLocalReadingProgressFromReadingSession(
                storyIdeaId: result.storyIdeaId,
                lastPageIndex: result.lastPageIndex,
                pageCount: result.pageCount,
              );
              hp.getTopicStoryDetails(topicId: topicId, showLoadingUi: false);
            } else {
              hp.getTopicStoryDetails(topicId: topicId);
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // When opened from the generation flow, disable the default pop so we can
      // intercept the system back button and go to home instead of the input screens.
      canPop: !widget.preferGeneratedData,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          // System back / gesture pop happened. Refresh Continue Reading when
          // we land back on Home.
          final hp = context.read<HomeProvider>();
          Future.microtask(() => hp.getContinueReading(force: true));
          return;
        }
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Consumer2<HomeProvider, StoryProvider>(
          builder: (context, homeProvider, storyProvider, child) {
            final generatedSummary = _mapGeneratedIdeasToSummary(
              storyProvider.storyIdeas,
            );
            // Track the topic this screen should operate on (especially important
            // for generation flow where HomeProvider may still hold an old topic id).
            _topicIdForScreen ??=
                widget.initialTopicId ??
                generatedSummary?.topicId ??
                homeProvider.storySummary?.topicId;

            if (generatedSummary != null) {
              if (widget.preferGeneratedData) {
                _topicIdForScreen = generatedSummary.topicId;
              }
              if (widget.preferGeneratedData &&
                  homeProvider.activeStoryIdeasTopicId !=
                      generatedSummary.topicId) {
                homeProvider.activeStoryIdeasTopicId = generatedSummary.topicId;
              }
            }

            if (widget.preferGeneratedData &&
                _waitingForGeneratedFirstResponse) {
              if (generatedSummary != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() => _waitingForGeneratedFirstResponse = false);
                });
              } else if (!storyProvider.isGenerateStoryIdeasLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() => _waitingForGeneratedFirstResponse = false);
                });
              }
              return HomeSectionShimmer.createdStoryIdeasLoadingShimmer();
            }

            _clearTopicDetailsShimmerIfReady(homeProvider);

            final shouldShowTopicDetailsShimmer =
                !widget.preferGeneratedData &&
                (_showTopicDetailsShimmer ||
                    homeProvider.isRefreshingStoryIdeas ||
                    homeProvider.isStoryIdeasLoading ||
                    homeProvider.isGenerateSeriesLoading ||
                    storyProvider.isGenerateStoryIdeasLoading ||
                    !_isTopicDetailsReady(homeProvider));

            if (shouldShowTopicDetailsShimmer) {
              return HomeSectionShimmer.createdStoryIdeasLoadingShimmer();
            }

            final apiSummaryMatchesGenerated =
                homeProvider.storySummary != null &&
                generatedSummary != null &&
                homeProvider.storySummary!.topicId == generatedSummary.topicId;

            final selectedSummary = widget.preferGeneratedData
                ? (_hasReadAStory
                      ? ((apiSummaryMatchesGenerated
                                ? homeProvider.storySummary
                                : null) ??
                            generatedSummary)
                      : generatedSummary)
                : homeProvider.storySummary;

            // If we're still showing the generated snapshot, overlay the local
            // reading progress so the UI updates instantly on return.
            final displaySummary =
                (selectedSummary != null && selectedSummary == generatedSummary)
                ? _applyLocalReadingOverlay(selectedSummary)
                : selectedSummary;

            if (displaySummary == null) {
              final errorMsg =
                  storyProvider.generateStoryIdeasError ??
                  homeProvider.generateSeriesError ??
                  homeProvider.storyIdeasError ??
                  "Unable to load stories.";
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48.w,
                        color: AppColors.black.withValues(alpha: 0.3),
                      ),
                      16.w.verticalSpace,
                      AppText(
                        text: errorMsg,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.medium(
                          fontSize: 16.sp,
                          color: AppColors.black.withValues(alpha: 0.7),
                        ),
                      ),
                      24.w.verticalSpace,
                      GestureDetector(
                        onTap: () {
                          if (widget.preferGeneratedData) {
                            // New-generation flow: re-run the generate API.
                            storyProvider.createStoryIdeas(
                              context: context,
                              forceRegenerate:
                                  storyProvider.forceRegenerateTopicId != null,
                              topicId: storyProvider.forceRegenerateTopicId,
                              onFailed: (error) {
                                if (!context.mounted) return;
                                AppToast.error(context, error);
                              },
                              onSuccess: () {
                                if (!context.mounted) return;
                                AppToast.success(
                                  context,
                                  "Story Ideas created successfully.",
                                );
                                context.read<HomeProvider>().getMyTopics();
                              },
                            );
                          } else {
                            // Existing topic: re-fetch via the mobile GET endpoint.
                            final topicId =
                                homeProvider.activeStoryIdeasTopicId;
                            if (topicId != null) {
                              homeProvider.getTopicStoryDetails(
                                topicId: topicId,
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.w,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 20.w,
                                color: AppColors.onFill,
                              ),
                              8.w.horizontalSpace,
                              AppText(
                                text: "Retry",
                                style: AppTextStyles.semibold(
                                  fontSize: 16.sp,
                                  color: AppColors.onFill,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      16.w.verticalSpace,
                      GestureDetector(
                        onTap: _handleBack,
                        child: AppText(
                          text: "Go Back",
                          style: AppTextStyles.semibold(
                            fontSize: 14.sp,
                            color: AppColors.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final summary = displaySummary;

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
            final tags =
                summary.subjects?.all.map((e) => e.name).toList() ?? [];
            tags.addAll(summary.topicInterests.map((e) => e.name).toList());
            final hasStartedReading = summary.storyIdeas.any((idea) {
              final progress = idea.continueReading;
              if (progress == null) return false;
              return progress.readPages > 0 ||
                  progress.percentComplete > 0 ||
                  progress.isCompleted;
            });

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
              ),
              child: Column(
                children: [
                  _StoryListHero(
                    imageUrl: topicThumb,
                    title: topicTitle,
                    topicId: summary.topicId,
                    onBack: _handleBack,
                    onShare: () => shareTopicLink(topicId: summary.topicId),
                  ),
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 24.h),
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _MyExpandableDescription(
                                text: topicDescription,
                                title: topicTitle,
                                description: topicDescription,
                                tags: tags,
                              ),
                              if (hasStartedReading) ...[
                              16.h.verticalSpace,
                              GestureDetector(
                                onTap: () {
                                  if (summary.storyIdeas.isEmpty) return;

                                  int
                                  resumeIndex = summary.storyIdeas.indexWhere(
                                    (idea) =>
                                        idea.continueReading != null &&
                                        !idea.continueReading!.isCompleted &&
                                        idea.continueReading!.readPages > 0,
                                  );
                                  if (resumeIndex < 0) {
                                    resumeIndex = summary.storyIdeas.indexWhere(
                                      (idea) =>
                                          idea.continueReading == null ||
                                          !idea.continueReading!.isCompleted,
                                    );
                                  }
                                  if (resumeIndex < 0) resumeIndex = 0;

                                  final resumeIdea =
                                      summary.storyIdeas[resumeIndex];
                                  final cr = resumeIdea.continueReading;
                                  // final pageCount = cr?.pageCount ?? 0;
                                  // final readPages = cr?.readPages ?? 0;
                                  final quizDone =
                                      cr?.quizProgress?.isCompleted == true;

                                  final percentComplete =
                                      cr?.percentComplete ?? 0;
                                  // If all pages are read but quiz isn't completed, jump to quiz flow.
                                  if (percentComplete >= 100 && !quizDone) {
                                    final sp = context.read<StoryProvider>();
                                    final hp = context.read<HomeProvider>();
                                    final story = sp.stories.isEmpty
                                        ? null
                                        : sp.stories.first;

                                    void openQuiz(
                                      String storyId, {
                                      String? storyTitle,
                                      String? storyImageUrl,
                                    }) {
                                      context
                                          .pushNamed(
                                            AppRoutes.startQuizScreen.name,
                                            extra: {
                                              'storyId': storyId,
                                              'storyTitle':
                                                  storyTitle ??
                                                  resumeIdea.storyTitle,
                                              'storyImageUrl':
                                                  storyImageUrl ??
                                                  resumeIdea.thumbnailUrl,
                                              'storyIdeaId': resumeIdea.id,
                                              'episodeNumber': resumeIndex + 1,
                                              'seriesTitle': summary.topicTitle,
                                              'totalEpisodes':
                                                  summary.storyIdeas.length,
                                              if (hp.activeStoryIdeasTopicId !=
                                                  null)
                                                'topicId':
                                                    hp.activeStoryIdeasTopicId,
                                            },
                                          )
                                          .then((result) {
                                            if (!mounted) return;
                                            if (result is QuizExitSnapshot) {
                                              hp.applyLocalQuizProgress(
                                                storyIdeaId: result.storyIdeaId,
                                                totalQuestions:
                                                    result.totalQuestions,
                                                correctAnswers:
                                                    result.correctAnswers,
                                                isCompleted: result.isCompleted,
                                                completedAt: result.completedAt,
                                              );
                                              final topicId =
                                                  hp.activeStoryIdeasTopicId;
                                              if (topicId != null) {
                                                hp.getTopicStoryDetails(
                                                  topicId: topicId,
                                                  showLoadingUi: false,
                                                );
                                              }
                                            }
                                          });
                                    }

                                    // If we already have the story loaded, we have a storyId.
                                    final storyId = story?.id ?? '';
                                    if (storyId.isNotEmpty) {
                                      openQuiz(
                                        storyId,
                                        storyTitle: story?.title,
                                        storyImageUrl: story?.thumbnailUrl,
                                      );
                                      return;
                                    }

                                    // Otherwise fetch the story first (silent), then open quiz.
                                    sp.getStoryByIdea(
                                      context: context,
                                      storyIdea: resumeIdea.id,
                                      fetchOnly: true,
                                      onStoryNotGenerated: () {
                                        if (!mounted) return;
                                        AppToast.info(
                                          context: context,
                                          durationSecond: 3,
                                          message:
                                              "Story is not ready yet. Please try again in a moment.",
                                        );
                                      },
                                      onSuccess: (payload) {
                                        sp.addStoryFromGetStoryByIdeaData(
                                          payload,
                                          0,
                                        );
                                        if (!mounted) return;
                                        openQuiz(
                                          payload.story.id,
                                          storyTitle: payload.story.title,
                                          storyImageUrl:
                                              payload.heroThumbnailUrl,
                                        );
                                      },
                                    );
                                    return;
                                  }

                                  final initialPageIndex = _resumePageIndex(cr);
                                  final initialConfirmedPageIndex =
                                      cr?.lastPageIndex ??
                                      (initialPageIndex - 1);

                                  _openReading(
                                    summary: summary,
                                    storyIdeaId: resumeIdea.id,
                                    ideaIndex: resumeIndex,
                                    initialPageIndex: initialPageIndex,
                                    initialConfirmedPageIndex:
                                        initialConfirmedPageIndex,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 15.w),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.buttonBackground,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  alignment: Alignment.center,
                                  child: AppText(
                                    text: 'Continue Reading',
                                    style:
                                        AppTextStyles.semibold(
                                          fontSize: 14,
                                          color: AppColors.onFill,
                                        ).copyWith(
                                          height: 17 / 14,
                                          letterSpacing: 0,
                                        ),
                                  ),
                                ),
                              ),
                              ],
                            ],
                          ),
                        ),
                        20.h.verticalSpace,
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0x1A1A1A1A),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: '${summary.storyIdeas.length} Readings',
                                style: AppTextStyles.semibold(
                                  fontSize: 16,
                                  color: AppColors.black.withValues(alpha: 0.8),
                                ),
                              ),
                              16.h.verticalSpace,
                              ...List.generate(
                                summary.storyIdeas.length,
                                (index) => Padding(
                                  padding: EdgeInsets.only(bottom: 9.h),
                                  child: _MyReadingItemTile(
                                    index: index + 1,
                                    isSelected:
                                        (summary
                                                    .storyIdeas[index]
                                                    .continueReading
                                                    ?.percentComplete ??
                                                0) >=
                                            100 &&
                                        (summary
                                                .storyIdeas[index]
                                                .continueReading
                                                ?.quizProgress
                                                ?.completedAt !=
                                            null),
                                    title: summary.storyIdeas[index].storyTitle,
                                    description:
                                        summary.storyIdeas[index].description,
                                    thumbnailUrl:
                                        summary.storyIdeas[index].thumbnailUrl,
                                    topicThumbnailUrl:
                                        summary.topicThumbnailUrl,
                                    continueReading: summary
                                        .storyIdeas[index]
                                        .continueReading,
                                    onOpenStory: () {
                                      final initialPage = _resumePageIndex(
                                        summary
                                            .storyIdeas[index]
                                            .continueReading,
                                      );
                                      _openReading(
                                        summary: summary,
                                        storyIdeaId:
                                            summary.storyIdeas[index].id,
                                        ideaIndex: index,
                                        initialPageIndex: initialPage,
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
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

}

class _StoryListHero extends StatelessWidget {
  const _StoryListHero({
    required this.imageUrl,
    required this.title,
    required this.topicId,
    required this.onBack,
    required this.onShare,
  });

  final String imageUrl;
  final String title;
  final String topicId;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final heroHeight = topInset + 228;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      child: SizedBox(
        height: heroHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(
              imageUrl: imageUrl,
              tag: 'MyStoryIdeas.hero',
              fit: BoxFit.cover,
              errorCompact: true,
              placeholder: (_) => const ColoredBox(color: Color(0xFF8E8E93)),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 93,
              child: ClipRect(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xFFFFFFFF)],
                      stops: [0, 0.55],
                    ).createShader(bounds);
                  },
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: OverflowBox(
                      alignment: Alignment.bottomCenter,
                      minHeight: heroHeight,
                      maxHeight: heroHeight,
                      child: AppNetworkImage(
                        imageUrl: imageUrl,
                        tag: 'MyStoryIdeas.heroBlur',
                        fit: BoxFit.cover,
                        height: heroHeight,
                        width: double.infinity,
                        errorCompact: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 93,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xFF000000)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, topInset + 8, 16, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      GlassIconButton(
                        onTap: onBack,
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      _HeroBookmarkButton(topicId: topicId),
                      const SizedBox(width: 10),
                      GlassIconButton(
                        onTap: onShare,
                        child: SvgIcon(
                          AppAssets.shareIcon,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 5.r, right: 8.r),
                      child: AppText(
                        text: title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semibold(
                          fontSize: 22.sp,
                          color: Colors.white,
                        ).copyWith(letterSpacing: -0.26, height: 1.27),
                      ),
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

class _HeroBookmarkButton extends StatelessWidget {
  const _HeroBookmarkButton({required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedSeriesProvider>();
    final isInList = saved.topicIsInMyListOverride(topicId) ?? false;
    final isToggling = saved.isTopicListToggling(topicId);

    return GlassIconButton(
      onTap: isToggling
          ? () {}
          : () {
              context
                  .read<SavedSeriesProvider>()
                  .toggleTopic(
                    topicId: topicId,
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
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(
              isInList ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: Colors.white,
              size: 22,
            ),
    );
  }
}


class _MyReadingItemTile extends StatelessWidget {
  const _MyReadingItemTile({
    required this.onOpenStory,
    required this.index,
    required this.isSelected,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.topicThumbnailUrl,
    this.continueReading,
  });

  final VoidCallback onOpenStory;
  final int index;
  final bool isSelected;
  final String title, description, thumbnailUrl, topicThumbnailUrl;
  final summary_models.ContinueReading? continueReading;

  @override
  Widget build(BuildContext context) {
    final pages = continueReading?.pageCount ?? 0;
    final readPages = continueReading?.readPages ?? 0;
    final completed = isSelected || (pages > 0 && readPages >= pages);

    return GestureDetector(
      onTap: onOpenStory,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                width: 130,
                height: 90,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(
                      imageUrl: thumbnailUrl,
                      tag: 'MyStoryIdeas.thumbnail (primary)',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => AppNetworkImage(
                        imageUrl: topicThumbnailUrl,
                        tag: 'MyStoryIdeas.thumbnail (fallback)',
                        fit: BoxFit.cover,
                        errorCompact: true,
                      ),
                    ),
                    if (completed) ...[
                      const ColoredBox(color: Color(0x80000000)),
                      const Center(
                        child: SvgIcon(AppAssets.checkmarkCircle, size: 40),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  AppText(
                    text: '$index. $title',
                    style: AppTextStyles.semibold(
                      fontSize: 16,
                      color: AppColors.black,
                    ).copyWith(height: 20 / 16, letterSpacing: -0.32),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    text: description.trim().isEmpty
                        ? 'No description available.'
                        : description.trim(),
                    style: AppTextStyles.regular(
                      fontSize: 14,
                      color: AppColors.black.withValues(alpha: 0.8),
                    ).copyWith(height: 18 / 14, letterSpacing: -0.28),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  _ReadingProgressIndicator(
                    readPages: readPages,
                    pageCount: pages,
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),

            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

class _ReadingProgressIndicator extends StatelessWidget {
  const _ReadingProgressIndicator({
    required this.readPages,
    required this.pageCount,
  });

  final int readPages;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final progress = pageCount > 0
        ? (readPages / pageCount).clamp(0.0, 1.0)
        : 0.0;
    if (pageCount <= 0) return const SizedBox.shrink();

    final label = '$readPages/$pageCount pages';

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0x1A1A1A1A),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFF28518),
              ),
            ),
          ),
        ),
        const SizedBox(width: 0),
        SizedBox(
          width: 50,
          child: AppText(
            text: label,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bold(
              fontSize: 12,
              color: AppColors.teal,
            ).copyWith(height: 14 / 12),
          ),
        ),
      ],
    );
  }
}

class _MyExpandableDescription extends StatefulWidget {
  const _MyExpandableDescription({
    required this.text,
    required this.title,
    required this.description,
    required this.tags,
  });
  final String text, title, description;
  final List<String> tags;

  @override
  State<_MyExpandableDescription> createState() =>
      _MyExpandableDescriptionState();
}

class _MyExpandableDescriptionState extends State<_MyExpandableDescription> {
  static const int _minCharsForToggle = 100;

  @override
  Widget build(BuildContext context) {
    final full = widget.text.trim();
    final display = full.isEmpty ? 'No description available.' : full;

    final bodyStyle = AppTextStyles.regular(
      fontSize: 14,
      color: AppColors.black.withValues(alpha: 0.8),
    ).copyWith(height: 1.57);
    final linkStyle = AppTextStyles.bold(
      fontSize: 14,
      color: AppColors.black,
    ).copyWith(height: 1.57);

    final showMore =
        display.length > _minCharsForToggle || widget.tags.isNotEmpty;
    if (!showMore) {
      return AppText(text: display, style: bodyStyle);
    }

    final preview = display.length <= _minCharsForToggle
        ? '$display '
        : '${display.substring(0, _minCharsForToggle)}... ';

    return RichText(
      text: TextSpan(
        style: bodyStyle,
        children: [
          TextSpan(
            text: preview,
            style: AppTextStyles.regular(
              fontSize: 14.sp,
              color: AppColors.black.setOpacity(0.8),
            ),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                elevation: 0,
                isScrollControlled: true,
                builder: (context) => _StoryIdeaDetailsBottomSheet(
                  title: widget.title,
                  description: widget.description,
                  tags: widget.tags,
                ),
              ),
              child: AppText(text: 'more', style: linkStyle),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryIdeaDetailsBottomSheet extends StatelessWidget {
  const _StoryIdeaDetailsBottomSheet({
    required this.title,
    required this.description,
    required this.tags,
  });

  final String title;
  final String description;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassIconButton(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            Icons.close_rounded,
            size: 24,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
            boxShadow: [
              BoxShadow(
                color: Color(0x2E000000),
                blurRadius: 75,
                offset: Offset(0, 15),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20, 28, 20, bottomInset + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: title,
                style: AppTextStyles.bold(
                  fontSize: 22,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),
              AppText(
                text: description,
                style: AppTextStyles.regular(
                  fontSize: 15,
                  color: AppColors.black.withValues(alpha: 0.8),
                ).copyWith(height: 1.45),
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in tags)
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 6),
                        decoration: BoxDecoration(
                          color: AppColors.extealighttealcolor,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: AppText(
                          text: tag,
                          style: AppTextStyles.medium(
                            fontSize: 12,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
