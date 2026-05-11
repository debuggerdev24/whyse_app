import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/models/home/story_models/quiz_model.dart';
import 'package:redstreakapp/models/home/story_models/story_idea_model.dart';
import 'package:redstreakapp/models/home/story_models/story_summary_model.dart'
    hide StoryIdea;
import 'package:redstreakapp/models/home/browse_topic_model.dart';
import 'package:redstreakapp/models/home/topic_progress_model.dart';
import '../../core/enums/app_enums.dart';
import '../../core/helper/log_helper.dart';
import '../../models/home/goal_model.dart';
import '../../models/home/interest_model.dart';
import '../../models/home/story_models/get_story_by_idea_response.dart';
import '../../models/home/story_models/story_model.dart';
import '../../models/home/topic_model.dart';
import '../../services/home/home_api_service.dart';
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
  StoryModel? _story;
  StoryIdeasModel? storyIdeas;
  QuizModel? quiz;
  List<StoryQuiz> quizMcqQuestions = [];
  String? quizError;
  bool isCreateQuizLoading = false;
  bool isSubmitQuizLoading = false;

  /// Set when entering story from search; used to show add/remove from my list toggle.
  BrowseTopicModel? _topicFromSearch;
  BrowseTopicModel? get topicFromSearch => _topicFromSearch;

  void setTopicFromSearch(BrowseTopicModel? topic) {
    _topicFromSearch = topic;
    notifyListeners();
  }

  void clearTopicFromSearch() {
    _topicFromSearch = null;
    notifyListeners();
  }

  void updateTopicFromSearchIsInMyList(bool isInMyList) {
    if (_topicFromSearch == null) return;
    _topicFromSearch = _topicFromSearch!.copyWith(isInMyList: isInMyList);
    notifyListeners();
  }

  String? _forceRegenerateTopicId;
  String? get forceRegenerateTopicId => _forceRegenerateTopicId;
  void setForceRegenerateTopicId(String? topicId) {
    _forceRegenerateTopicId = topicId;
    notifyListeners();
  }

  void clearForceRegenerateTopicId() {
    _forceRegenerateTopicId = null;
    notifyListeners();
  }

  List<StoryModel> get stories => _stories;
  StoryModel? get story => _story;
  final List<String> readingDurations = [
    '5 mins',
    '10 mins',
    '20 mins',
    'Custom',
  ];
  final List<String> ageRanges = ["6-8", "9-11", "12-14", "15-17", "18+"];

  //* topics field
  String _selectedTextType = "", _selectedAgeRange = "", _selectedLanguage = "";
  List<TopicModel> topicsList = [];
  List<SearchTopicModel> searchedTopicsList = [];
  final List<String> customTopics = [];
  String selectedTopicId = "",
      selectedTopicTitle = "",
      selectedReadingDuration = "5 mins";
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

  //* interest field
  List<InterestModel> interestsList = [];
  final List<String> customInterestsList = [];
  final Set<String> selectedInterestIds = {}, selectedCustomInterests = {};

  //* goal fields
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
        try {
          final dataMap = r["data"];
          final data = dataMap['userTopics'] ?? dataMap['topics'];
          if (data is List) {
            topicsList = data.map((e) => TopicModel.fromJson(e)).toList();
          }
        } catch (_) {
          topicsList = [];
        }
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

  void toggleApiTopic(String id, String title) {
    if (selectedTopicId == id) {
      selectedTopicId == "";
    } else {
      selectedTopicId = id;
    }
    selectedTopicTitle = title;
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

  /// Set when createStory API fails (e.g. receiveTimeout). Cleared when retrying.
  String? generateStoryError;

  /// Call before navigating to story series so the destination shows shimmer immediately (no close icon).
  // void beginGenerateSingleStoryLoading() {

  // }
  final Set<String> _markingReadStoryIdeaIds = {};
  final Set<String> _markedReadStoryIdeaIds = {};

  bool isMarkingStoryAsRead(String storyIdeaId) =>
      _markingReadStoryIdeaIds.contains(storyIdeaId);

  bool isStoryMarkedAsRead(String storyIdeaId) =>
      _markedReadStoryIdeaIds.contains(storyIdeaId);

  static const Duration _generateStoryTimeout = Duration(minutes: 1);

  Future<void> generateSingleStory({
    required String storyIdeaId,
    required BuildContext context,
    int? insertAtIndex,
    bool showToast = true,
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

    final payload = <String, dynamic>{"storyIdeaId": storyIdeaId};
    const receiveTimeout = _generateStoryTimeout;

    void applyResult(
      Either<ApiException, Map<String, dynamic>> createResponse,
    ) {
      createResponse.fold(
        (l) {
          generateStoryError = l.errorMsg;
          isGenerateSingleStoryLoading = false;
          notifyListeners();
          if (context.mounted) AppToast.error(context, l.errorMsg);
        },
        (r) {
          final data = r["data"];
          if (data == null || data is! Map) {
            generateStoryError = "Invalid story response";
            isGenerateSingleStoryLoading = false;
            notifyListeners();
            return;
          }
          final story = StoryModel.fromJson(Map<String, dynamic>.from(data));
          if (insertAtIndex != null && insertAtIndex >= 0) {
            _addStoryAtIndex(story, insertAtIndex);
            _currentStoryIndex = insertAtIndex;
          } else {
            _stories.add(story);
          }
          isGenerateSingleStoryLoading = false;
          notifyListeners();
        },
      );
    }

    bool isTimeoutError(String? msg) {
      if (msg == null || msg.isEmpty) return false;
      final lower = msg.toLowerCase();
      return lower.contains('timeout') ||
          lower.contains('timed out') ||
          lower.contains('took longer');
    }

    Future<Either<ApiException, Map<String, dynamic>>> doRequest() =>
        StoryApiService.instance.createStory(
          data: payload,
          receiveTimeout: receiveTimeout,
        );

    try {
      Either<ApiException, Map<String, dynamic>> createResponse =
          await doRequest().timeout(
            _generateStoryTimeout,
            onTimeout: () => throw TimeoutException(
              "Story generation took longer than 1 minute",
            ),
          );

      final isTimeout = createResponse.fold(
        (l) => isTimeoutError(l.errorMsg),
        (_) => false,
      );

      if (isTimeout && context.mounted) {
        AppToast.info(
          context: context,
          message: "Taking too long, retrying...",
        );
        try {
          createResponse = await StoryApiService.instance
              .createStory(data: payload, receiveTimeout: receiveTimeout)
              .timeout(
                _generateStoryTimeout,
                onTimeout: () => throw TimeoutException("Retry also timed out"),
              );
        } on TimeoutException {
          generateStoryError =
              "Story generation is taking too long. Please try again.";
          isGenerateSingleStoryLoading = false;
          notifyListeners();
          if (context.mounted) {
            AppToast.error(
              context,
              "Story generation is taking too long. Please try again.",
            );
          }
          return;
        }
      }

      applyResult(createResponse);
    } on TimeoutException {
      if (!context.mounted) {
        isGenerateSingleStoryLoading = false;
        notifyListeners();
        return;
      }
      AppToast.info(context: context, message: "Taking too long, retrying...");
      try {
        final retryResponse = await StoryApiService.instance
            .createStory(data: payload, receiveTimeout: receiveTimeout)
            .timeout(
              _generateStoryTimeout,
              onTimeout: () => throw TimeoutException("Retry also timed out"),
            );
        applyResult(retryResponse);
      } on TimeoutException {
        generateStoryError =
            "Story generation is taking too long. Please try again.";
        isGenerateSingleStoryLoading = false;
        notifyListeners();
        if (context.mounted) {
          AppToast.error(
            context,
            "Story generation is taking too long. Please try again.",
          );
        }
      } catch (e, st) {
        Logger.error("Generate story retry error: $e\n$st");
        generateStoryError = e.toString();
        isGenerateSingleStoryLoading = false;
        notifyListeners();
        if (context.mounted) {
          AppToast.error(context, "Something went wrong. Please try again.");
        }
      }
    } catch (e, st) {
      Logger.error("Generate story error: $e\n$st");
      generateStoryError = e.toString();
      isGenerateSingleStoryLoading = false;
      notifyListeners();
      if (context.mounted) {
        AppToast.error(context, "Something went wrong. Please try again.");
      }
    }
  }

  static StoryModel _placeholderStory() => StoryModel(
    id: '',
    title: '',
    content: '',
    quiz: [],
    pages: [],
    thumbnailUrl: '',
    lessonDuration: 0,
  );

  Future<void> fetchSingleStoryByIdea({
    required String storyIdeaId,
    required BuildContext context,
    int? insertAtIndex,
    VoidCallback? onSuccess,
    bool showToast = false,
    void Function(BuildContext context)? onStoryNotGenerated,
  }) async {
    generateStoryError = null;
    isGenerateSingleStoryLoading = true;
    notifyListeners();
    if (showToast && context.mounted) {
      AppToast.info(
        context: context,
        durationSecond: 2,
        message: "Loading story...",
      );
    }

    final response = await HomeApiService.instance.getStoryByStoryId(
      storyIdea: storyIdeaId,
    );

    response.fold(
      (l) {
        generateStoryError = l.errorMsg;
        isGenerateSingleStoryLoading = false;
        notifyListeners();
        if (context.mounted) AppToast.error(context, l.errorMsg);
      },
      (r) {
        final data = r["data"] is Map
            ? r["data"] as Map<String, dynamic>
            : null;
        final storyData = data?["story"];
        final storyIdeaMap = data?["storyIdea"] is Map
            ? data!["storyIdea"] as Map<String, dynamic>
            : null;
        final isGenerated =
            storyIdeaMap != null && storyIdeaMap["isGenerated"] == true;

        if (storyData == null || storyData is! Map || !isGenerated) {
          generateStoryError = "Story not found or not generated yet.";
          isGenerateSingleStoryLoading = false;
          notifyListeners();
          if (context.mounted) {
            if (onStoryNotGenerated != null) {
              onStoryNotGenerated(context);
            } else {
              AppToast.error(context, "Story not found. Please try again.");
            }
          }
          return;
        }

        try {
          final payload = GetStoryByIdeaData.fromDataMap(
            Map<String, dynamic>.from(data!),
          );
          final index = insertAtIndex ?? 0;
          addStoryFromGetStoryByIdeaData(payload, index);
          isGenerateSingleStoryLoading = false;
          notifyListeners();
          onSuccess?.call();
        } catch (e, st) {
          Logger.error("fetchSingleStoryByIdea parse: $e\n$st");
          generateStoryError = e.toString();
          isGenerateSingleStoryLoading = false;
          notifyListeners();
          if (context.mounted)
            {AppToast.error(context, "Something went wrong. Please try again.");}
        }
      },
    );
  }

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

  /// Sets storyIdea and state from getStoryIdeasByTopicId response (e.g. deep link by topicId). Clears stories and sets current index.
  void setFromStorySummary(StoryIdeaModel summary) {
    final topic = Topic(
      id: summary.topicId,
      title: summary.topicTitle,
      learningGoal: summary.topicLearningGoal,
      interests: [],
      createdAt: DateTime.now(),
      thumbnailUrl: summary.topicThumbnailUrl,
    );
    final storyIdeas = summary.storyIdeas
        .map(
          (s) => StoryIdea(
            id: s.id,
            title: s.storyTitle,
            description: s.description,
            thumbnailUrl: s.thumbnailUrl,
            createdAt: DateTime.tryParse(s.createdOn) ?? DateTime.now(),
            sequenceIndex: s.sequenceIndex,
            isGenerated: s.isGenerated,
          ),
        )
        .toList();
    this.storyIdeas = StoryIdeasModel(
      promptType: "topic",
      grade: null,
      mustIncludeWords: null,
      topic: topic,
      storyIdeas: storyIdeas,
    );
    _stories = [];
    _currentStoryIndex = 0;
    _currentStoryPageIndex = 0;
    notifyListeners();
  }

  /// Converts [GetStoryByIdeaData] (from `GET .../ideas/:id/story`) to [StoryModel] at [index].
  void addStoryFromGetStoryByIdeaData(GetStoryByIdeaData payload, int index) {
    final h = payload.story;
    final meta = h.metadata;
    final m = StoryModel(
      id: h.id,
      title: h.title,
      content: h.content,
      image: null,
      quiz: h.quiz,
      pages: h.pages,
      lessonDuration: h.lessonDuration,
      readingTopic: meta.readingTopic,
      readingLevel: meta.readingLevel,
      readingSkillFocus: meta.readingSkillFocus,
      age: meta.age,
      language: meta.language,
      textType: meta.textType,
      tags: meta.tags,
      createdAt: h.createdAt.toIso8601String(),
      updatedAt: h.updatedAt.toIso8601String(),
      thumbnailUrl: payload.heroThumbnailUrl,
    );
    _addStoryAtIndex(m, index);
    _currentStoryIndex = index;
    notifyListeners();
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
        .map(
          (r) => StoryIdea(
            id: r.storyIdeaId,
            title: r.title,
            description: "",
            thumbnailUrl: r.thumbnailUrl ?? "",
            createdAt: DateTime.now(),
            sequenceIndex: r.priority,
          ),
        )
        .toList();
    this.storyIdeas = StoryIdeasModel(
      promptType: "progress",
      grade: null,
      mustIncludeWords: null,
      topic: topic,
      storyIdeas: storyIdeas,
    );
    _stories = [];
    _currentStoryIndex = 0;
    _currentStoryPageIndex = 0;
    notifyListeners();
  }

  /// Index of a reading item by storyIdeaId in current storyIdea.
  int indexOfReadingByStoryIdeaId(String storyIdeaId) {
    if (storyIdeas == null) return -1;
    final idx = storyIdeas!.storyIdeas.indexWhere((s) => s.id == storyIdeaId);
    return idx;
  }

  bool isGenerateStoryIdeasLoading = false;
  String? generateStoryIdeasError;

  void setGenerateStoryIdeasLoading(bool value) {
    isGenerateStoryIdeasLoading = value;
    notifyListeners();
  }

  Future<void> createStoryIdeas({
    required Function(String error) onFailed,
    required BuildContext context,
    bool forceRegenerate = false,
    String? topicId,
    VoidCallback? onSuccess,
  }) async {
    // if (!forceRegenerate && !_validateCreateStoryInput(context)) return;

    // Derive _lessonDuration from the user's UI selection every time so we
    // don't rely on validateCreateStoryInput (which is currently bypassed).
    if (selectedReadingDuration.toLowerCase() == AppEnum.custom.name) {
      _lessonDuration =
          int.tryParse(customReadingDurationCtr.text.trim()) ?? 0;
    } else {
      _lessonDuration =
          int.tryParse(selectedReadingDuration.split(' ')[0]) ?? 0;
    }

    isGenerateStoryIdeasLoading = true;
    generateStoryIdeasError = null;
    _currentStoryIndex = 0;
    _currentStoryPageIndex = 0;
    stories.clear();
    storyIdeas = null;
    notifyListeners();

    dataToSendCreateStory = {
      "interestIds": selectedInterestIds.toList(),
      (selectedTopicId.isEmpty)
          ? "LessonContentInstructions"
          : "ReadingTopic": (selectedTopicId.isEmpty)
          ? customTopicCtr.text.trim()
          : selectedTopicTitle,
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
    if (forceRegenerate) {
      dataToSendCreateStory["forceRegenerate"] = true;
      if (topicId != null && topicId.isNotEmpty) {
        dataToSendCreateStory["topicId"] = topicId;
      }
      clearForceRegenerateTopicId();
    }
    try {
      final response = await StoryApiService.instance
          .createStoryIdeas(data: dataToSendCreateStory)
          .timeout(
            const Duration(minutes: 2),
            onTimeout: () => Left(
              ApiException(
                errorMsg: "Story ideas are taking too long. Please try again.",
                code: '',
              ),
            ),
          );

      response.fold(
        (l) {
          Logger.error(l.errorMsg);
          generateStoryIdeasError = l.errorMsg;
          onFailed.call(l.errorMsg);
        },
        (r) {
          Logger.info("createStoryIdeas response: ${r["data"].toString()}");
          storyIdeas = StoryIdeasModel.fromJson(r["data"]);

          if (_noOfStories > 0 &&
              storyIdeas!.storyIdeas.length > _noOfStories) {
            storyIdeas!.storyIdeas = storyIdeas!.storyIdeas
                .take(_noOfStories)
                .toList();
          }
          onSuccess?.call();
          notifyListeners();
        },
      );
    } catch (e, st) {
      Logger.error("createStoryIdeas error: $e\n$st");
      generateStoryIdeasError = "Something went wrong. Please try again.";
      onFailed.call("Something went wrong. Please try again.");
    } finally {
      isGenerateStoryIdeasLoading = false;
      notifyListeners();
    }
  }

  //* create story
  Future<void> createStory({
    required VoidCallback onSuccess,
    required Function(String error) onFailed,
    required int selectedIdeaIndex,
  }) async {
    stories.clear();
    if (storyIdeas == null ||
        selectedIdeaIndex < 0 ||
        selectedIdeaIndex >= storyIdeas!.storyIdeas.length) {
      onFailed.call("Please select a valid story idea.");
      return;
    }
    isCreateStoryLoading = true;
    notifyListeners();
    try {
      final response = await StoryApiService.instance
          .createStory(
            data: {"storyIdeaId": storyIdeas!.storyIdeas[selectedIdeaIndex].id},
          )
          .timeout(
            const Duration(minutes: 2),
            onTimeout: () => Left(
              ApiException(
                errorMsg: "Story generation timed out. Please try again.",
                code: '',
              ),
            ),
          );
      response.fold(
        (l) {
          onFailed.call(l.errorMsg);
        },
        (r) {
          final story = StoryModel.fromJson(r["data"]);
          _stories.add(story);
          onSuccess.call();
          notifyListeners();
        },
      );
    } catch (e, st) {
      Logger.error("createStory error: $e\n$st");
      onFailed.call("Something went wrong. Please try again.");
    } finally {
      isCreateStoryLoading = false;
      notifyListeners();
    }
  }

  //* create and quiz
  Future<List<StoryQuiz>?> generateMcqQuiz({
    required String storyId,
    required int quizMcqCount,
    bool replaceExisting = false,
  }) async {
    isCreateQuizLoading = true;
    quizError = null;
    quizMcqQuestions = [];
    notifyListeners();
    try {
      final data = {
        "quizMcqCount": quizMcqCount,
        "replaceExisting": replaceExisting,
      };
      final response = await StoryApiService.instance.createQuiz(
        storyId: storyId,
        data: data,
      );
      List<StoryQuiz>? parsed;
      response.fold(
        (l) {
          Logger.error(l.errorMsg);
          quizError = l.errorMsg;
          parsed = null;
        },
        (r) {
          try {
            final data = r["data"] as Map? ?? {};
            final questionsRaw = (data["questions"] as List?) ?? const [];
            final quizzes = questionsRaw
                .whereType<Map>()
                .map((e) => StoryQuiz.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            quizMcqQuestions = quizzes;
            quiz = QuizModel.fromJson(
              Map<String, dynamic>.from(data),
            );
            parsed = quizzes;
          } catch (e, st) {
            Logger.error("Quiz parse error: $e\n$st");
            quizError = "Unable to parse quiz.";
            parsed = null;
          }
        },
      );
      return parsed;
    } finally {
      isCreateQuizLoading = false;
      notifyListeners();
    }
  }

  /// Backward compatible wrapper used by `EnterQuizNumbersScreen`.
  /// The mobile API currently supports MCQ generation; other counts are ignored.
  Future<bool> createQuiz({
    required String storyId,
    required int noOfMcq,
    required int noOfOpenQuestions,
    required int noOfTrueFalse,
    bool replaceExisting = false,
  }) async {
    final result = await generateMcqQuiz(
      storyId: storyId,
      quizMcqCount: noOfMcq,
      replaceExisting: replaceExisting,
    );
    return result != null && result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> submitQuizResult({
    required String storyId,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    isSubmitQuizLoading = true;
    quizError = null;
    notifyListeners();
    try {
      final response = await StoryApiService.instance.submitQuiz(
        storyId: storyId,
        data: {
          "correctAnswers": correctAnswers,
          "totalQuestions": totalQuestions,
        },
      );
      Map<String, dynamic>? parsed;
      response.fold(
        (l) {
          quizError = l.errorMsg;
          parsed = null;
        },
        (r) {
          final data = r["data"];
          parsed = data is Map ? Map<String, dynamic>.from(data) : null;
        },
      );
      return parsed;
    } finally {
      isSubmitQuizLoading = false;
      notifyListeners();
    }
  }

  Future<void> getQuiz({required String storyId}) async {
    quiz = null;
    notifyListeners();
    final response = await StoryApiService.instance.getQuiz(storyId: storyId);
    response.fold(
      (l) {
        Logger.error(l.errorMsg);
      },
      (r) {
        if (r["data"]["questions"].isEmpty) {
          // createQuiz(
          //   storyId: storyId,
          //   noOfMcq: 1,
          //   noOfOpenQuestions: 1,
          //   noOfTrueFalse: 1,
          // );
          return;
        }
        quiz = QuizModel.fromJson(r["data"]);
        notifyListeners();
      },
    );
  }

  void clearStoryFields() {
    selectedGoalIds.clear();
    selectedInterestIds.clear();
    selectedTopicId = "";
    selectedTopicTitle = "";
    customTopicCtr.clear();
    _selectedLanguage = "";
    _selectedTextType = "";
    _selectedAgeRange = "";
    _noOfStories = 0;
    selectedReadingDuration = "5 mins";
    notifyListeners();
  }

  void clareStoryData() {
    createdStoryImages.clear();
    stories.clear();
    storyIdeas = null;
    dataToSendCreateStory = {};
    _markingReadStoryIdeaIds.clear();
    _markedReadStoryIdeaIds.clear();
  }

  void clearSessionData() {
    isCreateStoryLoading = false;
    isGenerateSingleStoryLoading = false;
    isGenerateStoryIdeasLoading = false;
    generateStoryIdeasError = null;
    isCreateQuizLoading = false;
    _currentStoryIndex = 0;
    _currentStoryPageIndex = 0;
    clareStoryData();
    clearStoryFields();
    notifyListeners();
  }

  bool validateCreateStoryInput(BuildContext context) =>
      _validateCreateStoryInput(context);

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
