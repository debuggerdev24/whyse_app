import 'package:redstreakapp/core/utils/network_image_url.dart';

class ContinueReadingTopic {
  ContinueReadingTopic({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String thumbnailUrl;

  factory ContinueReadingTopic.fromJson(Map<String, dynamic> json) {
    return ContinueReadingTopic(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      thumbnailUrl:
          resolveNetworkImageUrl(json['thumbnailUrl']?.toString() ?? ''),
    );
  }
}

class ContinueReadingItemModel {
  ContinueReadingItemModel({
    required this.storyIdeaId,
    required this.storyId,
    required this.storyTitle,
    required this.storyIdeaTitle,
    required this.storyIdeaDescription,
    required this.priority,
    required this.topic,
    required this.thumbnailUrl,
    required this.pageCount,
    required this.lastPageIndex,
    required this.continueFromPageIndex,
    required this.percentComplete,
    this.lastReadAt,
    this.storyUpdatedAt,
  });

  final String storyIdeaId;
  final String storyId;
  final String storyTitle;
  final String storyIdeaTitle;
  final String storyIdeaDescription;
  final int priority;
  final ContinueReadingTopic topic;
  final String thumbnailUrl;
  final int pageCount;
  final int lastPageIndex;
  final int continueFromPageIndex;
  final int percentComplete;
  final String? lastReadAt;
  final String? storyUpdatedAt;

  int get readPages => (lastPageIndex + 1).clamp(0, pageCount);
  double get progressValue =>
      pageCount <= 0 ? 0 : (readPages / pageCount).clamp(0.0, 1.0);

  factory ContinueReadingItemModel.fromJson(Map<String, dynamic> json) {
    return ContinueReadingItemModel(
      storyIdeaId: json['storyIdeaId']?.toString() ?? '',
      storyId: json['storyId']?.toString() ?? '',
      storyTitle: json['storyTitle']?.toString() ?? '',
      storyIdeaTitle: json['storyIdeaTitle']?.toString() ?? '',
      storyIdeaDescription: json['storyIdeaDescription']?.toString() ?? '',
      priority: json['priority'] is int
          ? json['priority'] as int
          : int.tryParse(json['priority']?.toString() ?? '') ?? 0,
      topic: ContinueReadingTopic.fromJson(
        Map<String, dynamic>.from(json['topic'] as Map? ?? {}),
      ),
      thumbnailUrl:
          resolveNetworkImageUrl(json['thumbnailUrl']?.toString() ?? ''),
      pageCount: json['pageCount'] is int
          ? json['pageCount'] as int
          : int.tryParse(json['pageCount']?.toString() ?? '') ?? 0,
      lastPageIndex: json['lastPageIndex'] is int
          ? json['lastPageIndex'] as int
          : int.tryParse(json['lastPageIndex']?.toString() ?? '') ?? 0,
      continueFromPageIndex: json['continueFromPageIndex'] is int
          ? json['continueFromPageIndex'] as int
          : int.tryParse(json['continueFromPageIndex']?.toString() ?? '') ?? 0,
      percentComplete: json['percentComplete'] is int
          ? json['percentComplete'] as int
          : int.tryParse(json['percentComplete']?.toString() ?? '') ?? 0,
      lastReadAt: json['lastReadAt']?.toString(),
      storyUpdatedAt: json['storyUpdatedAt']?.toString(),
    );
  }
}

class ContinueReadingPagination {
  ContinueReadingPagination({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
    required this.hasMore,
  });

  final int page;
  final int limit;
  final int totalCount;
  final int totalPages;
  final bool hasMore;

  factory ContinueReadingPagination.fromJson(Map<String, dynamic> json) {
    return ContinueReadingPagination(
      page: json['page'] is int
          ? json['page'] as int
          : int.tryParse(json['page']?.toString() ?? '') ?? 1,
      limit: json['limit'] is int
          ? json['limit'] as int
          : int.tryParse(json['limit']?.toString() ?? '') ?? 10,
      totalCount: json['totalCount'] is int
          ? json['totalCount'] as int
          : int.tryParse(json['totalCount']?.toString() ?? '') ?? 0,
      totalPages: json['totalPages'] is int
          ? json['totalPages'] as int
          : int.tryParse(json['totalPages']?.toString() ?? '') ?? 1,
      hasMore: json['hasMore'] == true,
    );
  }
}

class ContinueReadingListModel {
  ContinueReadingListModel({required this.items, this.pagination});

  final List<ContinueReadingItemModel> items;
  final ContinueReadingPagination? pagination;

  factory ContinueReadingListModel.fromResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map? ?? {};
    final itemsRaw = (data['items'] as List?) ?? const [];
    final paginationRaw = data['pagination'];
    return ContinueReadingListModel(
      items: itemsRaw
          .whereType<Map>()
          .map(
            (e) =>
                ContinueReadingItemModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
      pagination: paginationRaw is Map
          ? ContinueReadingPagination.fromJson(
              Map<String, dynamic>.from(paginationRaw),
            )
          : null,
    );
  }
}
