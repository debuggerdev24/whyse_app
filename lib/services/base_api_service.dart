import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:redstreakapp/core/constants/shared_pref.dart';

import '../core/helper/log_helper.dart';

class DioClient {
  DioClient._();
  static final _instance = DioClient._();
  // static const baseUrl = "https://whyse.com"; //"http://167.172.45.71";
  // static const apiBaseUrl = "$baseUrl/api/v1";
  static String get baseUrl =>
      dotenv.env['BASE_URL']!; //?? 'https://whyse.com';
  static String get apiBaseUrl => '$baseUrl/api/v1';
  static DioClient get instance => _instance;
  late Dio _dio;

  initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          "Content-Type": "application/json",
          if (LocalStorageService.instance.getAuthToken != null)
            "Authorization":
                "Bearer ${LocalStorageService.instance.getAuthToken}",
        },
      ),
    );

    Logger.info(
      "Authorization Token : ${LocalStorageService.instance.getAuthToken.toString()}",
    );
    Logger.info(
      "onBoarding ID : ${LocalStorageService.instance.onboardingId.toString()}",
    );
    _dio.interceptors.add(
      PrettyDioLogger(request: true, requestBody: true, requestHeader: true),
    );
  }

  Dio get dio => _dio;

  addToken(String token) {
    _dio.options = _dio.options.copyWith(
      headers: {"Authorization": "Bearer $token"},
    );
  }

  Future<bool> isTokenValid() async {
    final token = LocalStorageService.instance.getAuthToken;
    return token != null && token.isNotEmpty;
  }
}

class BaseApiHelper {
  BaseApiHelper._();
  static final BaseApiHelper _instance = BaseApiHelper._();
  static BaseApiHelper get instance => _instance;
  final Dio _dio = DioClient.instance.dio;
  Future<Either<ApiException, T>> get<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      // final result = _handleResponse(response);
      final result = response.data;
      if (parser != null) {
        return Right(parser(result));
      } else {
        return Right(result as T);
      }
    } on DioException catch (e) {
      return Left(
        ApiException(
          errorMsg: _handleErrorMessage(e),
          code: e.response?.statusCode.toString(),
          apiErrorMsg: e.message,
        ),
      );
    } on Exception catch (e) {
      return Left(
        ApiException(
          errorMsg: 'Somethign went wrong',
          apiErrorMsg: e.toString(),
          code: '',
        ),
      );
    }
  }

  Future<Either<ApiException, T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      final result = response.data;
      if (parser != null) {
        return Right(parser(result));
      } else {
        return Right(result as T);
      }
    } on DioException catch (e) {
      // Fallback for other errors
      return Left(
        ApiException(
          errorMsg: _handleErrorMessage(e),
          code: e.response?.statusCode.toString(),
          apiErrorMsg: e.message,
        ),
      );
    } catch (e) {
      Logger.error(":x: Exception: $e");
      return Left(
        ApiException(
          errorMsg: 'Something went wrong',
          code: '',
          apiErrorMsg: e.toString(),
        ),
      );
    }
  }

  Future<Either<ApiException, T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      final result = response.data;
      if (parser != null) {
        return Right(parser(result));
      } else {
        return Right(result as T);
      }
    } on DioException catch (e) {
      return Left(
        ApiException(
          errorMsg: _handleErrorMessage(e),
          code: e.response?.statusCode.toString(),
          apiErrorMsg: e.message,
        ),
      );
    } catch (e) {
      Logger.error(":x: Exception: $e");
      return Left(
        ApiException(
          errorMsg: 'Something went wrong',
          code: '',
          apiErrorMsg: e.toString(),
        ),
      );
    }
  }

  Future<Either<ApiException, T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      final result = response.data;
      if (parser != null) {
        return Right(parser(result));
      } else {
        return Right(result as T);
      }
    } on DioException catch (e) {
      return Left(
        ApiException(
          errorMsg: _handleErrorMessage(e),
          code: e.response?.statusCode.toString(),
          apiErrorMsg: e.message,
        ),
      );
    } catch (e) {
      Logger.error(":x: Exception: $e");
      return Left(
        ApiException(
          errorMsg: 'Something went wrong',
          code: '',
          apiErrorMsg: e.toString(),
        ),
      );
    }
  }

  // Future<Either<ApiException, bool>> checkTokenExpired() async {
  //   try {
  //     final response = await _dio.get(EndPoints.checkTokenExpired);
  //     final result = response.data;
  //     Logger.info("inside try section -> ${result["messages"].toString()}");
  //     if (result['details'] == "token_not_valid") {
  //       Logger.info("expired");
  //       return Right(true);
  //     } else {
  //       return Right(false);
  //     }
  //   } on DioException catch (e) {
  //     return Right(false);
  //   } catch (e) {
  //     Logger.error(":x: Exception: $e");
  //     return Right(false);
  //   }
  // }

  // Future<Either<ApiException, void>> refreshAuthToken() async {
  //   Logger.info(
  //     "refresh auth token : ${LocaleStoaregService.userRefreshToken}",
  //   );
  //   var data = FormData.fromMap({
  //     'refresh': LocaleStoaregService.userRefreshToken,
  //   });
  //   try {
  //     final response = await _dio.post(Endpoints.refreshToken, data: data);
  //     final result = response.data;
  //     if (result["code"] == token_not_valid) {
  //       return Left(
  //         ApiException(
  //           'Token is expired',
  //           code: '0',
  //           originalErrorMessage: 'Token is expired',
  //         ),
  //       );
  //     } else {
  //       final newToken = result["access"];
  //       // await LocaleStoaregService.saveUserToken(newToken);
  //     }
  //     return Right(null);
  //   } on DioException catch (e) {
  //     return Left(
  //       ApiException(
  //         _handleErrorMessage(e),
  //         code: e.response!.data["code"],
  //         originalErrorMessage: e.message,
  //       ),
  //     );
  //   } catch (e) {
  //     Logger.info(":x: Exception: $e");
  //     return Left(
  //       ApiException(
  //         'Something went wrong',
  //         code: '',
  //         originalErrorMessage: e.toString(),
  //       ),
  //     );
  //   }
  // }

  String _handleErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timed out';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout';
    }
    if (e.response != null) {
      final data = e.response?.data;
      if (e.response?.statusCode == 400) {
        if (data is Map) {
          final errorContent = data['error'] ?? data['errors'];
          // If we found 'error' or 'errors' and it's a map
          if (errorContent is Map && errorContent.isNotEmpty) {
            final firstKey = errorContent.keys.first;
            Logger.info("[Base Api Helper] --- first key: $firstKey");
            final errorValue = errorContent[firstKey];
            if (errorValue is List && errorValue.isNotEmpty) {
              return errorValue.first.toString();
            } else if (errorValue is String) {
              return errorValue;
            }
          }
          // If 'message' exists
          if (data.containsKey('message')) {
            return data['message'].toString();
          }
          // Try generic key-based parsing (Django/DRF style)
          final firstKey = data.keys.firstOrNull;
          final errorList = data[firstKey];
          if (errorList is List && errorList.isNotEmpty) {
            return errorList.first.toString();
          }
        } else if (data is String) {
          return data;
        }
        return 'Invalid request (400)';
      } else if (e.response?.statusCode == 401) {
        return 'Unauthorized. Please log in again.';
      }
      return data[1] ?? 'Unexpected server response';
    }
    return e.message ?? 'Unknown error occurred';
  }
}

class ApiException implements Exception {
  ApiException({required this.errorMsg, required this.code, this.apiErrorMsg});
  final String errorMsg;
  final String? code;
  final String? apiErrorMsg;
  @override
  String toString() {
    return "api error: $errorMsg ----- status code: $code";
  }
}
