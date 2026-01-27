import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redstreakapp/core/constants/shared_pref.dart';
import 'package:redstreakapp/core/utils/field_validator.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/services/auth/auth_api_service.dart';
import 'package:redstreakapp/services/base_api_service.dart';

import '../../core/constants/app_constants.dart';
import '../../core/helper/log_helper.dart';
import '../../models/auth/on_boarding_progress_model.dart' hide User;

class AuthProvider with ChangeNotifier {
  TextEditingController customGoalTitleCtr = TextEditingController(),
      customGoalDesCtr = TextEditingController(),
      signUpEmailCtr = TextEditingController(),
      loginEmailCtr = TextEditingController(),
      otpCtr = TextEditingController(),
      newPasswordCtr = TextEditingController(),
      resetConfirmPasswordCtr = TextEditingController(),
      parentEmailCtr = TextEditingController(),
      forgotPasswordEmailCtr = TextEditingController();
  bool isLoading = false,
      isStoryCreation = false,
      isCustomGoalSelected = false,
      isConsentRequestApproved = false;

  int? age;
  int calculatedAge = 0;
  DateTime? selectedDate;
  String googleLoginEmail = "", selectedGoalId = "", googleBirthDate = "";

  bool acceptedTerms = false;
  bool isEmailSent = false;
  bool isPasswordObscure = true;
  bool isConfirmPasswordObscure = true;

  // -------- TOGGLE FUNCTIONS -------- //

  void toggleAcceptedTerms({bool? value}) {
    acceptedTerms = value ?? !acceptedTerms;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    isPasswordObscure = !isPasswordObscure;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscure = !isConfirmPasswordObscure;
    notifyListeners();
  }

  void setEmailSent(bool value) {
    isEmailSent = value;
    notifyListeners();
  }

  // Future<void> handleAccountCreation({required BuildContext context}) async {
  //   // if (isEmailSent) {
  //   //   isVerifyEmailLoading = true;
  //   //   notifyListeners();
  //   //
  //   //   final success = await verifyCreateAccEmail(context);
  //   //
  //   //   isVerifyEmailLoading = false;
  //   //   notifyListeners();
  //   //
  //   //   if (success && context.mounted) {
  //   //     context.pushNamed(AppRoutes.profileInfoScreen.name);
  //   //   } else {
  //   //     isEmailSent = false;
  //   //     notifyListeners();
  //   //   }
  //   // } else {
  //   isCreateAccountLoading = true;
  //   notifyListeners();
  //
  //   final success = await createAccount(
  //     context,
  //     isTermsAccepted: acceptedTerms,
  //   );
  //
  //
  //
  //   if (success) {
  //
  //   }
  //   // }
  // }

  void updateGoalId(String id) {
    if (selectedGoalId == id) {
      selectedGoalId = "";
    } else {
      isCustomGoalSelected = false;
      customGoalTitleCtr.clear();
      customGoalDesCtr.clear();
      selectedGoalId = id;
    }
    notifyListeners();
  }

  void toggleCustomGoal() {
    isCustomGoalSelected = !isCustomGoalSelected;
    if (!isCustomGoalSelected) {
      customGoalTitleCtr.clear();
      customGoalDesCtr.clear();
    } else {
      selectedGoalId = "";
    }
    notifyListeners();
  }

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
    final error = FieldValidators().email(email);
    if (error != null) {
      AppToast.error(context, error);
      return;
    }

    isStartOnBoardingLoading = true;
    notifyListeners();

    final response = await AuthApiServices().startOnboarding(email: email);

    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) async {
        final data = r['data'];
        await LocalStorageService.instance.setOnboardingEmail(data['email']);
        await LocalStorageService.instance.saveOnboardingId(
          data['onboardingId'],
        );
        onSuccess.call();

        signUpEmailCtr.clear();
      },
    );

    isStartOnBoardingLoading = false;
    notifyListeners();
  }

  // Future<String?> fetchOnboardingStep() async {
  //   try {
  //     final onboardingId = SharedPrefs.instance.onboardingId;
  //     if (onboardingId == null) return null;
  //
  //     final response = await AuthApiServices().getOnboardingProgress(
  //       onboardingId: onboardingId,
  //     );
  //     response.fold((l) {}, (r) {
  //       final data = r['data'];
  //
  //       if (data['nextStep'] != null &&
  //           data['nextStep'].toString().isNotEmpty) {
  //         return data['nextStep'];
  //       }
  //
  //       if (data['currentStep'] == 'CREATE_ACCOUNT' &&
  //           data['userProfile'] != null &&
  //           data['userProfile']['firstName'] != null) {
  //         return 'PROFILE_INFO';
  //       }
  //
  //       if (data['currentStep'] == 'PROFILE_INFO' &&
  //           data['userProfile'] != null &&
  //           data['userProfile']['country'] != null) {
  //         return 'READING_GOAL';
  //       }
  //
  //       if (data['currentStep'] == 'READING_GOAL' &&
  //           data['userProfile'] != null &&
  //           data['userProfile']['dailyReadingGoal'] != null) {
  //         return 'INTERESTS';
  //       }
  //
  //       if (data['currentStep'] == 'INTERESTS' &&
  //           ((data['userInterests'] != null &&
  //                   (data['userInterests'] as List).isNotEmpty) ||
  //               (data['userProfile']['interests'] != null &&
  //                   (data['userProfile']['interests'] as List).isNotEmpty))) {
  //         return 'TOPICS';
  //       }
  //
  //       if (data['currentStep'] == 'TOPICS' &&
  //           ((data['userTopics'] != null &&
  //                   (data['userTopics'] as List).isNotEmpty) ||
  //               (data['userProfile']['topics'] != null &&
  //                   (data['userProfile']['topics'] as List).isNotEmpty))) {
  //         return 'GOALS';
  //       }
  //
  //       if (data['currentStep'] == 'GOALS' &&
  //           ((data['userGoals'] != null &&
  //                   (data['userGoals'] as List).isNotEmpty) ||
  //               (data['userProfile']['goals'] != null &&
  //                   (data['userProfile']['goals'] as List).isNotEmpty))) {
  //         return 'COMPLETED';
  //       }
  //
  //       return data['currentStep'];
  //     });
  //     return null;
  //   } catch (e) {
  //     debugPrint("Onboarding progress error: $e");
  //     return null;
  //   }
  // }

  Future<String?> getOnBoardingProgress() async {
    try {
      final onboardingId = LocalStorageService.instance.onboardingId;
      if (onboardingId == null) return null;

      final response = await AuthApiServices().getOnboardingProgress(
        onboardingId: onboardingId,
      );

      if (response != null && response['success'] == true) {
        final data = OnBoardingProgressModel.fromJson(response["data"]);

        // if (data['nextStep'] != null &&
        //     data['nextStep'].toString().isNotEmpty) {
        //   return data['nextStep'];
        // }

        if (data.currentStep == AppConstants.createAccount &&
            data.userProfile != null &&
            data.userProfile != null) {
          return AppConstants.profileInfo;
        }

        if (data.currentStep == AppConstants.profileInfo &&
            data.userProfile != null &&
            data.userProfile!.country != null) {
          return AppConstants.readingGoal;
        }

        if (data.currentStep == AppConstants.readingGoal &&
            data.userProfile != null &&
            data.userProfile!.dailyReadingGoal != null) {
          return AppConstants.interest;
        }

        if (data.currentStep == AppConstants.interest &&
            ((data.userInterests != null &&
                (data.userInterests as List).isNotEmpty))
        // ||
        // (data.userProfile. != null &&
        //     (data['userProfile']['interests'] as List).isNotEmpty)
        ) {
          return AppConstants.topics;
        }

        if (data.currentStep == AppConstants.topics &&
            (data.userTopics != null && (data.userTopics as List).isNotEmpty)
        //     ||
        //     (data.userTopics['topics'] != null &&
        //         (data['userProfile']['topics'] as List).isNotEmpty)
        // )
        ) {
          return AppConstants.goals;
        }

        if (data.currentStep == AppConstants.goals &&
            ((data.userGoals != null && (data.userGoals as List).isNotEmpty) ||
                (data.userProfile!.dailyReadingGoal != null))) {
          return AppConstants.completed;
        }

        if (data.currentStep == AppConstants.consentStatus &&
            data.consentStatus == AppConstants.accepted) {
          return AppConstants.createAccount;
        }

        return data.currentStep;
      }
      return null;
    } catch (e) {
      debugPrint("Onboarding progress error: $e");
      return null;
    }
  }

  //todo
  bool get isUnder16 => calculatedAge < 16;

  bool isSaveUserAgeLoading = false;

  Future<void> saveAge({
    required BuildContext context,
    required Function onSuccess,
    required Function(String error) onFailed,
  }) async {
    //todo checking onBoarding id null or not
    final onboardingId = LocalStorageService.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "Onboarding session not found");
      return;
    }

    //todo Calculate age to check if we need to spoof for backend compliance
    String? dateToSend = calculateDateToSend();
    Logger.info("dateToSend $dateToSend");

    isSaveUserAgeLoading = true;
    notifyListeners();

    final response = await AuthApiServices().saveBirthDate(
      onboardingId: onboardingId,
      dateOfBirth: dateToSend!,
    );
    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) async {
        await LocalStorageService.instance.setAgeCompleted(true);
        // clearCreateAccountFields();
        onSuccess.call();
      },
    );

    isSaveUserAgeLoading = false;
    notifyListeners();
  }

  String? calculateDateToSend() {
    if (selectedDate != null) {
      final today = DateTime.now();
      calculatedAge = today.year - selectedDate!.year;
      if (today.month < selectedDate!.month ||
          (today.month == selectedDate!.month &&
              today.day < selectedDate!.day)) {
        calculatedAge--;
      }
      String dateToSend =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
      return dateToSend;
    }
    return googleBirthDate;
  }

  //todo create account
  // Create Account Properties
  TextEditingController firstNameCtr = TextEditingController(),
      lastNameCtr = TextEditingController(),
      createAccEmailCtr = TextEditingController(),
      loginPasswordCtr = TextEditingController(),
      createAccPasswordCtr = TextEditingController(),
      confirmPasswordCtr = TextEditingController();

  bool isCreateAccountLoading = false;
  Future<bool> createAccount({
    required bool isTermsAccepted,
    required BuildContext context,
  }) async {
    final firstName = firstNameCtr.text.trim();
    final lastName = lastNameCtr.text.trim();
    final email = createAccEmailCtr.text.trim();
    final password = createAccPasswordCtr.text.trim();
    final confirmPassword = confirmPasswordCtr.text.trim();

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

    final onboardingId = LocalStorageService.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "Session invalid");
      return false;
    }

    try {
      isCreateAccountLoading = true;
      notifyListeners();

      final response = await AuthApiServices().createAccount(
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
          response['message'] ??
              "Verification link sent to your mail, please verify.",
        );
        setEmailSent(true);
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

  //todo verify account
  bool isVerifyEmailLoading = false;
  Future<bool> verifyCreateAccEmail(BuildContext context) async {
    final onboardingId = LocalStorageService.instance.onboardingId;
    final email = createAccEmailCtr.text.trim();

    if (onboardingId == null) {
      AppToast.error(context, "Session invalid");
      return false;
    }

    try {
      isVerifyEmailLoading = true;
      notifyListeners();

      final response = await AuthApiServices().verifyEmail(
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
        context.pushNamed(AppRoutes.profileInfoScreen.name);

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
      Logger.info("here");
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
    final onboardingId = LocalStorageService.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "Session invalid");
      return false;
    }

    try {
      isSaveProfileLoading = true;
      notifyListeners();

      final response = await AuthApiServices().saveProfileInfo(
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
    final onboardingId = LocalStorageService.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "Session invalid");
      return false;
    }

    try {
      isSaveReadingGoal = true;
      notifyListeners();

      final response = await AuthApiServices().saveReadingGoal(
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
      final response = await AuthApiServices().getDefaultInterests();
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
    final onboardingId = LocalStorageService.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "Session invalid");
      return false;
    }

    try {
      isSaveInterestLoading = true;
      notifyListeners();

      final response = await AuthApiServices().saveInterests(
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

      final response = await AuthApiServices().getDefaultTopics();

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
    final onboardingId = LocalStorageService.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "Session invalid");
      return false;
    }

    try {
      isSaveTopicsLoading = true;
      notifyListeners();

      final response = await AuthApiServices().saveTopics(
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

      final response = await AuthApiServices().getGoals();

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
    final onboardingId = LocalStorageService.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "Session invalid");
      return false;
    }

    try {
      isSaveGoalsLoading = true;
      notifyListeners();

      final response = await AuthApiServices().saveGoals(
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
        goalIds.clear();
        customGoals.clear();
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

  Future<bool> loginUser(BuildContext context) async {
    final email = loginEmailCtr.text.trim();
    final password = loginPasswordCtr.text.trim();

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

      final response = await AuthApiServices().login(
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
              await LocalStorageService.instance.saveRefreshToken(
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
            await LocalStorageService.instance.saveAuthToken(token);
            // Update the current API instance with the new token immediately
            DioClient.instance.addToken(token);
            debugPrint("Token saved successfully from login: $token");
          } else {
            debugPrint("No access token found in login response!");
          }

          if (data['onboardingId'] != null) {
            await LocalStorageService.instance.saveOnboardingId(
              data['onboardingId'].toString(),
            );
          }
        }

        AppToast.success(context, response['message'] ?? "Login successful");
        loginEmailCtr.clear();
        loginPasswordCtr.clear();
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

  //todo social login
  bool isSocialLoginLoading = false;

  Future<void> googleSignUp({
    required VoidCallback onSuccess,
    required String? idToken,
    Function(String error)? onNoAccountFound,

    required Function(String error) onFailed,
  }) async {
    if (idToken == null) {
      isSocialLoginLoading = false;
      notifyListeners();
      return;
    }

    final data = {
      "provider": "google",
      "idToken": idToken, //YOUR_GOOGLE_ID_TOKEN_HERE
      // "onboardingId": SharedPrefs.instance.onboardingId,
    };
    final response = await AuthApiServices().googleSignUp(data: data);
    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) async {
        final data = r['data'];
        Logger.info("Login Response Data: $data");

        // if (data != null) {
        //   String? accessToken;
        //   if (data["session"] == null && onNoAccountFound != null) {
        //     onNoAccountFound.call(data["user"]["email"]);
        //     return;
        //   }
        //
        //   //todo Check for nested session object first (as seen in logs)
        //   if (data['session'] != null) {
        //     final session = data['session'];
        //
        //     if (session["accessToken"] != null) {
        //       accessToken = session["accessToken"];
        //       await LocalStorageService.instance.saveAuthToken(accessToken!);
        //     }
        //
        //     if (session["refreshToken"] != null) {
        //       await LocalStorageService.instance.saveRefreshToken(
        //         session["refreshToken"],
        //       );
        //     }
        //   }
        //
        //   if (accessToken != null) {
        //     //todo Update the current API instance with the new token immediately
        //     DioClient.instance.addToken(accessToken);
        //     Logger.error("Token saved successfully from login: $accessToken");
        //   }
        //
        //   if (data['onboardingId'] != null) {
        //     await LocalStorageService.instance.saveOnboardingId(
        //       data['onboardingId'].toString(),
        //     );
        //   }
        // }
        signUpEmailCtr.text = data["user"]["email"];

        onSuccess.call();
      },
    );

    isSocialLoginLoading = false;
    notifyListeners();
  }

  Future<void> googleLogin({
    required VoidCallback onSuccess,
    required String? idToken,
    Function(String error)? onNoAccountFound,

    required Function(String error) onFailed,
  }) async {
    if (idToken == null) {
      isSocialLoginLoading = false;
      notifyListeners();
      return;
    }

    final data = {
      "provider": "google",
      "idToken": idToken,
      // "onboardingId": SharedPrefs.instance.onboardingId,
    };
    final response = await AuthApiServices().googleSignUp(data: data);
    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) async {
        final data = r['data'];
        Logger.info("Google Login Response Data: $data");

        if (data != null) {
          String? accessToken;
          if (data["session"] == null && onNoAccountFound != null) {
            onNoAccountFound.call(data["user"]["email"]);
            return;
          }

          //todo Check for nested session object first (as seen in logs)
          if (data['session'] != null) {
            final session = data['session'];

            if (session["accessToken"] != null) {
              accessToken = session["accessToken"];
              await LocalStorageService.instance.saveAuthToken(accessToken!);
            }

            if (session["refreshToken"] != null) {
              await LocalStorageService.instance.saveRefreshToken(
                session["refreshToken"],
              );
            }
          }

          if (accessToken != null) {
            //todo Update the current API instance with the new token immediately
            DioClient.instance.addToken(accessToken);
            Logger.error("Token saved successfully from login: $accessToken");
          }

          if (data['onboardingId'] != null) {
            await LocalStorageService.instance.saveOnboardingId(
              data['onboardingId'].toString(),
            );
          }
        }
        // signUpEmailCtr.text = data["user"]["email"];

        onSuccess.call();
      },
    );

    isSocialLoginLoading = false;
    notifyListeners();
  }

  //todo google login functions
  //todo Google Sign-In Platform Exception: com.google.android.gms.common.api.ApiException: 16:
  Future<String?> getGoogleIDTokenForLogin() async {
    try {
      isSocialLoginLoading = true;
      notifyListeners();
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: AppConstants.serverClientId,
        clientId: (Platform.isIOS) ? AppConstants.clientIdIos : null,
        scopes: ["email", "profile"],
      );

      GoogleSignInAccount? account = await googleSignIn.signIn();
      //
      if (account == null) {
        Logger.error("User cancelled sign-in");
        return null;
      }

      final auth = await account.authentication;
      googleLoginEmail = account.email;
      Logger.info(account.email);
      Logger.info("Account: /${account.toString()}");
      Logger.info("access Token: ${auth.accessToken ?? 'NULL'}");
      Logger.info("idToken: /${auth.idToken ?? 'NULL'}");
      Logger.info("\nclose");

      // Check if ID token is null
      if (auth.idToken == null) {
        Logger.error(
          "⚠️ ID Token is NULL - Check serverClientId configuration!",
        );
        Logger.error(
          "Make sure you're using the Web Client ID, not Android Client ID",
        );
        return null;
      }

      return auth.idToken;
    } catch (e) {
      Logger.error("Google Sign In catch error : ${e.toString()}");
      return null;
    }
  }

  Future<String?> getGoogleIDTokenForSignUp() async {
    GoogleSignIn? googleSignIn;

    try {
      isSocialLoginLoading = true;
      notifyListeners();

      googleSignIn = GoogleSignIn(
        serverClientId: AppConstants.serverClientId,
        clientId: (Platform.isIOS) ? AppConstants.clientIdIos : null,
        scopes: [
          "email",
          "profile",
          "https://www.googleapis.com/auth/user.birthday.read",
        ],
      );

      // Critical: Ensure UI thread is ready (prevents deadlock)
      await Future.delayed(const Duration(milliseconds: 100));

      // Sign in with proper error handling
      GoogleSignInAccount? account;
      try {
        account = await googleSignIn.signIn();
      } on PlatformException catch (e) {
        Logger.error("Google Sign-In Platform Exception: ${e.message}");
        isSocialLoginLoading = false;
        notifyListeners();
        return null;
      }

      if (account == null) {
        Logger.error("User cancelled sign-in");
        isSocialLoginLoading = false;
        notifyListeners();
        return null;
      }

      // Parse and set user information
      final displayName = account.displayName?.trim() ?? "";
      if (displayName.isNotEmpty) {
        final parts = displayName.split(RegExp(r'\s+'));
        firstNameCtr.text = parts.first;
        lastNameCtr.text = (parts.length > 1) ? parts.sublist(1).join(" ") : "";
      } else {
        firstNameCtr.text = "";
        lastNameCtr.text = "";
      }

      createAccEmailCtr.text = account.email;
      googleLoginEmail = account.email;

      Logger.info("Email: ${account.email}");
      Logger.info("Display Name: $displayName");

      // Get authentication details
      final auth = await account.authentication;

      Logger.info("Access Token: ${auth.accessToken ?? 'NULL'}");
      Logger.info("ID Token: ${auth.idToken ?? 'NULL'}");

      // Validate ID token
      if (auth.idToken == null) {
        Logger.error(
          "⚠️ ID Token is NULL - Check serverClientId configuration!",
        );
        Logger.error(
          "Make sure you're using the Web Client ID, not Android Client ID",
        );
        isSocialLoginLoading = false;
        notifyListeners();
        return null;
      }

      // Fetch additional user data (birthday)
      if (auth.accessToken != null) {
        Logger.info("Birthdate API Calling");
        await _fetchGoogleBirthday(auth.accessToken!);
      }

      // Generate password for account creation
      generateStrongPassword();

      return auth.idToken;
    } catch (e) {
      Logger.error("Google Sign In error: ${e.toString()}");

      // Attempt to sign out to clear any stuck state
      try {
        await googleSignIn?.signOut();
      } catch (signOutError) {
        Logger.error("Sign out error: $signOutError");
      }

      isSocialLoginLoading = false;
      notifyListeners();
      return null;
    }
  }

  //todo fetch google birth date
  Future<void> _fetchGoogleBirthday(String accessToken) async {
    try {
      final response = await BaseApiHelper.instance.get(
        "https://people.googleapis.com/v1/people/me",
        queryParameters: {"personFields": "birthdays"},
        options: Options(headers: {"Authorization": "Bearer $accessToken"}),
      );

      response.fold(
        (l) {
          Logger.error("Error while getting birthdate: $e");
          return;
        },
        (r) {
          Logger.info("Birthdate response: $r");
          final birthdays = r["birthdays"];
          if (birthdays == null || birthdays.isEmpty) return;

          final date = birthdays.first["date"];
          if (date == null) return;

          final int day = date["day"];
          final int month = date["month"];
          final int year = date["year"];
          final today = DateTime.now();

          calculatedAge = today.year - year;
          if (today.month < month ||
              (today.month == month && today.day < day)) {
            calculatedAge--;
          }

          googleBirthDate =
              "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
          Logger.info("Google Birthdate: $googleBirthDate");
        },
      );
    } catch (e) {
      Logger.error("Failed to fetch birthday: $e");
      return;
    }
  }

  //todo generate password for google sign up
  String generateStrongPassword() {
    const int passwordLength = 14;

    // Character sets based on your email validation pattern
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String specialChars = '._%+-'; // From your email regex pattern

    // Combine all character sets
    const String allChars = uppercase + lowercase + numbers + specialChars;

    final random = Random.secure();

    // Ensure at least one character from each set
    List<String> password = [
      uppercase[random.nextInt(uppercase.length)],
      lowercase[random.nextInt(lowercase.length)],
      numbers[random.nextInt(numbers.length)],
      specialChars[random.nextInt(specialChars.length)],
    ];

    // Fill the rest with random characters
    for (int i = password.length; i < passwordLength; i++) {
      password.add(allChars[random.nextInt(allChars.length)]);
    }

    //todo Shuffle to randomize positions
    password.shuffle(random);

    Logger.info("Generated PassWord: ${password.join('')}");
    createAccPasswordCtr.text = password.join('');
    confirmPasswordCtr.text = password.join('');
    return password.join('');
  }

  //todo save parent email
  bool isSaveParentEmailLoading = false;
  Future<void> saveParentEmail({
    required BuildContext context,
    required VoidCallback onSuccess,
    required Function(String error) onFailed,
  }) async {
    final onboardingId = LocalStorageService.instance.onboardingId;
    if (onboardingId == null) {
      AppToast.error(context, "On Boarding Id not found!");
      return;
    }

    isSaveParentEmailLoading = true;
    notifyListeners();

    final response = await AuthApiServices().saveParentEmail(
      onboardingId: onboardingId,
      parentEmail: parentEmailCtr.text.trim(),
    );

    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) {
        parentEmailCtr.clear();
        onSuccess.call();
      },
    );

    isSaveParentEmailLoading = false;
    notifyListeners();
  }

  int resendSeconds = 50;
  bool isResendTimerRunning = false;
  Timer? _resendTimer;

  bool isSendLinkForgotPassLoading = false;
  Future<void> sendLinkForgotPass({
    required Function(String error) onFailed,
    required VoidCallback onSuccess,
  }) async {
    isSendLinkForgotPassLoading = true;
    notifyListeners();

    final response = await AuthApiServices().forgotPassword(
      data: {"email": forgotPasswordEmailCtr.text.trim()},
    );
    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) {
        // forgotPasswordEmailCtr.clear();
        startResendTimer();
        onSuccess.call();
      },
    );

    isSendLinkForgotPassLoading = false;
    notifyListeners();
  }

  void startResendTimer() {
    isResendTimerRunning = true;
    resendSeconds = 50;
    notifyListeners();

    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds > 0) {
        resendSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        isResendTimerRunning = false;
        notifyListeners();
      }
    });
  }

  bool isLogOutLoading = false;
  Future<void> logOutUser({required VoidCallback onSuccess}) async {
    final token = LocalStorageService.instance.getAuthToken;
    Logger.info(token.toString());
    isLogOutLoading = true;
    notifyListeners();

    if (token != null) {
      try {
        AuthApiServices().logOut(accessToken: token);
      } catch (e) {
        debugPrint("Logout API error: $e");
      }
    }

    // 1. Clear Local Data Immediately
    await LocalStorageService.instance.removeAuthToken();
    await LocalStorageService.instance.removeRefreshToken();
    await LocalStorageService.instance.clear();
    LocalStorageService.instance.saveParentConsentStatus(status: false);

    clearAllData();
    notifyListeners();

    isLogOutLoading = false;
    notifyListeners();
    onSuccess.call();

    // 3. Call API in background (fire and forget)
  }

  void clearLoginFields() {
    loginEmailCtr.clear();
    loginPasswordCtr.clear();
    notifyListeners();
  }

  void clearSignupFields() {
    signUpEmailCtr.clear();
    notifyListeners();
  }

  void clearCreateAccountFields() {
    firstNameCtr.clear();
    lastNameCtr.clear();
    createAccEmailCtr.clear();
    createAccPasswordCtr.clear();
    confirmPasswordCtr.clear();
    notifyListeners();
  }

  void clearAllData() {
    signUpEmailCtr.clear();
    firstNameCtr.clear();
    lastNameCtr.clear();
    createAccEmailCtr.clear();
    createAccPasswordCtr.clear();
    confirmPasswordCtr.clear();
    age = null;
    selectedDate = null;
    notifyListeners();
  }

  //todo Generate Story
  // bool isLoadingStory = false;
  // Future<Story?> generateStory(
  //   BuildContext context, {
  //   required GenerateStoryRequest request,
  // }) async {
  //   try {
  //     isLoadingStory = true;
  //     notifyListeners();
  //
  //     // 1. Generate Story & Image in Parallel
  //     // We wrap image generation to ensure it doesn't fail the whole batch if it throws
  //     final results = await Future.wait([
  //       AuthApiServices().generateMobileStory(request),
  //       AuthApiServices().generateStoryImage(request).catchError((e) {
  //         Logger.info("Image generation error in parallel: $e");
  //         return null;
  //       }),
  //     ]);
  //
  //     final storyResponse = results[0];
  //     final imageResponse = results[1];
  //
  //     if (storyResponse != null && storyResponse['success'] == true) {
  //       Logger.info("Story Response: $storyResponse");
  //
  //       Story? story;
  //       if (storyResponse['data'] != null) {
  //         story = Story.fromJson(storyResponse['data']);
  //       }
  //
  //       if (story != null) {
  //         try {
  //           Logger.info("Image Response: $imageResponse");
  //
  //           if (imageResponse != null && imageResponse['success'] == true) {
  //             final imageData = imageResponse['data'];
  //             if (imageData != null && imageData['imagePath'] != null) {
  //               final String imagePath = imageData['imagePath'];
  //
  //               // 3. Link Image
  //               await AuthApiServices().linkImageToStory(
  //                 storyId: story.id,
  //                 images: [imagePath],
  //               );
  //
  //               // Update local object
  //               // story.image = imagePath;
  //             }
  //           }
  //         } catch (e) {
  //           Logger.error("Image linking failed or timed out: $e");
  //         }
  //
  //         isLoadingStory = false;
  //         notifyListeners();
  //
  //         AppToast.success(
  //           context,
  //           storyResponse['message'] ?? "Story generated successfully",
  //         );
  //         return story;
  //       }
  //
  //       isLoadingStory = false;
  //       notifyListeners();
  //       return null;
  //     } else {
  //       isLoadingStory = false;
  //       notifyListeners();
  //       AppToast.error(
  //         context,
  //         storyResponse?['message'] ?? "Failed to generate story",
  //       );
  //       return null;
  //     }
  //   } catch (e) {
  //     isLoadingStory = false;
  //     notifyListeners();
  //
  //     if (e is DioException) {
  //       final data = e.response?.data;
  //       if (data != null &&
  //           data['errors'] != null &&
  //           (data['errors'] as List).isNotEmpty) {
  //         final firstError = data['errors'][0];
  //         final msg = firstError['msg'];
  //         if (msg != null) {
  //           AppToast.error(context, msg);
  //           return null;
  //         }
  //       }
  //     }
  //
  //     AppToast.error(context, e.toString());
  //     return null;
  //   }
  // }

  String? _consentRequestToken, _resetPasswordToken;

  set setResetPasswordToken(String token) {
    _resetPasswordToken = token;
    // notifyListeners();
  }

  set setConsentRequestToken(String token) {
    _consentRequestToken = token;
    notifyListeners();
  }

  bool isVerifyForgotPassMailLoading = false;
  Future<void> verifyForgotPasswordEmail({
    required VoidCallback onSuccess,
    required Function(ApiException e) onFailed,
  }) async {
    isVerifyForgotPassMailLoading = true;
    notifyListeners();

    final response = await AuthApiServices().verifyForgotPasswordEmail(
      data: {"accessToken": _resetPasswordToken},
    );

    response.fold(
      (l) {
        onFailed.call(l);
      },
      (r) {
        onSuccess.call();
        forgotPasswordEmailCtr.clear();
        notifyListeners();
      },
    );
    isVerifyForgotPassMailLoading = false;
    notifyListeners();
  }

  bool isVerifyConsentRequestLoading = false;
  Future<void> verifyConsentRequest({
    required VoidCallback onSuccess,
    required Function(ApiException e) onFailed,
  }) async {
    isVerifyConsentRequestLoading = true;
    notifyListeners();

    final response = await AuthApiServices().verifyParentConsent(
      data: {
        "token": _consentRequestToken,
        "onboardingId": LocalStorageService.instance.onboardingId,
        "action": "approve",
      },
    );

    response.fold(
      (l) {
        onFailed.call(l);
      },
      (r) {
        onSuccess.call();
        isConsentRequestApproved = true;
        notifyListeners();
      },
    );
    isVerifyConsentRequestLoading = false;
    notifyListeners();
  }

  bool isResetPasswordLoading = false;

  Future<void> resetPassword({
    required VoidCallback onSuccess,
    required Function(String error) onFailed,
  }) async {
    isResetPasswordLoading = true;
    notifyListeners();

    final response = await AuthApiServices().resetPassword(
      data: {
        "password": newPasswordCtr.text.trim(),
        "accessToken": _resetPasswordToken,
      },
    );

    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) {
        onSuccess.call();
        newPasswordCtr.clear();
        resetConfirmPasswordCtr.clear();
      },
    );
    isResetPasswordLoading = false;
    notifyListeners();
  }

  void decideFirstScreen({
    required BuildContext context,
    required String step,
  }) {
    Logger.info("Current Step: $step");
    if (step == AppConstants.age) {
      context.goNamed(AppRoutes.enterAgeScreen.name);
    } else if (step == AppConstants.email) {
      context.goNamed(AppRoutes.enterAgeScreen.name);
    } else if (step == AppConstants.parentEmail) {
      context.goNamed(AppRoutes.parentEmailScreen.name);
    } else if (step == AppConstants.consentStatus) {
      context.goNamed(AppRoutes.consentStatusScreen.name);
    } else if (step == AppConstants.createAccount) {
      context.goNamed(AppRoutes.createAccountScreen.name);
    } else if (step == AppConstants.profileInfo) {
      context.goNamed(AppRoutes.profileInfoScreen.name);
    } else if (step == AppConstants.readingGoal) {
      context.goNamed(AppRoutes.readingGoalScreen.name);
    } else if (step == AppConstants.interest) {
      context.goNamed(AppRoutes.interestsScreen.name);
    } else if (step == AppConstants.topics) {
      context.goNamed(AppRoutes.topicsScreen.name);
    } else if (step == AppConstants.goals) {
      context.goNamed(AppRoutes.goalsScreen.name);
    } else if (step == AppConstants.completed) {
      if (LocalStorageService.instance.getAuthToken == null) {
        context.goNamed(AppRoutes.loginScreen.name);
      } else {
        context.goNamed(AppRoutes.homeScreen.name);
      }
    }

    if (step != AppConstants.completed) {
      AppToast.info(
        context: context,
        durationSecond: 5,
        message: "Please complete your on boarding session.",
      );
    }
  }
}
