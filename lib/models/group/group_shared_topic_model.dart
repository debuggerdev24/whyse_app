class GroupSharedTopic {
  final String shareId;
  final String sharedAt;
  final String sharedBy;
  final SharedTopicDetail topic;

  GroupSharedTopic({
    required this.shareId,
    required this.sharedAt,
    required this.sharedBy,
    required this.topic,
  });

  factory GroupSharedTopic.fromJson(Map<String, dynamic> json) =>
      GroupSharedTopic(
        shareId: json['shareId']?.toString() ?? '',
        sharedAt: json['sharedAt']?.toString() ?? '',
        sharedBy: json['sharedBy']?.toString() ?? '',
        topic: SharedTopicDetail.fromJson(
          Map<String, dynamic>.from(json['topic'] as Map? ?? {}),
        ),
      );
}

class SharedTopicDetail {
  final String id;
  final String title;
  final String thumbnailUrl;
  final SharedTopicReadingProgress readingProgress;
  final List<SharedTopicStory> stories;

  SharedTopicDetail({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.readingProgress,
    required this.stories,
  });

  factory SharedTopicDetail.fromJson(Map<String, dynamic> json) =>
      SharedTopicDetail(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
        readingProgress: json['readingProgress'] is Map
            ? SharedTopicReadingProgress.fromJson(
                Map<String, dynamic>.from(json['readingProgress'] as Map),
              )
            : SharedTopicReadingProgress(totalStories: 0, completedStories: 0),
        stories: json['stories'] is List
            ? (json['stories'] as List)
                .map((e) => SharedTopicStory.fromJson(
                      Map<String, dynamic>.from(e as Map? ?? {}),
                    ))
                .toList()
            : [],
      );
}

class SharedTopicReadingProgress {
  final int totalStories;
  final int completedStories;

  SharedTopicReadingProgress({
    required this.totalStories,
    required this.completedStories,
  });

  factory SharedTopicReadingProgress.fromJson(Map<String, dynamic> json) =>
      SharedTopicReadingProgress(
        totalStories: json['totalStories'] is int
            ? json['totalStories'] as int
            : int.tryParse(json['totalStories']?.toString() ?? '') ?? 0,
        completedStories: json['completedStories'] is int
            ? json['completedStories'] as int
            : int.tryParse(json['completedStories']?.toString() ?? '') ?? 0,
      );
}

class SharedTopicStory {
  final String id;
  final String title;

  SharedTopicStory({required this.id, required this.title});

  factory SharedTopicStory.fromJson(Map<String, dynamic> json) =>
      SharedTopicStory(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
      );
}
