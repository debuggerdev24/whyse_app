import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';

import '../../core/enums/app_enums.dart';
import '../../models/home/goal_model.dart';
import '../../models/home/interest_model.dart';
import '../../models/home/story_models/story_model.dart';
import '../../models/home/topic_model.dart';
import '../../routes/user_routes.dart';
import '../../services/home/home_api_service.dart';

class StoryProvider extends ChangeNotifier {
  TextEditingController goalTitleController = TextEditingController();
  TextEditingController goalDesController = TextEditingController();
  TextEditingController customInterestCtr = TextEditingController();
  TextEditingController searchTopicCtr = TextEditingController();
  TextEditingController customTopicCtr = TextEditingController();
  TextEditingController customReadingDurationCtr = TextEditingController();
  int lessonDuration = 0;
  final allowedDurations = {5, 10, 15, 20, 25, 30, 35, 40, 45};

  //todo topics field
  String _selectedTextType = "", _selectedAgeRange = "", _selectedLanguage = "";

  List<TopicModel> topicsList = [];
  List<SearchTopicModel> searchedTopicsList = [];
  final List<String> customTopics = [];
  String selectedTopicId = "", selectedReadingDuration = "5 mins";
  final Set<String> selectedCustomTopics = {};

  set setSelectedReadingDuration(String value) {
    selectedReadingDuration = value;
    notifyListeners();
  }

  set setSelectedAgeRange(String value) {
    _selectedAgeRange = value;
    notifyListeners();
  }

  set setSelectedLanguage(String value) {
    _selectedLanguage = value;
    notifyListeners();
  }

  set setSelectedTextType(String value) {
    _selectedTextType = value;
    notifyListeners();
  }

  //todo interest field
  List<InterestModel> interestsList = [];
  final List<String> customInterestsList = [];
  final Set<String> selectedInterestIds = {};
  final Set<String> selectedCustomInterests = {};
  Story? story;

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
  Future<void> getStoryInterest({
    required Function(String error) onFailed,
  }) async {
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
  Future<void> getStoryTopics({
    required Function(String error) onFailed,
  }) async {
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
  Future<void> getSearchedStoryTopics({
    required Function(String error) onFailed,
  }) async {
    isGetSearchedTopicsLoading = true;
    notifyListeners();

    final response = await HomeApiService.instance.getSearchedTopics(
      queryParams: {"search": searchTopicCtr.text.trim()},
    );
    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) {
        final data = r["data"]["topics"];

        searchedTopicsList = (data as List)
            .map((e) => SearchTopicModel.fromJson(json: e))
            .toList();
        notifyListeners();
      },
    );

    isGetSearchedTopicsLoading = false;
    notifyListeners();
  }

  void toggleApiTopic(String id) {
    if (selectedTopicId == id) {
      selectedTopicId == "";
    } else {
      selectedTopicId = id;
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

  bool isCreateStoryLoading = false;
  Future<void> createStory({
    required Function(String error) onFailed,
    required VoidCallback onSuccess,
    required VoidCallback onStarted,
    required BuildContext context,
  }) async {
    if (customReadingDurationCtr.text.trim().isEmpty &&
        selectedReadingDuration.toLowerCase() == AppEnum.custom.name) {
      AppToast.error(context, "Please enter minuets");
      return;
    }

    if (_selectedTextType.isEmpty) {
      AppToast.error(context, "Please enter Text Type");
      return;
    }
    if (_selectedAgeRange.isEmpty) {
      AppToast.error(context, "Please enter Age Range");
      return;
    }
    if (_selectedLanguage.isEmpty) {
      AppToast.error(context, "Please enter Language");
      return;
    }

    onStarted.call();

    if (selectedReadingDuration.toLowerCase() == AppEnum.custom.name) {
      if (customReadingDurationCtr.text.isEmpty) {
        AppToast.error(context, "Please Enter Minutes");
        return;
      }
      lessonDuration = int.tryParse(customReadingDurationCtr.text.trim()) ?? 0;
    } else {
      lessonDuration = int.tryParse(selectedReadingDuration.split(' ')[0]) ?? 0;
    }
    if (!allowedDurations.contains(lessonDuration)) {
      AppToast.error(
        context,

        "Lesson duration must be one \nof: 5, 10, 15, 20, 25, 30, 35, 40, 45",
      );
      return;
    }

    // if (lessonDuration == 0) {
    //   AppToast.error(context, "Please enter valid minutes");
    //   return;
    // }

    isCreateStoryLoading = true;
    notifyListeners();

    Map<String, dynamic> data = {
      "interestIds": selectedInterestIds.toList(),
      (selectedTopicId.isEmpty)
          ? "customTopicDescription"
          : "topicId": (selectedTopicId.isEmpty)
          ? customTopicCtr.text.trim()
          : selectedTopicId,
      "lessonDuration": lessonDuration,
      "language": _selectedLanguage,
      "textType": _selectedTextType,
      "ageRange": _selectedAgeRange,
    };
    //todo adding goalIds
    if (selectedGoalIds.isNotEmpty) {
      data["goalIds"] = selectedGoalIds.toList();
    }

    Logger.info(data.toString());
    final response = await HomeApiService.instance.createStory(data: data);

    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) {
        final data = r["data"];
        story = Story.fromJson(data);
        context.pushNamed(AppRoutes.readingScreen.name, extra: story);
        // if (!(isCreateStoryImageLoading && isCreateStoryLoading)) {

        onSuccess.call();
      },
    );

    isCreateStoryLoading = false;
    notifyListeners();
  }

  bool isCreateStoryImageLoading = false;
  Future<void> createStoryImage({
    required VoidCallback onSuccess,
    required Function(String error) onFailed,
  }) async {
    if (customReadingDurationCtr.text.trim().isEmpty &&
        selectedReadingDuration.toLowerCase() == AppEnum.custom.name)
      return;

    if (_selectedTextType.isEmpty) return;

    if (_selectedAgeRange.isEmpty) return;

    if (_selectedLanguage.isEmpty) return;

    if (selectedReadingDuration.toLowerCase() == AppEnum.custom.name) {
      if (customReadingDurationCtr.text.isEmpty) return;

      lessonDuration = int.tryParse(customReadingDurationCtr.text.trim()) ?? 0;
    } else {
      lessonDuration = int.tryParse(selectedReadingDuration.split(' ')[0]) ?? 0;
    }
    if (!allowedDurations.contains(lessonDuration)) return;

    isCreateStoryImageLoading = true;
    notifyListeners();

    Map<String, dynamic> data = {
      "interestIds": selectedInterestIds.toList(),
      (selectedTopicId.isEmpty)
          ? "customTopicDescription"
          : "topicId": (selectedTopicId.isEmpty)
          ? customTopicCtr.text.trim()
          : selectedTopicId,
      "lessonDuration": lessonDuration,
      "language": _selectedLanguage,
      "textType": _selectedTextType,
      "ageRange": _selectedAgeRange,
    };

    if (selectedGoalIds.isNotEmpty) {
      data["goalIds"] = selectedGoalIds.toList();
    }

    final response = await HomeApiService.instance.createStoryImage(data: data);

    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) async {
        final storyId = r["data"]["storyId"];
        final imagePath = r["data"]["imagePath"];
        onSuccess.call();
        isCreateStoryImageLoading = false;
        notifyListeners();
        await HomeApiService.instance.storeImage(
          id: storyId,
          data: {
            "images": [imagePath],
          },
        );
      },
    );
  }
}
