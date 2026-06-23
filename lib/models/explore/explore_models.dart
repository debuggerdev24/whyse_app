import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/models/home/browse_topic_model.dart';

class ExploreDiscoverInterest {
  const ExploreDiscoverInterest({
    required this.id,
    required this.name,
    required this.color,
  });

  final String id;
  final String name;
  final String color;

  factory ExploreDiscoverInterest.fromJson(Map<String, dynamic> json) {
    return ExploreDiscoverInterest(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
    );
  }
}

class ExplorePagination {
  const ExplorePagination({
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.totalPages = 0,
    this.hasMore = false,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  factory ExplorePagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ExplorePagination();
    return ExplorePagination(
      page: ExplorePagination.asInt(json['page']),
      limit: ExplorePagination.asInt(json['limit'], fallback: 10),
      total: ExplorePagination.asInt(json['total']),
      totalPages: ExplorePagination.asInt(json['totalPages']),
      hasMore: json['hasMore'] == true,
    );
  }

  static int asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  ExplorePagination copyWith({
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool? hasMore,
  }) {
    return ExplorePagination(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

int exploreJsonInt(dynamic value, {int fallback = 0}) =>
    ExplorePagination.asInt(value, fallback: fallback);

class ExploreSparkItem {
  const ExploreSparkItem({
    required this.id,
    required this.question,
    required this.imageUrl,
    required this.interestName,
    this.title = '',
    this.rawJson = const {},
  });

  final String id;
  final String title;
  final String question;
  final String imageUrl;
  final String interestName;
  final Map<String, dynamic> rawJson;

  factory ExploreSparkItem.fromJson(Map<String, dynamic> json) {
    return ExploreSparkItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      imageUrl: resolveNetworkImageUrl(json['imgUrl']?.toString() ?? ''),
      interestName: json['interestName']?.toString() ?? '',
      rawJson: Map<String, dynamic>.from(json),
    );
  }
}

class ExplorePagedSection<T> {
  ExplorePagedSection({
    required this.key,
    required this.title,
    this.state = DataState.loading,
    this.error,
    this.items = const [],
    this.pagination = const ExplorePagination(),
    this.isLoadingMore = false,
    this.interestId,
  });

  final String key;
  final String? interestId;
  String title;
  DataState state;
  String? error;
  List<T> items;
  ExplorePagination pagination;
  bool isLoadingMore;

  bool get hasMore => pagination.hasMore;
  bool get isEmpty => items.isEmpty;
}

BrowseTopicModel browseTopicFromExplorerJson(Map<String, dynamic> json) {
  return BrowseTopicModel(
    id: json['id']?.toString() ?? '',
    topic: json['title']?.toString() ?? json['topic']?.toString() ?? '',
    learningGoal: json['learningGoal']?.toString() ?? '',
    type: 'story',
    interests: json['interests'] == null
        ? const []
        : List<String>.from(
            (json['interests'] as List).map((interest) => interest.toString()),
          ),
    noOfStories: exploreJsonInt(json['noOfStories']),
    noOfStoriesGenerated: exploreJsonInt(json['noOfStoriesGenerated']),
    createdBy: 'admin',
    isOwnTopic: false,
    isInMyList: false,
    createdOn: null,
    updatedAt: null,
    thumbnailUrl: resolveNetworkImageUrl(json['thumbnailUrl']?.toString() ?? ''),
    thumbnailSource: '',
    thumbnailLicense: '',
    thumbnailAttribution: '',
    thumbnailSearchEntity: '',
  );
}
