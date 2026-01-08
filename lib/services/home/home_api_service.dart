import 'package:dartz/dartz.dart';

import '../../core/constants/end_points.dart';
import '../base_api_service.dart';

class HomeApiService {
  HomeApiService._();

  static final HomeApiService _instance = HomeApiService._();
  static HomeApiService instance = _instance;

  Future<Either<ApiException, Map<String, dynamic>>> getGoals() async {
    return await BaseApiHelper.instance.get(EndPoints.getGoals);
  }
}
