import 'package:dartz/dartz.dart';
import 'package:redstreakapp/core/network/end_points.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';

class HomeApiService {
  HomeApiService._();
  static final HomeApiService _instance = HomeApiService._();
  static HomeApiService get instance => _instance;
  Future<Either<ApiException, Map<String, dynamic>>> getHomeScreenTopics() async {
    return await BaseApiHelper.instance.get(EndPoints.getHomeScreenTopics);
  }

  Future<Either<ApiException, Map<String, dynamic>>> getStoryIdeasByTopicId({required String topicId}) async {
    return await BaseApiHelper.instance.get(EndPoints.getStoryIdeasByTopicId(topicId: topicId));
  }
  Future<Either<ApiException, Map<String, dynamic>>> getStoryByStoryId({required String storyIdea}) async {
    return await BaseApiHelper.instance.get(EndPoints.getStoryByStoryIdea(storyIdea: storyIdea));
  }
}