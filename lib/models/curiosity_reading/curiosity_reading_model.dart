import 'package:freezed_annotation/freezed_annotation.dart';

part 'curiosity_reading_model.freezed.dart';
part 'curiosity_reading_model.g.dart';

@freezed
abstract class CuriosityReadingModel with _$CuriosityReadingModel {
  const factory CuriosityReadingModel({
    required bool success,
    required CuriosityReadingData data,
  }) = _CuriosityReadingModel;

  factory CuriosityReadingModel.fromJson(Map<String, dynamic> json) =>
      _$CuriosityReadingModelFromJson(json);
}

@freezed
abstract class CuriosityReadingData with _$CuriosityReadingData {
  const factory CuriosityReadingData({
    required List<Reading> readings,
    required ReadingMeta meta,
  }) = _CuriosityReadingData;

  factory CuriosityReadingData.fromJson(Map<String, dynamic> json) =>
      _$CuriosityReadingDataFromJson(json);
}

@freezed
abstract class Reading with _$Reading {
  const factory Reading({
    required String id,
    required String title,
    required String question,
    required String imgUrl,
    required String interestId,
    required String interestName,
    required String ageBand,
    required String language,
    required String previewCardType,
    // List<String>? previewFacts,
    required DateTime publishedAt,
    required int estimatedReadTimeMinutes,
    required ReadingBody body,
    required bool hasBody,
    required bool isTranslated,
    required bool isRecycled,
    required String recommendationReason,
    required double rankScore,
  }) = _Reading;

  factory Reading.fromJson(Map<String, dynamic> json) =>
      _$ReadingFromJson(json);
}

@freezed
abstract class ReadingBody with _$ReadingBody {
  const factory ReadingBody({
    required String article,
    required List<String> keyFacts,
    required String quote,
    required String readingLevel,
  }) = _ReadingBody;

  factory ReadingBody.fromJson(Map<String, dynamic> json) =>
      _$ReadingBodyFromJson(json);
}

@freezed
abstract class ReadingMeta with _$ReadingMeta {
  const factory ReadingMeta({
    required String userId,
    required String ageBand,
    required String language,
    required String languageCode,
    required List<String> interestsUsed,
    required bool isColdStart,
    required int totalCandidates,
    required int returnedCount,
    required ReadingPool pool,
    required Pagination pagination,
    required TranslationMeta translation,
    // required CacheMeta cache,
  }) = _ReadingMeta;

  factory ReadingMeta.fromJson(Map<String, dynamic> json) =>
      _$ReadingMetaFromJson(json);
}

@freezed
abstract class ReadingPool with _$ReadingPool {
  const factory ReadingPool({
    required int sameAgeUnseen,
    required int crossAgeInterestUnseen,
    required int crossAgeBroadUnseen,
    required int recycled,
    required bool expandedBeyondAgeBand,
    required bool includesRecycled,
  }) = _ReadingPool;

  factory ReadingPool.fromJson(Map<String, dynamic> json) =>
      _$ReadingPoolFromJson(json);
}

@freezed
abstract class Pagination with _$Pagination {
  const factory Pagination({
    required int page,
    required int limit,
    required int offset,
    required int total,
    required int totalPages,
    required bool hasMore,
  }) = _Pagination;

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);
}

@freezed
abstract class TranslationMeta with _$TranslationMeta {
  const factory TranslationMeta({
    required String contentLanguage,
    required bool isTranslatedInResponse,
    required List<String> translatableLanguages,
    required String note,
  }) = _TranslationMeta;

  factory TranslationMeta.fromJson(Map<String, dynamic> json) =>
      _$TranslationMetaFromJson(json);
}

@freezed
abstract class CacheMeta with _$CacheMeta {
  const factory CacheMeta({
    required bool hit,
    required int ttlSeconds,
  }) = _CacheMeta;

  factory CacheMeta.fromJson(Map<String, dynamic> json) =>
      _$CacheMetaFromJson(json);
}