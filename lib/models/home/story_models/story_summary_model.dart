class StoryIdeaModel {
    String topicId;
    String topicTitle;
    String topicType;
    bool isOwnTopic;
    List<StoryIdea> storyIdeas;

    StoryIdeaModel({
        required this.topicId,
        required this.topicTitle,
        required this.topicType,
        required this.isOwnTopic,
        required this.storyIdeas,
    });

    factory StoryIdeaModel.fromJson(Map<String, dynamic> json) => StoryIdeaModel(
        topicId: json["topicId"],
        topicTitle: json["topicTitle"],
        topicType: json["topicType"],
        isOwnTopic: json["isOwnTopic"],
        storyIdeas: List<StoryIdea>.from(json["storyIdeas"].map((x) => StoryIdea.fromJson(x))),
    );
}

class StoryIdea {
    String id;
    String storyTitle;
    String description;
    int sequenceIndex;
    String grade;
    List<String> tags;
    String level;
    String age;
    String language,topic,topicType,source,createdOn,updatedAt;
    bool isGenerated;
    bool hasStory;

    StoryIdea({
        required this.id,
        required this.storyTitle,
        required this.description,
        required this.sequenceIndex,
        required this.grade,
        required this.tags,
        required this.level,
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
        id: json["id"],
        storyTitle: json["storyTitle"],
        description: json["description"],
        sequenceIndex: json["sequenceIndex"],
        grade: json["grade"],
        tags: List<String>.from(json["tags"].map((x) => x)),
        level: json["level"],
        age: json["age"],
        language: json["language"],
        topic: json["topic"],
        topicType: json["topicType"],
        source: json["source"],
        isGenerated: json["isGenerated"],
        hasStory: json["hasStory"],
        createdOn: json["createdOn"],
        updatedAt: json["updatedAt"],
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
