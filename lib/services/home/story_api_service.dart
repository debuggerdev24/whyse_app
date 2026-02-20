import 'package:dartz/dartz.dart';

import '../../core/network/end_points.dart';
import '../../core/network/base_api_service.dart';

class StoryApiService {
  StoryApiService._();

  static final StoryApiService _instance = StoryApiService._();
  static StoryApiService instance = _instance;

  Future<Either<ApiException, Map<String, dynamic>>> getGoals() async {
    return await BaseApiHelper.instance.get(EndPoints.getStoryGoals);
  }

  Future<Either<ApiException, Map<String, dynamic>>> getInterest() async {
    return await BaseApiHelper.instance.get(EndPoints.getStoryInterest);
  }

  Future<Either<ApiException, Map<String, dynamic>>> getTopics() async {
    return await BaseApiHelper.instance.get(EndPoints.getStoryTopics);
  }

  Future<Either<ApiException, Map<String, dynamic>>> getSearchedTopics({
    required Map<String, dynamic> queryParams,
  }) async {
    return await BaseApiHelper.instance.get(
      EndPoints.getSearchTopics,
      queryParameters: queryParams,
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> createStoryIdea({
    required Map<String, dynamic> data,
  }) async {
    return await BaseApiHelper.instance.post(
      EndPoints.createStoryIdea,
      data: data,
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> createStory({
    required Map<String, dynamic> data,
  }) async {
    return await BaseApiHelper.instance.post(EndPoints.createStory, data: data);
  }

  Future<Either<ApiException, Map<String, dynamic>>> createStoryImage({
    required Map<String, dynamic> data,
  }) async {
    return await BaseApiHelper.instance.post(
      EndPoints.createStoryImage,
      data: data,
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> linkeIMageToStory({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    return await BaseApiHelper.instance.post(
      EndPoints.storeImage(storyId: id),
      data: data,
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getAllStories() async {
    return BaseApiHelper.instance.get(EndPoints.getAllStories);
  }
}
