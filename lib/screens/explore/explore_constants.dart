import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/models/home/browse_topic_model.dart';
import 'package:redstreakapp/models/curiosity_reading/curiosity_reading_model.dart';

enum ExploreMainTab { series, spark }

String iconForInterestName(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('adventure')) return AppAssets.adventure;
  if (lower.contains('mystery')) return AppAssets.mystery;
  if (lower.contains('science')) return AppAssets.science;
  if (lower.contains('fantasy')) return AppAssets.fantancy;
  if (lower.contains('history')) return AppAssets.histoy;
  if (lower.contains('nature') || lower.contains('animal')) {
    return AppAssets.nature;
  }
  if (lower.contains('comic')) return AppAssets.comics;
  return AppAssets.adventure;
}

bool matchesInterestLabel(String topicInterest, String filterLabel) {
  final interest = topicInterest.toLowerCase().trim();
  final filter = filterLabel.toLowerCase().trim();
  if (interest.isEmpty || filter.isEmpty) return false;
  if (interest == filter) return true;
  if (interest.contains(filter) || filter.contains(interest)) return true;

  final filterKeyword = filter.split(RegExp(r'[&\s]+')).first;
  final interestKeyword = interest.split(RegExp(r'[&\s]+')).first;
  return filterKeyword == interestKeyword ||
      interest.contains(filterKeyword) ||
      filter.contains(interestKeyword);
}

List<BrowseTopicModel> topicsForInterest(
  List<BrowseTopicModel> topics,
  String interestLabel,
) {
  return topics
      .where(
        (topic) => topic.interests.any(
          (interest) => matchesInterestLabel(interest, interestLabel),
        ),
      )
      .toList();
}

List<BrowseTopicModel> recommendedSeriesTopics(
  List<BrowseTopicModel> topics,
  List<String> userInterests,
) {
  if (topics.isEmpty) return [];

  final matched = topics.where((topic) {
    return topic.interests.any(
      (interest) => userInterests.any(
        (userInterest) => matchesInterestLabel(interest, userInterest),
      ),
    );
  }).toList();

  if (matched.isNotEmpty) return matched.take(10).toList();
  return topics.take(10).toList();
}

List<BrowseTopicModel> popularSeriesTopics(List<BrowseTopicModel> topics) {
  final sorted = [...topics]
    ..sort(
      (a, b) => b.noOfStoriesGenerated.compareTo(a.noOfStoriesGenerated),
    );
  return sorted.take(10).toList();
}

List<Reading> sparkReadingsForInterest(
  List<Reading> readings,
  String interestLabel,
) {
  return readings
      .where(
        (reading) => matchesInterestLabel(reading.interestName, interestLabel),
      )
      .toList();
}

List<Reading> freshSparkReadings(
  List<Reading> readings,
  List<String> userInterests,
) {
  if (userInterests.isEmpty) {
    return readings.take(10).toList();
  }

  return readings
      .where(
        (reading) => !userInterests.any(
          (interest) => matchesInterestLabel(reading.interestName, interest),
        ),
      )
      .toList();
}

String seriesReadingsLabel(BrowseTopicModel topic) {
  final read = topic.noOfStoriesGenerated;
  final total = topic.noOfStories > 0 ? topic.noOfStories : read;
  return '$read out of $total Readings';
}
