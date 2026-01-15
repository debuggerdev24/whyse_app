import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:redstreakapp/core/constants/end_points.dart';
import 'package:redstreakapp/services/base_api_service.dart';

import '../../models/home/story_models/generate_story_request.dart';

class AuthApiServices {
  final _api = DioClient.instance.dio;

  AuthApiServices._();

  static final AuthApiServices _instance = AuthApiServices._();

  factory AuthApiServices() => _instance;

  //todo 2nd
  //@override
  Future<Either<ApiException, Map<String, dynamic>>> startOnboarding({
    required String email,
  }) async {
    Map<String, String> data = {"email": email};
    return await BaseApiHelper.instance.post(
      EndPoints.startOnBoarding, //ing,
      data: data,
    );
  }

  //todo 1st
  // Future<Either<ApiException, Map<String, dynamic>>> getOnboardingProgress({
  //   required String onboardingId,
  // }) async {
  //   return BaseApiHelper.instance.post(
  //     EndPoints.onBoardingProgress,
  //     data: {"identifier": onboardingId},
  //   );
  // }

  Future<dynamic> getOnboardingProgress({required String onboardingId}) async {
    final res = await _api.post(
      EndPoints.onBoardingProgress,
      data: {"identifier": onboardingId},
    );
    return res.data;
  }

  //@override
  Future<Either<ApiException, Map<String, dynamic>>> saveBirthDate({
    required String onboardingId,
    required String dateOfBirth,
  }) async {
    return await BaseApiHelper.instance.post(
      EndPoints.saveAge,
      data: {"onboardingId": onboardingId, "dateOfBirth": dateOfBirth},
    );
  }

  //@override
  Future<dynamic> createAccount({
    required String onboardingId,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final res = await _api.post(
      EndPoints.createAccount,
      data: {
        "onboardingId": onboardingId,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
      },
    );
    return res.data;
  }

  //@override
  Future<dynamic> verifyEmail({
    required String onboardingId,
    required String email,
  }) async {
    final res = await _api.post(
      EndPoints.verifyEmail,
      data: {"onboardingId": onboardingId, "email": email},
    );
    return res.data;
  }

  //@override
  Future<dynamic> saveProfileInfo({
    required String onboardingId,
    required String country,
    required String preferredLanguage,
  }) async {
    final res = await _api.post(
      EndPoints.saveProfile,
      data: {
        "onboardingId": onboardingId,
        "country": country,
        "preferredLanguage": preferredLanguage,
      },
    );
    return res.data;
  }

  //@override
  Future<dynamic> saveReadingGoal({
    required String onboardingId,
    required int dailyReadingGoal,
  }) async {
    final res = await _api.post(
      EndPoints.saveReadings,
      data: {
        "onboardingId": onboardingId,
        "dailyReadingGoal": dailyReadingGoal,
      },
    );
    return res.data;
  }

  //@override
  Future<dynamic> getDefaultInterests() async {
    final res = await _api.get(EndPoints.getDefaultInterest);
    return res.data;
  }

  //@override
  //@override
  Future<dynamic> saveInterests({
    required String onboardingId,
    required List<String> interestIds,
    required List<String> customInterests,
  }) async {
    final res = await _api.post(
      EndPoints.saveInterest,
      data: {
        "onboardingId": onboardingId,
        "interestIds": interestIds,
        "customInterests": customInterests,
      },
    );
    return res.data;
  }

  //@override
  Future<dynamic> getDefaultTopics() async {
    final res = await _api.get(EndPoints.getDefaultTopics);
    return res.data;
  }

  //@override
  Future<dynamic> saveTopics({
    required String onboardingId,
    required List<String> topicIds,
    required List<String> customTopics,
  }) async {
    final res = await _api.post(
      EndPoints.saveTopics,
      data: {
        "onboardingId": onboardingId,
        "topicIds": topicIds,
        "customTopics": customTopics,
      },
    );
    return res.data;
  }

  //@override
  Future<dynamic> getGoals() async {
    final res = await _api.get(EndPoints.getDefaultGoals);
    return res.data;
  }

  //@override
  Future<dynamic> saveGoals({
    required String onboardingId,
    required List<String> goalIds,
    required List<Map<String, String>> customGoals,
  }) async {
    final res = await _api.post(
      EndPoints.saveGoals,
      data: {
        "onboardingId": onboardingId,
        "goalIds": goalIds,
        "customGoals": customGoals,
      },
    );
    return res.data;
  }

  //@override
  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post(
      EndPoints.logIn,
      data: {"email": email, "password": password},
    );
    return res.data;
  }

  Future<Either<ApiException, Map<String, dynamic>>> socialLogin({
    required Map<String, dynamic> data,
  }) async {
    return await BaseApiHelper.instance.post(EndPoints.socialLogin, data: data);
  }

  //@override
  Future<Either<ApiException, Map<String, dynamic>>> saveParentEmail({
    required String onboardingId,
    required String parentEmail,
  }) async {
    return BaseApiHelper.instance.post(
      EndPoints.saveParentEmail,
      data: {"onboardingId": onboardingId, "parentEmail": parentEmail},
    );
  }

  //@override
  Future<dynamic> logOut({required String accessToken}) async {
    final res = await _api.post(
      EndPoints.logOut,
      data: {"accessToken": accessToken},
      options: Options(headers: {"Authorization": "Bearer $accessToken"}),
    );
    return res.data;
  }

  //@override
  Future<dynamic> generateMobileStory(GenerateStoryRequest request) async {
    final res = await _api.post(
      'http://167.172.45.71/api/v1/story/generateMobileStory',
      data: request.toJson(),
      options: Options(receiveTimeout: const Duration(minutes: 5)),
    );
    return res.data;
  }

  //@override
  Future<dynamic> generateStoryImage(GenerateStoryRequest request) async {
    final res = await _api.post(
      'http://167.172.45.71/api/v1/story/generateMobileStoryImage',
      data: request.toJson(),
      options: Options(receiveTimeout: const Duration(minutes: 5)),
    );
    return res.data;
  }

  //@override
  Future<dynamic> linkImageToStory({
    required String storyId,
    required List<String> images,
  }) async {
    final res = await _api.post(
      'http://167.172.45.71/api/v1/story/mobile-story/$storyId/store-images',
      data: {"images": images},
    );
    return res.data;
  }

  //@override
  Future<dynamic> getAllStories() async {
    final res = await _api.get('http://167.172.45.71/api/v1/story/mobile');
    return res.data;
  }

  Future<Either<ApiException, Map<String, dynamic>>> forgotPassword({
    required Map<String, dynamic> data,
  }) {
    return BaseApiHelper.instance.post(EndPoints.forgotPassword, data: data);
  }

  Future<Either<ApiException, Map<String, dynamic>>> verifyForgotPasswordEmail({
    required Map<String, dynamic> data,
  }) {
    return BaseApiHelper.instance.post(EndPoints.verifyToken, data: data);
  }

  Future<Either<ApiException, Map<String, dynamic>>> resetPassword({
    required Map<String, dynamic> data,
  }) {
    return BaseApiHelper.instance.post(EndPoints.resetPassword, data: data);
  }
}
