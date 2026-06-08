// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curiosity_reading_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CuriosityReadingModel _$CuriosityReadingModelFromJson(
  Map<String, dynamic> json,
) => _CuriosityReadingModel(
  success: json['success'] as bool,
  data: CuriosityReadingData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CuriosityReadingModelToJson(
  _CuriosityReadingModel instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

_CuriosityReadingData _$CuriosityReadingDataFromJson(
  Map<String, dynamic> json,
) => _CuriosityReadingData(
  readings: (json['readings'] as List<dynamic>)
      .map((e) => Reading.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: ReadingMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CuriosityReadingDataToJson(
  _CuriosityReadingData instance,
) => <String, dynamic>{'readings': instance.readings, 'meta': instance.meta};

_Reading _$ReadingFromJson(Map<String, dynamic> json) => _Reading(
  id: json['id'] as String,
  title: json['title'] as String,
  question: json['question'] as String,
  imgUrl: json['imgUrl'] as String,
  interestId: json['interestId'] as String,
  interestName: json['interestName'] as String,
  ageBand: json['ageBand'] as String,
  language: json['language'] as String,
  previewCardType: json['previewCardType'] as String,
  publishedAt: DateTime.parse(json['publishedAt'] as String),
  estimatedReadTimeMinutes: (json['estimatedReadTimeMinutes'] as num).toInt(),
  body: ReadingBody.fromJson(json['body'] as Map<String, dynamic>),
  hasBody: json['hasBody'] as bool,
  isTranslated: json['isTranslated'] as bool,
  isRecycled: json['isRecycled'] as bool,
  recommendationReason: json['recommendationReason'] as String,
  rankScore: (json['rankScore'] as num).toDouble(),
);

Map<String, dynamic> _$ReadingToJson(_Reading instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'question': instance.question,
  'imgUrl': instance.imgUrl,
  'interestId': instance.interestId,
  'interestName': instance.interestName,
  'ageBand': instance.ageBand,
  'language': instance.language,
  'previewCardType': instance.previewCardType,
  'publishedAt': instance.publishedAt.toIso8601String(),
  'estimatedReadTimeMinutes': instance.estimatedReadTimeMinutes,
  'body': instance.body,
  'hasBody': instance.hasBody,
  'isTranslated': instance.isTranslated,
  'isRecycled': instance.isRecycled,
  'recommendationReason': instance.recommendationReason,
  'rankScore': instance.rankScore,
};

_ReadingBody _$ReadingBodyFromJson(Map<String, dynamic> json) => _ReadingBody(
  article: json['article'] as String,
  keyFacts: (json['keyFacts'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  quote: json['quote'] as String,
  readingLevel: json['readingLevel'] as String,
);

Map<String, dynamic> _$ReadingBodyToJson(_ReadingBody instance) =>
    <String, dynamic>{
      'article': instance.article,
      'keyFacts': instance.keyFacts,
      'quote': instance.quote,
      'readingLevel': instance.readingLevel,
    };

_ReadingMeta _$ReadingMetaFromJson(Map<String, dynamic> json) => _ReadingMeta(
  userId: json['userId'] as String,
  ageBand: json['ageBand'] as String,
  language: json['language'] as String,
  languageCode: json['languageCode'] as String,
  interestsUsed: (json['interestsUsed'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isColdStart: json['isColdStart'] as bool,
  totalCandidates: (json['totalCandidates'] as num).toInt(),
  returnedCount: (json['returnedCount'] as num).toInt(),
  pool: ReadingPool.fromJson(json['pool'] as Map<String, dynamic>),
  pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
  translation: TranslationMeta.fromJson(
    json['translation'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ReadingMetaToJson(_ReadingMeta instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'ageBand': instance.ageBand,
      'language': instance.language,
      'languageCode': instance.languageCode,
      'interestsUsed': instance.interestsUsed,
      'isColdStart': instance.isColdStart,
      'totalCandidates': instance.totalCandidates,
      'returnedCount': instance.returnedCount,
      'pool': instance.pool,
      'pagination': instance.pagination,
      'translation': instance.translation,
    };

_ReadingPool _$ReadingPoolFromJson(Map<String, dynamic> json) => _ReadingPool(
  sameAgeUnseen: (json['sameAgeUnseen'] as num).toInt(),
  crossAgeInterestUnseen: (json['crossAgeInterestUnseen'] as num).toInt(),
  crossAgeBroadUnseen: (json['crossAgeBroadUnseen'] as num).toInt(),
  recycled: (json['recycled'] as num).toInt(),
  expandedBeyondAgeBand: json['expandedBeyondAgeBand'] as bool,
  includesRecycled: json['includesRecycled'] as bool,
);

Map<String, dynamic> _$ReadingPoolToJson(_ReadingPool instance) =>
    <String, dynamic>{
      'sameAgeUnseen': instance.sameAgeUnseen,
      'crossAgeInterestUnseen': instance.crossAgeInterestUnseen,
      'crossAgeBroadUnseen': instance.crossAgeBroadUnseen,
      'recycled': instance.recycled,
      'expandedBeyondAgeBand': instance.expandedBeyondAgeBand,
      'includesRecycled': instance.includesRecycled,
    };

_Pagination _$PaginationFromJson(Map<String, dynamic> json) => _Pagination(
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  total: (json['total'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  hasMore: json['hasMore'] as bool,
);

Map<String, dynamic> _$PaginationToJson(_Pagination instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'offset': instance.offset,
      'total': instance.total,
      'totalPages': instance.totalPages,
      'hasMore': instance.hasMore,
    };

_TranslationMeta _$TranslationMetaFromJson(Map<String, dynamic> json) =>
    _TranslationMeta(
      contentLanguage: json['contentLanguage'] as String,
      isTranslatedInResponse: json['isTranslatedInResponse'] as bool,
      translatableLanguages: (json['translatableLanguages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      note: json['note'] as String,
    );

Map<String, dynamic> _$TranslationMetaToJson(_TranslationMeta instance) =>
    <String, dynamic>{
      'contentLanguage': instance.contentLanguage,
      'isTranslatedInResponse': instance.isTranslatedInResponse,
      'translatableLanguages': instance.translatableLanguages,
      'note': instance.note,
    };

_CacheMeta _$CacheMetaFromJson(Map<String, dynamic> json) => _CacheMeta(
  hit: json['hit'] as bool,
  ttlSeconds: (json['ttlSeconds'] as num).toInt(),
);

Map<String, dynamic> _$CacheMetaToJson(_CacheMeta instance) =>
    <String, dynamic>{'hit': instance.hit, 'ttlSeconds': instance.ttlSeconds};
