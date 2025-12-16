import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:redstreakapp/core/constants/shared_pref.dart';

class BaseRepository {
  BaseRepository._();
  static final _instance = BaseRepository._();
  static const baseUrl = "http://167.172.45.71/api/v1/mobile/auth";
  static const apiBaseUrl = "$baseUrl/";
  static BaseRepository get instance => _instance;
  late Dio _dio;

  initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      headers: {
        "Content-Type": "application/json",
        if (SharedPrefs.instance.token != null)
          "Authorization": "Bearer ${SharedPrefs.instance.token}"
      },
    ));

    log("============>access token${SharedPrefs.instance.token}");
    _dio.interceptors.add(
        PrettyDioLogger(request: true, requestBody: true, requestHeader: true));

    // _dio.interceptors.add(InterceptorsWrapper(
    //   onError: (DioException error, ErrorInterceptorHandler handler) async {
    //     // Check if token is invalid
    //     if (error.response?.statusCode == 401 ||
    //         error.response?.statusCode == 400 ||
    //         (error.response?.data?['code'] == 'token_not_valid')) {
    //       log("====refersh api tyring to call");
    //       final refreshed = await _refreshToken();
    //       if (refreshed) {
    //         // Retry original request
    //         final options = error.requestOptions;
    //         options.headers['Authorization'] =
    //             'Bearer ${SharedPrefs.instance.token}';
    //         print(
    //             "============>access token in error${SharedPrefs.instance.token}");
    //         final retryResponse = await _dio.fetch(options);
    //         return handler.resolve(retryResponse);
    //       }
    //     }
    //     return handler.next(error); // pass other errors
    //   },
    // ));
  }

  Dio get dio => _dio;

  addToken(String token) {
    _dio.options = _dio.options.copyWith(headers: {
      'Authorization': "Bearer $token",
    });
    print("Authorization token =======> $token");
  }

  Future<bool> isTokenValid() async {
    final token = SharedPrefs.instance.token;
    return token != null && token.isNotEmpty;
  }

  Future<bool> _refreshToken() async {
    try {
      final dio = Dio();
      final refreshToken = SharedPrefs.instance.refreshToken;

      final response = await _dio.post(
        '${BaseRepository.apiBaseUrl}auth/token/refresh/',
        data: {'refresh': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

//---modification----
      // if (response.data is Map<String, dynamic>) {
      //   final newAccessToken = response.data['access'];
      //   final newRefreshToken = response.data['refresh'];

      //   if (newAccessToken != null) {
      //     SharedPrefs.instance.setToken(newAccessToken);
      //     addToken(newAccessToken);
      //   }

      //   if (newRefreshToken != null) {
      //     SharedPrefs.instance.setRefreshToken(newRefreshToken);
      //   }

      //   print("Token refreshed successfully");
      //   return true;
      // } else {
      //   print("Unexpected response format: ${response.data}");
      //   return false;
      // }
// ---finish modification---

      final newAccessToken = response.data['access'];
      final newRefreshToken = response.data['refresh'];

      SharedPrefs.instance.setRefreshToken(newRefreshToken);
      SharedPrefs.instance.setToken(newAccessToken);

      debugPrint(response.data);
      print("-----called refresh token api");
      SharedPrefs.instance.setToken(response.data['access']);
      print("stored not in shared prefrence");
      print(
          "store refresh token:->${SharedPrefs.instance.setToken(response.data['access'])}");
      addToken(newAccessToken);
      print("new access token:->${newAccessToken}");
      print("Token refreshed successfully");
      return true;
    } catch (e) {
      print("Token refresh failed: $e");
      return false;
    }
  }
}


/* 
  mport 'package:car_repair_service_connector_app/utils/shred_pref.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class BaseRepository {
  BaseRepository._();
  static final _instance = BaseRepository._();
  static const baseUrl = "http://143.110.242.52:8000";
  static const apiBaseUrl = "$baseUrl/";
  static BaseRepository get instance => _instance;
  late Dio _dio;
  initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      headers: {
        "Content-Type": "application/json",
        if (SharedPrefs.instance.token != null)
          "Authorization": "Bearer ${SharedPrefs.instance.token}"
      },
    ));
    _dio.interceptors.add(
        PrettyDioLogger(request: true, requestBody: true, requestHeader: true));
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        // Check if token is invalid
        if (error.response?.statusCode == 401 ||
            (error.response?.data?['code'] == 'token_not_valid')) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry original request
            final options = error.requestOptions;
            options.headers['Authorization'] =
                'Bearer ${SharedPrefs.instance.token}';
            final retryResponse = await _dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        }
        return handler.next(error); // pass other errors
      },
    ));
  }

  Dio get dio => _dio;
  addToken(String token) {
    _dio.options = _dio.options.copyWith(headers: {
      'Authorization': "Bearer $token",
    });
    print("Authorization token =======> $token");
  }

  /// Call this to refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = SharedPrefs.instance.refreshToken;
      final response = await Dio().post(
        'auth/token/refresh/',
        data: {'refresh': SharedPrefs.instance.refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      debugPrint(response.data);
      // final newAccessToken = response.data['access'];
      // final newRefreshToken = response.data['refresh'];
      // // Save new tokens
      // SharedPrefs.instance.token = newAccessToken;
      // SharedPrefs.instance.refreshToken = newRefreshToken;
      // // Update dio header
      // addToken(newAccessToken);
      return true;
    } catch (e) {
      print("Token refresh failed: $e");
      return false;
    }
  }
}
*/