import 'package:flutter/widgets.dart';

import '../../core/helper/log_helper.dart';
import '../../models/home/goal_model.dart';
import '../../models/home/interest_model.dart';
import '../../models/home/story_models/story_model.dart';
import '../../models/home/topic_model.dart';
import '../../services/home/home_api_service.dart';

class StoryProvider extends ChangeNotifier {
  TextEditingController goalTitleController = TextEditingController();
  TextEditingController goalDesController = TextEditingController();
  final TextEditingController customInterestCtr = TextEditingController();
  final TextEditingController searchTopicCtr = TextEditingController();


  //todo topics field
  List<TopicModel> topicsList = [];
  List<SearchTopicModel> searchedTopicsList = [];
  final List<String> customTopics = [];
  final Set<String> selectedTopicIds = {};
  final Set<String> selectedCustomTopics = {};

  //todo interest field
  List<InterestModel> interestsList = [];
  final List<String> customInterestsList = [];
  final Set<String> selectedInterestIds = {};
  final Set<String> selectedCustomInterests = {};

  //todo goal fields
  List<GoalModel> goalsList = [];
  final Set<String> selectedGoalIds = {};


  bool isCustomGoalSelected = false;

  void toggleGoal(String id) {
    if (selectedGoalIds.contains(id)) {
      selectedGoalIds.remove(id);
    } else {
      selectedGoalIds.add(id);
    }
    notifyListeners();
  }

  void toggleCustomGoal() {
    isCustomGoalSelected = !isCustomGoalSelected;
    if (!isCustomGoalSelected) {
      goalTitleController.clear();
      goalDesController.clear();
    }
    notifyListeners();
  }

  bool isGetGoalsLoading = false;
  Future<void> getStoryGoals({required Function(String error) onFailed}) async {
    isGetGoalsLoading = true;
    notifyListeners();

    final response = await HomeApiService.instance.getGoals();
    response.fold(
          (l) {
        onFailed.call(l.errorMsg);
      },
          (r) {
        final goalList = r["data"]["goals"];
        goalsList = (goalList as List)
            .map((e) => GoalModel.fromJson(e))
            .toList();
      },
    );

    isGetGoalsLoading = false;
    notifyListeners();
  }

  bool isGetInterestLoading = false;
  Future<void> getStoryInterest({required Function(String error) onFailed}) async {
    isGetInterestLoading = true;
    notifyListeners();

    final response = await HomeApiService.instance.getInterest();
    response.fold(
          (l) {
        onFailed.call(l.errorMsg);
      },
          (r) {
        final data = r["data"]["interests"];

        interestsList = (data as List)
            .map((e) => InterestModel.fromJson(e))
            .toList();
      },
    );

    isGetInterestLoading = false;
    notifyListeners();
  }

  void addCustomInterest(String name) {
    if (name.trim().isEmpty) return;

    if (!customInterestsList.contains(name)) {
      customInterestsList.add(name);
      selectedCustomInterests.add(name);
      customInterestCtr.clear();
      notifyListeners();
    }
  }

  void toggleApiInterest(String id) {
    if (selectedInterestIds.contains(id)) {
      selectedInterestIds.remove(id);
    } else {
      selectedInterestIds.add(id);
    }
    notifyListeners();
  }

  void toggleCustomInterest(String name) {
    if (selectedCustomInterests.contains(name)) {
      selectedCustomInterests.remove(name);
    } else {
      selectedCustomInterests.add(name);
    }
    notifyListeners();
  }

  bool isGetTopicsLoading = false;
  Future<void> getStoryTopics({required Function(String error) onFailed}) async {
    isGetTopicsLoading = true;
    notifyListeners();

    final response = await HomeApiService.instance.getTopics();
    response.fold(
          (l) {
        onFailed.call(l.errorMsg);
      },
          (r) {
        final data = r["data"]["topics"];

        topicsList = (data as List).map((e) => TopicModel.fromJson(e)).toList();
        notifyListeners();
      },
    );

    isGetTopicsLoading = false;
    notifyListeners();
  }

  bool isGetSearchedTopicsLoading = false;
  Future<void> getSearchedStoryTopics({required Function(String error) onFailed}) async {
    isGetSearchedTopicsLoading = true;
    notifyListeners();


    final response = await HomeApiService.instance.getSearchedTopics(queryParams: {"search": searchTopicCtr.text.trim()});
    response.fold(
          (l) {
        onFailed.call(l.errorMsg);
      },
          (r) {
        final data = r["data"]["topics"];

        searchedTopicsList = (data as List).map((e) => SearchTopicModel.fromJson(json: e)).toList();
        notifyListeners();
      },
    );

    isGetSearchedTopicsLoading = false;
    notifyListeners();
  }

  void toggleApiTopic(String id) {
    if (selectedTopicIds.contains(id)) {
      selectedTopicIds.remove(id);
    } else {
      selectedTopicIds.add(id);
    }
    notifyListeners();
  }

  void toggleCustomTopic(String title) {
    if (selectedCustomTopics.contains(title)) {
      selectedCustomTopics.remove(title);
    } else {
      selectedCustomTopics.add(title);
    }
    notifyListeners();
  }
}