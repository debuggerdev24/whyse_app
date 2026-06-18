class ExploreSparkItem {
  const ExploreSparkItem({
    required this.id,
    required this.question,
    required this.imageUrl,
    required this.interestName,
  });

  final String id;
  final String question;
  final String imageUrl;
  final String interestName;
}

class ExploreSparkSection {
  const ExploreSparkSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<ExploreSparkItem> items;
}

List<ExploreSparkSection> exploreDummySparkSections() {
  return [
    ExploreSparkSection(
      title: 'For You',
      items: const [
        ExploreSparkItem(
          id: 'spark-for-you-1',
          question: 'Why are there clouds in the sky?',
          imageUrl: 'https://picsum.photos/seed/explore-spark-clouds/480/640',
          interestName: 'Science & Discovery',
        ),
        ExploreSparkItem(
          id: 'spark-for-you-2',
          question: 'Why does it rain?',
          imageUrl: 'https://picsum.photos/seed/explore-spark-rain/480/640',
          interestName: 'Nature & Animals',
        ),
        ExploreSparkItem(
          id: 'spark-for-you-3',
          question: 'How do birds learn to fly?',
          imageUrl: 'https://picsum.photos/seed/explore-spark-birds/480/640',
          interestName: 'Animals',
        ),
      ],
    ),
    ExploreSparkSection(
      title: 'Popular',
      items: const [
        ExploreSparkItem(
          id: 'spark-popular-1',
          question: 'Why do tigers have stripes?',
          imageUrl: 'https://picsum.photos/seed/explore-spark-tiger/480/640',
          interestName: 'Animals',
        ),
        ExploreSparkItem(
          id: 'spark-popular-2',
          question: 'What is a black hole?',
          imageUrl: 'https://picsum.photos/seed/explore-spark-space/480/640',
          interestName: 'Science & Discovery',
        ),
        ExploreSparkItem(
          id: 'spark-popular-3',
          question: 'Who built the pyramids?',
          imageUrl: 'https://picsum.photos/seed/explore-spark-history/480/640',
          interestName: 'History & Past Civilizations',
        ),
      ],
    ),
    ExploreSparkSection(
      title: 'Fresh Sparks',
      items: const [
        ExploreSparkItem(
          id: 'spark-fresh-1',
          question: 'How do robots learn new tasks?',
          imageUrl: 'https://picsum.photos/seed/explore-spark-robot/480/640',
          interestName: 'AI & Future Tech',
        ),
        ExploreSparkItem(
          id: 'spark-fresh-2',
          question: 'Why do we dream at night?',
          imageUrl: 'https://picsum.photos/seed/explore-spark-dream/480/640',
          interestName: 'Human Body & Health',
        ),
      ],
    ),
  ];
}

const List<ExploreSparkSection> _sparkInterestSections = [
  ExploreSparkSection(
    title: 'Mystery',
    items: [
      ExploreSparkItem(
        id: 'spark-mystery-1',
        question: 'What happened to the lost city?',
        imageUrl: 'https://picsum.photos/seed/explore-spark-mystery/480/640',
        interestName: 'Mystery',
      ),
    ],
  ),
  ExploreSparkSection(
    title: 'Adventure',
    items: [
      ExploreSparkItem(
        id: 'spark-adventure-1',
        question: 'How do explorers find hidden trails?',
        imageUrl: 'https://picsum.photos/seed/explore-spark-adventure/480/640',
        interestName: 'Adventure',
      ),
    ],
  ),
];

bool _matchesSparkInterest(String sectionTitle, String itemInterest, String filter) {
  final value = filter.toLowerCase();
  return sectionTitle.toLowerCase() == value ||
      sectionTitle.toLowerCase().contains(value) ||
      value.contains(sectionTitle.toLowerCase()) ||
      itemInterest.toLowerCase().contains(value) ||
      value.contains(itemInterest.toLowerCase());
}

List<ExploreSparkSection> exploreDummySparkSectionsForFilter(Set<String> filters) {
  final baseSections = exploreDummySparkSections();
  if (filters.isEmpty) return baseSections;

  final interestSections = _sparkInterestSections.where((section) {
    return filters.any(
      (filter) => _matchesSparkInterest(section.title, '', filter) ||
          section.items.any(
            (item) => _matchesSparkInterest(section.title, item.interestName, filter),
          ),
    );
  }).toList();

  return [...baseSections, ...interestSections];
}
