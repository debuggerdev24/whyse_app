import 'package:dartz/dartz.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';

import '../../core/constants/end_points.dart';
import '../base_api_service.dart';

class HomeApiService {
  HomeApiService._();

  static final HomeApiService _instance = HomeApiService._();
  static HomeApiService instance = _instance;

  Future<Either<ApiException, Map<String, dynamic>>> getGoals() async {
    return await BaseApiHelper.instance.get(EndPoints.getStoryGoals);
  }

  Future<Either<ApiException, Map<String, dynamic>>> getInterest() async {
    Logger.info("Called : ${EndPoints.getStoryInterest}");

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

  Future<Either<ApiException, Map<String, dynamic>>> storeImage({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    return await BaseApiHelper.instance.post(
      EndPoints.storeImage(storyId: id),
      data: data,
    );
  }
}
