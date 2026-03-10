import 'package:flutter/material.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/models/home/story_models/story_history_model.dart';
import 'package:redstreakapp/models/home/story_models/story_topics.dart';
import 'package:redstreakapp/models/home/story_models/story_summary_model.dart';
import 'package:redstreakapp/services/home/home_api_service.dart';

class HomeProvider extends ChangeNotifier {
  static const int storyIdeasPageLimit = 20;
  List<CreatedStoryTopicsModel>? topicsList;
  // String? topicId;
  StoryIdeaModel? storySummary;
  StoryHistoryModel? story;
  bool isStoryIdeasLoading = false;
  bool isStoryIdeasLoadingMore = false;
  bool hasMoreStoryIdeas = true;
  String? storyIdeasError;
  String? activeStoryIdeasTopicId;
  int _storyIdeasCurrentPage = 1;

  Future<void> getMyTopics() async {
    topicsList = null;
    notifyListeners();
    final response = await HomeApiService.instance.getMyTopics();

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
        } catch (e, stack) {
          Logger.error("Error parsing topics: $e\n$stack");
          topicsList = [];
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
  Future<void> getStoryByIdea({required String storyIdea,required Function(StoryHistoryModel story) onSuccess}) async {
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
      (r) {
        final data = r["data"]["story"];
        story = StoryHistoryModel.fromJson(data);
        
        // Logger.info("Story: ${story.image}");

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
}
