import 'package:flutter/material.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/models/home/continue_reading_item_model.dart';
import 'package:redstreakapp/models/home/story_models/story_topics.dart';
import 'package:redstreakapp/models/home/story_models/story_summary_model.dart';
import 'package:redstreakapp/services/home/home_api_service.dart';
import 'package:redstreakapp/services/home/story_api_service.dart';

class HomeProvider extends ChangeNotifier {
  static const int storyIdeasPageLimit = 20;
  static const int topicsPageLimit = 10;
  static const int continueReadingPageLimit = 10;

  List<CreatedStoryTopicsModel>? topicsList;
  bool isTopicsLoading = false;
  bool isTopicsLoadingMore = false;
  bool hasMoreTopics = true;
  int _topicsCurrentPage = 1;

  /// When [data] is a map with `pagination.hasMore`, uses the API flag; otherwise
  /// assumes more pages exist if we received a full page.
  static bool _inferHasMoreTopics(
    Map<dynamic, dynamic>? dataMap,
    int itemsInPage,
    int pageLimit,
  ) {
    if (itemsInPage <= 0) return false;
    if (dataMap != null) {
      final p = dataMap['pagination'];
      if (p is Map && p['hasMore'] != null) {
        return p['hasMore'] == true;
      }
    }
    return itemsInPage >= pageLimit;
  }

  // String? topicId;
  StoryIdeaModel? storySummary;
  bool isStoryIdeasLoading = false;
  bool isStoryIdeasLoadingMore = false;
  bool hasMoreStoryIdeas = true;
  String? storyIdeasError;
  String? activeStoryIdeasTopicId;
  int _storyIdeasCurrentPage = 1;

  // ---------------- Continue Reading (Home shelf) ----------------
  List<ContinueReadingItemModel>? continueReadingItems;
  bool isContinueReadingLoading = false;
  bool isContinueReadingLoadingMore = false;
  bool hasMoreContinueReading = false;
  int _continueReadingPage = 1;
  String? continueReadingError;

  void _mergeContinueReadingUnique(List<ContinueReadingItemModel> pageItems) {
    final merged = List<ContinueReadingItemModel>.from(
      continueReadingItems ?? const [],
    );
    final ids = merged.map((e) => e.storyIdeaId).toSet();
    for (final e in pageItems) {
      if (e.storyIdeaId.isEmpty || ids.contains(e.storyIdeaId)) continue;
      merged.add(e);
      ids.add(e.storyIdeaId);
    }
    ContinueReadingItemModel.sortByLastReadDesc(merged);
    continueReadingItems = merged;
  }

  Future<void> getContinueReading({bool force = false}) async {
    // Allow [force] refetch even while a request is in flight (e.g. after quiz → home).
    if (isContinueReadingLoading && !force) return;
    if (!force && continueReadingItems != null) return;
    isContinueReadingLoading = true;
    isContinueReadingLoadingMore = false;
    continueReadingError = null;
    if (force) {
      continueReadingItems = null;
      _continueReadingPage = 1;
      hasMoreContinueReading = true;
    }
    notifyListeners();

    // Load Series (topics) in parallel with Continue Reading — same moment, not after.
    // ignore: unawaited_futures
    getMyTopics();

    final response = await HomeApiService.instance.getContinueReading(
      page: 1,
      limit: continueReadingPageLimit,
    );

    response.fold(
      (l) {
        continueReadingError = l.errorMsg;
        continueReadingItems = [];
        hasMoreContinueReading = false;
      },
      (r) {
        try {
          final model = ContinueReadingListModel.fromResponse(r);
          continueReadingItems = model.items;
          continueReadingError = null;
          _continueReadingPage = 1;
          hasMoreContinueReading = model.pagination?.hasMore ?? false;
        } catch (e, stack) {
          Logger.error("Error parsing continue reading: $e\n$stack");
          continueReadingError = "Unable to load continue reading.";
          continueReadingItems = [];
          hasMoreContinueReading = false;
        }
      },
    );

    isContinueReadingLoading = false;
    notifyListeners();
  }

  Future<void> getContinueReadingLoadMore() async {
    if (!hasMoreContinueReading ||
        isContinueReadingLoading ||
        isContinueReadingLoadingMore ||
        continueReadingItems == null) {
      return;
    }

    isContinueReadingLoadingMore = true;
    notifyListeners();

    final nextPage = _continueReadingPage + 1;
    final response = await HomeApiService.instance.getContinueReading(
      page: nextPage,
      limit: continueReadingPageLimit,
    );

    response.fold(
      (l) {
        Logger.error('Continue reading load more: ${l.errorMsg}');
      },
      (r) {
        try {
          final model = ContinueReadingListModel.fromResponse(r);
          _mergeContinueReadingUnique(model.items);
          _continueReadingPage = nextPage;
          hasMoreContinueReading = model.pagination?.hasMore ?? false;
        } catch (e, stack) {
          Logger.error("Error parsing continue reading (more): $e\n$stack");
        }
      },
    );

    isContinueReadingLoadingMore = false;
    notifyListeners();
  }

  Future<void> getMyTopics() async {
    if (isTopicsLoading) return;
    isTopicsLoading = true;
    topicsList = null;
    hasMoreTopics = true;
    _topicsCurrentPage = 1;
    notifyListeners();

    final response = await HomeApiService.instance.getMyTopics(
      page: 1,
      limit: topicsPageLimit,
    );

    isTopicsLoading = false;
    response.fold(
      (l) {
        Logger.error(l.errorMsg);
        topicsList = [];
        hasMoreTopics = false;
      },
      (r) {
        try {
          final data = r["data"];
          if (data is List) {
            topicsList = data
                .map((e) => CreatedStoryTopicsModel.fromJson(e))
                .toList();
            hasMoreTopics = _inferHasMoreTopics(
              null,
              topicsList!.length,
              topicsPageLimit,
            );
          } else if (data is Map && data.containsKey("topics")) {
            final map = Map<dynamic, dynamic>.from(data);
            topicsList = (data["topics"] as List)
                .map((e) => CreatedStoryTopicsModel.fromJson(e))
                .toList();
            hasMoreTopics = _inferHasMoreTopics(
              map,
              topicsList!.length,
              topicsPageLimit,
            );
          } else {
            topicsList = [];
            hasMoreTopics = false;
          }
        } catch (e, stack) {
          Logger.error("Error parsing topics: $e\n$stack");
          topicsList = [];
          hasMoreTopics = false;
        }
      },
    );
    notifyListeners();
  }

  Future<void> getMyTopicsLoadMore() async {
    if (isTopicsLoading ||
        isTopicsLoadingMore ||
        !hasMoreTopics ||
        topicsList == null ||
        topicsList!.isEmpty) {
      return;
    }

    isTopicsLoadingMore = true;
    notifyListeners();

    final nextPage = _topicsCurrentPage + 1;
    final response = await HomeApiService.instance.getMyTopics(
      page: nextPage,
      limit: topicsPageLimit,
    );

    isTopicsLoadingMore = false;
    response.fold(
      (l) {
        Logger.error(l.errorMsg);
        hasMoreTopics = false;
      },
      (r) {
        try {
          final data = r["data"];
          List<CreatedStoryTopicsModel>? nextList;
          Map<dynamic, dynamic>? dataMap;
          if (data is List) {
            nextList = data
                .map((e) => CreatedStoryTopicsModel.fromJson(e))
                .toList();
          } else if (data is Map && data.containsKey("topics")) {
            dataMap = Map<dynamic, dynamic>.from(data);
            nextList = (data["topics"] as List)
                .map((e) => CreatedStoryTopicsModel.fromJson(e))
                .toList();
          }
          if (nextList != null && nextList.isNotEmpty) {
            final existingIds = topicsList!.map((e) => e.id).toSet();
            final unique = nextList
                .where((e) => !existingIds.contains(e.id))
                .toList();
            if (unique.isEmpty) {
              hasMoreTopics = false;
            } else {
              topicsList = [...topicsList!, ...unique];
              _topicsCurrentPage = nextPage;
              hasMoreTopics = _inferHasMoreTopics(
                dataMap,
                nextList.length,
                topicsPageLimit,
              );
            }
          } else {
            hasMoreTopics = false;
          }
        } catch (e, stack) {
          Logger.error("Error parsing topics loadMore: $e\n$stack");
          hasMoreTopics = false;
        }
      },
    );
    notifyListeners();
  }

  bool isGenerateSeriesLoading = false;
  String? generateSeriesError;

  Future<void> generateStoryIdeasForTopic({required String topicId}) async {
    isGenerateSeriesLoading = true;
    generateSeriesError = null;
    storySummary = null;
    activeStoryIdeasTopicId = topicId;
    notifyListeners();

    final response = await StoryApiService.instance.createStoryIdeas(
      data: {"topicid": topicId},
    );

    response.fold(
      (l) {
        Logger.error(l.errorMsg);
        generateSeriesError = l.errorMsg;
        storySummary = null;
      },
      (r) {
        try {
          final data = r["data"];
          if (data != null && data is Map<String, dynamic>) {
            storySummary = StoryIdeaModel.fromGenerateMobileJson(data);
          } else {
            generateSeriesError = "Invalid response format.";
          }
        } catch (e, stack) {
          Logger.error("Error parsing generate-mobile response: $e\n$stack");
          generateSeriesError = "Something went wrong. Please try again.";
        }
      },
    );

    isGenerateSeriesLoading = false;
    notifyListeners();
  }

  Future<void> getStoryIdeasByTopicId({
    required String topicId,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (isStoryIdeasLoading ||
          isStoryIdeasLoadingMore ||
          !hasMoreStoryIdeas ||
          activeStoryIdeasTopicId != topicId) {
        return;
      }
      isStoryIdeasLoadingMore = true;
      notifyListeners();
    } else {
      activeStoryIdeasTopicId = topicId;
      storySummary = null;
      storyIdeasError = null;
      hasMoreStoryIdeas = true;
      _storyIdeasCurrentPage = 1;
      isStoryIdeasLoading = true;
      notifyListeners();
    }

    final int pageToLoad = loadMore ? _storyIdeasCurrentPage + 1 : 1;
    final response = await HomeApiService.instance.getStoryIdeasByTopicId(
      topicId: topicId,
      page: pageToLoad,
      limit: storyIdeasPageLimit,
    );
    response.fold(
      (l) {
        Logger.error(l.errorMsg);
        if (!loadMore) {
          storyIdeasError = l.errorMsg;
          storySummary = null;
          hasMoreStoryIdeas = false;
        }
      },
      (r) {
        final incomingSummary = StoryIdeaModel.fromJson(r["data"]);
        if (loadMore && storySummary != null) {
          final existingIds = storySummary!.storyIdeas
              .map((story) => story.id)
              .toSet();
          final nextStories = incomingSummary.storyIdeas
              .where((story) => !existingIds.contains(story.id))
              .toList();
          storySummary!.storyIdeas.addAll(nextStories);
        } else {
          storySummary = incomingSummary;
        }
        activeStoryIdeasTopicId = topicId;
        storyIdeasError = null;
        _storyIdeasCurrentPage = pageToLoad;
        hasMoreStoryIdeas =
            incomingSummary.storyIdeas.length >= storyIdeasPageLimit;
      },
    );

    isStoryIdeasLoading = false;
    isStoryIdeasLoadingMore = false;
    notifyListeners();
  }

  // True while [getTopicStoryDetails] is in progress.
  bool isRefreshingStoryIdeas = false;
  int _topicDetailsRequestId = 0;

  /// Sets loading UI synchronously before navigating to [MyStoryIdeasScreen].
  void beginTopicStoryDetailsLoad({required String topicId}) {
    activeStoryIdeasTopicId = topicId;
    storySummary = null;
    storyIdeasError = null;
    isRefreshingStoryIdeas = true;
    notifyListeners();
  }

  // Fetches already-generated story ideas for a topic using the mobile GET
  // endpoint (/story/mobile/topics/{id}/story-ideas).
  // When [topicId] differs from [activeStoryIdeasTopicId] the existing
  // storySummary is cleared so the ideas screen shows a loading shimmer.
  // When [topicId] matches, storySummary is kept until the response arrives;
  // MyStoryIdeasScreen shows a full-page shimmer while [isRefreshingStoryIdeas]
  // is true so users do not see stale data during refresh.
  //
  /// [showLoadingUi]: when false (e.g. after reading), skips loading shimmer and
  /// only merges server data when the response arrives — list already updated
  /// optimistically via [applyLocalReadingProgressFromReadingSession].
  Future<void> getTopicStoryDetails({
    required String topicId,
    bool showLoadingUi = true,
  }) async {
    final requestId = ++_topicDetailsRequestId;
    final isSameTopic = activeStoryIdeasTopicId == topicId;

    if (showLoadingUi && !isSameTopic) {
      storySummary = null;
      storyIdeasError = null;
      activeStoryIdeasTopicId = topicId;
    }

    if (showLoadingUi) {
      isRefreshingStoryIdeas = true;
      notifyListeners();
    }

    final response = await HomeApiService.instance.getMobileTopicStoryIdeas(
      topicId: topicId,
    );

    if (requestId != _topicDetailsRequestId) return;

    response.fold(
      (l) {
        Logger.error(l.errorMsg);
        if (showLoadingUi) {
          storyIdeasError = l.errorMsg;
        }
      },
      (r) {
        try {
          final data = r["data"];
          if (data != null && data is Map<String, dynamic>) {
            storySummary = StoryIdeaModel.fromGenerateMobileJson(data);
            activeStoryIdeasTopicId = topicId;
            storyIdeasError = null;
          }
        } catch (e, stack) {
          Logger.error("Error parsing mobile story-ideas: $e\n$stack");
          if (showLoadingUi) {
            storyIdeasError = "Something went wrong. Please try again.";
          }
        }
      },
    );

    if (showLoadingUi) {
      isRefreshingStoryIdeas = false;
    }
    notifyListeners();
  }

  /// Updates [storySummary] in memory so UI matches the reader before the
  /// server acknowledges [updatePageProgress] / topic refetch completes.
  void applyLocalReadingProgressFromReadingSession({
    required String storyIdeaId,
    required int lastPageIndex,
    required int pageCount,
  }) {
    final summary = storySummary;
    if (summary == null || pageCount <= 0) return;

    final index = summary.storyIdeas.indexWhere((e) => e.id == storyIdeaId);
    if (index < 0) return;

    final idea = summary.storyIdeas[index];
    final prev = idea.continueReading;
    final currentLast = lastPageIndex.clamp(0, pageCount - 1);

    final prevLastIdx = prev?.lastPageIndex ?? -1;
    final farthestIdx = currentLast > prevLastIdx ? currentLast : prevLastIdx;

    var readPagesFromFarthest = farthestIdx + 1;
    if (prev != null && prev.readPages > readPagesFromFarthest) {
      readPagesFromFarthest = prev.readPages;
    }
    final effectiveFarthest = (readPagesFromFarthest - 1).clamp(
      0,
      pageCount - 1,
    );

    idea.continueReading = ContinueReading(
      pageCount: pageCount,
      readPages: readPagesFromFarthest,
      remainingPages: (pageCount - readPagesFromFarthest).clamp(0, pageCount),
      lastPageIndex: effectiveFarthest,
      continueFromPageIndex: effectiveFarthest.clamp(0, pageCount - 1),
      percentComplete: pageCount <= 0
          ? 0
          : ((readPagesFromFarthest / pageCount) * 100).round().clamp(0, 100),
      lastReadAt: prev?.lastReadAt ?? DateTime.now().toUtc().toIso8601String(),
      completedAt: prev?.completedAt,
      // Completion now depends on quiz completion (when quizProgress exists).
      isCompleted:
          (readPagesFromFarthest >= pageCount) &&
              ((prev?.quizProgress == null) ||
                  (prev?.quizProgress?.isCompleted == true)) ||
          (prev?.isCompleted ?? false),
    );
    notifyListeners();
  }

  void applyLocalQuizProgress({
    required String storyIdeaId,
    required int totalQuestions,
    required int correctAnswers,
    required bool isCompleted,
    String? completedAt,
  }) {
    final summary = storySummary;
    if (summary == null) return;
    final index = summary.storyIdeas.indexWhere((e) => e.id == storyIdeaId);
    if (index < 0) return;
    final idea = summary.storyIdeas[index];
    final cr = idea.continueReading;
    if (cr == null) return;

    cr.quizProgress = QuizProgress(
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );

    // If quiz is completed, finalize the story locally immediately.
    // This prevents the UI from waiting for a topic refetch to reflect completion.
    if (isCompleted && cr.pageCount > 0) {
      // If the user reached quiz from the last page, they effectively completed reading too.
      cr.readPages = cr.pageCount;
      cr.remainingPages = 0;
      cr.lastPageIndex = cr.pageCount - 1;
      cr.continueFromPageIndex = (cr.pageCount - 1).clamp(0, cr.pageCount - 1);
      cr.percentComplete = 100;
      cr.isCompleted = true;
      cr.completedAt = completedAt ?? DateTime.now().toUtc().toIso8601String();
    }
    notifyListeners();
  }

  // Future<void> deleteStory({required String storyIdea}) async {
  //   final response = await HomeApiService.instance.deleteStory(
  //     storyIdea: storyIdea,
  //   );
  //   response.fold(
  //     (l) {
  //       Logger.error(l.errorMsg);
  //     },
  //     (r) {
  //       Logger.info(r.toString());
  //       getStoryIdeasByTopicId(topicId: topicId!);
  //     },
  //   );
  // }

  Future<void> getTopicProgress({
    required String topicId,
    void Function(String errorMsg)? onFailed,
    required void Function(Map<String, dynamic> result) onSuccess,
  }) async {
    final response = await HomeApiService.instance.getTopicProgress(
      topicId: topicId,
    );
    response.fold(
      (error) => onFailed?.call(error.errorMsg),
      (result) => onSuccess(result),
    );
  }

  void clearSessionData() {
    topicsList = null;
    isTopicsLoading = false;
    isTopicsLoadingMore = false;
    hasMoreTopics = true;
    _topicsCurrentPage = 1;
    storySummary = null;
    isStoryIdeasLoading = false;
    isStoryIdeasLoadingMore = false;
    hasMoreStoryIdeas = true;
    storyIdeasError = null;
    activeStoryIdeasTopicId = null;
    _storyIdeasCurrentPage = 1;
    isGenerateSeriesLoading = false;
    generateSeriesError = null;
    isRefreshingStoryIdeas = false;
    continueReadingItems = null;
    isContinueReadingLoading = false;
    isContinueReadingLoadingMore = false;
    hasMoreContinueReading = false;
    _continueReadingPage = 1;
    continueReadingError = null;
    notifyListeners();
  }
}
