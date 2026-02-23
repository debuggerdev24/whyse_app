import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';

import '../../core/enums/app_enums.dart';
import '../../core/helper/log_helper.dart';
import '../../models/home/goal_model.dart';
import '../../models/home/interest_model.dart';
import '../../models/home/story_models/story_model.dart';
import '../../models/home/topic_model.dart';
import '../../routes/user_routes.dart';
import '../../services/home/story_api_service.dart';

class StoryProvider extends ChangeNotifier {
  TextEditingController goalTitleController = TextEditingController(),
      goalDesController = TextEditingController(),
      customInterestCtr = TextEditingController(),
      searchTopicCtr = TextEditingController(),
      customTopicCtr = TextEditingController(),
      customReadingDurationCtr = TextEditingController();
  int _lessonDuration = 0,
      _noOfStories = 0,
      _currentStoryIndex = 0,
      detector = 0;
  int _currentStoryPageIndex = 0;
  int get lessonDuration => _lessonDuration;
  int get noOfStories => _noOfStories;
  int get currentStoryIndex => _currentStoryIndex;
  int get currentStoryPageIndex => _currentStoryPageIndex;
  set setCurrentStoryIndex(int value) {
    _currentStoryIndex = value;
    notifyListeners();
  }

  void setCurrentStoryPageIndex(int value) {
    _currentStoryPageIndex = value;
    notifyListeners();
  }

  void resetStoryPageIndex() {
    _currentStoryPageIndex = 0;
    notifyListeners();
  }

  List<Map<String, List<String>>> createdStoryImages = [];
  Map<String, dynamic> dataToSendCreateStory = {};
  final allowedDurations = {5, 10, 15, 20, 25, 30, 35, 40, 45};
  List<StoryModel> _stories = [];
  List<String> storyIdeas = [];

  List<StoryModel> get stories => _stories;
  final List<String> readingDurations = [
    '5 mins',
    '10 mins',
    '20 mins',
    'Custom',
  ];
  final List<String> ageRanges = ["6-8", "9-11", "12-14", "15-17", "18+"];

  //todo topics field
  String _selectedTextType = "", _selectedAgeRange = "", _selectedLanguage = "";

  List<TopicModel> topicsList = [];
  List<SearchTopicModel> searchedTopicsList = [];
  final List<String> customTopics = [];
  String selectedTopic = "", selectedReadingDuration = "5 mins";
  final Set<String> selectedCustomTopics = {};

  set setNoOfStories(String value) {
    _noOfStories = int.parse(value);
    notifyListeners();
  }

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

  bool isGetStoryLoading = false;
  Future<void> getAllStories() async {
    isGetStoryLoading = true;
    notifyListeners();

    final response = await StoryApiService.instance.getAllStories();

    response.fold(
      (l) {
        Logger.error(l.errorMsg);
      },
      (r) {
        final data = r['data'] as List;
        _stories = data.map((e) => StoryModel.fromJson(e)).toList();
        isGetStoryLoading = false;
        notifyListeners();
      },
    );
  }

  bool isGetGoalsLoading = false;

  Future<void> getStoryGoals({required Function(String error) onFailed}) async {
    isGetGoalsLoading = true;
    notifyListeners();

    final response = await StoryApiService.instance.getGoals();
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

    final response = await StoryApiService.instance.getInterest();
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

    final response = await StoryApiService.instance.getTopics();
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

    final response = await StoryApiService.instance.getSearchedTopics(
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
    if (selectedTopic == id) {
      selectedTopic == "";
    } else {
      selectedTopic = id;
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
  //todo create story
  Future<void> createStory({
    required Function(String error) onCreateStoryFailed,
    required Function(String error) onCreateImageFailed,
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

    if (selectedReadingDuration.toLowerCase() == AppEnum.custom.name) {
      if (customReadingDurationCtr.text.isEmpty) {
        AppToast.error(context, "Please Enter Minutes");
        return;
      }
      _lessonDuration = int.tryParse(customReadingDurationCtr.text.trim()) ?? 0;
    } else {
      _lessonDuration =
          int.tryParse(selectedReadingDuration.split(' ')[0]) ?? 0;
    }
    if (!allowedDurations.contains(_lessonDuration)) {
      AppToast.error(
        context,
        "Lesson duration must be one \nof: 5, 10, 15, 20, 25, 30, 35, 40, 45",
      );
      return;
    }

    if (_noOfStories == 0) {
      AppToast.error(context, "Please enter number of stories");
      return;
    }

    isCreateStoryLoading = true;
    notifyListeners();
    onStarted.call();

    dataToSendCreateStory = {
      "interestIds": selectedInterestIds.toList(),
      (selectedTopic.isEmpty) ? "LessonContentInstructions" : "ReadingTopic":
          (selectedTopic.isEmpty) ? customTopicCtr.text.trim() : selectedTopic,
      "LessonDuration": _lessonDuration,
      "Language": _selectedLanguage,
      "TextType": _selectedTextType,
      "ReadingSkillFocus": "Phonics",
      "Age": _selectedAgeRange,
      "readingLevel": "CEFR A2",
      "NoOfStories": _noOfStories,
    };
    //todo adding goalIds
    if (selectedGoalIds.isNotEmpty) {
      dataToSendCreateStory["goalIds"] = selectedGoalIds.toList();
    }
    //* create story idea
    stories.clear();
    storyIdeas.clear();
    final response = await StoryApiService.instance.createStoryIdea(
      data: dataToSendCreateStory,
    );

    response.fold(
      (l) {
        onCreateStoryFailed.call(l.errorMsg);
      },
      (r) async {
        Logger.info(
          "Story Ideas length: ${(r["data"]["storyIdeas"] as List).length.toString()}",
        );
        storyIdeas = (r["data"]["storyIdeas"] as List)
            .map((e) => e["id"].toString())
            .toList();
        Logger.info("Story Ideas length: ${storyIdeas.length}");

        // for (var storyIdea in storyIdeas) {
        final response = await StoryApiService.instance.createStory(
          data: {"storyIdeaId": storyIdeas.first},
        );
        response.fold(
          (l) {
            onCreateStoryFailed.call(l.errorMsg);
          },
          (r) {
            final story = StoryModel.fromJson(r["data"]);

            stories.add(story);

          //todo if in the future we want to create story images from the AI, we can uncomment this
            // createStoryImage(
            //   onFailed: onCreateImageFailed,
            //   storyid: story.id,
            //   pageCount: story.pages!.length,
            // );
            isCreateStoryLoading = false;
            notifyListeners();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.pushNamed(AppRoutes.readingScreen.name, extra: stories.first);
              }
            });
          },
        );
        for (var storyIdea in storyIdeas) {
          if (storyIdea == storyIdeas.first) continue;
          final response = await StoryApiService.instance.createStory(
            data: {"storyIdeaId": storyIdea},
          );
          // Logger.info("i: $i");
          Logger.info("len: ${storyIdeas.length}");
          ++detector;

          Logger.info("Detector: $detector");
          response.fold(
            (l) {
              onCreateStoryFailed.call(l.errorMsg);
            },
            (r) async {
              final story = StoryModel.fromJson(r["data"]);
              stories.add(story);
              // createStoryImage(onFailed: onCreateImageFailed, storyid: story.id, pageCount: story.pages!.length);

              final response = await StoryApiService.instance.createStoryImage(
                data: {"storyId": story.id, "imageCount": story.pages.length},
              );

              response.fold(
                (l) {
                  onCreateImageFailed.call(l.errorMsg);
                },
                (r) async {
                  Logger.info(
                    "createdStoryImagePath : ${r["data"]["imagePaths"].toString()}",
                  );
                  final images = List<String>.from(r["data"]["imagePaths"]);
                  createdStoryImages.add({"images": images});
                  Logger.info(
                    "createdStoryImagePaths length: ${createdStoryImages.length}",
                  );
                  Logger.info("storyPage length: ${story.pages.length}}");
                },
              );
            },
          );
        }
      },
    );
  }

  //todo create story image
  bool isCreateStoryImageLoading = false;
  Future<void> createStoryImage({
    required Function(String error) onFailed,
    required String storyid,
    required int pageCount,
  }) async {
    isCreateStoryImageLoading = true;
    notifyListeners();
    createdStoryImages.clear();
    final response = await StoryApiService.instance.createStoryImage(
      data: {"storyId": storyid, "imageCount": pageCount},
    );

    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) async {
        Logger.info(
          "createdStoryImagePath : ${r["data"]["imagePaths"].toString()}",
        );
        final images = List<String>.from(r["data"]["imagePaths"]);
        createdStoryImages.add({"images": images});
        Logger.info(
          "createdStoryImagePaths length: ${createdStoryImages.length}",
        );
        Logger.info("storyPage length: ${pageCount}}");
        linkImageToStory(image: createdStoryImages.first["images"]!.first);

        isCreateStoryImageLoading = false;
        notifyListeners();
        // clearStoryFields();
      },
    );
  }

  void clearStoryFields() {
    selectedGoalIds.clear();
    selectedInterestIds.clear();
    selectedTopic = "";
    customTopicCtr.clear();
    // _lessonDuration = 0;
    _selectedLanguage = "";
    _selectedTextType = "";
    _selectedAgeRange = "";
  }

  void clareStoryData() {
    createdStoryImages.clear();
    stories.clear();
    storyIdeas.clear();
    dataToSendCreateStory = {};
  }

  Future<void> linkImageToStory({required String image}) async {
    //todo calling connect image to story API
    Logger.info("Link image : $image");

    final response = await StoryApiService.instance.linkeIMageToStory(
      id: stories.first.id,
      data: {
        "images": [image],
      },
    );

    response.fold(
      (l) {
        Logger.error(l.errorMsg);
      },
      (r) {
        // isCreateImageFirstTime = false;
      },
    );
  }
}