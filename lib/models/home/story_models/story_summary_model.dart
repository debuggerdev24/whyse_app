class StoryIdeaModel {
    String topicId;
    String topicTitle;
    String topicType;
    bool isOwnTopic;
    String topicLearningGoal;
    String topicThumbnailUrl;
    List<StoryIdea> storyIdeas;
    OverallProgress? overallProgress;

    StoryIdeaModel({
        required this.topicId,
        required this.topicTitle,
        required this.topicType,
        required this.isOwnTopic,
        required this.topicLearningGoal,
        required this.topicThumbnailUrl,
        required this.storyIdeas,
        this.overallProgress,
    });

    factory StoryIdeaModel.fromJson(Map<String, dynamic> json) => StoryIdeaModel(
        topicId: json["topicId"]?.toString() ?? "",
        topicTitle: json["topicTitle"]?.toString() ?? "",
        topicType: json["topicType"]?.toString() ?? "",
        isOwnTopic: json["isOwnTopic"] == true,
        topicLearningGoal: json["topicLearningGoal"]?.toString() ??
            json["learningGoal"]?.toString() ??
            "",
        topicThumbnailUrl: json["topicThumbnailUrl"]?.toString() ??
            json["thumbnailUrl"]?.toString() ??
            "",
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
            topicThumbnailUrl: topic["thumbnailUrl"]?.toString() ?? "",
            storyIdeas: json["storyIdeas"] == null
                ? []
                : List<StoryIdea>.from(
                    json["storyIdeas"].map((x) => StoryIdea.fromGenerateMobileJson(x)),
                  ),
            overallProgress: progress != null
                ? OverallProgress.fromJson(progress)
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
    });

    factory StoryIdea.fromJson(Map<String, dynamic> json) => StoryIdea(
        id: json["id"]?.toString() ?? "",
        storyTitle: json["storyTitle"]?.toString() ?? "",
        description: json["description"]?.toString() ?? "",
        thumbnailUrl: json["thumbnailUrl"]?.toString() ?? "",
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
        thumbnailUrl: json["thumbnailUrl"]?.toString() ?? "",
        sequenceIndex: json["sequenceIndex"] is int
            ? json["sequenceIndex"] as int
            : int.tryParse(json["sequenceIndex"]?.toString() ?? "") ?? 0,
        grade: "",
        tags: json["tags"] == null
            ? []
            : List<String>.from(json["tags"].map((x) => x.toString())),
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
    });

    factory ContinueReading.fromJson(Map<String, dynamic> json) => ContinueReading(
        pageCount: json["pageCount"] ?? 0,
        readPages: json["readPages"] ?? 0,
        remainingPages: json["remainingPages"] ?? 0,
        lastPageIndex: json["lastPageIndex"],
        continueFromPageIndex: json["continueFromPageIndex"] ?? 0,
        percentComplete: json["percentComplete"] ?? 0,
        lastReadAt: json["lastReadAt"]?.toString(),
        completedAt: json["completedAt"]?.toString(),
        isCompleted: json["isCompleted"] == true,
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
