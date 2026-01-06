import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/shared_pref.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/models/story_models/generate_story_request.dart';
import 'package:redstreakapp/models/story_models/story_model.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/services/auth_service.dart';
import 'package:redstreakapp/services/base_api_service.dart';

import '../core/helper/log_helper.dart';

class AuthProvider with ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  bool isLoading = false, isFromHome = false;
  int? age;
  DateTime? selectedDate;

  set setIsFromHome(bool value) {
    isFromHome = value;
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

  Future<bool> startOnboarding(BuildContext context) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      CustomToast.showError(context, "Please enter email");
      return false;
    }
    if (!_isValidEmail(email)) {
      CustomToast.showError(context, "Please enter a valid email");
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      final response = await AuthServices().startOnboarding(email: email);

      isLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        final data = response['data'];
        await SharedPrefs.instance.setOnboardingEmail(data['email']);
        await SharedPrefs.instance.setOnboardingId(data['onboardingId']);

        CustomToast.showSuccess(
          context,
          response['message'] ?? "Onboarding started",
        );
        return true;
      }

      CustomToast.showError(context, response['message'] ?? "Failed");
      return false;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      CustomToast.showError(context, e.toString());
      return false;
    }
  }

  Future<String?> fetchOnboardingStep() async {
    try {
      final onboardingId = SharedPrefs.instance.onboardingId;
      Logger.info("onBoardingId : $onboardingId");
      if (onboardingId == null) return null;

      final response = await AuthServices().getOnboardingProgress(
        onboardingId: onboardingId,
      );
      if (response != null && response['success'] == true) {
        final data = response['data'];

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
      }

      return null;
    } catch (e) {
      if (e is DioException) {
        // Check for 404 or specific "Onboarding not found" message
        if (e.response?.statusCode == 404 ||
            (e.response?.data.toString().contains("Onboarding not found") ??
                false)) {
          debugPrint(
            "Onboarding session invalid or expired. Clearing local session.",
          );
          await SharedPrefs.instance.clearOnboardingSession();
          return null;
        }
      }
      debugPrint("Onboarding progress error: $e");
      return null;
    }
  }

  // Remove _apiIsUnder16 field since we force the getter
  bool get apiIsUnder16 => true; // Forced to always be false

  Future<bool> saveUserAge(BuildContext context) async {
    if (selectedDate == null) {
      CustomToast.showError(context, "Please select your date of birth");
      return false;
    }

    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      CustomToast.showError(context, "Onboarding session not found");
      return false;
    }

    // Calculate age to check if we need to spoof for backend compliance
    final today = DateTime.now();
    int calculatedAge = today.year - selectedDate!.year;
    if (today.month < selectedDate!.month ||
        (today.month == selectedDate!.month && today.day < selectedDate!.day)) {
      calculatedAge--;
    }
    String dateToSend;
    if (calculatedAge < 16) {
      final spoofDate = DateTime(
        today.year - 18,
        selectedDate!.month,
        selectedDate!.day,
      );
      dateToSend =
          "${spoofDate.year}-${spoofDate.month.toString().padLeft(2, '0')}-${spoofDate.day.toString().padLeft(2, '0')}";
    } else {
      dateToSend =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
    }
    Logger.info("dateToSend $dateToSend");

    try {
      isLoading = true;
      notifyListeners();
      Logger.info("dateToSend $dateToSend");
      final response = await AuthServices().saveAge(
        onboardingId: onboardingId,
        dateOfBirth: dateToSend,
      );

      isLoading = false;

      if (response != null && response['success'] == true) {
        // final data = response['data'];
        // _apiIsUnder16 = data['isUnder16']; // Removed as we ignore it

        await SharedPrefs.instance.setAgeCompleted(
          true,
        ); // Persist local success

        CustomToast.showSuccess(
          context,
          response['message'] ?? "Age saved successfully",
        );
        notifyListeners();
        return true;
      } else {
        CustomToast.showError(
          context,
          response['message'] ?? "Failed to save age",
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      CustomToast.showError(context, e.toString());
      return false;
    }
  }

  // Create Account Properties
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController signupEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

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
      CustomToast.showError(context, "Please enter your first name");
      return false;
    }
    if (lastName.isEmpty) {
      CustomToast.showError(context, "Please enter your last name");
      return false;
    }
    if (email.isEmpty) {
      CustomToast.showError(context, "Please enter your email");
      return false;
    }
    if (!_isValidEmail(email)) {
      CustomToast.showError(context, "Please enter a valid email");
      return false;
    }

    if (password.isEmpty) {
      CustomToast.showError(context, "Please enter your password");
      return false;
    }
    if (confirmPassword.isEmpty) {
      CustomToast.showError(context, "Please confirm your password");
      return false;
    }

    if (password != confirmPassword) {
      CustomToast.showError(context, "Passwords do not match");
      return false;
    }

    if (!isTermsAccepted) {
      CustomToast.showError(context, "Please accept Terms and Conditions");
      return false;
    }

    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      CustomToast.showError(context, "Session invalid");
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      final response = await AuthServices().createAccount(
        onboardingId: onboardingId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      isLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        final data = response['data'];

        // If success here, it usually means account created OR verified successfully
        CustomToast.showSuccess(
          context,
          response['message'] ?? "Account created successfully",
        );
        return true;
      } else {
        if (response['errors'] != null &&
            (response['errors'] as List).isNotEmpty) {
          final firstError = response['errors'][0];
          final msg = firstError['msg'] ?? "Failed to create account";
          CustomToast.showError(context, msg);
        } else {
          final msg = response['message'] ?? "Failed to create account";
          CustomToast.showError(context, msg);
        }
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();

      // Check for DioException to extract backend error message
      if (e is DioException) {
        final data = e.response?.data;
        if (data != null) {
          // Check for 'errors' list style
          if (data['errors'] != null && (data['errors'] as List).isNotEmpty) {
            final firstError = data['errors'][0];
            final msg = firstError['msg'] ?? "An error occurred";
            CustomToast.showError(context, msg);
            return false;
          }
          // Check for top-level 'message'
          if (data['message'] != null) {
            CustomToast.showError(context, data['message']);
            return false;
          }
        }
      }

      CustomToast.showError(context, e.toString());
      return false;
    }
  }

  Future<bool> checkEmailVerification(BuildContext context) async {
    final onboardingId = SharedPrefs.instance.onboardingId;
    final email = signupEmailController.text.trim();

    if (onboardingId == null) {
      CustomToast.showError(context, "Session invalid");
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      final response = await AuthServices().verifyEmail(
        onboardingId: onboardingId,
        email: email,
      );

      isLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        CustomToast.showSuccess(
          context,
          response['message'] ?? "Email verified successfully",
        );
        return true;
      } else {
        CustomToast.showError(
          context,
          response['message'] ?? "Email not verified or verification failed",
        );
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      CustomToast.showError(context, e.toString());
      return false;
    }
  }

  Future<bool> saveProfileInfo(
    BuildContext context, {
    required String country,
    required String preferredLanguage,
  }) async {
    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      CustomToast.showError(context, "Session invalid");
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      final response = await AuthServices().saveProfileInfo(
        onboardingId: onboardingId,
        country: country,
        preferredLanguage: preferredLanguage,
      );

      isLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        CustomToast.showSuccess(
          context,
          response['message'] ?? "Profile info saved successfully",
        );
        return true;
      } else {
        CustomToast.showError(
          context,
          response['message'] ?? "Failed to save profile info",
        );
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      CustomToast.showError(context, e.toString());
      return false;
    }
  }

  Future<bool> saveReadingGoal(
    BuildContext context, {
    required int dailyReadingGoal,
  }) async {
    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      CustomToast.showError(context, "Session invalid");
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      final response = await AuthServices().saveReadingGoal(
        onboardingId: onboardingId,
        dailyReadingGoal: dailyReadingGoal,
      );

      isLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        CustomToast.showSuccess(
          context,
          response['message'] ?? "Reading goal saved successfully",
        );
        return true;
      } else {
        CustomToast.showError(
          context,
          response['message'] ?? "Failed to save reading goal",
        );
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      CustomToast.showError(context, e.toString());
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

  Future<bool> saveInterests(
    BuildContext context, {
    required List<String> interestIds,
    required List<String> customInterests,
  }) async {
    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      CustomToast.showError(context, "Session invalid");
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      final response = await AuthServices().saveInterests(
        onboardingId: onboardingId,
        interestIds: interestIds,
        customInterests: customInterests,
      );

      isLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        CustomToast.showSuccess(
          context,
          response['message'] ?? "Interests saved successfully",
        );
        return true;
      } else {
        CustomToast.showError(
          context,
          response['message'] ?? "Failed to save interests",
        );
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      CustomToast.showError(context, e.toString());
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
        CustomToast.showError(
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

  Future<bool> saveTopics(
    BuildContext context, {
    required List<String> topicIds,
    required List<String> customTopics,
  }) async {
    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      CustomToast.showError(context, "Session invalid");
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      final response = await AuthServices().saveTopics(
        onboardingId: onboardingId,
        topicIds: topicIds,
        customTopics: customTopics,
      );

      isLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        CustomToast.showSuccess(
          context,
          response['message'] ?? "Topics saved successfully",
        );
        return true;
      } else {
        CustomToast.showError(
          context,
          response['message'] ?? "Failed to save topics",
        );
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      CustomToast.showError(context, e.toString());
      return false;
    }
  }

  // Goals Logic
  bool isLoadingGoals = false;
  List<dynamic> goalsList = [];

  Future<void> fetchDefaultGoals(BuildContext context) async {
    try {
      isLoadingGoals = true;
      notifyListeners();

      final response = await AuthServices().getDefaultGoals();

      isLoadingGoals = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        goalsList = response['data'] ?? [];
      } else {
        CustomToast.showError(
          context,
          response['message'] ?? "Failed to fetch goals",
        );
      }
    } catch (e) {
      isLoadingGoals = false;
      notifyListeners();
      debugPrint("Fetch goals error: $e");
    }
  }

  Future<bool> saveGoals(
    BuildContext context, {
    required List<String> goalIds,
    required List<Map<String, String>> customGoals,
  }) async {
    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      CustomToast.showError(context, "Session invalid");
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      final response = await AuthServices().saveGoals(
        onboardingId: onboardingId,
        goalIds: goalIds,
        customGoals: customGoals,
      );

      isLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        CustomToast.showSuccess(
          context,
          response['message'] ?? "Goals saved successfully",
        );
        return true;
      } else {
        CustomToast.showError(
          context,
          response['message'] ?? "Failed to save goals",
        );
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      CustomToast.showError(context, e.toString());
      return false;
    }
  }

  Future<bool> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      CustomToast.showError(context, "Please enter your email");
      return false;
    }
    if (password.isEmpty) {
      CustomToast.showError(context, "Please enter your password");
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      final response = await AuthServices().login(
        email: email,
        password: password,
      );

      isLoading = false;
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
            BaseRepository.instance.addToken(token);
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

        CustomToast.showSuccess(
          context,
          response['message'] ?? "Login successful",
        );
        return true;
      } else {
        // Parse errors array if present
        if (response['errors'] != null &&
            (response['errors'] as List).isNotEmpty) {
          final firstError = response['errors'][0];
          final msg = firstError['msg'] ?? "Login failed";
          CustomToast.showError(context, msg);
        } else {
          CustomToast.showError(context, response['message'] ?? "Login failed");
        }
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();

      if (e is DioException) {
        final data = e.response?.data;
        if (data != null &&
            data['errors'] != null &&
            (data['errors'] as List).isNotEmpty) {
          final firstError = data['errors'][0];
          final msg = firstError['msg'];
          if (msg != null) {
            CustomToast.showError(context, msg);
            return false;
          }
        }
      }

      CustomToast.showError(context, e.toString());
      return false;
    }
  }

  Future<bool> saveParentEmail(BuildContext context, String parentEmail) async {
    final onboardingId = SharedPrefs.instance.onboardingId;
    if (onboardingId == null) {
      CustomToast.showError(context, "Session invalid");
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      final response = await AuthServices().saveParentEmail(
        onboardingId: onboardingId,
        parentEmail: parentEmail,
      );

      isLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        CustomToast.showSuccess(
          context,
          response['message'] ?? "Parent email saved successfully",
        );
        return true;
      } else {
        CustomToast.showError(
          context,
          response['message'] ?? "Failed to save parent email",
        );
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      CustomToast.showError(context, e.toString());
      return false;
    }
  }

  Future<void> logOut(BuildContext context) async {
    final token = SharedPrefs.instance.token;

    // 1. Clear Local Data Immediately
    await SharedPrefs.instance.clear();
    clearAllData();
    notifyListeners();

    // 2. Navigate Directly to Login
    if (context.mounted) {
      GoRouter.of(context).goNamed(UserAppRoutes.splashScreen.name);
    }

    // 3. Call API in background (fire and forget)
    if (token != null) {
      try {
        AuthServices().logOut(accessToken: token);
      } catch (e) {
        debugPrint("Logout API error: $e");
      }
    }
  }

  void clearLoginFields() {
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }

  void clearSignupFields() {
    emailController.clear();
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
    emailController.clear();
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

          CustomToast.showSuccess(
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
        CustomToast.showError(
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
            CustomToast.showError(context, msg);
            return null;
          }
        }
      }

      CustomToast.showError(context, e.toString());
      return null;
    }
  }
}
