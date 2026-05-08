import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/core/utils/share_helper.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/widgets/global_widgets.dart';
import 'package:redstreakapp/models/home/story_models/story_idea_model.dart'
    as generated_models;
import 'package:redstreakapp/models/home/story_models/story_summary_model.dart'
    as summary_models;
import 'package:redstreakapp/models/home/story_models/reading_exit_snapshot.dart';
import 'package:redstreakapp/models/home/story_models/quiz_exit_snapshot.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/saved_series_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/screens/home/widgets/story_ui_components.dart';
import 'package:redstreakapp/screens/home/widgets/home_section_shimmers.dart';
import 'package:shimmer/shimmer.dart';

class MyStoryIdeasScreen extends StatefulWidget {
  const MyStoryIdeasScreen({super.key, this.preferGeneratedData = false});

  final bool preferGeneratedData;

  @override
  State<MyStoryIdeasScreen> createState() => _MyStoryIdeasScreenState();
}

class _MyStoryIdeasScreenState extends State<MyStoryIdeasScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _waitingForGeneratedFirstResponse = true;
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
              final readPages =
                  (result.lastPageIndex + 1).clamp(0, result.pageCount);
              final remainingPages =
                  (result.pageCount - readPages).clamp(0, result.pageCount);
              final percent = result.pageCount > 0
                  ? ((readPages / result.pageCount) * 100)
                      .round()
                      .clamp(0, 100)
                  : 0;
              setState(() {
                _localContinueReading[result.storyIdeaId] =
                    summary_models.ContinueReading(
                  pageCount: result.pageCount,
                  readPages: readPages,
                  remainingPages: remainingPages,
                  lastPageIndex: result.lastPageIndex,
                  continueFromPageIndex:
                      result.lastPageIndex.clamp(0, result.pageCount - 1),
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
        backgroundColor: AppColors.white,
        body: Consumer2<HomeProvider, StoryProvider>(
          builder: (context, homeProvider, storyProvider, child) {
            final generatedSummary = _mapGeneratedIdeasToSummary(
              storyProvider.storyIdeas,
            );
            // Track the topic this screen should operate on (especially important
            // for generation flow where HomeProvider may still hold an old topic id).
            _topicIdForScreen ??= generatedSummary?.topicId ??
                homeProvider.storySummary?.topicId;
            if (generatedSummary != null) {
              _topicIdForScreen = generatedSummary.topicId;
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

            // For the new-generation flow (preferGeneratedData == true):
            //   Before any reading: show ONLY the freshly generated data.
            //   Falling back to homeProvider.storySummary would show stale data
            //   from a previous topic if generation failed or is still loading.
            //   After returning from a reading session: prefer the refreshed API
            //   data (which includes read-progress) then fall back to generated.
            // For existing topics (preferGeneratedData == false):
            //   Use homeProvider.storySummary only — ignore any leftover
            //   generatedSummary from a previous generation flow.
            final apiSummaryMatchesGenerated = homeProvider.storySummary != null &&
                generatedSummary != null &&
                homeProvider.storySummary!.topicId == generatedSummary.topicId;

            final selectedSummary = widget.preferGeneratedData
                ? (_hasReadAStory
                    ? ((apiSummaryMatchesGenerated ? homeProvider.storySummary : null) ??
                        generatedSummary)
                    : generatedSummary)
                : homeProvider.storySummary;

            // If we're still showing the generated snapshot, overlay the local
            // reading progress so the UI updates instantly on return.
            final displaySummary =
                (selectedSummary != null && selectedSummary == generatedSummary)
                    ? _applyLocalReadingOverlay(selectedSummary)
                    : selectedSummary;

            if (homeProvider.isStoryIdeasLoading ||
                homeProvider.isGenerateSeriesLoading ||
                homeProvider.isRefreshingStoryIdeas ||
                (displaySummary == null &&
                    storyProvider.isGenerateStoryIdeasLoading)) {
              return HomeSectionShimmer.createdStoryIdeasLoadingShimmer();
            }

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
                                color: AppColors.white,
                              ),
                              8.w.horizontalSpace,
                              AppText(
                                text: "Retry",
                                style: AppTextStyles.semibold(
                                  fontSize: 16.sp,
                                  color: AppColors.white,
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

            print("tags: $tags");
            print("summary: ${summary.subjects?.all}");

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: StoryHeroHeader(
                    imageUrl: topicThumb,
                    title: topicTitle,
                    topLeft: StoryCircleButton(
                      onTap: _handleBack,
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 19.w,
                        color: AppColors.black,
                      ),
                    ),
                    // bottomRight: StoryCircleButton(
                    //   onTap: () {},
                    //   child: Icon(
                    //     Icons.more_vert,
                    //     size: 18.w,
                    //     color: AppColors.black,
                    //   ),
                    // ),
                    titleStyle: AppTextStyles.bold(
                      fontSize: 24.sp,
                      color: AppColors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        18.w.verticalSpace,
                        _MyExpandableDescription(
                          text: topicDescription,
                          title: topicTitle,
                          description: topicDescription,
                          tags: tags,
                        ),
                        10.w.verticalSpace,
                        // show first two tags
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: tags
                              .take(2)
                              .map(
                                (e) => Padding(
                                  padding: EdgeInsets.only(right: 10.r),
                                  child: _infoChip(e),
                                ),
                              )
                              .toList(),
                        ),
                        20.w.verticalSpace,
                        GestureDetector(
                          onTap: () {
                            if (summary.storyIdeas.isEmpty) return;

                            int resumeIndex = summary.storyIdeas.indexWhere(
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

                            final resumeIdea = summary.storyIdeas[resumeIndex];
                            final cr = resumeIdea.continueReading;
                            final pageCount = cr?.pageCount ?? 0;
                            final readPages = cr?.readPages ?? 0;
                            final quizDone =
                                cr?.quizProgress?.isCompleted == true;

                            // If all pages are read but quiz isn't completed, jump to quiz flow.
                            if (pageCount > 0 &&
                                readPages >= pageCount &&
                                !quizDone) {
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
                                            storyTitle ?? resumeIdea.storyTitle,
                                        'storyImageUrl':
                                            storyImageUrl ??
                                            resumeIdea.thumbnailUrl,
                                        'storyIdeaId': resumeIdea.id,
                                      },
                                    )
                                    .then((result) {
                                      if (!mounted) return;
                                      if (result is QuizExitSnapshot) {
                                        hp.applyLocalQuizProgress(
                                          storyIdeaId: result.storyIdeaId,
                                          totalQuestions: result.totalQuestions,
                                          correctAnswers: result.correctAnswers,
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
                              hp.getStoryByIdea(
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
                                onSuccess: (history) {
                                  sp.addStoryFromHistory(history, 0);
                                  if (!mounted) return;
                                  openQuiz(
                                    history.id,
                                    storyTitle: history.title,
                                    storyImageUrl: history.thumbnailUrl,
                                  );
                                },
                              );
                              return;
                            }

                            final initialPageIndex = _resumePageIndex(cr);
                            final initialConfirmedPageIndex =
                                cr?.lastPageIndex ?? (initialPageIndex - 1);

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
                            width: double.infinity,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            alignment: Alignment.center,
                            child: AppText(
                              text: summary.storyIdeas.first.isGenerated
                                  ? 'Continue Reading'
                                  : 'Start Reading',
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
                              Builder(
                                builder: (context) {
                                  final ssp = context
                                      .watch<SavedSeriesProvider>();
                                  final isInList =
                                      ssp.topicIsInMyListOverride(
                                        summary.topicId,
                                      ) ??
                                      false;
                                  final isToggling = ssp.isTopicListToggling(
                                    summary.topicId,
                                  );
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: isToggling
                                        ? null
                                        : () {
                                            context
                                                .read<SavedSeriesProvider>()
                                                .toggleTopic(
                                                  topicId: summary.topicId,
                                                  onFailed: (error) {
                                                    if (!context.mounted)
                                                      return;
                                                    AppToast.error(
                                                      context,
                                                      error,
                                                    );
                                                  },
                                                )
                                                .then((result) {
                                                  if (result == null ||
                                                      !context.mounted) {
                                                    return;
                                                  }
                                                  final msg =
                                                      result.message ??
                                                      (result.isInMyList
                                                          ? "Added to My List"
                                                          : "Removed from My List");
                                                  AppToast.success(
                                                    context,
                                                    msg,
                                                  );
                                                });
                                          },
                                    child: Column(
                                      children: [
                                        if (isToggling)
                                          SizedBox(
                                            width: 20.w,
                                            height: 20.w,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.teal,
                                            ),
                                          )
                                        else
                                          Icon(
                                            isInList
                                                ? Icons.check_rounded
                                                : Icons.add_rounded,
                                            size: 20.w,
                                            color: isInList
                                                ? AppColors.teal
                                                : AppColors.black,
                                          ),
                                        2.w.verticalSpace,
                                        AppText(
                                          text: isToggling
                                              ? (isInList
                                                    ? 'Removing...'
                                                    : 'Adding...')
                                              : (isInList
                                                    ? 'In My List'
                                                    : 'Add to List'),
                                          style: AppTextStyles.semibold(
                                            fontSize: 14,
                                            color: isInList
                                                ? AppColors.teal
                                                : AppColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              25.w.horizontalSpace,
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () =>
                                    shareTopicLink(topicId: summary.topicId),
                                child: Column(
                                  children: [
                                    SvgIcon(
                                      AppAssets.shareIcon,
                                      size: 18.w,
                                      color: AppColors.black,
                                    ),
                                    4.w.verticalSpace,
                                    AppText(
                                      text: 'Share',
                                      style: AppTextStyles.semibold(
                                        fontSize: 14,
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
                          text: "${summary.storyIdeas.length} Readings",
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
                              isSelected:
                                  (summary
                                          .storyIdeas[index]
                                          .continueReading
                                          ?.isCompleted ??
                                      false) &&
                                  (summary
                                          .storyIdeas[index]
                                          .continueReading
                                          ?.quizProgress
                                          ?.isCompleted ??
                                      false),
                              title: summary.storyIdeas[index].storyTitle,
                              description:
                                  summary.storyIdeas[index].description,
                              thumbnailUrl:
                                  summary.storyIdeas[index].thumbnailUrl,
                              topicThumbnailUrl: summary.topicThumbnailUrl,
                              continueReading:
                                  summary.storyIdeas[index].continueReading,
                              onOpenStory: () {
                                final initialPage = _resumePageIndex(
                                  summary.storyIdeas[index].continueReading,
                                );
                                _openReading(
                                  summary: summary,
                                  storyIdeaId: summary.storyIdeas[index].id,
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
                ),
              ],
            );
          },
        ),
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
                      errorWidget: (_, __, ___) =>
                          const NoImageFound(compact: true),
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
              _MyReadingDescription(
                text: description,
                onOpenStory: onOpenStory,
              ),
              if (continueReading != null) ...[
                6.w.verticalSpace,
                _ReadingProgressIndicator(continueReading: continueReading!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadingProgressIndicator extends StatelessWidget {
  const _ReadingProgressIndicator({required this.continueReading});

  final summary_models.ContinueReading continueReading;

  @override
  Widget build(BuildContext context) {
    final progress = continueReading.pageCount > 0
        ? (continueReading.readPages / continueReading.pageCount).clamp(
            0.0,
            1.0,
          )
        : 0.0;
    final label = continueReading.isCompleted
        ? "Completed"
        : "${continueReading.readPages}/${continueReading.pageCount} pages";

    return continueReading.isCompleted
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4.h,
                        backgroundColor: AppColors.black.withValues(
                          alpha: 0.08,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          continueReading.isCompleted
                              ? AppColors.teal
                              : AppColors.orangeColor,
                        ),
                      ),
                    ),
                  ),
                  8.w.horizontalSpace,
                  AppText(
                    text: label,
                    style: AppTextStyles.medium(
                      fontSize: 11.sp,
                      color: AppColors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
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

    final bodyStyle = AppTextStyles.medium(
      color: AppColors.black.withValues(alpha: 0.65),
      fontSize: 14.sp,
    );
    final linkStyle = AppTextStyles.bold(
      fontSize: 14.sp,
      color: AppColors.black,
    );

    if (display.length <= _minCharsForToggle) {
      return AppText(text: display, style: bodyStyle);
    }

    return RichText(
      text: TextSpan(
        style: bodyStyle,
        children: [
          TextSpan(text: '${display.substring(0, _minCharsForToggle)}... '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Container(
                      height: 4.w,
                      width: 40.w,
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            height: 32.h,
                            width: 32.h,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.black.withValues(alpha: 0.1),
                                width: 1.w,
                              ),
                            ),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(4.r),
                            child: Icon(
                              Icons.close,
                              size: 15.w,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              5.h.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: AppText(
                  text: title,
                  style: AppTextStyles.bold(fontSize: 24),
                ),
              ),
              10.h.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: AppText(
                  text: description,
                  style: AppTextStyles.regular(
                    fontSize: 14,
                    color: AppColors.black.setOpacity(0.4),
                  ),
                ),
              ),
              15.h.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.w,
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  children: List.generate(
                    tags.length,
                    (index) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.w,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.extealighttealcolor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: AppText(
                        text: tags[index],
                        style: AppTextStyles.bold(
                          fontSize: 12.sp,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
            ],
          ),
        ),
      ],
    );
  }
}
