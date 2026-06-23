import 'package:dartz/dartz.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/network/end_points.dart';

class ExploreApiService {
  static const bool enableApiLogging = false;
  static final _api = BaseApiHelper(enableApiLogging: enableApiLogging);

  ExploreApiService._();
  static final ExploreApiService _instance = ExploreApiService._();
  static ExploreApiService get instance => _instance;

  Future<Either<ApiException, Map<String, dynamic>>> getDiscoverInterests() {
    return _api.get(EndPoints.explorerDiscoverInterests);
  }

  Future<Either<ApiException, Map<String, dynamic>>> getSeriesForYou({
    int page = 1,
    int limit = 10,
    String? search,
  }) {
    return _api.get(
      EndPoints.explorerSeriesForYou,
      queryParameters: _pageParams(
        page: page,
        limit: limit,
        search: search,
      ),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getSeriesPopular({
    int page = 1,
    int limit = 10,
  }) {
    return _api.get(
      EndPoints.explorerSeriesPopular,
      queryParameters: _pageParams(page: page, limit: limit),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getSeriesInterest({
    int page = 1,
    int limit = 10,
    String? interestId,
    List<String>? selectedInterestIds,
    String? search,
  }) {
    return _api.get(
      EndPoints.explorerSeriesInterest,
      queryParameters: _interestParams(
        page: page,
        limit: limit,
        interestId: interestId,
        selectedInterestIds: selectedInterestIds,
        search: search,
      ),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getSparkForYou({
    int page = 1,
    int limit = 10,
    String? search,
  }) {
    return _api.get(
      EndPoints.explorerSparkForYou,
      queryParameters: _pageParams(
        page: page,
        limit: limit,
        search: search,
      ),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getSparkPopular({
    int page = 1,
    int limit = 10,
  }) {
    return _api.get(
      EndPoints.explorerSparkPopular,
      queryParameters: _pageParams(page: page, limit: limit),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getSparkInterest({
    int page = 1,
    int limit = 10,
    String? interestId,
    List<String>? selectedInterestIds,
    String? search,
  }) {
    return _api.get(
      EndPoints.explorerSparkInterest,
      queryParameters: _interestParams(
        page: page,
        limit: limit,
        interestId: interestId,
        selectedInterestIds: selectedInterestIds,
        search: search,
      ),
    );
  }

  Map<String, dynamic> _pageParams({
    required int page,
    required int limit,
    String? search,
  }) {
    return {
      'page': page,
      'limit': limit,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };
  }

  Map<String, dynamic> _interestParams({
    required int page,
    required int limit,
    String? interestId,
    List<String>? selectedInterestIds,
    String? search,
  }) {
    final params = _pageParams(page: page, limit: limit, search: search);
    if (interestId != null && interestId.isNotEmpty) {
      params['interestId'] = interestId;
    } else if (selectedInterestIds != null && selectedInterestIds.isNotEmpty) {
      params['selectedInterestIds'] = selectedInterestIds.join(',');
    }
    return params;
  }
}
