import 'package:redstreakapp/core/utils/network_image_url.dart';

class TopicModel {
  String id,title,learningGoal;
  dynamic adminPromptId;
  String userId,type,thumbnailUrl;
  List<dynamic> interestIds;
  DateTime createdAt,updatedAt;

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
    required this.thumbnailUrl,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) => TopicModel(
    id: json["id"],
    title: json["title"] ?? json["topic"] ?? "",
    learningGoal: json["learningGoal"] ?? "",
    adminPromptId: json["adminPromptId"],
    userId: json["userId"] ?? "",
    type: json["type"] ?? "",
    interestIds: json["interestIds"] != null
        ? List<dynamic>.from(json["interestIds"].map((x) => x))
        : [],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    thumbnailUrl: resolveNetworkImageUrl(json["thumbnailUrl"]?.toString() ?? ""),
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
