import 'package:redstreakapp/core/utils/network_image_url.dart';

class TopicInterest {
    String id;
    String name;

    TopicInterest({required this.id, required this.name});

    factory TopicInterest.fromJson(Map<String, dynamic> json) => TopicInterest(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
    );
}

class SubjectItem {
    String id;
    String name;

    SubjectItem({required this.id, required this.name});

    factory SubjectItem.fromJson(Map<String, dynamic> json) => SubjectItem(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
    );
}

class SubjectsData {
    List<SubjectItem> all;
    List<String> allIds;
    String type;

    SubjectsData({
        required this.all,
        required this.allIds,
        required this.type,
    });

    factory SubjectsData.fromJson(Map<String, dynamic> json) => SubjectsData(
        all: json["all"] is List
            ? (json["all"] as List)
                .map((e) => SubjectItem.fromJson(
                      Map<String, dynamic>.from(e as Map? ?? {}),
                    ))
                .toList()
            : [],
        allIds: json["allIds"] is List
            ? List<String>.from(
                (json["allIds"] as List).map((x) => x.toString()),
              )
            : [],
        type: json["type"]?.toString() ?? "",
    );
}

class StoryIdeaModel {
    String topicId;
    String topicTitle;
    String topicType;
    bool isOwnTopic;
    String topicLearningGoal;
    String topicThumbnailUrl;
    List<StoryIdea> storyIdeas;
    OverallProgress? overallProgress;
    // Top-level generate-mobile fields
    String? promptType;
    String? grade;
    String? mustIncludeWords;
    // Extended topic fields
    List<TopicInterest> topicInterests;
    String? topicCreatedAt;
    String? topicThumbnailSource;
    String? topicThumbnailLicense;
    String? topicThumbnailAttribution;
    String? topicThumbnailSearchEntity;
    // Subjects from data.subjects
    SubjectsData? subjects;

    StoryIdeaModel({
        required this.topicId,
        required this.topicTitle,
        required this.topicType,
        required this.isOwnTopic,
        required this.topicLearningGoal,
        required this.topicThumbnailUrl,
        required this.storyIdeas,
        this.overallProgress,
        this.promptType,
        this.grade,
        this.mustIncludeWords,
        List<TopicInterest>? topicInterests,
        this.topicCreatedAt,
        this.topicThumbnailSource,
        this.topicThumbnailLicense,
        this.topicThumbnailAttribution,
        this.topicThumbnailSearchEntity,
        this.subjects,
    }) : topicInterests = topicInterests ?? [];

    factory StoryIdeaModel.fromJson(Map<String, dynamic> json) => StoryIdeaModel(
        topicId: json["topicId"]?.toString() ?? "",
        topicTitle: json["topicTitle"]?.toString() ?? "",
        topicType: json["topicType"]?.toString() ?? "",
        isOwnTopic: json["isOwnTopic"] == true,
        topicLearningGoal: json["topicLearningGoal"]?.toString() ??
            json["learningGoal"]?.toString() ??
            "",
        topicThumbnailUrl: resolveNetworkImageUrl(
          json["topicThumbnailUrl"]?.toString() ??
              json["thumbnailUrl"]?.toString() ??
              "",
        ),
        storyIdeas: json["storyIdeas"] == null
            ? []
            : List<StoryIdea>.from(
                json["storyIdeas"].map((x) => StoryIdea.fromJson(x)),
              ),
        overallProgress: json["overallProgress"] != null
            ? OverallProgress.fromJson(json["overallProgress"])
            : null,
    );

    factory StoryIdeaModel.fromGenerateMobileJson(Map<String, dynamic> json) {
        final topic = json["topic"] as Map<String, dynamic>? ?? {};
        final progress = json["overallProgress"];
        return StoryIdeaModel(
            topicId: topic["id"]?.toString() ?? "",
            topicTitle: topic["title"]?.toString() ?? "",
            topicType: topic["type"]?.toString() ?? "",
            isOwnTopic: true,
            topicLearningGoal: topic["learningGoal"]?.toString() ?? "",
            topicThumbnailUrl:
                resolveNetworkImageUrl(topic["thumbnailUrl"]?.toString() ?? ""),
            storyIdeas: json["storyIdeas"] == null
                ? []
                : List<StoryIdea>.from(
                    json["storyIdeas"].map((x) => StoryIdea.fromGenerateMobileJson(x)),
                  ),
            overallProgress: progress != null
                ? OverallProgress.fromJson(progress)
                : null,
            promptType: json["promptType"]?.toString(),
            grade: json["grade"]?.toString(),
            mustIncludeWords: json["mustIncludeWords"]?.toString(),
            topicInterests: topic["interests"] is List
                ? (topic["interests"] as List)
                    .map((e) => TopicInterest.fromJson(
                          Map<String, dynamic>.from(e as Map? ?? {}),
                        ))
                    .toList()
                : [],
            topicCreatedAt: topic["createdAt"]?.toString(),
            topicThumbnailSource: topic["thumbnailSource"]?.toString(),
            topicThumbnailLicense: topic["thumbnailLicense"]?.toString(),
            topicThumbnailAttribution: topic["thumbnailAttribution"]?.toString(),
            topicThumbnailSearchEntity: topic["thumbnailSearchEntity"]?.toString(),
            subjects: json["subjects"] is Map
                ? SubjectsData.fromJson(
                    Map<String, dynamic>.from(json["subjects"] as Map),
                  )
                : null,
        );
    }
}

class StoryIdea {
    String id;
    String storyTitle;
    String description;
    String thumbnailUrl;
    int sequenceIndex;
    String grade;
    List<String> tags;
    String age;
    String language,topic,topicType,source,createdOn,updatedAt;
    bool isGenerated;
    bool hasStory;
    ContinueReading? continueReading;
    // Extended fields from generate-mobile response
    String? sampleQuestion;
    List<String> subjectIds;
    List<String> extraSubjectTags;
    String? thumbnailSource;
    String? thumbnailLicense;
    String? thumbnailAttribution;
    String? thumbnailSearchEntity;

    StoryIdea({
        required this.id,
        required this.storyTitle,
        required this.description,
        required this.thumbnailUrl,
        required this.sequenceIndex,
        required this.grade,
        required this.tags,
        required this.age,
        required this.language,
        required this.topic,
        required this.topicType,
        required this.source,
        required this.isGenerated,
        required this.hasStory,
        required this.createdOn,
        required this.updatedAt,
        this.continueReading,
        this.sampleQuestion,
        List<String>? subjectIds,
        List<String>? extraSubjectTags,
        this.thumbnailSource,
        this.thumbnailLicense,
        this.thumbnailAttribution,
        this.thumbnailSearchEntity,
    })  : subjectIds = subjectIds ?? [],
          extraSubjectTags = extraSubjectTags ?? [];

    factory StoryIdea.fromJson(Map<String, dynamic> json) => StoryIdea(
        id: json["id"]?.toString() ?? "",
        storyTitle: json["storyTitle"]?.toString() ?? "",
        description: json["description"]?.toString() ?? "",
        thumbnailUrl: resolveNetworkImageUrl(
          json["thumbnailUrl"]?.toString() ?? "",
        ),
        sequenceIndex: json["sequenceIndex"] is int
            ? json["sequenceIndex"] as int
            : int.tryParse(json["sequenceIndex"]?.toString() ?? "") ?? 0,
        grade: json["grade"]?.toString() ?? "",
        tags: json["tags"] == null
            ? []
            : List<String>.from(json["tags"].map((x) => x.toString())),
        age: json["age"]?.toString() ?? "",
        language: json["language"]?.toString() ?? "",
        topic: json["topic"]?.toString() ?? "",
        topicType: json["topicType"]?.toString() ?? "",
        source: json["source"]?.toString() ?? "",
        isGenerated: json["isGenerated"] == true,
        hasStory: json["hasStory"] == true,
        createdOn: json["createdOn"]?.toString() ?? "",
        updatedAt: json["updatedAt"]?.toString() ?? "",
        continueReading: json["continueReading"] != null
            ? ContinueReading.fromJson(json["continueReading"])
            : null,
    );

    factory StoryIdea.fromGenerateMobileJson(Map<String, dynamic> json) => StoryIdea(
        id: json["id"]?.toString() ?? "",
        storyTitle: json["title"]?.toString() ?? "",
        description: json["description"]?.toString() ?? "",
        thumbnailUrl: resolveNetworkImageUrl(
          json["thumbnailUrl"]?.toString() ?? "",
        ),
        sequenceIndex: json["sequenceIndex"] is int
            ? json["sequenceIndex"] as int
            : int.tryParse(json["sequenceIndex"]?.toString() ?? "") ?? 0,
        grade: "",
        tags: json["tags"] is List
            ? List<String>.from((json["tags"] as List).map((x) => x.toString()))
            : [],
        age: "",
        language: "",
        topic: "",
        topicType: "",
        source: json["source"]?.toString() ?? "",
        isGenerated: json["isGenerated"] == true,
        hasStory: json["isGenerated"] == true,
        createdOn: json["createdAt"]?.toString() ?? "",
        updatedAt: json["createdAt"]?.toString() ?? "",
        continueReading: json["continueReading"] != null
            ? ContinueReading.fromJson(json["continueReading"])
            : null,
        sampleQuestion: json["sampleQuestion"]?.toString(),
        subjectIds: json["subjectIds"] is List
            ? List<String>.from(
                (json["subjectIds"] as List).map((x) => x.toString()),
              )
            : [],
        extraSubjectTags: json["extraSubjectTags"] is List
            ? List<String>.from(
                (json["extraSubjectTags"] as List).map((x) => x.toString()),
              )
            : [],
        thumbnailSource: json["thumbnailSource"]?.toString(),
        thumbnailLicense: json["thumbnailLicense"]?.toString(),
        thumbnailAttribution: json["thumbnailAttribution"]?.toString(),
        thumbnailSearchEntity: json["thumbnailSearchEntity"]?.toString(),
    );
}

class StoryShort {
    String id;
    String title;
    DateTime createdAt;

    StoryShort({
        required this.id,
        required this.title,
        required this.createdAt,
    });

    factory StoryShort.fromJson(Map<String, dynamic> json) => StoryShort(
        id: json["id"],
        title: json["title"],
        createdAt: DateTime.parse(json["createdAt"]),
    );
}

class ContinueReading {
    int pageCount;
    int readPages;
    int remainingPages;
    int? lastPageIndex;
    int continueFromPageIndex;
    int percentComplete;
    String? lastReadAt;
    String? completedAt;
    bool isCompleted;
    QuizProgress? quizProgress;

    ContinueReading({
        required this.pageCount,
        required this.readPages,
        required this.remainingPages,
        this.lastPageIndex,
        required this.continueFromPageIndex,
        required this.percentComplete,
        this.lastReadAt,
        this.completedAt,
        required this.isCompleted,
        this.quizProgress,
    });

    bool get isReadingComplete => pageCount > 0 && readPages >= pageCount;

    /// UI-level completion: a reading is considered completed only when both
    /// reading and quiz are completed. We intentionally do NOT trust the backend
    /// `isCompleted` flag because it can be inconsistent.
    bool get isFullyCompleted {
      final qp = quizProgress;
      if (!isReadingComplete) return false;
      if (qp == null) return false;
      // Guard: backend sometimes sends totalQuestions=0 with isCompleted=true.
      if (qp.totalQuestions <= 0) return false;
      return qp.isCompleted == true;
    }

    factory ContinueReading.fromJson(Map<String, dynamic> json) {
      final pageCount = json["pageCount"] is int
          ? json["pageCount"] as int
          : int.tryParse(json["pageCount"]?.toString() ?? "") ?? 0;
      final readPages = json["readPages"] is int
          ? json["readPages"] as int
          : int.tryParse(json["readPages"]?.toString() ?? "") ?? 0;
      final remainingPages = json["remainingPages"] is int
          ? json["remainingPages"] as int
          : int.tryParse(json["remainingPages"]?.toString() ?? "") ?? 0;
      final lastPageIndex = json["lastPageIndex"] is int
          ? json["lastPageIndex"] as int
          : int.tryParse(json["lastPageIndex"]?.toString() ?? "");
      final continueFromPageIndex = json["continueFromPageIndex"] is int
          ? json["continueFromPageIndex"] as int
          : int.tryParse(json["continueFromPageIndex"]?.toString() ?? "") ?? 0;
      final percentComplete = json["percentComplete"] is int
          ? json["percentComplete"] as int
          : int.tryParse(json["percentComplete"]?.toString() ?? "") ?? 0;
      final lastReadAt = json["lastReadAt"]?.toString();
      final completedAt = json["completedAt"]?.toString();
      final qp = json["quizProgress"] is Map
          ? QuizProgress.fromJson(
              Map<String, dynamic>.from(json["quizProgress"] as Map),
            )
          : null;

      final isReadingComplete = pageCount > 0 && readPages >= pageCount;
      final isQuizComplete =
          qp != null && qp.isCompleted == true && qp.totalQuestions > 0;
      final isCompleted = isReadingComplete && isQuizComplete;

      return ContinueReading(
        pageCount: pageCount,
        readPages: readPages,
        remainingPages: remainingPages,
        lastPageIndex: lastPageIndex,
        continueFromPageIndex: continueFromPageIndex,
        percentComplete: percentComplete,
        lastReadAt: lastReadAt,
        // Keep server completedAt if provided, else null.
        completedAt: isCompleted ? (completedAt ?? qp.completedAt) : null,
        isCompleted: isCompleted,
        quizProgress: qp,
      );
    }
}

class QuizProgress {
    int totalQuestions;
    int correctAnswers;
    bool isCompleted;
    String? completedAt;

    QuizProgress({
        required this.totalQuestions,
        required this.correctAnswers,
        required this.isCompleted,
        this.completedAt,
    });

    factory QuizProgress.fromJson(Map<String, dynamic> json) => QuizProgress(
        totalQuestions: json["totalQuestions"] is int
            ? json["totalQuestions"] as int
            : int.tryParse(json["totalQuestions"]?.toString() ?? "") ?? 0,
        correctAnswers: json["correctAnswers"] is int
            ? json["correctAnswers"] as int
            : int.tryParse(json["correctAnswers"]?.toString() ?? "") ?? 0,
        isCompleted: json["isCompleted"] == true,
        completedAt: json["completedAt"]?.toString(),
    );
}

class OverallProgress {
    int totalStories;
    int generatedStories;
    int completedStories;
    int inProgressStories;
    int notStartedStories;
    int remainingStories;
    int percentComplete;

    OverallProgress({
        required this.totalStories,
        required this.generatedStories,
        required this.completedStories,
        required this.inProgressStories,
        required this.notStartedStories,
        required this.remainingStories,
        required this.percentComplete,
    });

    factory OverallProgress.fromJson(Map<String, dynamic> json) => OverallProgress(
        totalStories: json["totalStories"] ?? 0,
        generatedStories: json["generatedStories"] ?? 0,
        completedStories: json["completedStories"] ?? 0,
        inProgressStories: json["inProgressStories"] ?? 0,
        notStartedStories: json["notStartedStories"] ?? 0,
        remainingStories: json["remainingStories"] ?? 0,
        percentComplete: json["percentComplete"] ?? 0,
    );
}
