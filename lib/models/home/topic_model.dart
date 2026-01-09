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

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "learningGoal": learningGoal,
    "adminPromptId": adminPromptId,
    "userId": userId,
    "type": type,
    "interestIds": List<dynamic>.from(interestIds.map((x) => x)),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}
