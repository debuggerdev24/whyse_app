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
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          "Content-Type": "application/json",
          if (SharedPrefs.instance.token != null)
            "Authorization": "Bearer ${SharedPrefs.instance.token}",
        },
      ),
    );

    log("============>access token${SharedPrefs.instance.token}");
    _dio.interceptors.add(
      PrettyDioLogger(request: true, requestBody: true, requestHeader: true),
    );
  }

  Dio get dio => _dio;

  addToken(String token) {
    _dio.options = _dio.options.copyWith(
      headers: {'Authorization': "Bearer $token"},
    );
    print("Authorization token =======> $token");
  }

  Future<bool> isTokenValid() async {
    final token = SharedPrefs.instance.token;
    return token != null && token.isNotEmpty;
  }
}
