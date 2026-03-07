class CreatedStoryTopicsModel {
    String id,topic,learningGoal,type,updatedAt,createdOn,createdBy,thumbnailUrl;
    List<String> interests;
    int noOfStories,noOfStoriesGenerated;
    bool isOwnTopic;
    

    CreatedStoryTopicsModel({
        required this.id,
        required this.topic,
        required this.learningGoal,
        required this.type,
        required this.interests,
        required this.noOfStories,
        required this.noOfStoriesGenerated,
        required this.createdBy,
        required this.isOwnTopic,
        required this.createdOn,
        required this.updatedAt,
        required this.thumbnailUrl,
    });

    factory CreatedStoryTopicsModel.fromJson(Map<String, dynamic> json) => CreatedStoryTopicsModel(
        id: json["id"],
        topic: json["topic"],
        learningGoal: json["learningGoal"],
        type: json["type"],
        interests: List<String>.from(json["interests"].map((x) => x)),
        noOfStories: json["noOfStories"],
        noOfStoriesGenerated: json["noOfStoriesGenerated"],
        createdBy: json["createdBy"],
        isOwnTopic: json["isOwnTopic"],
        createdOn: json["createdOn"],
        updatedAt: json["updatedAt"],
        thumbnailUrl: json["thumbnailUrl"],
    );
}
