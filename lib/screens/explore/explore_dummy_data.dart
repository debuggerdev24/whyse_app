import 'package:redstreakapp/models/home/browse_topic_model.dart';

class ExploreDummySection {
  const ExploreDummySection({
    required this.title,
    required this.topics,
  });

  final String title;
  final List<BrowseTopicModel> topics;
}

BrowseTopicModel exploreDummyTopic({
  required String id,
  required String topic,
  required String thumbnailUrl,
  int generated = 0,
  int total = 50,
  List<String> interests = const [],
}) {
  return BrowseTopicModel(
    id: id,
    topic: topic,
    learningGoal: '',
    type: 'story',
    interests: interests,
    noOfStories: total,
    noOfStoriesGenerated: generated,
    createdBy: 'admin',
    isOwnTopic: false,
    isInMyList: false,
    createdOn: null,
    updatedAt: null,
    thumbnailUrl: thumbnailUrl,
    thumbnailSource: '',
    thumbnailLicense: '',
    thumbnailAttribution: '',
    thumbnailSearchEntity: '',
  );
}

List<ExploreDummySection> exploreDummySeriesSections() {
  return [
    ExploreDummySection(
      title: 'For You',
      topics: [
        exploreDummyTopic(
          id: 'for-you-1',
          topic: 'Nature',
          thumbnailUrl: 'https://picsum.photos/seed/explore-nature/480/360',
        ),
        exploreDummyTopic(
          id: 'for-you-2',
          topic: 'Space',
          thumbnailUrl: 'https://picsum.photos/seed/explore-space/480/360',
          generated: 3,
        ),
        exploreDummyTopic(
          id: 'for-you-3',
          topic: 'Global Cultures',
          thumbnailUrl: 'https://picsum.photos/seed/explore-cultures/480/360',
          total: 1,
        ),
      ],
    ),
    ExploreDummySection(
      title: 'Adventure Stories & Fiction',
      topics: [
        exploreDummyTopic(
          id: 'adventure-1',
          topic: 'Lost Island Quest',
          thumbnailUrl: 'https://picsum.photos/seed/explore-adventure-1/480/360',
          generated: 2,
          total: 12,
          interests: ['Adventure Stories & Fiction'],
        ),
        exploreDummyTopic(
          id: 'adventure-2',
          topic: 'The Hidden Map',
          thumbnailUrl: 'https://picsum.photos/seed/explore-adventure-2/480/360',
          total: 20,
          interests: ['Adventure Stories & Fiction'],
        ),
      ],
    ),
    ExploreDummySection(
      title: 'Animals',
      topics: [
        exploreDummyTopic(
          id: 'animals-1',
          topic: 'Rainforest Friends',
          thumbnailUrl: 'https://picsum.photos/seed/explore-animals-1/480/360',
          generated: 1,
          total: 15,
          interests: ['Animals'],
        ),
        exploreDummyTopic(
          id: 'animals-2',
          topic: 'Ocean Life',
          thumbnailUrl: 'https://picsum.photos/seed/explore-animals-2/480/360',
          generated: 4,
          total: 30,
          interests: ['Animals'],
        ),
        exploreDummyTopic(
          id: 'animals-3',
          topic: 'Safari Stories',
          thumbnailUrl: 'https://picsum.photos/seed/explore-animals-3/480/360',
          total: 25,
          interests: ['Animals'],
        ),
      ],
    ),
  ];
}

bool _matchesInterestFilter(String sectionTitle, String filter) {
  final title = sectionTitle.toLowerCase();
  final value = filter.toLowerCase();
  return title == value || title.contains(value) || value.contains(title);
}

List<ExploreDummySection> exploreDummySeriesSectionsForFilter(
  Set<String> filters,
) {
  final sections = exploreDummySeriesSections();
  if (filters.isEmpty) return sections;

  final forYou = sections.first;
  final interestSections = sections.skip(1).where((section) {
    return filters.any(
      (filter) => _matchesInterestFilter(section.title, filter),
    );
  }).toList();

  if (interestSections.isEmpty) return [];

  return [forYou, ...interestSections];
}
