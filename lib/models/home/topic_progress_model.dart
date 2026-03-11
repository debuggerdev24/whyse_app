/// API: GET /story/topics/:topicId/progress
class TopicProgressModel {
  final TopicProgressTopic topic;
  final String role;
  final TopicProgressProgress progress;
  final TopicProgressReadingItem? resume;
  final TopicProgressReadingItem? startOver;
  final List<TopicProgressReadingItem> readings;

  const TopicProgressModel({
    required this.topic,
    required this.role,
    required this.progress,
    this.resume,
    this.startOver,
    required this.readings,
  });

  factory TopicProgressModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] is Map
        ? Map<String, dynamic>.from(json["data"] as Map)
        : json;

    return TopicProgressModel(
      topic: TopicProgressTopic.fromJson(
        Map<String, dynamic>.from((data["topic"] ?? {}) as Map),
      ),
      role: data["role"]?.toString() ?? "",
      progress: TopicProgressProgress.fromJson(
        Map<String, dynamic>.from((data["progress"] ?? {}) as Map),
      ),
      resume: data["resume"] != null
          ? TopicProgressReadingItem.fromJson(
              Map<String, dynamic>.from(data["resume"] as Map))
          : null,
      startOver: data["startOver"] != null
          ? TopicProgressReadingItem.fromJson(
              Map<String, dynamic>.from(data["startOver"] as Map))
          : null,
      readings: data["readings"] is List
          ? (data["readings"] as List)
              .map((e) => TopicProgressReadingItem.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : [],
    );
  }

  bool get hasResume => resume != null && (resume!.storyIdeaId.isNotEmpty);
}

class TopicProgressTopic {
  final String id;
  final String title;
  final String learningGoal;
  final String type;
  final String thumbnailUrl;
  final String thumbnailSource;
  final String thumbnailLicense;
  final String thumbnailAttribution;
  final String thumbnailSearchEntity;
  final bool isInMyList;
  final bool isOwner;

  const TopicProgressTopic({
    required this.id,
    required this.title,
    required this.learningGoal,
    required this.type,
    required this.thumbnailUrl,
    this.thumbnailSource = "",
    this.thumbnailLicense = "",
    this.thumbnailAttribution = "",
    this.thumbnailSearchEntity = "",
    this.isInMyList = false,
    this.isOwner = false,
  });

  factory TopicProgressTopic.fromJson(Map<String, dynamic> json) {
    return TopicProgressTopic(
      id: json["id"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "",
      learningGoal: json["learningGoal"]?.toString() ?? "",
      type: json["type"]?.toString() ?? "",
      thumbnailUrl: json["thumbnailUrl"]?.toString() ?? "",
      thumbnailSource: json["thumbnailSource"]?.toString() ?? "",
      thumbnailLicense: json["thumbnailLicense"]?.toString() ?? "",
      thumbnailAttribution: json["thumbnailAttribution"]?.toString() ?? "",
      thumbnailSearchEntity: json["thumbnailSearchEntity"]?.toString() ?? "",
      isInMyList: json["isInMyList"] == true,
      isOwner: json["isOwner"] == true,
    );
  }
}

class TopicProgressProgress {
  final int totalReadings;
  final int completedReadings;
  final int percentComplete;
  final String status;

  const TopicProgressProgress({
    required this.totalReadings,
    required this.completedReadings,
    required this.percentComplete,
    required this.status,
  });

  factory TopicProgressProgress.fromJson(Map<String, dynamic> json) {
    return TopicProgressProgress(
      totalReadings: _intFrom(json["totalReadings"]),
      completedReadings: _intFrom(json["completedReadings"]),
      percentComplete: _intFrom(json["percentComplete"]),
      status: json["status"]?.toString() ?? "",
    );
  }
}

int _intFrom(dynamic v) {
  if (v is int) return v;
  if (v == null) return 0;
  return int.tryParse(v.toString()) ?? 0;
}

class TopicProgressReadingItem {
  final String storyIdeaId;
  final String title;
  final int priority;
  final bool isGenerated;
  final String? storyId;
  final String? storyTitle;
  final String? thumbnailUrl;

  const TopicProgressReadingItem({
    required this.storyIdeaId,
    required this.title,
    required this.priority,
    required this.isGenerated,
    this.storyId,
    this.storyTitle,
    this.thumbnailUrl,
  });

  factory TopicProgressReadingItem.fromJson(Map<String, dynamic> json) {
    return TopicProgressReadingItem(
      storyIdeaId: json["storyIdeaId"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "",
      priority: _intFrom(json["priority"]),
      isGenerated: json["isGenerated"] == true,
      storyId: json["storyId"]?.toString(),
      storyTitle: json["storyTitle"]?.toString(),
      thumbnailUrl: json["thumbnailUrl"]?.toString(),
    );
  }
}
