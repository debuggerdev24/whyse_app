import 'package:dartz/dartz.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/network/end_points.dart';

class SavedSeriesService {
  SavedSeriesService._();
  static final SavedSeriesService instance = SavedSeriesService._();

  Future<Either<ApiException, Map<String, dynamic>>> getMyList({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    return BaseApiHelper.instance.get(
      EndPoints.getMyList(page: page, limit: limit, search: search),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> toggleTopicList({
    required String topicId,
  }) async {
    return BaseApiHelper.instance.post(
      EndPoints.addOrRemoveToMyList(topicId: topicId),
    );
  }
}
