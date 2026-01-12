class TopicModel {
  String id;
  String title;
  String learningGoal;
  dynamic adminPromptId;
  String userId;
  String type;
  List<dynamic> interestIds;
  DateTime createdAt;
  DateTime updatedAt;

  TopicModel({
    required this.id,
    required this.title,
    required this.learningGoal,
    required this.adminPromptId,
    required this.userId,
    required this.type,
    required this.interestIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) => TopicModel(
    id: json["id"],
    title: json["title"],
    learningGoal: json["learningGoal"],
    adminPromptId: json["adminPromptId"],
    userId: json["userId"],
    type: json["type"],
    interestIds: List<dynamic>.from(json["interestIds"].map((x) => x)),
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );
}

class SearchTopicModel {
  String id, title, learningGoal;

  SearchTopicModel({
    required this.title,
    required this.id,
    required this.learningGoal,
  });

  factory SearchTopicModel.fromJson({required Map json}) {
    return SearchTopicModel(
      title: json["title"],
      id: json["id"],
      learningGoal: json["learningGoal"],
    );
  }
}
