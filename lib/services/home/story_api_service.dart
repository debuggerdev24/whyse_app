import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/network/end_points.dart';
import '../../core/network/base_api_service.dart';

class StoryApiService {
  static const bool enableApiLogging = false;
  static final _api = BaseApiHelper(enableApiLogging: enableApiLogging);

  StoryApiService._();

  static final StoryApiService _instance = StoryApiService._();
  static StoryApiService instance = _instance;

  Future<Either<ApiException, Map<String, dynamic>>> getGoals() async {
    return await _api.get(EndPoints.getStoryGoals);
  }

  Future<Either<ApiException, Map<String, dynamic>>> getInterest() async {
    return await _api.get(EndPoints.getStoryInterest);
  }

  /// `GET /story-flow/topics` with optional `search`, `page`, and `limit`.
  Future<Either<ApiException, Map<String, dynamic>>> getStoryFlowTopics({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    final q = search?.trim();
    if (q != null && q.isNotEmpty) {
      query['search'] = q;
    }
    return await _api.get(
      EndPoints.getStoryTopics,
      queryParameters: query,
    );
  }

  /// No per-request timeouts — generation can run as long as the server needs.
  static final Options _generateMobileOptions = Options(
    receiveTimeout: Duration.zero,
    sendTimeout: Duration.zero,
    connectTimeout: Duration.zero,
  );

  Future<Either<ApiException, Map<String, dynamic>>> createStoryIdeas({
    required Map<String, dynamic> data,
  }) async {
    return await _api.post(
      EndPoints.createStoryIdea,
      data: data,
      options: _generateMobileOptions,
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> createStory({
    required Map<String, dynamic> data,
    Duration? receiveTimeout,
  }) async {
    final options = receiveTimeout != null
        ? Options(receiveTimeout: receiveTimeout)
        : null;
    return await _api.post(
      EndPoints.createStory,
      data: data,
      options: options,
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> createStoryImage({
    required Map<String, dynamic> data,
  }) async {
    return await _api.post(
      EndPoints.createStoryImage,
      data: data,
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> linkeIMageToStory({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    return await _api.post(
      EndPoints.storeImage(storyId: id),
      data: data,
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getAllStories() async {
    return _api.get(EndPoints.getAllStories);
  }

  Future<Either<ApiException, Map<String, dynamic>>> markAsRead({
    required String storyIdeaId,
  }) async {
    return _api.post(
      EndPoints.markAsRead(storyIdeaId: storyIdeaId),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> updatePageProgress({
    required String storyIdeaId,
    required int pageIndex,
  }) async {
    return _api.post(
      EndPoints.pageProgress(storyIdeaId: storyIdeaId),
      data: {"pageIndex": pageIndex},
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> createQuiz({
    required String storyId,
    Map<String, dynamic>? data,
  }) async {
    return _api.post(
      EndPoints.createQuiz(storyId: storyId),
      data: data,
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getQuiz({
    required String storyId,
  }) async {
    return _api.get(EndPoints.getQuiz(storyId: storyId));
  }

  Future<Either<ApiException, Map<String, dynamic>>> submitQuiz({
    required String storyId,
    required Map<String, dynamic> data,
  }) async {
    return _api.post(
      EndPoints.submitQuiz(storyId: storyId),
      data: data,
      // Idempotent for same inputs; allow retry on transient null responses.
      options: Options(extra: {"retryOnNullData": true}),
    );
  }
}
