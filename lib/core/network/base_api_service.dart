import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:redstreakapp/core/auth/session_expiry_notifier.dart';
import 'package:redstreakapp/core/network/end_points.dart';
import 'package:redstreakapp/core/utils/shared_pref.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import '../helper/log_helper.dart';

class DioClient {
  DioClient._();
  static final _instance = DioClient._();
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://whyse.com';
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
        receiveTimeout: const Duration(seconds: 300),
        sendTimeout: const Duration(seconds: 120),
        headers: {"Content-Type": "application/json"},
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
          if (options.data is! FormData) {
            options.headers["Content-Type"] = "application/json";
          } else {
            options.headers.remove("Content-Type");
          }
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

  static const int _nullDataMaxRetries = 1;
  static const Duration _nullDataRetryDelay = Duration(milliseconds: 350);

  bool _shouldRetryNullData({
    required String method,
    required int attempt,
    required Options? options,
  }) {
    if (attempt >= _nullDataMaxRetries) return false;
    final retryDisabled = options?.extra?["retryOnNullData"] == false;
    if (retryDisabled) return false;
    // Default safety: auto-retry GET/DELETE only. For POST/PATCH, opt-in by
    // passing options.extra["retryOnNullData"]=true on that call site.
    final normalized = method.toUpperCase();
    final optIn = options?.extra?["retryOnNullData"] == true;
    if (normalized == "GET" || normalized == "DELETE") return true;
    return optIn;
  }

  Future<Response<dynamic>> _requestWithNullDataRetry({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    DioException? lastDioError;
    for (var attempt = 0;; attempt++) {
      try {
        late final Response<dynamic> response;
        switch (method.toUpperCase()) {
          case "GET":
            response = await _dio.get(
              path,
              queryParameters: queryParameters,
              options: options,
            );
            break;
          case "POST":
            response = await _dio.post(
              path,
              data: data,
              queryParameters: queryParameters,
              options: options,
            );
            break;
          case "PATCH":
            response = await _dio.patch(
              path,
              data: data,
              queryParameters: queryParameters,
              options: options,
            );
            break;
          case "DELETE":
            response = await _dio.delete(
              path,
              data: data,
              queryParameters: queryParameters,
              options: options,
            );
            break;
          default:
            response = await _dio.request(
              path,
              data: data,
              queryParameters: queryParameters,
              options: (options ?? Options()).copyWith(method: method),
            );
        }

        // Retry once when backend returns success but data is null.
        if (response.data == null &&
            _shouldRetryNullData(method: method, attempt: attempt, options: options)) {
          Logger.warning(
            "Null API response data for $method $path. Retrying (${attempt + 1}/$_nullDataMaxRetries)...",
          );
          await Future<void>.delayed(_nullDataRetryDelay);
          continue;
        }
        return response;
      } on DioException catch (e) {
        lastDioError = e;
        // Some backends return DioExceptionType.unknown with null message/data on transient disconnects.
        // We only auto-retry these for GET/DELETE unless opted in.
        final isNullLike = e.response == null && (e.message == null || e.message!.trim().isEmpty);
        if (isNullLike &&
            _shouldRetryNullData(method: method, attempt: attempt, options: options)) {
          Logger.warning(
            "Unknown Dio error for $method $path (null response). Retrying (${attempt + 1}/$_nullDataMaxRetries)...",
          );
          await Future<void>.delayed(_nullDataRetryDelay);
          continue;
        }
        rethrow;
      }
    }
    // Unreachable but keeps analyzer happy.
    // ignore: dead_code
    throw lastDioError!;
  }

  Future<Either<ApiException, T>> get<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _requestWithNullDataRetry(
        method: "GET",
        path: path,
        queryParameters: queryParameters,
        options: options,
      );
      final result = response.data;
      if (result is String && isUnsuitableUserFacingText(result)) {
        return Left(
          ApiException(
            errorMsg:
                'Could not reach the server. Please check your connection and try again.',
            code: response.statusCode?.toString(),
            apiErrorMsg: 'non_json_response',
          ),
        );
      }
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
    } catch (e) {
      Logger.error(':x: API get unexpected: $e');
      return Left(
        ApiException(
          errorMsg: 'Something went wrong. Please try again.',
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
      final response = await _requestWithNullDataRetry(
        method: "POST",
        path: path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      final result = response.data;
      if (result is String && isUnsuitableUserFacingText(result)) {
        return Left(
          ApiException(
            errorMsg:
                'Could not reach the server. Please check your connection and try again.',
            code: response.statusCode?.toString(),
            apiErrorMsg: 'non_json_response',
          ),
        );
      }
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
      final response = await _requestWithNullDataRetry(
        method: "DELETE",
        path: path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      final result = response.data;
      if (result is String && isUnsuitableUserFacingText(result)) {
        return Left(
          ApiException(
            errorMsg:
                'Could not reach the server. Please check your connection and try again.',
            code: response.statusCode?.toString(),
            apiErrorMsg: 'non_json_response',
          ),
        );
      }
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
      final response = await _requestWithNullDataRetry(
        method: "PATCH",
        path: path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      final result = response.data;
      if (result is String && isUnsuitableUserFacingText(result)) {
        return Left(
          ApiException(
            errorMsg:
                'Could not reach the server. Please check your connection and try again.',
            code: response.statusCode?.toString(),
            apiErrorMsg: 'non_json_response',
          ),
        );
      }
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
    final response = e.response;
    if (response == null) {
      return userFacingMessage(e.message, fallback: 'Unknown error occurred');
    }

    final data = response.data;
    final statusCode = response.statusCode;

    if (statusCode == 401) {
      return 'Something went wrong. Please restart again.';
    }

    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      if (data is Map) {
        final errorContent = data['error'] ?? data['errors'];
        if (errorContent is Map && errorContent.isNotEmpty) {
          final firstKey = errorContent.keys.first;
          Logger.info('[Base Api Helper] --- first key: $firstKey');
          final errorValue = errorContent[firstKey];
          if (errorValue is List && errorValue.isNotEmpty) {
            final first = errorValue.first;
            if (first is Map && first['msg'] != null) {
              return userFacingMessage(first['msg']?.toString());
            }
            return userFacingMessage(first.toString());
          } else if (errorValue is String) {
            return userFacingMessage(errorValue);
          }
        }
        if (data.containsKey('message')) {
          return userFacingMessage(data['message']?.toString());
        }
        if (data.isNotEmpty) {
          final firstKey = data.keys.first;
          final errorList = data[firstKey];
          if (errorList is List && errorList.isNotEmpty) {
            final first = errorList.first;
            if (first is Map && first['msg'] != null) {
              return userFacingMessage(first['msg']?.toString());
            }
          }
        }
      } else if (data is String) {
        return userFacingMessage(
          data,
          fallback: 'Could not reach the server. Please try again.',
        );
      }
      return userFacingMessage(
        null,
        fallback: 'Invalid request. Please try again.',
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return userFacingMessage(
        null,
        fallback: 'Server error. Please try again later.',
      );
    }

    return userFacingMessage(
      response.statusMessage,
      fallback: 'Unexpected server response',
    );
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
