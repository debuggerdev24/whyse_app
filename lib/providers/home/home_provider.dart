import 'package:flutter/material.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/models/home/story_models/story_history_model.dart';
import 'package:redstreakapp/models/home/story_models/story_topics.dart';
import 'package:redstreakapp/models/home/story_models/story_summary_model.dart';
import 'package:redstreakapp/services/home/home_api_service.dart';

class HomeProvider extends ChangeNotifier {
  List<CreatedStoryTopicsModel>? topicsList;
  // String? topicId;
  StoryIdeaModel? storySummary;
  StoryHistoryModel? story;

  Future<void> getHomeScreenTopics() async {
    topicsList = null;
    notifyListeners();
    final response = await HomeApiService.instance.getHomeScreenTopics();

    response.fold(
      (l) {
        Logger.error(l.errorMsg);
      },
      (r) {
        final data = r["data"];
        topicsList = (data as List)
            .map((e) => CreatedStoryTopicsModel.fromJson(e))
            .toList();
      },
    );
    notifyListeners();
  }

  Future<void> getStoryIdeasByTopicId({required String topicId}) async {
    storySummary = null;
    notifyListeners();
    final response = await HomeApiService.instance.getStoryIdeasByTopicId(
      topicId: topicId,
    );
    response.fold(
      (l) {
        Logger.error(l.errorMsg);
      },
      (r) {
        // this.topicId = topicId;
        storySummary = StoryIdeaModel.fromJson(r["data"]);
        notifyListeners();
      },
    );
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
