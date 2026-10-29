import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/models/curiosity_reading/curiosity_reading_model.dart';
import 'package:redstreakapp/models/explore/explore_models.dart';

ReadingBody _readingBodyFromSparkJson(Map<String, dynamic> json) {
  final raw = json['body'] ?? json['article'] ?? json['content'];
  if (raw is String) {
    return ReadingBody(
      article: raw,
      keyFacts: const [],
      quote: '',
      readingLevel: '',
    );
  }
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final article =
        map['article'] ?? map['content'] ?? map['text'] ?? map['markdown'] ?? '';
    final facts = map['keyFacts'];
    return ReadingBody(
      article: article.toString(),
      keyFacts: facts is List
          ? facts.map((fact) => fact.toString()).toList()
          : const [],
      quote: map['quote']?.toString() ?? '',
      readingLevel: map['readingLevel']?.toString() ?? '',
    );
  }
  return const ReadingBody(
    article: '',
    keyFacts: [],
    quote: '',
    readingLevel: '',
  );
}

Reading readingFromSparkJson(Map<String, dynamic> json) {
  final body = _readingBodyFromSparkJson(json);

  return Reading(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    question: json['question']?.toString() ?? '',
    imgUrl: resolveNetworkImageUrl(json['imgUrl']?.toString() ?? ''),
    interestId: json['interestId']?.toString() ?? '',
    interestName: json['interestName']?.toString() ?? '',
    ageBand: json['ageBand']?.toString() ?? '',
    language: json['language']?.toString() ?? '',
    previewCardType: json['previewCardType']?.toString() ?? 'QUESTION',
    publishedAt:
        DateTime.tryParse(json['publishedAt']?.toString() ?? '') ??
        DateTime.now(),
    estimatedReadTimeMinutes: exploreJsonInt(
      json['estimatedReadTimeMinutes'],
      fallback: 5,
    ),
    body: body,
    hasBody: json['hasBody'] == true || body.article.trim().isNotEmpty,
    isTranslated: json['isTranslated'] == true,
    isRecycled: json['isRecycled'] == true,
    recommendationReason: json['recommendationReason']?.toString() ?? '',
    rankScore: (json['rankScore'] as num?)?.toDouble() ?? 0,
  );
}

ReadingMeta readingMetaFromExplorePagination(ExplorePagination pagination) {
  return ReadingMeta(
    userId: '',
    ageBand: '',
    language: '',
    languageCode: '',
    interestsUsed: const [],
    isColdStart: false,
    totalCandidates: pagination.total,
    returnedCount: pagination.limit,
    pool: const ReadingPool(
      sameAgeUnseen: 0,
      crossAgeInterestUnseen: 0,
      crossAgeBroadUnseen: 0,
      recycled: 0,
      expandedBeyondAgeBand: false,
      includesRecycled: false,
    ),
    pagination: Pagination(
      page: pagination.page,
      limit: pagination.limit,
      offset: (pagination.page - 1) * pagination.limit,
      total: pagination.total,
      totalPages: pagination.totalPages,
      hasMore: pagination.hasMore,
    ),
    translation: const TranslationMeta(
      contentLanguage: '',
      isTranslatedInResponse: false,
      translatableLanguages: [],
      note: '',
    ),
  );
}
