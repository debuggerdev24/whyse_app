import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/models/home/story_models/story_idea_model.dart';
import 'package:redstreakapp/models/home/topic_progress_model.dart';
import '../../core/enums/app_enums.dart';
import '../../core/helper/log_helper.dart';
import '../../models/home/goal_model.dart';
import '../../models/home/interest_model.dart';
import '../../models/home/story_models/story_model.dart';
import '../../models/home/topic_model.dart';
import '../../routes/app_router.dart';
import '../../routes/user_routes.dart';
import '../../services/home/story_api_service.dart';

class StoryProvider extends ChangeNotifier {
  TextEditingController goalTitleController = TextEditingController(),
      goalDesController = TextEditingController(),
      customInterestCtr = TextEditingController(),
      searchTopicCtr = TextEditingController(),
      customTopicCtr = TextEditingController(),
      customReadingDurationCtr = TextEditingController();
  int _lessonDuration = 0, _noOfStories = 0, _currentStoryIndex = 0;
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
  StoryIdeasModel? storyIdea;

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

  bool isGenerateSingleStoryLoading = false;
  /// Call before navigating to story series so the destination shows shimmer immediately (no close icon).
  void beginGenerateSingleStoryLoading() {
    isGenerateSingleStoryLoading = true;
    notifyListeners();
  }
  /// Set when createStory API fails (e.g. receiveTimeout). Cleared when retrying.
  String? generateStoryError;
  final Set<String> _markingReadStoryIdeaIds = {};
  final Set<String> _markedReadStoryIdeaIds = {};

  bool isMarkingStoryAsRead(String storyIdeaId) =>
      _markingReadStoryIdeaIds.contains(storyIdeaId);

  bool isStoryMarkedAsRead(String storyIdeaId) =>
      _markedReadStoryIdeaIds.contains(storyIdeaId);

  Future<void> generateSingleStory({
    required String storyIdeaId,
    required BuildContext context,
    required VoidCallback onSuccess,
    int? insertAtIndex,
    bool showToast = true,
    bool forceRegenerate = false,
  }) async {
    generateStoryError = null;
    isGenerateSingleStoryLoading = true;
    notifyListeners();
    if (showToast && context.mounted) {
      AppToast.info(
        context: context,
        durationSecond: 3,
        message: "It can take few seconds to generate the story",
      );
    }

    final payload = <String, dynamic>{
      ...dataToSendCreateStory,
      "storyIdeaId": storyIdeaId,
      if (forceRegenerate) "forceRegenerate": true,
    };
    final createResponse = await StoryApiService.instance.createStory(
      data: payload,
    );

    createResponse.fold(
      (l) {
        generateStoryError = l.errorMsg;
        isGenerateSingleStoryLoading = false;
        notifyListeners();
        if (context.mounted) AppToast.error(context, l.errorMsg);
      },
      (r) {
        final story = StoryModel.fromJson(r["data"]);
        if (insertAtIndex != null && insertAtIndex >= 0) {
          _addStoryAtIndex(story, insertAtIndex);
          _currentStoryIndex = insertAtIndex;
        } else {
          _stories.add(story);
        }
        isGenerateSingleStoryLoading = false;
        notifyListeners();
        onSuccess();
      },
    );
  }

  static StoryModel _placeholderStory() => StoryModel(
        id: '',
        title: '',
        content: '',
        quiz: [],
        pages: [],
        lessonDuration: 0,
      );

  Future<void> markStoryAsRead({
    required String storyIdeaId,
    required BuildContext context,
  }) async {
    if (storyIdeaId.trim().isEmpty ||
        _markingReadStoryIdeaIds.contains(storyIdeaId) ||
        _markedReadStoryIdeaIds.contains(storyIdeaId)) {
      return;
    }

    _markingReadStoryIdeaIds.add(storyIdeaId);
    notifyListeners();

    final response = await StoryApiService.instance.markAsRead(
      storyIdeaId: storyIdeaId,
    );

    response.fold(
      (l) {
        _markingReadStoryIdeaIds.remove(storyIdeaId);
        notifyListeners();
        if (context.mounted) {
          AppToast.error(context, l.errorMsg);
        }
      },
      (r) {
        _markingReadStoryIdeaIds.remove(storyIdeaId);
        _markedReadStoryIdeaIds.add(storyIdeaId);
        notifyListeners();
        if (context.mounted) {
          AppToast.success(context, "Story marked as read successfully");
        }
      },
    );
  }

  void _addStoryAtIndex(StoryModel story, int index) {
    while (_stories.length <= index) {
      _stories.add(_placeholderStory());
    }
    _stories[index] = story;
  }

  /// Sets storyIdea and state from topic progress (e.g. from Browse). Clears stories and sets current index.
  void setFromTopicProgress(TopicProgressModel progress) {
    final t = progress.topic;
    final topic = Topic(
      id: t.id,
      title: t.title,
      learningGoal: t.learningGoal,
      interests: [],
      createdAt: DateTime.now(),
      thumbnailUrl: t.thumbnailUrl,
    );
    final storyIdeas = progress.readings
        .map((r) => StoryIdea(
              id: r.storyIdeaId,
              title: r.title,
              description: "",
              thumbnailUrl: r.thumbnailUrl ?? "",
              createdAt: DateTime.now(),
              sequenceIndex: r.priority,
            ))
        .toList();
    storyIdea = StoryIdeasModel(
      promptType: "progress",
      grade: null,
      mustIncludeWords: null,
      topic: topic,
      storyIdeas: storyIdeas,
    );
    _stories = [];
    _currentStoryIndex = 0;
    _currentStoryPageIndex = 0;
    if (_lessonDuration <= 0) _lessonDuration = 5;
    notifyListeners();
  }

  /// Index of a reading item by storyIdeaId in current storyIdea.
  int indexOfReadingByStoryIdeaId(String storyIdeaId) {
    if (storyIdea == null) return -1;
    final idx = storyIdea!.storyIdeas.indexWhere((s) => s.id == storyIdeaId);
    return idx;
  }

  bool isGenerateStoryIdeasLoading = false;

  void setGenerateStoryIdeasLoading(bool value) {
    isGenerateStoryIdeasLoading = value;
    notifyListeners();
  }

  Future<void> createStoryIdeas({
    required VoidCallback onStarted,
    required Function(String error) onFailed,
    required BuildContext context,
    bool forceRegenerate = false,
    String? topicId,
    bool onlyIdeas = false,
  }) async {
    if (!forceRegenerate && !_validateCreateStoryInput(context)) return;
    isGenerateStoryIdeasLoading = true;
    _currentStoryIndex = 0;
    _currentStoryPageIndex = 0;
    stories.clear();
    storyIdea = null;
    notifyListeners();
    Future.delayed(Duration(seconds: 2), () {
      onStarted.call();
    });

    if (forceRegenerate) {
      dataToSendCreateStory = {...dataToSendCreateStory};
      dataToSendCreateStory["forceRegenerate"] = true;
      if (topicId != null && topicId.isNotEmpty) {
        dataToSendCreateStory["topicId"] = topicId;
      }
    } else {
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

      if (selectedGoalIds.isNotEmpty) {
        dataToSendCreateStory["goalIds"] = selectedGoalIds.toList();
      }
    }

    final response = await StoryApiService.instance.createStoryIdeas(
      data: dataToSendCreateStory,
    );

    response.fold(
      (l) {
        Logger.error(l.errorMsg);
        isGenerateStoryIdeasLoading = false;
        notifyListeners();
        onFailed.call(l.errorMsg);
      },
      (r) async {
        storyIdea = StoryIdeasModel.fromJson(r["data"]);
        if (storyIdea!.storyIdeas.isEmpty) {
          isGenerateStoryIdeasLoading = false;
          notifyListeners();
          onFailed.call("No story ideas returned");
          return;
        }

        if (storyIdea!.storyIdeas.length > _noOfStories) {
          storyIdea!.storyIdeas = storyIdea!.storyIdeas
              .take(_noOfStories)
              .toList();
        }

        if (onlyIdeas) {
          isGenerateStoryIdeasLoading = false;
          notifyListeners();
          return;
        }

        final createResponse = await StoryApiService.instance.createStory(
          data: {"storyIdeaId": storyIdea!.storyIdeas.first.id},
        );

        createResponse.fold(
          (l) {
            isGenerateStoryIdeasLoading = false;
            notifyListeners();
            onFailed.call(l.errorMsg);
          },
          (r) async {
            final story = StoryModel.fromJson(r["data"]);
            stories.add(story);
            _currentStoryIndex = 0;
            _currentStoryPageIndex = 0;
            isGenerateStoryIdeasLoading = false;
            notifyListeners();
          },
        );
      },
    );
  }

  //todo create story
  Future<void> createStory({
    required VoidCallback onStarted,
    required BuildContext context,
  }) async {
    isCreateStoryLoading = true;
    notifyListeners();
    // onStarted.call();

    final response = await StoryApiService.instance.createStoryIdeas(
      data: dataToSendCreateStory,
    );

    response.fold(
      (l) {
        if (context.mounted) {
          AppToast.error(context, l.errorMsg);
        }
      },
      (r) async {
        storyIdea = StoryIdeasModel.fromJson(r["data"]);
        if (storyIdea!.storyIdeas.isEmpty) {
          if (context.mounted)
            AppToast.error(context, "No story ideas returned");
          return;
        }

        if (storyIdea!.storyIdeas.length > _noOfStories) {
          storyIdea!.storyIdeas = storyIdea!.storyIdeas
              .take(_noOfStories)
              .toList();
        }

        Logger.info(
          "Story Ideas length: ${storyIdea!.storyIdeas.length.toString()}",
        );

        final response = await StoryApiService.instance.createStory(
          data: {"storyIdeaId": storyIdea!.storyIdeas.first.id},
        );
        response.fold(
          (l) {
            if (context.mounted) {
              AppToast.error(context, l.errorMsg);
            }
          },
          (r) {
            final story = StoryModel.fromJson(r["data"]);
            stories.add(story);

            if (context.mounted) {
              context.pushNamed(AppRoutes.storyIdeasScreen.name);
            } else {
              AppRouter.goRouter.pushNamed(AppRoutes.storyIdeasScreen.name);
            }
          },
        );
      },
    );
    isGenerateStoryIdeasLoading = false;
    notifyListeners();
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
        // linkImageToStory(image: createdStoryImages.first["images"]!.first);

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
    storyIdea = null;
    dataToSendCreateStory = {};
    _markingReadStoryIdeaIds.clear();
    _markedReadStoryIdeaIds.clear();
  }

  void clearSessionData() {
    isCreateStoryLoading = false;
    isGenerateSingleStoryLoading = false;
    isGenerateStoryIdeasLoading = false;
    isCreateStoryImageLoading = false;
    _currentStoryIndex = 0;
    _currentStoryPageIndex = 0;
    clareStoryData();
    clearStoryFields();
    notifyListeners();
  }

  bool _validateCreateStoryInput(BuildContext context) {
    if (customReadingDurationCtr.text.trim().isEmpty &&
        selectedReadingDuration.toLowerCase() == AppEnum.custom.name) {
      AppToast.error(context, "Please enter minuets");
      return false;
    }

    if (_selectedTextType.isEmpty) {
      AppToast.error(context, "Please enter Text Type");
      return false;
    }
    if (_selectedAgeRange.isEmpty) {
      AppToast.error(context, "Please enter Age Range");
      return false;
    }
    if (_selectedLanguage.isEmpty) {
      AppToast.error(context, "Please enter Language");
      return false;
    }

    if (selectedReadingDuration.toLowerCase() == AppEnum.custom.name) {
      if (customReadingDurationCtr.text.isEmpty) {
        AppToast.error(context, "Please Enter Minutes");
        return false;
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
      return false;
    }

    if (_noOfStories == 0) {
      AppToast.error(context, "Please enter number of stories");
      return false;
    }

    return true;
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
