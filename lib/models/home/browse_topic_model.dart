import 'package:redstreakapp/core/utils/network_image_url.dart';

class BrowseTopicModel {
  final String id;
  final String topic;
  final String learningGoal;
  final String type;
  final List<String> interests;
  final int noOfStories;
  final int noOfStoriesGenerated;
  final String createdBy;
  final bool isOwnTopic;
  final bool isInMyList;
  final DateTime? createdOn;
  final DateTime? updatedAt;
  final String thumbnailUrl;
  final String thumbnailSource;
  final String thumbnailLicense;
  final String thumbnailAttribution;
  final String thumbnailSearchEntity;

  const BrowseTopicModel({
    required this.id,
    required this.topic,
    required this.learningGoal,
    required this.type,
    required this.interests,
    required this.noOfStories,
    required this.noOfStoriesGenerated,
    required this.createdBy,
    required this.isOwnTopic,
    required this.isInMyList,
    required this.createdOn,
    required this.updatedAt,
    required this.thumbnailUrl,
    required this.thumbnailSource,
    required this.thumbnailLicense,
    required this.thumbnailAttribution,
    required this.thumbnailSearchEntity,
  });

  factory BrowseTopicModel.fromJson(Map<String, dynamic> json) {
    return BrowseTopicModel(
      id: json["id"]?.toString() ?? "",
      topic: json["topic"]?.toString() ?? "",
      learningGoal: json["learningGoal"]?.toString() ?? "",
      type: json["type"]?.toString() ?? "",
      interests: json["interests"] == null
          ? []
          : List<String>.from(
              (json["interests"] as List).map((interest) => interest.toString()),
            ),
      noOfStories: json["noOfStories"] is int
          ? json["noOfStories"] as int
          : int.tryParse(json["noOfStories"]?.toString() ?? "") ?? 0,
      noOfStoriesGenerated: json["noOfStoriesGenerated"] is int
          ? json["noOfStoriesGenerated"] as int
          : int.tryParse(json["noOfStoriesGenerated"]?.toString() ?? "") ?? 0,
      createdBy: json["createdBy"]?.toString() ?? "",
      isOwnTopic: json["isOwnTopic"] == true,
      isInMyList: json["isInMyList"],
      createdOn: DateTime.tryParse(json["createdOn"]?.toString() ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"]?.toString() ?? ""),
      thumbnailUrl:
          resolveNetworkImageUrl(json["thumbnailUrl"]?.toString() ?? ""),
      thumbnailSource: json["thumbnailSource"]?.toString() ?? "",
      thumbnailLicense: json["thumbnailLicense"]?.toString() ?? "",
      thumbnailAttribution: json["thumbnailAttribution"]?.toString() ?? "",
      thumbnailSearchEntity: json["thumbnailSearchEntity"]?.toString() ?? "",
    );
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "topic": topic,
        "learningGoal": learningGoal,
        "type": type,
        "interests": interests,
        "noOfStories": noOfStories,
        "noOfStoriesGenerated": noOfStoriesGenerated,
        "createdBy": createdBy,
        "isOwnTopic": isOwnTopic,
        "isInMyList": isInMyList,
        "createdOn": createdOn?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "thumbnailUrl": thumbnailUrl,
        "thumbnailSource": thumbnailSource,
        "thumbnailLicense": thumbnailLicense,
        "thumbnailAttribution": thumbnailAttribution,
        "thumbnailSearchEntity": thumbnailSearchEntity,
      };

  String get creatorLabel {
    if (isOwnTopic) return "My Topic";
    if (createdBy.toLowerCase() == "admin") return "Whyse Pick";
    return "Community";
  }

  String get storiesCountLabel => "$noOfStories stories";

  String get generatedCountLabel => "$noOfStoriesGenerated generated";

  bool get hasThumbnail => thumbnailUrl.trim().isNotEmpty;

  // bool get canManageMyList => createdBy.toLowerCase() != "self";

  BrowseTopicModel copyWith({
    String? id,
    String? topic,
    String? learningGoal,
    String? type,
    List<String>? interests,
    int? noOfStories,
    int? noOfStoriesGenerated,
    String? createdBy,
    bool? isOwnTopic,
    bool? isInMyList,
    DateTime? createdOn,
    DateTime? updatedAt,
    String? thumbnailUrl,
    String? thumbnailSource,
    String? thumbnailLicense,
    String? thumbnailAttribution,
    String? thumbnailSearchEntity,
  }) {
    return BrowseTopicModel(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      learningGoal: learningGoal ?? this.learningGoal,
      type: type ?? this.type,
      interests: interests ?? this.interests,
      noOfStories: noOfStories ?? this.noOfStories,
      noOfStoriesGenerated: noOfStoriesGenerated ?? this.noOfStoriesGenerated,
      createdBy: createdBy ?? this.createdBy,
      isOwnTopic: isOwnTopic ?? this.isOwnTopic,
      isInMyList: isInMyList ?? this.isInMyList,
      createdOn: createdOn ?? this.createdOn,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      thumbnailSource: thumbnailSource ?? this.thumbnailSource,
      thumbnailLicense: thumbnailLicense ?? this.thumbnailLicense,
      thumbnailAttribution: thumbnailAttribution ?? this.thumbnailAttribution,
      thumbnailSearchEntity: thumbnailSearchEntity ?? this.thumbnailSearchEntity,
    );
  }
}
