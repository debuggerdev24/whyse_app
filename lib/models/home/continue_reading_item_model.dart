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
      id: json['id']?.toString() ?? json['topicId']?.toString() ?? '',
      title: json['title']?.toString() ?? json['topicTitle']?.toString() ?? '',
      thumbnailUrl: resolveNetworkImageUrl(
        json['thumbnailUrl']?.toString() ??
            json['topicThumbnailUrl']?.toString() ??
            '',
      ),
    );
  }
}

/// One Continue Reading shelf row (flattened from continue-reading API).
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
    required this.readPages,
    required this.lastPageIndex,
    required this.continueFromPageIndex,
    required this.percentComplete,
    this.lastReadAt,
    this.storyUpdatedAt,
    this.isGenerated = true,
    this.displayReadingsNum,
    this.displayReadingsDen,
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

  /// Pages read (from API `progress.readPages`).
  final int readPages;

  /// Last page index confirmed read (0-based), derived for the reader.
  final int lastPageIndex;

  /// Page index to open first (0-based), derived for the reader.
  final int continueFromPageIndex;

  final int percentComplete;
  final String? lastReadAt;
  final String? storyUpdatedAt;
  final bool isGenerated;

  /// When set (nested-topics API), the shelf shows `X out of Y Readings` using
  /// topic-level counts; [readPages] / [pageCount] still reflect the resume story
  /// for the reader.
  final int? displayReadingsNum;
  final int? displayReadingsDen;

  double get progressValue =>
      pageCount <= 0 ? 0 : (readPages / pageCount).clamp(0.0, 1.0);

  static int _parseInt(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  static int _storySequence(Map<String, dynamic> sm) {
    if (sm['sequenceIndex'] is int) return sm['sequenceIndex'] as int;
    return int.tryParse(sm['sequenceIndex']?.toString() ?? '') ?? 0;
  }

  /// Picks the story to open: first in-progress, else first not started, else first.
  static Map<String, dynamic>? _pickResumeStoryMap(List<dynamic> storiesRaw) {
    final stories = <Map<String, dynamic>>[];
    for (final s in storiesRaw) {
      if (s is! Map) continue;
      stories.add(Map<String, dynamic>.from(s));
    }
    if (stories.isEmpty) return null;
    stories.sort((a, b) => _storySequence(a).compareTo(_storySequence(b)));

    for (final sm in stories) {
      final progRaw = sm['progress'];
      if (progRaw is! Map) continue;
      final p = Map<String, dynamic>.from(progRaw);
      if (p['isCompleted'] == true) continue;
      return sm;
    }
    for (final sm in stories) {
      if (sm['progress'] == null) return sm;
    }
    return stories.first;
  }

  /// New API: one shelf row per topic; nested `stories` supply the resume target.
  static List<ContinueReadingItemModel> flattenTopicsItems(
    List<dynamic> itemsRaw,
  ) {
    final out = <ContinueReadingItemModel>[];
    for (final raw in itemsRaw) {
      if (raw is! Map) continue;
      final topicMap = Map<String, dynamic>.from(raw);
      if (topicMap['stories'] is! List) continue;

      final storiesList = topicMap['stories'] as List;
      final totalStories = _parseInt(topicMap['totalStories']);
      if (totalStories <= 0) continue;

      final chosen = _pickResumeStoryMap(storiesList);
      if (chosen == null) continue;

      final topicId = topicMap['topicId']?.toString() ?? '';
      final topicTitle = topicMap['topicTitle']?.toString() ?? '';
      final topicThumb = topicMap['topicThumbnailUrl']?.toString() ?? '';
      final topic = ContinueReadingTopic(
        id: topicId,
        title: topicTitle,
        thumbnailUrl: resolveNetworkImageUrl(topicThumb),
      );

      final completedStories = _parseInt(topicMap['completedStories']);
      final topicPercent = _parseInt(topicMap['percentComplete']);
      final topicLastReadAt = topicMap['lastReadAt']?.toString();

      final storyIdeaId = chosen['storyIdeaId']?.toString() ?? '';
      if (storyIdeaId.isEmpty) continue;

      final chosenTitle = chosen['title']?.toString() ?? '';
      final progRaw = chosen['progress'];
      int pageCount = 0;
      int apiReadPages = 0;
      int percent = topicPercent;
      String? storyLastRead = topicLastReadAt;

      if (progRaw is Map) {
        final p = Map<String, dynamic>.from(progRaw);
        pageCount = _parseInt(p['pageCount']);
        apiReadPages = _parseInt(p['readPages']);
        percent = _parseInt(p['percentComplete'], topicPercent);
        storyLastRead = p['lastReadAt']?.toString() ?? topicLastReadAt;
      }

      final lastIdx = _lastPageIndexFromReadPages(apiReadPages, pageCount);
      final continueIdx =
          _continueFromPageIndexFromReadPages(apiReadPages, pageCount);

      final storyThumb =
          resolveNetworkImageUrl(chosen['thumbnailUrl']?.toString() ?? '');

      out.add(
        ContinueReadingItemModel(
          storyIdeaId: storyIdeaId,
          storyId: '',
          storyTitle: topicTitle.isNotEmpty ? topicTitle : chosenTitle,
          storyIdeaTitle: chosenTitle,
          storyIdeaDescription: '',
          priority: chosen['sequenceIndex'] is int
              ? chosen['sequenceIndex'] as int
              : int.tryParse(chosen['sequenceIndex']?.toString() ?? '') ?? 0,
          topic: topic,
          thumbnailUrl: storyThumb,
          pageCount: pageCount,
          readPages: apiReadPages,
          lastPageIndex: lastIdx,
          continueFromPageIndex: continueIdx,
          percentComplete: percent,
          lastReadAt: storyLastRead ?? topicLastReadAt,
          storyUpdatedAt: null,
          isGenerated: chosen['isGenerated'] == true,
          displayReadingsNum: completedStories.clamp(0, totalStories),
          displayReadingsDen: totalStories,
        ),
      );
    }

    sortByLastReadDesc(out);
    return out;
  }

  static void sortByLastReadDesc(List<ContinueReadingItemModel> list) {
    list.sort((a, b) {
      final ta = a.lastReadAt;
      final tb = b.lastReadAt;
      if (ta == null && tb == null) return 0;
      if (ta == null) return 1;
      if (tb == null) return -1;
      try {
        return DateTime.parse(tb).compareTo(DateTime.parse(ta));
      } catch (_) {
        return 0;
      }
    });
  }

  static int _lastPageIndexFromReadPages(int readPages, int pageCount) {
    if (readPages <= 0 || pageCount <= 0) return -1;
    return (readPages - 1).clamp(0, pageCount - 1);
  }

  static int _continueFromPageIndexFromReadPages(int readPages, int pageCount) {
    if (pageCount <= 0) return 0;
    if (readPages <= 0) return 0;
    if (readPages >= pageCount) return pageCount - 1;
    return readPages;
  }

  /// Legacy flat `data.items[]` element (pre–nested-topics API).
  factory ContinueReadingItemModel.fromLegacyJson(Map<String, dynamic> json) {
    final pageCount = json['pageCount'] is int
        ? json['pageCount'] as int
        : int.tryParse(json['pageCount']?.toString() ?? '') ?? 0;
    final lastPageIndex = json['lastPageIndex'] is int
        ? json['lastPageIndex'] as int
        : int.tryParse(json['lastPageIndex']?.toString() ?? '') ?? 0;
    final continueFromPageIndex = json['continueFromPageIndex'] is int
        ? json['continueFromPageIndex'] as int
        : int.tryParse(json['continueFromPageIndex']?.toString() ?? '') ?? 0;
    final derivedRead = (lastPageIndex + 1).clamp(0, pageCount);

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
      pageCount: pageCount,
      readPages: derivedRead,
      lastPageIndex: lastPageIndex,
      continueFromPageIndex: continueFromPageIndex,
      percentComplete: json['percentComplete'] is int
          ? json['percentComplete'] as int
          : int.tryParse(json['percentComplete']?.toString() ?? '') ?? 0,
      lastReadAt: json['lastReadAt']?.toString(),
      storyUpdatedAt: json['storyUpdatedAt']?.toString(),
      isGenerated: true,
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

    final List<ContinueReadingItemModel> items;
    if (itemsRaw.isNotEmpty &&
        itemsRaw.first is Map &&
        (itemsRaw.first as Map)['stories'] is List) {
      items = ContinueReadingItemModel.flattenTopicsItems(itemsRaw);
    } else {
      items = itemsRaw
          .whereType<Map>()
          .map(
            (e) => ContinueReadingItemModel.fromLegacyJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    }

    return ContinueReadingListModel(
      items: items,
      pagination: paginationRaw is Map
          ? ContinueReadingPagination.fromJson(
              Map<String, dynamic>.from(paginationRaw),
            )
          : null,
    );
  }
}
