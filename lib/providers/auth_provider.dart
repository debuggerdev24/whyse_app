import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:redstreakapp/core/constants/shared_pref.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/services/auth/auth_api_service.dart';
import 'package:redstreakapp/services/base_api_service.dart';

import '../core/helper/log_helper.dart';
import '../models/home/story_models/generate_story_request.dart';
import '../models/home/story_models/story_model.dart';

class AuthProvider with ChangeNotifier {
  TextEditingController signUpEmailCtr = TextEditingController();
  TextEditingController loginEmailCtr = TextEditingController();
  TextEditingController forgotPasswordCtr = TextEditingController();
  TextEditingController otpCtr = TextEditingController();
  TextEditingController newPasswordCtr = TextEditingController();
  TextEditingController resetConfirmPasswordCtr = TextEditingController();
  TextEditingController parentEmailCtr = TextEditingController();
  bool isLoading = false, isStoryCreation = false;
  int? age;
  int calculatedAge = 0;
  DateTime? selectedDate;

  set setIsFromHome(bool value) {
    isStoryCreation = value;
  }

  void setDate(DateTime date) {
    selectedDate = date;
    calculateAge();
    notifyListeners();
  }

  void calculateAge() {
    if (selectedDate == null) return;
    final today = DateTime.now();
    int calculatedAge = today.year - selectedDate!.year;
    if (today.month < selectedDate!.month ||
        (today.month == selectedDate!.month && today.day < selectedDate!.day)) {
      calculatedAge--;
    }
    age = calculatedAge;
  }

  bool get isAbove16 => true; // Forced to always be true
  bool get isBelow16 => false; // Forced to always be false

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isStartOnBoardingLoading = false;
  Future<void> startOnboarding({
    required BuildContext context,
    required VoidCallback onSuccess,
    required Function(String error) onFailed,
  }) async {
    final email = signUpEmailCtr.text.trim();
    if (email.isEmpty) {
      AppToast.error(context, "Please enter email!");
      return;
    }
    if (!_isValidEmail(email)) {
      AppToast.error(context, "Please enter a valid email");
      return;
    }

    isStartOnBoardingLoading = true;
    notifyListeners();

    final response = await AuthServices().startOnboarding(email: email);

    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) async {
        final data = r['data'];
        await SharedPrefs.instance.setOnboardingEmail(data['email']);
        await SharedPrefs.instance.setOnboardingId(data['onboardingId']);
        onSuccess.call();
        signUpEmailCtr.clear();
      },
    );

    isStartOnBoardingLoading = false;
    notifyListeners();
  }

  Future<String?> fetchOnboardingStep() async {
    try {
      final onboardingId = SharedPrefs.instance.onboardingId;
      if (onboardingId == null) return null;

      final response = await AuthServices().getOnboardingProgress(
        onboardingId: onboardingId,
      );
      response.fold((l) {}, (r) {
        final data = r['data'];

        if (data['nextStep'] != null &&
            data['nextStep'].toString().isNotEmpty) {
          return data['nextStep'];
        }

        if (data['currentStep'] == 'CREATE_ACCOUNT' &&
            data['userProfile'] != null &&
            data['userProfile']['firstName'] != null) {
          return 'PROFILE_INFO';
        }

        if (data['currentStep'] == 'PROFILE_INFO' &&
            data['userProfile'] != null &&
            data['userProfile']['country'] != null) {
          return 'READING_GOAL';
        }

        if (data['currentStep'] == 'READING_GOAL' &&
            data['userProfile'] != null &&
            data['userProfile']['dailyReadingGoal'] != null) {
          return 'INTERESTS';
        }

        if (data['currentStep'] == 'INTERESTS' &&
            ((data['userInterests'] != null &&
                    (data['userInterests'] as List).isNotEmpty) ||
                (data['userProfile']['interests'] != null &&
                    (data['userProfile']['interests'] as List).isNotEmpty))) {
          return 'TOPICS';
        }

        if (data['currentStep'] == 'TOPICS' &&
            ((data['userTopics'] != null &&
                    (data['userTopics'] as List).isNotEmpty) ||
                (data['userProfile']['topics'] != null &&
                    (data['userProfile']['topics'] as List).isNotEmpty))) {
          return 'GOALS';
        }

        if (data['currentStep'] == 'GOALS' &&
            ((data['userGoals'] != null &&
                    (data['userGoals'] as List).isNotEmpty) ||
                (data['userProfile']['goals'] != null &&
                    (data['userProfile']['goals'] as List).isNotEmpty))) {
          return 'COMPLETED';
        }

        return data['currentStep'];
      });
      return null;
    } catch (e) {
      debugPrint("Onboarding progress error: $e");
      return null;
    }
  }

  //todo
  bool get isUnder16 => calculatedAge! < 16;

  bool isSaveUserAgeLoading = false;
  Future<void> saveUserAge({
    required BuildContext context,
    required Function onSuccess,
    required Function(String error) onFailed,
  }) async {
    //todo checking onBoarding id null or not
    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "Onboarding session not found");
      return;
    }

    //todo Calculate age to check if we need to spoof for backend compliance
    String dateToSend = calculateDateToSend();
    Logger.info("dateToSend $dateToSend");

    isSaveUserAgeLoading = true;
    notifyListeners();

    final response = await AuthServices().saveBirthDate(
      onboardingId: onboardingId,
      dateOfBirth: dateToSend,
    );
    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) async {
        await SharedPrefs.instance.setAgeCompleted(true);

        onSuccess.call();
      },
    );

    isSaveUserAgeLoading = false;
    notifyListeners();
  }

  String calculateDateToSend() {
    final today = DateTime.now();
    calculatedAge = today.year - selectedDate!.year;
    if (today.month < selectedDate!.month ||
        (today.month == selectedDate!.month && today.day < selectedDate!.day)) {
      calculatedAge--;
    }
    String dateToSend;
    // if (calculatedAge < 16) {
    //   final spoofDate = DateTime(
    //     today.year, //- 18
    //     selectedDate!.month,
    //     selectedDate!.day,
    //   );
    //   dateToSend =
    //       "${spoofDate.year}-${spoofDate.month.toString().padLeft(2, '0')}-${spoofDate.day.toString().padLeft(2, '0')}";
    // } else {
    //   dateToSend =
    //   "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
    // }
    dateToSend =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
    return dateToSend;
  }

  // Create Account Properties
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController signupEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isCreateAccountLoading = false;
  Future<bool> createAccount(
    BuildContext context, {
    required bool isTermsAccepted,
  }) async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = signupEmailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (firstName.isEmpty) {
      AppToast.error(context, "Please enter your first name");
      return false;
    }
    if (lastName.isEmpty) {
      AppToast.error(context, "Please enter your last name");
      return false;
    }
    if (email.isEmpty) {
      AppToast.error(context, "Please enter your email");
      return false;
    }
    if (!_isValidEmail(email)) {
      AppToast.error(context, "Please enter a valid email");
      return false;
    }

    if (password.isEmpty) {
      AppToast.error(context, "Please enter your password");
      return false;
    }
    if (confirmPassword.isEmpty) {
      AppToast.error(context, "Please confirm your password");
      return false;
    }

    if (password != confirmPassword) {
      AppToast.error(context, "Passwords do not match");
      return false;
    }

    if (!isTermsAccepted) {
      AppToast.error(context, "Please accept Terms and Conditions");
      return false;
    }

    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "Session invalid");
      return false;
    }

    try {
      isCreateAccountLoading = true;
      notifyListeners();

      final response = await AuthServices().createAccount(
        onboardingId: onboardingId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      isCreateAccountLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        // If success here, it usually means account created OR verified successfully
        AppToast.success(
          context,
          response['message'] ?? "Account created successfully",
        );
        return true;
      } else {
        if (response['errors'] != null &&
            (response['errors'] as List).isNotEmpty) {
          final firstError = response['errors'][0];
          final msg = firstError['msg'] ?? "Failed to create account";
          AppToast.error(context, msg);
        } else {
          final msg = response['message'] ?? "Failed to create account";
          AppToast.error(context, msg);
        }
        return false;
      }
    } catch (e) {
      isCreateAccountLoading = false;
      notifyListeners();

      // Check for DioException to extract backend error message
      if (e is DioException) {
        final data = e.response?.data;
        if (data != null) {
          // Check for 'errors' list style
          if (data['errors'] != null && (data['errors'] as List).isNotEmpty) {
            final firstError = data['errors'][0];
            final msg = firstError['msg'] ?? "An error occurred";
            AppToast.error(context, msg);
            return false;
          }
          // Check for top-level 'message'
          if (data['message'] != null) {
            AppToast.error(context, data['message']);
            return false;
          }
        }
      }

      AppToast.error(context, e.toString());
      return false;
    }
  }

  bool isVerifyEmailLoading = false;
  Future<bool> checkEmailVerification(BuildContext context) async {
    final onboardingId = SharedPrefs.instance.onboardingId;
    final email = signupEmailController.text.trim();

    if (onboardingId == null) {
      AppToast.error(context, "Session invalid");
      return false;
    }

    try {
      isVerifyEmailLoading = true;
      notifyListeners();

      final response = await AuthServices().verifyEmail(
        onboardingId: onboardingId,
        email: email,
      );

      isVerifyEmailLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        AppToast.success(
          context,
          response['message'] ?? "Email verified successfully",
        );

        return true;
      } else {
        AppToast.error(
          context,
          response['message'] ?? "Email not verified or verification failed",
        );
        return false;
      }
    } catch (e) {
      isVerifyEmailLoading = false;
      notifyListeners();
      AppToast.error(context, e.toString());
      return false;
    }
  }

  bool isSaveProfileLoading = false;
  Future<bool> saveProfileInfo(
    BuildContext context, {
    required String country,
    required String preferredLanguage,
  }) async {
    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "Session invalid");
      return false;
    }

    try {
      isSaveProfileLoading = true;
      notifyListeners();

      final response = await AuthServices().saveProfileInfo(
        onboardingId: onboardingId,
        country: country,
        preferredLanguage: preferredLanguage,
      );

      isSaveProfileLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        AppToast.success(
          context,
          response['message'] ?? "Profile info saved successfully",
        );
        return true;
      } else {
        AppToast.error(
          context,
          response['message'] ?? "Failed to save profile info",
        );
        return false;
      }
    } catch (e) {
      isSaveProfileLoading = false;
      notifyListeners();
      AppToast.error(context, e.toString());
      return false;
    }
  }

  bool isSaveReadingGoal = false;
  Future<bool> saveReadingGoal(
    BuildContext context, {
    required int dailyReadingGoal,
  }) async {
    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "Session invalid");
      return false;
    }

    try {
      isSaveReadingGoal = true;
      notifyListeners();

      final response = await AuthServices().saveReadingGoal(
        onboardingId: onboardingId,
        dailyReadingGoal: dailyReadingGoal,
      );

      isSaveReadingGoal = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        AppToast.success(
          context,
          response['message'] ?? "Reading goal saved successfully",
        );
        return true;
      } else {
        AppToast.error(
          context,
          response['message'] ?? "Failed to save reading goal",
        );
        return false;
      }
    } catch (e) {
      isSaveReadingGoal = false;
      notifyListeners();
      AppToast.error(context, e.toString());
      return false;
    }
  }

  // Interests Logic
  bool isLoadingInterests = false;
  List<dynamic> interestsList = [];

  Future<void> fetchDefaultInterests(BuildContext context) async {
    try {
      isLoadingInterests = true;
      notifyListeners();
      final response = await AuthServices().getDefaultInterests();
      isLoadingInterests = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        interestsList = response['data'] ?? [];
      } else {
        // CustomToast.showError(
        //   context,
        //   response['message'] ?? "Failed to fetch interests",
        // );
      }
    } catch (e) {
      isLoadingInterests = false;
      notifyListeners();
      debugPrint("Fetch interests error: $e");
    }
  }

  bool isSaveInterestLoading = false;
  Future<bool> saveInterests(
    BuildContext context, {
    required List<String> interestIds,
    required List<String> customInterests,
  }) async {
    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "Session invalid");
      return false;
    }

    try {
      isSaveInterestLoading = true;
      notifyListeners();

      final response = await AuthServices().saveInterests(
        onboardingId: onboardingId,
        interestIds: interestIds,
        customInterests: customInterests,
      );

      isSaveInterestLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        AppToast.success(
          context,
          response['message'] ?? "Interests saved successfully",
        );
        return true;
      } else {
        AppToast.error(
          context,
          response['message'] ?? "Failed to save interests",
        );
        return false;
      }
    } catch (e) {
      isSaveInterestLoading = false;
      notifyListeners();
      AppToast.error(context, e.toString());
      return false;
    }
  }

  // Topics Logic
  bool isLoadingTopics = false;
  List<dynamic> topicsList = [];

  Future<void> fetchDefaultTopics(BuildContext context) async {
    try {
      isLoadingTopics = true;
      notifyListeners();

      final response = await AuthServices().getDefaultTopics();

      isLoadingTopics = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        topicsList = response['data'] ?? [];
      } else {
        AppToast.error(
          context,
          response['message'] ?? "Failed to fetch topics",
        );
      }
    } catch (e) {
      isLoadingTopics = false;
      notifyListeners();
      debugPrint("Fetch topics error: $e");
    }
  }

  bool isSaveTopicsLoading = false;
  Future<bool> saveTopics(
    BuildContext context, {
    required List<String> topicIds,
    required List<String> customTopics,
  }) async {
    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "Session invalid");
      return false;
    }

    try {
      isSaveTopicsLoading = true;
      notifyListeners();

      final response = await AuthServices().saveTopics(
        onboardingId: onboardingId,
        topicIds: topicIds,
        customTopics: customTopics,
      );

      isSaveTopicsLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        AppToast.success(
          context,
          response['message'] ?? "Topics saved successfully",
        );
        return true;
      } else {
        AppToast.error(context, response['message'] ?? "Failed to save topics");
        return false;
      }
    } catch (e) {
      isSaveTopicsLoading = false;
      notifyListeners();
      AppToast.error(context, e.toString());
      return false;
    }
  }

  // Goals Logic
  bool isLoadingGoals = false;
  List<dynamic> goalsList = [];

  Future<void> getGoals(BuildContext context) async {
    try {
      isLoadingGoals = true;
      notifyListeners();

      final response = await AuthServices().getGoals();

      isLoadingGoals = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        goalsList = response['data'] ?? [];
      } else {
        AppToast.error(context, response['message'] ?? "Failed to fetch goals");
      }
    } catch (e) {
      isLoadingGoals = false;
      notifyListeners();
      debugPrint("Fetch goals error: $e");
    }
  }

  bool isSaveGoalsLoading = false;
  Future<bool> saveGoals(
    BuildContext context, {
    required List<String> goalIds,
    required List<Map<String, String>> customGoals,
  }) async {
    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "Session invalid");
      return false;
    }

    try {
      isSaveGoalsLoading = true;
      notifyListeners();

      final response = await AuthServices().saveGoals(
        onboardingId: onboardingId,
        goalIds: goalIds,
        customGoals: customGoals,
      );

      isSaveGoalsLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        AppToast.success(
          context,
          response['message'] ?? "Goals saved successfully",
        );
        return true;
      } else {
        AppToast.error(context, response['message'] ?? "Failed to save goals");
        return false;
      }
    } catch (e) {
      isSaveGoalsLoading = false;
      notifyListeners();
      AppToast.error(context, e.toString());
      return false;
    }
  }

  bool isLoginLoading = false;
  Future<bool> login(BuildContext context) async {
    final email = loginEmailCtr.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      AppToast.error(context, "Please enter your email");
      return false;
    }
    if (password.isEmpty) {
      AppToast.error(context, "Please enter your password");
      return false;
    }

    try {
      isLoginLoading = true;
      notifyListeners();

      final response = await AuthServices().login(
        email: email,
        password: password,
      );

      isLoginLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        final data = response['data'];
        debugPrint("Login Response Data: $data"); // Debug log

        if (data != null) {
          String? token;

          // Check for nested session object first (as seen in logs)
          if (data['session'] != null) {
            final session = data['session'];

            // Extract access token
            if (session['accessToken'] != null) {
              token = session['accessToken'];
            }

            // Extract refresh token
            if (session['refreshToken'] != null) {
              await SharedPrefs.instance.setRefreshToken(
                session['refreshToken'],
              );
            }
          }
          // Fallback to flat structure
          else if (data['accessToken'] != null) {
            token = data['accessToken'];
          } else if (data['token'] != null) {
            token = data['token'];
          }

          if (token != null) {
            await SharedPrefs.instance.setToken(token);
            // Update the current API instance with the new token immediately
            DioClient.instance.addToken(token);
            debugPrint("Token saved successfully from login: $token");
          } else {
            debugPrint("No access token found in login response!");
          }

          if (data['onboardingId'] != null) {
            await SharedPrefs.instance.setOnboardingId(
              data['onboardingId'].toString(),
            );
          }
        }

        AppToast.success(context, response['message'] ?? "Login successful");
        loginEmailCtr.clear();
        passwordController.clear();
        return true;
      } else {
        // Parse errors array if present
        if (response['errors'] != null &&
            (response['errors'] as List).isNotEmpty) {
          final firstError = response['errors'][0];
          final msg = firstError['msg'] ?? "Login failed";
          AppToast.error(context, msg);
        } else {
          AppToast.error(context, response['message'] ?? "Login failed");
        }
        return false;
      }
    } catch (e) {
      isLoginLoading = false;
      notifyListeners();

      if (e is DioException) {
        final data = e.response?.data;
        if (data != null &&
            data['errors'] != null &&
            (data['errors'] as List).isNotEmpty) {
          final firstError = data['errors'][0];
          final msg = firstError['msg'];
          if (msg != null) {
            AppToast.error(context, msg);
            return false;
          }
        }
      }

      AppToast.error(context, e.toString());
      return false;
    }
  }

  bool isSaveParentEmailLoading = false;
  Future<void> saveParentEmail({
    required BuildContext context,
    required VoidCallback onSuccess,
    required Function(String error) onFailed,
  }) async {
    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "On Boarding Id not found!");
      return;
    }

    isSaveParentEmailLoading = true;
    notifyListeners();

    final response = await AuthServices().saveParentEmail(
      onboardingId: onboardingId,
      parentEmail: parentEmailCtr.text.trim(),
    );

    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) {
        onSuccess.call();
      },
    );

    isSaveParentEmailLoading = false;
    notifyListeners();
  }

  bool isLogOutLoading = false;
  Future<void> logOutUser({required VoidCallback onSuccess}) async {
    final token = SharedPrefs.instance.authToken;
    isLogOutLoading = true;
    notifyListeners();

    if (token != null) {
      try {
        AuthServices().logOut(accessToken: token);
      } catch (e) {
        debugPrint("Logout API error: $e");
      }
    }

    // 1. Clear Local Data Immediately
    await SharedPrefs.instance.clear();
    clearAllData();
    notifyListeners();

    isLogOutLoading = false;
    notifyListeners();

    // 3. Call API in background (fire and forget)
  }

  void clearLoginFields() {
    signUpEmailCtr.clear();
    passwordController.clear();
    notifyListeners();
  }

  void clearSignupFields() {
    signUpEmailCtr.clear();
    notifyListeners();
  }

  void clearCreateAccountFields() {
    firstNameController.clear();
    lastNameController.clear();
    signupEmailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    notifyListeners();
  }

  void clearAllData() {
    signUpEmailCtr.clear();
    firstNameController.clear();
    lastNameController.clear();
    signupEmailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    age = null;
    selectedDate = null;
    notifyListeners();
  }

  // Story Generation Logic
  bool isLoadingStory = false;

  Future<Story?> generateStory(
    BuildContext context, {
    required GenerateStoryRequest request,
  }) async {
    try {
      isLoadingStory = true;
      notifyListeners();

      // 1. Generate Story & Image in Parallel
      // We wrap image generation to ensure it doesn't fail the whole batch if it throws
      final results = await Future.wait([
        AuthServices().generateMobileStory(request),
        AuthServices().generateStoryImage(request).catchError((e) {
          log("Image generation error in parallel: $e");
          return null;
        }),
      ]);

      final storyResponse = results[0];
      final imageResponse = results[1];

      if (storyResponse != null && storyResponse['success'] == true) {
        log("Story Response: $storyResponse");

        Story? story;
        if (storyResponse['data'] != null) {
          story = Story.fromJson(storyResponse['data']);
        }

        if (story != null) {
          try {
            log("Image Response: $imageResponse");

            if (imageResponse != null && imageResponse['success'] == true) {
              final imageData = imageResponse['data'];
              if (imageData != null && imageData['imagePath'] != null) {
                final String imagePath = imageData['imagePath'];

                // 3. Link Image
                await AuthServices().linkImageToStory(
                  storyId: story.id,
                  images: [imagePath],
                );

                // Update local object
                story.images.add(imagePath);
              }
            }
          } catch (e) {
            log("Image linking failed or timed out: $e");
          }

          isLoadingStory = false;
          notifyListeners();

          AppToast.success(
            context,
            storyResponse['message'] ?? "Story generated successfully",
          );
          return story;
        }

        isLoadingStory = false;
        notifyListeners();
        return null;
      } else {
        isLoadingStory = false;
        notifyListeners();
        AppToast.error(
          context,
          storyResponse?['message'] ?? "Failed to generate story",
        );
        return null;
      }
    } catch (e) {
      isLoadingStory = false;
      notifyListeners();

      if (e is DioException) {
        final data = e.response?.data;
        if (data != null &&
            data['errors'] != null &&
            (data['errors'] as List).isNotEmpty) {
          final firstError = data['errors'][0];
          final msg = firstError['msg'];
          if (msg != null) {
            AppToast.error(context, msg);
            return null;
          }
        }
      }

      AppToast.error(context, e.toString());
      return null;
    }
  }
}
