import 'package:redstreakapp/core/utils/network_image_url.dart';

class SavedSeriesItem {
  final String savedAt;
  final SavedTopicDetail topic;

  SavedSeriesItem({
    required this.savedAt,
    required this.topic,
  });

  factory SavedSeriesItem.fromJson(Map<String, dynamic> json) => SavedSeriesItem(
    savedAt: json["savedAt"]?.toString() ?? "",
    topic: SavedTopicDetail.fromJson(
      json["topic"] as Map<String, dynamic>? ?? {},
    ),
  );
}

class SavedTopicDetail {
  final String id;
  final String title;
  final String learningGoal;
  final String type;
  final String thumbnailUrl;
  final String createdAt;
  final int storiesCount;
  final List<SavedStoryIdea> storyIdeas;

  SavedTopicDetail({
    required this.id,
    required this.title,
    required this.learningGoal,
    required this.type,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.storiesCount,
    required this.storyIdeas,
  });

  factory SavedTopicDetail.fromJson(Map<String, dynamic> json) => SavedTopicDetail(
    id: json["id"]?.toString() ?? "",
    title: json["title"]?.toString() ?? "",
    learningGoal: json["learningGoal"]?.toString() ?? "",
    type: json["type"]?.toString() ?? "",
    thumbnailUrl: resolveNetworkImageUrl(json["thumbnailUrl"]?.toString() ?? ""),
    createdAt: json["createdAt"]?.toString() ?? "",
    storiesCount: json["storiesCount"] ?? 0,
    storyIdeas: json["storyIdeas"] == null
        ? []
        : List<SavedStoryIdea>.from(
            (json["storyIdeas"] as List).map((x) => SavedStoryIdea.fromJson(x)),
          ),
  );
}

class SavedStoryIdea {
  final String id;
  final String title;
  final String description;
  final int sequenceIndex;
  final bool isGenerated;
  final String thumbnailUrl;
  final String createdAt;

  SavedStoryIdea({
    required this.id,
    required this.title,
    required this.description,
    required this.sequenceIndex,
    required this.isGenerated,
    required this.thumbnailUrl,
    required this.createdAt,
  });

  factory SavedStoryIdea.fromJson(Map<String, dynamic> json) => SavedStoryIdea(
    id: json["id"]?.toString() ?? "",
    title: json["title"]?.toString() ?? "",
    description: json["description"]?.toString() ?? "",
    sequenceIndex: json["sequenceIndex"] ?? 0,
    isGenerated: json["isGenerated"] == true,
    thumbnailUrl: resolveNetworkImageUrl(json["thumbnailUrl"]?.toString() ?? ""),
    createdAt: json["createdAt"]?.toString() ?? "",
  );
}
