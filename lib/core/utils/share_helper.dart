import 'package:share_plus/share_plus.dart';
import 'package:redstreakapp/core/constants/app_constants.dart';

// Builds the universal link for a story idea (iOS: opens app if installed).
String buildStoryIdeaShareLink(String storyIdeaId) {
  final uri = Uri.https(
    AppConstants.domain,
    AppConstants.storyPath,
    {AppConstants.storyIdeaIdParam: storyIdeaId},
  );
  return uri.toString();
}

// Builds the universal link for a topic (share by topicId).
String buildTopicShareLink(String topicId) {
  final uri = Uri.https(
    AppConstants.domain,
    AppConstants.storyPath,
    {AppConstants.topicIdParam: topicId},
  );
  return uri.toString();
}

// Shares only the story idea link via the platform share sheet (e.g. Messages, Mail).
Future<void> shareStoryIdeaLink({
  required String storyIdeaId,
  String? storyTitle,
}) async {
  final link = buildStoryIdeaShareLink(storyIdeaId);
  await Share.share(link);
}

// Shares the topic link via the platform share sheet (uses topicId).
Future<void> shareTopicLink({
  required String topicId,
}) async {
  final link = buildTopicShareLink(topicId);
  await Share.share(link);
}