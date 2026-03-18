class StoryIdeasModel {
    String promptType;
    dynamic grade;
    dynamic mustIncludeWords;
    Topic topic;
    List<StoryIdea> storyIdeas;

    StoryIdeasModel({
        required this.promptType,
        required this.grade,
        required this.mustIncludeWords,
        required this.topic,
        required this.storyIdeas,
    });

    factory StoryIdeasModel.fromJson(Map<String, dynamic> json) => StoryIdeasModel(
        promptType: json["promptType"],
        grade: json["grade"],
        mustIncludeWords: json["mustIncludeWords"],
        topic: Topic.fromJson(json["topic"]),
        storyIdeas: List<StoryIdea>.from(json["storyIdeas"].map((x) => StoryIdea.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "promptType": promptType,
        "grade": grade,
        "mustIncludeWords": mustIncludeWords,
        "topic": topic.toJson(),
        "storyIdeas": List<dynamic>.from(storyIdeas.map((x) => x.toJson())),
    };
}

class StoryIdea {
    String id;
    String title;
    String description;
    dynamic thumbnailUrl;
    DateTime createdAt;
    int sequenceIndex;
    /// When false, story is not generated yet (e.g. shared link). UI can show lock icon.
    bool isGenerated;

    StoryIdea({
        required this.id,
        required this.title,
        required this.description,
        required this.thumbnailUrl,
        required this.createdAt,
        required this.sequenceIndex,
        this.isGenerated = true,
    });

    factory StoryIdea.fromJson(Map<String, dynamic> json) => StoryIdea(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        thumbnailUrl: json["thumbnailUrl"],
        createdAt: DateTime.parse(json["createdAt"]),
        sequenceIndex: json["sequenceIndex"],
        isGenerated: json["isGenerated"] != false,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "thumbnailUrl": thumbnailUrl,
        "createdAt": createdAt.toIso8601String(),
        "sequenceIndex": sequenceIndex,
        "isGenerated": isGenerated,
    };
}

class Topic {
    String id;
    String title;
    String learningGoal;
    List<Interest> interests;
    DateTime createdAt;
    String thumbnailUrl;

    Topic({
        required this.id,
        required this.title,
        required this.learningGoal,
        required this.interests,
        required this.createdAt,
        required this.thumbnailUrl,
    });

    factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: json["id"],
        title: json["title"],
        learningGoal: json["learningGoal"],
        interests: List<Interest>.from(json["interests"].map((x) => Interest.fromJson(x))),
        createdAt: DateTime.parse(json["createdAt"]),
        thumbnailUrl: json["thumbnailUrl"] ?? "",
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "learningGoal": learningGoal,
        "interests": List<dynamic>.from(interests.map((x) => x.toJson())),
        "createdAt": createdAt.toIso8601String(),
        "thumbnailUrl": thumbnailUrl,
    };
}

class Interest {
    String id;
    String name;

    Interest({
        required this.id,
        required this.name,
    });

    factory Interest.fromJson(Map<String, dynamic> json) => Interest(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
