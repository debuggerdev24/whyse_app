import 'package:dartz/dartz.dart';
import 'package:redstreakapp/core/network/end_points.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';

class HomeApiService {
  HomeApiService._();
  static final HomeApiService _instance = HomeApiService._();
  static HomeApiService get instance => _instance;
  Future<Either<ApiException, Map<String, dynamic>>> getMyTopics({
    int page = 1,
    int limit = 20,
  }) async {
    return await BaseApiHelper.instance.get(
      EndPoints.getMyTopics(page: page, limit: limit),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getStoryIdeasByTopicId({
    required String topicId,
    int page = 1,
    int limit = 20,
  }) async {
    return await BaseApiHelper.instance.get(
      EndPoints.getStoryIdeasByTopicId(topicId: topicId),
      queryParameters: {
        "page": page,
        "limit": limit,
        "sortOrder": "asc",
      },
    );
  }
  
  Future<Either<ApiException, Map<String, dynamic>>> getStoryByStoryId({required String storyIdea}) async {
    return await BaseApiHelper.instance.get(EndPoints.getStoryByStoryIdea(storyIdea: storyIdea));
  }
  
  //*browse
  Future<Either<ApiException, Map<String, dynamic>>> browseAllTopics({
    String search = "",
    int page = 1,
  }) async {
    final queryParameters = <String, dynamic>{
      "page": page,
      "limit": 20,
      "createdBy": "all",
      "sortBy": "createdAt",
      "sortOrder": "asc",
      if (search.trim().isNotEmpty) "search": search.trim(),
    };

    return await BaseApiHelper.instance.get(
      EndPoints.browseAllTopics,
      queryParameters: queryParameters,
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> toggleTopicList({
    required String topicId,
  }) async {
    return await BaseApiHelper.instance.post(
      EndPoints.addOrRemoveToMyList(topicId: topicId),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getTopicProgress({
    required String topicId,
  }) async {
    return await BaseApiHelper.instance.get(
      EndPoints.topicProgress(topicId: topicId),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getMyList({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    return await BaseApiHelper.instance.get(
      EndPoints.getMyList(page: page, limit: limit, search: search),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getMobileTopicStoryIdeas({
    required String topicId,
  }) async {
    return await BaseApiHelper.instance.get(
      EndPoints.getMobileTopicStoryIdeas(topicId: topicId),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getContinueReading({
    int page = 1,
    int limit = 10,
  }) async {
    return await BaseApiHelper.instance.get(
      EndPoints.getContinueReading(page: page, limit: limit),
    );
  }
}