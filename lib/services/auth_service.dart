import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:redstreakapp/services/base_api_service.dart';

abstract class BaseAuthService {
  Future<dynamic> startOnboarding({required String email});
  Future<dynamic> getOnboardingProgress({required String onboardingId});
  Future<dynamic> saveAge({
    required String onboardingId,
    required String dateOfBirth,
  });
  Future<dynamic> createAccount({
    required String onboardingId,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  });
  Future<dynamic> saveProfileInfo({
    required String onboardingId,
    required String country,
    required String preferredLanguage,
  });
  Future<dynamic> saveReadingGoal({
    required String onboardingId,
    required int dailyReadingGoal,
  });
  Future<dynamic> getDefaultInterests();
  Future<dynamic> saveInterests({
    required String onboardingId,
    required List<String> interestIds,
    required List<String> customInterests,
  });
  Future<dynamic> getDefaultTopics();
  Future<dynamic> saveTopics({
    required String onboardingId,
    required List<String> topicIds,
    required List<String> customTopics,
  });
  Future<dynamic> getDefaultGoals();
  Future<dynamic> saveGoals({
    required String onboardingId,
    required List<String> goalIds,
    required List<Map<String, String>> customGoals,
  });
  Future<dynamic> login({required String email, required String password});
  Future<dynamic> saveParentEmail({
    required String onboardingId,
    required String parentEmail,
  });
  Future<dynamic> logOut({required String accessToken});
}

class AuthServices implements BaseAuthService {
  final _api = BaseRepository.instance.dio;

  AuthServices._();

  static final AuthServices _instance = AuthServices._();

  factory AuthServices() => _instance;

  @override
  Future<dynamic> startOnboarding({required String email}) async {
    Map<String, String> data = {"email": email};
    final res = await _api.post('start-onboarding', data: data);
    return res.data;
  }

  @override
  Future<dynamic> getOnboardingProgress({required String onboardingId}) async {
    final res = await _api.post(
      'onboarding-progress',
      data: {"identifier": onboardingId},
    );
    return res.data;
  }

  @override
  Future<dynamic> saveAge({
    required String onboardingId,
    required String dateOfBirth,
  }) async {
    final res = await _api.post(
      'save-age',
      data: {"onboardingId": onboardingId, "dateOfBirth": dateOfBirth},
    );
    return res.data;
  }

  @override
  Future<dynamic> createAccount({
    required String onboardingId,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final res = await _api.post(
      'create-account',
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

  @override
  Future<dynamic> saveProfileInfo({
    required String onboardingId,
    required String country,
    required String preferredLanguage,
  }) async {
    final res = await _api.post(
      'save-profile-info',
      data: {
        "onboardingId": onboardingId,
        "country": country,
        "preferredLanguage": preferredLanguage,
      },
    );
    return res.data;
  }

  @override
  Future<dynamic> saveReadingGoal({
    required String onboardingId,
    required int dailyReadingGoal,
  }) async {
    final res = await _api.post(
      'save-reading-goal',
      data: {
        "onboardingId": onboardingId,
        "dailyReadingGoal": dailyReadingGoal,
      },
    );
    return res.data;
  }

  @override
  Future<dynamic> getDefaultInterests() async {
    final res = await _api.get('default-interests');
    return res.data;
  }

  @override
  @override
  Future<dynamic> saveInterests({
    required String onboardingId,
    required List<String> interestIds,
    required List<String> customInterests,
  }) async {
    final res = await _api.post(
      'save-interests',
      data: {
        "onboardingId": onboardingId,
        "interestIds": interestIds,
        "customInterests": customInterests,
      },
    );
    return res.data;
  }

  @override
  Future<dynamic> getDefaultTopics() async {
    final res = await _api.get('default-topics');
    return res.data;
  }

  @override
  Future<dynamic> saveTopics({
    required String onboardingId,
    required List<String> topicIds,
    required List<String> customTopics,
  }) async {
    final res = await _api.post(
      'save-topics',
      data: {
        "onboardingId": onboardingId,
        "topicIds": topicIds,
        "customTopics": customTopics,
      },
    );
    return res.data;
  }

  @override
  Future<dynamic> getDefaultGoals() async {
    final res = await _api.get('default-goals');
    return res.data;
  }

  @override
  Future<dynamic> saveGoals({
    required String onboardingId,
    required List<String> goalIds,
    required List<Map<String, String>> customGoals,
  }) async {
    final res = await _api.post(
      'save-goals',
      data: {
        "onboardingId": onboardingId,
        "goalIds": goalIds,
        "customGoals": customGoals,
      },
    );
    return res.data;
  }

  @override
  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post(
      'login',
      data: {"email": email, "password": password},
    );
    return res.data;
  }

  @override
  Future<dynamic> saveParentEmail({
    required String onboardingId,
    required String parentEmail,
  }) async {
    final res = await _api.post(
      'save-parent-email',
      data: {"onboardingId": onboardingId, "parentEmail": parentEmail},
    );
    return res.data;
  }

  @override
  Future<dynamic> logOut({required String accessToken}) async {
    final res = await _api.post(
      'logout',
      data: {"accessToken": accessToken},
      options: Options(headers: {"Authorization": "Bearer $accessToken"}),
    );
    return res.data;
  }

  // @override
  // Future signUpUser({
  //   required String userName,
  //   required String mobileNo,
  //   required String password,
  //   required String confirmPassword,
  // }) async {
  //   final Map<String, dynamic> parms = {
  //     "username": userName,
  //     "mobile_number": mobileNo,
  //     "password": password,
  //     "confirm_password": confirmPassword,
  //   };
  //   final res = await _api.post("auth/signup/user", data: parms);
  //   return res.data;
  // }

  // @override
  // Future signUpAdmin({
  //   required String userName,
  //   required String mobileNo,
  //   required String password,
  //   required String confirmPassword,
  // }) async {
  //   final Map<String, dynamic> parms = {
  //     "username": userName,
  //     "mobile_number": mobileNo,
  //     "password": password,
  //     "confirm_password": confirmPassword,
  //   };
  //   final res = await _api.post("auth/signup/admin", data: parms);
  //   return res.data;
  // }

  // @override
  // Future signUpMechanic({
  //   required String userName,
  //   required String mobileNo,
  //   required String password,
  //   required String confirmPassword,
  //   /*required List<String> servicesExpertise*/
  // }) async {
  //   final Map<String, dynamic> parms = {
  //     "username": userName,
  //     "mobile_number": mobileNo,
  //     "password": password,
  //     "confirm_password": confirmPassword,
  //     /*"services_expertise": servicesExpertise*/
  //   };
  //   final res = await _api.post("auth/signup/mechanic", data: parms);
  //   return res.data;
  // }

  // @override
  // Future verifyOtp({required String mobileNo, required String otp}) async {
  //   final Map<String, dynamic> parms = {
  //     "mobile_number": mobileNo,
  //     "otp_code": otp,
  //   };
  //   final res = await _api.post("auth/verify-otp", data: parms);
  //   return res.data;
  // }

  // @override
  // Future requestOtp({required String mobileNo}) async {
  //   final Map<String, dynamic> parms = {"mobile_number": mobileNo};
  //   final res = await _api.post(
  //     "auth/forget-password/request-otp",
  //     data: parms,
  //   );
  //   return res.data;
  // }

  // @override
  // Future forgetVerifyOtp({
  //   required String mobileNo,
  //   required String otp,
  // }) async {
  //   final Map<String, dynamic> parms = {
  //     "mobile_number": mobileNo,
  //     "otp_code": otp,
  //   };
  //   final res = await _api.post("auth/forget-password/verify-otp", data: parms);
  //   return res.data;
  // }

  // @override
  // Future resetPassoword({
  //   required String mobileNo,
  //   required String newPassword,
  //   required String confirmPassword,
  // }) async {
  //   final Map<String, dynamic> params = {
  //     "mobile_number": mobileNo,
  //     "new_password": newPassword,
  //     "confirm_password": confirmPassword,
  //   };
  //   final res = await _api.post("auth/forget-password/reset", data: params);
  //   return res.data;
  // }

  // @override
  // Future logOut() async {
  //   final res = await _api.get('logout');
  //   return res.data;
  // }
}
