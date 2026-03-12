import 'package:flutter/material.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/models/home/browse_topic_model.dart';
import 'package:redstreakapp/models/home/story_models/story_history_model.dart';
import 'package:redstreakapp/models/home/story_models/story_topics.dart';
import 'package:redstreakapp/models/home/story_models/story_summary_model.dart';
import 'package:redstreakapp/services/home/home_api_service.dart';
import 'package:redstreakapp/services/home/story_api_service.dart';

class ToggleTopicListResult {
  final bool isInMyList;
  final String topicTitle;
  final String? message;

  const ToggleTopicListResult({
    required this.isInMyList,
    required this.topicTitle,
    this.message,
  });
}

class HomeProvider extends ChangeNotifier {
  static const int storyIdeasPageLimit = 20;
  static const int topicsPageLimit = 20;

  List<CreatedStoryTopicsModel>? topicsList;
  bool isTopicsLoading = false;
  bool isTopicsLoadingMore = false;
  bool hasMoreTopics = true;
  int _topicsCurrentPage = 1;

  // String? topicId;
  StoryIdeaModel? storySummary;
  StoryHistoryModel? story;
  bool isStoryIdeasLoading = false;
  bool isStoryIdeasLoadingMore = false;
  bool hasMoreStoryIdeas = true;
  String? storyIdeasError;
  String? activeStoryIdeasTopicId;
  int _storyIdeasCurrentPage = 1;
  final Set<String> _togglingTopicIds = <String>{};

  bool isTopicListToggling(String topicId) =>
      _togglingTopicIds.contains(topicId);

  Future<void> getMyTopics() async {
    if (isTopicsLoading) return;
    isTopicsLoading = true;
    topicsList = null;
    hasMoreTopics = true;
    _topicsCurrentPage = 1;
    notifyListeners();

    final response = await HomeApiService.instance.getMyTopics(page: 1);

    isTopicsLoading = false;
    response.fold(
      (l) {
        Logger.error(l.errorMsg);
        topicsList = [];
      },
      (r) {
        try {
          final data = r["data"];
          if (data is List) {
            topicsList = data
                .map((e) => CreatedStoryTopicsModel.fromJson(e))
                .toList();
          } else if (data is Map && data.containsKey("topics")) {
            topicsList = (data["topics"] as List)
                .map((e) => CreatedStoryTopicsModel.fromJson(e))
                .toList();
          } else {
            topicsList = [];
          }
          hasMoreTopics = (topicsList?.length ?? 0) >= topicsPageLimit;
        } catch (e, stack) {
          Logger.error("Error parsing topics: $e\n$stack");
          topicsList = [];
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
        topicsList!.isEmpty)
      return;

    isTopicsLoadingMore = true;
    notifyListeners();

    final nextPage = _topicsCurrentPage + 1;
    final response = await HomeApiService.instance.getMyTopics(page: nextPage);

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
          if (data is List) {
            nextList = data
                .map((e) => CreatedStoryTopicsModel.fromJson(e))
                .toList();
          } else if (data is Map && data.containsKey("topics")) {
            nextList = (data["topics"] as List)
                .map((e) => CreatedStoryTopicsModel.fromJson(e))
                .toList();
          }
          if (nextList != null && nextList.isNotEmpty) {
            topicsList = [...(topicsList ?? []), ...nextList];
            _topicsCurrentPage = nextPage;
            hasMoreTopics = nextList.length >= topicsPageLimit;
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

  bool isGettingStoryLoading = false;
  Future<void> getStoryByIdea({
    required BuildContext context,
    required String storyIdea,
    required Function(StoryHistoryModel story) onSuccess,
    void Function()? onStoryNotGenerated,
  }) async {
    story = null;
    isGettingStoryLoading = true;
    notifyListeners();
    final response = await HomeApiService.instance.getStoryByStoryId(
      storyIdea: storyIdea,
    );
    response.fold(
      (l) {
        Logger.error(l.errorMsg);
        isGettingStoryLoading = false;
        notifyListeners();
      },
      (r) async {
        final data = r["data"] is Map ? r["data"] as Map : null;
        final storyData = data?["story"];
        final storyIdeaMap = data?["storyIdea"] is Map
            ? data!["storyIdea"] as Map
            : null;
        final isGenerated =
            storyIdeaMap != null && storyIdeaMap["isGenerated"] == true;
        if (storyData == null || !isGenerated) {
          
          AppToast.info(
            context: context,
            durationSecond: 3,
            message: "It can take few seconds to generate the story.",
          );
          final createResponse = await StoryApiService.instance.createStory(
            data: {"storyIdeaId": storyIdea},
          );
          createResponse.fold(
            (_) {
              isGettingStoryLoading = false;
              notifyListeners();
              onStoryNotGenerated?.call();
            },
            (_) async {
              final retryResponse = await HomeApiService.instance
                  .getStoryByStoryId(storyIdea: storyIdea);
              retryResponse.fold(
                (__) {
                  isGettingStoryLoading = false;
                  notifyListeners();
                  onStoryNotGenerated?.call();
                },
                (rr) {
                  final retryData = rr["data"] is Map
                      ? rr["data"]["story"]
                      : null;
                  final retryGenerated =
                      rr["data"] is Map &&
                      (rr["data"]["storyIdea"] is Map) &&
                      rr["data"]["storyIdea"]["isGenerated"] == true;
                  if (retryData != null && retryGenerated) {
                    story = StoryHistoryModel.fromJson(
                      Map<String, dynamic>.from(retryData as Map),
                    );
                    onSuccess.call(story!);
                  } else {
                    onStoryNotGenerated?.call();
                  }
                  isGettingStoryLoading = false;
                  notifyListeners();
                },
              );
            },
          );
          return;
        }
        story = StoryHistoryModel.fromJson(
          Map<String, dynamic>.from(storyData as Map),
        );
        onSuccess.call(story!);
        isGettingStoryLoading = false;
        notifyListeners();
      },
    );
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

  Future<ToggleTopicListResult?> toggleTopicList({
    required BrowseTopicModel topic,
    required Function(String error) onFailed,
  }) async {
    if (!topic.canManageMyList || _togglingTopicIds.contains(topic.id)) {
      return null;
    }

    _togglingTopicIds.add(topic.id);
    notifyListeners();

    final response = await HomeApiService.instance.toggleTopicList(
      topicId: topic.id,
    );

    return response.fold(
      (error) {
        _togglingTopicIds.remove(topic.id);
        notifyListeners();
        onFailed.call(error.errorMsg);
        return null;
      },
      (result) async {
        final data = result["data"] is Map
            ? Map<String, dynamic>.from(result["data"] as Map)
            : <String, dynamic>{};
        final bool isInMyList = data["isInMyList"] == true;
        final String topicTitle =
            data["topicTitle"]?.toString().trim().isNotEmpty == true
            ? data["topicTitle"].toString()
            : topic.topic;

        _togglingTopicIds.remove(topic.id);
        notifyListeners();
        await getMyTopics();

        return ToggleTopicListResult(
          isInMyList: isInMyList,
          topicTitle: topicTitle,
          message: result["message"]?.toString(),
        );
      },
    );
  }

  void clearSessionData() {
    topicsList = null;
    isTopicsLoading = false;
    isTopicsLoadingMore = false;
    hasMoreTopics = true;
    _topicsCurrentPage = 1;
    storySummary = null;
    story = null;
    isStoryIdeasLoading = false;
    isStoryIdeasLoadingMore = false;
    hasMoreStoryIdeas = true;
    storyIdeasError = null;
    activeStoryIdeasTopicId = null;
    _storyIdeasCurrentPage = 1;
    isGettingStoryLoading = false;
    notifyListeners();
  }
}
