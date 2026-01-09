import 'package:flutter/material.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/models/home/goal_model.dart';
import 'package:redstreakapp/services/auth/auth_api_service.dart';
import 'package:redstreakapp/services/home/home_api_service.dart';

import '../../models/home/interest_model.dart';
import '../../models/home/story_models/story_model.dart';
import '../../models/home/topic_model.dart';

class HomeProvider extends ChangeNotifier {
  TextEditingController goalTitleController = TextEditingController();
  TextEditingController goalDesController = TextEditingController();
  final TextEditingController customInterestCtr = TextEditingController();
  int _currentIndex = 0;
  // Interest state (same as screen, just moved)
  final List<String> customInterestsList = [];

  final Set<String> selectedInterestIds = {};
  final Set<String> selectedCustomInterests = {};

  bool _isLoading = false;
  List<Story> _stories = [];
  List<GoalModel> goalsList = [];
  List<InterestModel> interestsList = [];
  List<TopicModel> topicsList = [];
  String? selectedGoalId;

  set setSelectedId(String? value) {
    selectedGoalId = value;
    if (selectedGoalId != "custom") {
      goalTitleController.clear();
      goalDesController.clear();
    }
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  List<Story> get stories => _stories;

  final List<String> contents = [
    "*Dinosaurs* lived a very long time ago, even before people were on Earth. They were animals that came in many sizes. Some *dinosaurs* were as big as houses, while others were small, almost like chickens. They lived in many different places, such as *forests*, *swamps*, and even *deserts*. *Dinosaurs* ruled the Earth for *millions* of years.",
    "Dinosaurs did not all eat the same food. Some dinosaurs liked to eat plants, such as *leaves* and *ferns*. These are called *plant-eaters*. Other dinosaurs ate meat and used their *sharp teeth* to catch animals. These are called *meat-eaters*. Some walked on two legs, and some walked on four. There were even flying dinosaurs, like *pterosaurs*, that could glide in the sky.",
    "Dinosau looked very different from each other. Some had *long necks* to reach tall trees, while others had *horns* or *spikes* to stay safe. A few even had big *plates* on their backs or sharp *claws*. After many, many years, all dinosaurs *disappeared*. Today, scientists find their *bones* and study them to learn what they were like. We can see these bones in *museums*, and that helps us imagine how amazing dinosaurs once were.",
  ];

  int get currentIndex => _currentIndex;
  int get total => contents.length;
  String get currentContent => contents[_currentIndex];

  void next() {
    if (_currentIndex < contents.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  Future<void> getAllStories() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await AuthApiServices().getAllStories();
      if (response != null && response['success'] == true) {
        final data = response['data'] as List;
        _stories = data.map((e) => Story.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching stories: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isGetGoalsLoading = false;
  Future<void> getGoals({required Function(String error) onFailed}) async {
    isGetGoalsLoading = true;
    notifyListeners();

    final response = await HomeApiService.instance.getGoals();
    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) {
        final goalList = r["data"]["goals"];
        Logger.info("Story Goal List: ${goalList.toString()}");
        goalsList = (goalList as List)
            .map((e) => GoalModel.fromJson(e))
            .toList();
      },
    );

    isGetGoalsLoading = false;
    notifyListeners();
  }

  bool isGetInterestLoading = false;
  Future<void> getInterest({required Function(String error) onFailed}) async {
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

  bool isGetTopicsScreen = false;
  Future<void> getTopics({required Function(String error) onFailed}) async {
    isGetTopicsScreen = true;
    notifyListeners();

    final response = await HomeApiService.instance.getTopics();
    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) {
        final data = r["data"]["topics"];

        topicsList = (data as List).map((e) => TopicModel.fromJson(e)).toList();
      },
    );

    isGetTopicsScreen = false;
    notifyListeners();
  }
}
