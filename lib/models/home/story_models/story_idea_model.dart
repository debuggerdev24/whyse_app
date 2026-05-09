import 'package:redstreakapp/core/utils/network_image_url.dart';

class StoryIdeasModel {
  String promptType;
  dynamic grade;
  dynamic mustIncludeWords;
  Topic topic;
  List<StoryIdea> storyIdeas;
  // Subjects from the "subjects" block in the generate-mobile response.
  List<SubjectItem> subjects;

  StoryIdeasModel({
    required this.promptType,
    required this.grade,
    required this.mustIncludeWords,
    required this.topic,
    required this.storyIdeas,
    List<SubjectItem>? subjects,
  }) : subjects = subjects ?? [];

  factory StoryIdeasModel.fromJson(
    Map<String, dynamic> json,
  ) => StoryIdeasModel(
    promptType: json["promptType"]?.toString() ?? "",
    grade: json["grade"],
    mustIncludeWords: json["mustIncludeWords"],
    topic: Topic.fromJson(
      json["topic"] is Map
          ? Map<String, dynamic>.from(json["topic"] as Map)
          : <String, dynamic>{},
    ),
    storyIdeas: json["storyIdeas"] is List
        ? List<StoryIdea>.from(
            (json["storyIdeas"] as List).map(
              (x) => StoryIdea.fromJson(
                x is Map ? Map<String, dynamic>.from(x) : <String, dynamic>{},
              ),
            ),
          )
        : [],
    subjects: () {
      final s = json["subjects"];
      if (s is Map) {
        final all = s["all"];
        if (all is List) {
          return all
              .map(
                (x) => SubjectItem.fromJson(
                  x is Map ? Map<String, dynamic>.from(x) : <String, dynamic>{},
                ),
              )
              .toList();
        }
      }
      return <SubjectItem>[];
    }(),
  );
}

class StoryIdea {
  String id;
  String title;
  String description;
  dynamic thumbnailUrl;
  DateTime createdAt;
  int sequenceIndex;
  List<String> tags;

  /// When false, story is not generated yet (e.g. shared link). UI can show lock icon.
  bool isGenerated;

  StoryIdea({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.sequenceIndex,
    List<String>? tags,
    this.isGenerated = true,
  }) : tags = tags ?? [];

  factory StoryIdea.fromJson(Map<String, dynamic> json) => StoryIdea(
    id: json["id"]?.toString() ?? "",
    title: json["title"]?.toString() ?? "",
    description: json["description"]?.toString() ?? "",
    thumbnailUrl: resolveNetworkImageUrl(json["thumbnailUrl"]?.toString() ?? ""),
    createdAt: json["createdAt"] != null
        ? DateTime.tryParse(json["createdAt"].toString()) ?? DateTime.now()
        : DateTime.now(),
    sequenceIndex: json["sequenceIndex"] is int
        ? json["sequenceIndex"] as int
        : int.tryParse(json["sequenceIndex"]?.toString() ?? "") ?? 0,
    tags: json["tags"] is List
        ? List<String>.from((json["tags"] as List).map((x) => x.toString()))
        : [],
    isGenerated: json["isGenerated"] != false,
  );
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
    id: json["id"]?.toString() ?? "",
    title: json["title"]?.toString() ?? "",
    learningGoal: json["learningGoal"]?.toString() ?? "",
    interests: json["interests"] is List
        ? List<Interest>.from(
            (json["interests"] as List).map(
              (x) => Interest.fromJson(
                x is Map ? Map<String, dynamic>.from(x) : <String, dynamic>{},
              ),
            ),
          )
        : [],
    createdAt: json["createdAt"] != null
        ? DateTime.tryParse(json["createdAt"].toString()) ?? DateTime.now()
        : DateTime.now(),
    thumbnailUrl: resolveNetworkImageUrl(json["thumbnailUrl"]?.toString() ?? ""),
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

  Interest({required this.id, required this.name});

  factory Interest.fromJson(Map<String, dynamic> json) => Interest(
    id: json["id"]?.toString() ?? "",
    name: json["name"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class SubjectItem {
  String id;
  String name;

  SubjectItem({required this.id, required this.name});

  factory SubjectItem.fromJson(Map<String, dynamic> json) => SubjectItem(
    id: json["id"]?.toString() ?? "",
    name: json["name"]?.toString() ?? "",
  );
}
