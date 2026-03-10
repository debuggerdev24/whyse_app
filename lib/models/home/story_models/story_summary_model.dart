class StoryIdeaModel {
    String topicId;
    String topicTitle;
    String topicType;
    bool isOwnTopic;
    String topicLearningGoal;
    String topicThumbnailUrl;
    List<StoryIdea> storyIdeas;

    StoryIdeaModel({
        required this.topicId,
        required this.topicTitle,
        required this.topicType,
        required this.isOwnTopic,
        required this.topicLearningGoal,
        required this.topicThumbnailUrl,
        required this.storyIdeas,
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
    );
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
