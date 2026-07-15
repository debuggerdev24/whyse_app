import 'package:dartz/dartz.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/network/end_points.dart';
import 'package:redstreakapp/models/curiosity_reading/curiosity_reading_model.dart';
import 'package:redstreakapp/models/explore/spark_reading_mapper.dart';

class CuriosityReadingService {
  static const bool enableApiLogging = false;
  static final _defaultApi =
      BaseApiHelper(enableApiLogging: enableApiLogging);

  final BaseApiHelper _api;

  CuriosityReadingService([BaseApiHelper? api])
      : _api = api ?? _defaultApi;

  Future<Either<ApiException, CuriosityReadingModel>> getCuriosityReading({
    int page = 1,
    int limit = 10,
  }) async {
    final result = await _api.get(
      EndPoints.getCuriosityReading(page: page, limit: limit),
    );
    return result.fold(
      (exception) => Left(exception),
      (data) => Right(
        CuriosityReadingModel.fromJson(
          data as Map<String, dynamic>,
        ),
      ),
    );
  }

  Future<Either<ApiException, Reading>> getReadingById({
    required String readingId,
  }) async {
    final result = await _api.get(
      EndPoints.getCuriosityReadingById(readingId: readingId),
    );

    return result.fold(
      Left.new,
      (data) {
        final map = data as Map<String, dynamic>;
        final payload = map['data'];
        if (payload is Map<String, dynamic>) {
          if (payload['reading'] is Map<String, dynamic>) {
            return Right(
              readingFromSparkJson(
                payload['reading'] as Map<String, dynamic>,
              ),
            );
          }
          if (payload['id'] != null) {
            return Right(readingFromSparkJson(payload));
          }
        }
        return Left(
          ApiException(
            errorMsg: 'Could not load this Spark.',
            apiErrorMsg: 'invalid_reading_response',
            code: '',
          ),
        );
      },
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> recordReadingInteraction({
    required String readingId,
    required String eventType,
    required String sessionId,
    int? readDurationMs,
    int? scrollDepthPercent,
  }) {
    final body = <String, dynamic>{
      'eventType': eventType,
      'sessionId': sessionId,
      if (readDurationMs != null) 'readDurationMs': readDurationMs,
      if (scrollDepthPercent != null) 'scrollDepthPercent': scrollDepthPercent,
    };

    return _api.post(
      EndPoints.curiosityReadingInteract(readingId: readingId),
      data: body,
    );
  }
}
