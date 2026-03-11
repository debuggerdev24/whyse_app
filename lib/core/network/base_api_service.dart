import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:redstreakapp/core/auth/session_expiry_notifier.dart';
import 'package:redstreakapp/core/network/end_points.dart';
import 'package:redstreakapp/core/utils/shared_pref.dart';

import '../helper/log_helper.dart';

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
  Completer<String?>? _refreshCompleter;
  bool _isHandlingSessionExpiry = false;

  initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 180),
        sendTimeout: const Duration(seconds: 120),
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );

    Logger.info(
      "Authorization Token : ${LocalStorageService.instance.getAuthToken.toString()}",
    );
    Logger.info(
      "Authorization Token : ${LocalStorageService.instance.getRefreshToken.toString()}",
    );
    Logger.info(
      "onBoarding ID : ${LocalStorageService.instance.onboardingId.toString()}",
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = LocalStorageService.instance.getAuthToken;
          options.headers["Content-Type"] = "application/json";
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          } else {
            options.headers.remove("Authorization");
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (!_shouldHandleUnauthorized(error)) {
            handler.next(error);
            return;
          }

          final refreshedToken = await _refreshAccessToken();
          if (refreshedToken == null || refreshedToken.isEmpty) {
            await _handleSessionExpiry();
            handler.next(error);
            return;
          }

          try {
            final response = await _retryRequest(
              requestOptions: error.requestOptions,
              accessToken: refreshedToken,
            );
            handler.resolve(response);
          } on DioException catch (retryError) {
            handler.next(retryError);
          } catch (_) {
            handler.next(error);
          }
        },
      ),
    );
    _dio.interceptors.add(
      PrettyDioLogger(request: true, requestBody: true, requestHeader: true),
    );
  }

  Dio get dio => _dio;

  addToken(String token) {
    _isHandlingSessionExpiry = false;
    _dio.options.headers["Authorization"] = "Bearer $token";
  }

  void clearToken() {
    _dio.options.headers.remove("Authorization");
  }

  Future<bool> isTokenValid() async {
    final token = LocalStorageService.instance.getAuthToken;
    return token != null && token.isNotEmpty;
  }

  bool _shouldHandleUnauthorized(DioException error) {
    final statusCode = error.response?.statusCode;
    final requestOptions = error.requestOptions;
    final path = requestOptions.path;

    if (statusCode != 401) return false;
    if (requestOptions.extra["skipAuthRefresh"] == true) return false;
    if (requestOptions.extra["hasRetried"] == true) return false;
    if (path == EndPoints.refreshToken) return false;
    if (path.startsWith("/mobile/auth/")) return false;

    return true;
  }

  Future<String?> _refreshAccessToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();
    final refreshToken = LocalStorageService.instance.getRefreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      _refreshCompleter!.complete(null);
      final future = _refreshCompleter!.future;
      future.whenComplete(() => _refreshCompleter = null);
      return future;
    }

    final refreshDio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 180),
        sendTimeout: const Duration(seconds: 120),
        headers: {"Content-Type": "application/json"},
      ),
    );

    try {
      final response = await refreshDio.post(
        EndPoints.refreshToken,
        data: {"refreshToken": refreshToken},
      );
      final session = response.data["session"] as Map<String, dynamic>?;
      final accessToken = session?["accessToken"]?.toString();
      final nextRefreshToken = session?["refreshToken"]?.toString();

      if (accessToken == null || accessToken.isEmpty) {
        _refreshCompleter!.complete(null);
      } else {
        await LocalStorageService.instance.saveAuthToken(accessToken);
        if (nextRefreshToken != null && nextRefreshToken.isNotEmpty) {
          await LocalStorageService.instance.saveRefreshToken(nextRefreshToken);
        }
        addToken(accessToken);
        _refreshCompleter!.complete(accessToken);
      }
    } catch (e, stack) {
      Logger.error("Refresh token failed: $e\n$stack");
      _refreshCompleter!.complete(null);
    }

    final future = _refreshCompleter!.future;
    future.whenComplete(() => _refreshCompleter = null);
    return future;
  }

  Future<Response<dynamic>> _retryRequest({
    required RequestOptions requestOptions,
    required String accessToken,
  }) {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        "Authorization": "Bearer $accessToken",
      },
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      sendTimeout: requestOptions.sendTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
      extra: {...requestOptions.extra, "hasRetried": true},
      followRedirects: requestOptions.followRedirects,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      validateStatus: requestOptions.validateStatus,
      listFormat: requestOptions.listFormat,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      cancelToken: requestOptions.cancelToken,
      options: options,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
    );
  }

  Future<void> _handleSessionExpiry() async {
    if (_isHandlingSessionExpiry) return;
    _isHandlingSessionExpiry = true;

    await LocalStorageService.instance.removeAuthToken();
    await LocalStorageService.instance.removeRefreshToken();
    clearToken();
    SessionExpiryNotifier.instance.notifySessionExpired();
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
        return "Something went wrong. Please restart again.";//'Unauthorized. Please log in again.';
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
