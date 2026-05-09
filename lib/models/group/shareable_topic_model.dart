import 'package:redstreakapp/core/utils/network_image_url.dart';

class ShareableTopicItem {
  final String id;
  final String title;
  final String type;
  final String? thumbnailUrl;
  final bool isOwnTopic;
  final bool isSavedTopic;
  final ShareableReadingProgress readingProgress;

  const ShareableTopicItem({
    required this.id,
    required this.title,
    required this.type,
    this.thumbnailUrl,
    required this.isOwnTopic,
    required this.isSavedTopic,
    required this.readingProgress,
  });

  factory ShareableTopicItem.fromJson(Map<String, dynamic> json) {
    return ShareableTopicItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      thumbnailUrl:
          resolveNullableNetworkImageUrl(json['thumbnailUrl']?.toString()),
      isOwnTopic: json['isOwnTopic'] == true,
      isSavedTopic: json['isSavedTopic'] == true,
      readingProgress: ShareableReadingProgress.fromJson(
        json['readingProgress'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class ShareableReadingProgress {
  final int completedReadings;
  final int totalReadings;
  final int inProgressReadings;
  final int notStartedReadings;
  final String progressLabel;

  const ShareableReadingProgress({
    required this.completedReadings,
    required this.totalReadings,
    required this.inProgressReadings,
    required this.notStartedReadings,
    required this.progressLabel,
  });

  factory ShareableReadingProgress.fromJson(Map<String, dynamic> json) {
    return ShareableReadingProgress(
      completedReadings: json['completedReadings'] as int? ?? 0,
      totalReadings: json['totalReadings'] as int? ?? 0,
      inProgressReadings: json['inProgressReadings'] as int? ?? 0,
      notStartedReadings: json['notStartedReadings'] as int? ?? 0,
      progressLabel: json['progressLabel']?.toString() ?? '',
    );
  }
}
