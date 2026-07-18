import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redstreakapp/core/session/app_session_reset.dart';
import 'package:redstreakapp/core/utils/shared_pref.dart';
import 'package:redstreakapp/core/utils/field_validator.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/core/routes/app_router.dart';
import 'package:redstreakapp/services/auth/auth_api_service.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';

import '../../core/constants/app_constants.dart';
import '../../core/helper/log_helper.dart';
import '../../models/auth/on_boarding_progress_model.dart' hide User;

enum _GoogleSocialLoginOutcome { existingAccount, newAccount, failed }

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
  final Set<String> selectedGoalIds = {};
  //selectedGoalId = "",
  String googleLoginEmail = "", googleBirthDate = "";

  bool acceptedTerms = false,
      isEmailSent = false,
      isPasswordObscure = true,
      isConfirmPasswordObscure = true,
      _isUnder16FromGoogle = false,
      _pendingGoogleSignup = false,
      _pendingGoogleLogin = false,
      _openDatePickerOnAgeScreen = false;

  GoogleSignInAccount? _lastGoogleSignInAccount;
  String? _pendingGoogleIdToken;
  VoidCallback? _onGoogleAccountFound;
  VoidCallback? _onGoogleNoAccountFound;
  Function(String)? _onGoogleLoginFailed;

  static const _googleBirthdayScope =
      'https://www.googleapis.com/auth/user.birthday.read';

  // -------- TOGGLE FUNCTIONS -------- //

  void setIsUnder16FromGoogle({required bool value}) {
    _isUnder16FromGoogle = value;
    notifyListeners();
  }

  void setPendingGoogleSignup(bool value) {
    _pendingGoogleSignup = value;
    notifyListeners();
  }

  bool get pendingGoogleSignup => _pendingGoogleSignup;
  bool get pendingGoogleLogin => _pendingGoogleLogin;
  bool get hasGoogleBirthDate => googleBirthDate.isNotEmpty;
  bool get openDatePickerOnAgeScreen => _openDatePickerOnAgeScreen;

  void setPendingGoogleLogin(bool value) {
    _pendingGoogleLogin = value;
    notifyListeners();
  }

  void setOpenDatePickerOnAgeScreen(bool value) {
    _openDatePickerOnAgeScreen = value;
    notifyListeners();
  }

  void clearGoogleBirthDate() {
    googleBirthDate = "";
    notifyListeners();
  }

  void _clearGoogleLoginPendingState() {
    _pendingGoogleIdToken = null;
    _pendingGoogleLogin = false;
    _onGoogleAccountFound = null;
    _onGoogleNoAccountFound = null;
    _onGoogleLoginFailed = null;
    notifyListeners();
  }

  void _finishGoogleLoginWithExistingAccount() {
    final onFound = _onGoogleAccountFound;
    _clearGoogleLoginPendingState();
    onFound?.call();
  }

  Future<bool> ensureOnboardingAndSaveAgeForGoogle({
    required BuildContext context,
    required Function(String error) onFailed,
  }) async {
    final email = googleLoginEmail.trim().isNotEmpty
        ? googleLoginEmail.trim()
        : createAccEmailCtr.text.trim();
    if (email.isEmpty) {
      onFailed("Could not get email from Google account");
      return false;
    }

    final dateToSend = calculateDateToSend();
    Logger.info("dateToSend $dateToSend");
    if (dateToSend == null || dateToSend.isEmpty) {
      onFailed("Please select your date of birth");
      return false;
    }

    var onboardingId = LocalStorageService.instance.onboardingId;
    if (onboardingId == null) {
      final onboardingResult = await AuthApiServices().startOnboarding(
        email: email,
      );
      final started = await onboardingResult.fold<Future<bool>>(
        (l) async {
          onFailed(l.errorMsg);
          return false;
        },
        (r) async {
          final data = r['data'];
          await LocalStorageService.instance.setOnboardingEmail(data['email']);
          await LocalStorageService.instance.saveOnboardingId(
            data['onboardingId'],
          );
          return true;
        },
      );
      if (!started) return false;
      onboardingId = LocalStorageService.instance.onboardingId;
    }

    isSaveUserAgeLoading = true;
    notifyListeners();

    final response = await AuthApiServices().saveBirthDate(
      onboardingId: onboardingId!,
      dateOfBirth: dateToSend,
    );

    isSaveUserAgeLoading = false;
    notifyListeners();

    return response.fold(
      (l) {
        onFailed(l.errorMsg);
        return false;
      },
      (r) async {
        await LocalStorageService.instance.setAgeCompleted(true);
        await LocalStorageService.instance.saveDateOfBirth(dateToSend);
        return true;
      },
    );
  }

  Future<void> beginGoogleSocialLogin({
    required BuildContext context,
    required String idToken,
    required VoidCallback onAccountFound,
    required VoidCallback onNoAccountFound,
    required Function(String error) onFailed,
  }) async {
    _pendingGoogleIdToken = idToken;
    _onGoogleAccountFound = onAccountFound;
    _onGoogleNoAccountFound = onNoAccountFound;
    _onGoogleLoginFailed = onFailed;

    if (!hasGoogleBirthDate && selectedDate == null) {
      final hasBirthday = await tryFetchGoogleBirthdayFromSignedInAccount();
      if (!hasBirthday) {
        setPendingGoogleLogin(true);
        setOpenDatePickerOnAgeScreen(true);
        if (context.mounted) {
          context.pushNamed(AppRoutes.enterAgeScreen.name);
        }
        return;
      }
    }

    final dateOfBirth = calculateDateToSend();
    if (dateOfBirth == null || dateOfBirth.isEmpty) {
      onFailed("Please select your date of birth");
      return;
    }

    var outcome = await _performGoogleSocialLogin(
      idToken: idToken,
      dateOfBirth: dateOfBirth,
    );

    if (outcome == _GoogleSocialLoginOutcome.existingAccount) {
      _finishGoogleLoginWithExistingAccount();
      return;
    }
    if (outcome == _GoogleSocialLoginOutcome.failed || !context.mounted) {
      return;
    }

    await LocalStorageService.instance.clearOnboardingSession();
    final ageSaved = await ensureOnboardingAndSaveAgeForGoogle(
      context: context,
      onFailed: (error) => _onGoogleLoginFailed?.call(error),
    );
    if (!ageSaved || !context.mounted) return;

    outcome = await _performGoogleSocialLogin(
      idToken: idToken,
      dateOfBirth: dateOfBirth,
      onboardingId: LocalStorageService.instance.onboardingId,
    );

    if (outcome == _GoogleSocialLoginOutcome.existingAccount) {
      _finishGoogleLoginWithExistingAccount();
      return;
    }
    if (outcome == _GoogleSocialLoginOutcome.newAccount) {
      _onGoogleNoAccountFound?.call();
    }
  }

  Future<void> completeGoogleSocialLogin(BuildContext context) async {
    final idToken = _pendingGoogleIdToken;
    if (idToken == null) {
      _onGoogleLoginFailed?.call(
        "Google sign-in session expired. Please try again.",
      );
      return;
    }

    final dateOfBirth = calculateDateToSend();
    if (dateOfBirth == null || dateOfBirth.isEmpty) {
      _onGoogleLoginFailed?.call("Please select your date of birth");
      return;
    }

    if (LocalStorageService.instance.onboardingId == null) {
      await LocalStorageService.instance.clearOnboardingSession();
      final ageSaved = await ensureOnboardingAndSaveAgeForGoogle(
        context: context,
        onFailed: (error) => _onGoogleLoginFailed?.call(error),
      );
      if (!ageSaved || !context.mounted) return;
    }

    final outcome = await _performGoogleSocialLogin(
      idToken: idToken,
      dateOfBirth: dateOfBirth,
      onboardingId: LocalStorageService.instance.onboardingId,
    );

    if (outcome == _GoogleSocialLoginOutcome.existingAccount) {
      _finishGoogleLoginWithExistingAccount();
      return;
    }
    if (outcome == _GoogleSocialLoginOutcome.newAccount) {
      _onGoogleNoAccountFound?.call();
    }
  }

  void navigateToHomeScreen([BuildContext? context]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.goRouter.goNamed(AppRoutes.homeScreen.name);
    });
  }

  Future<_GoogleSocialLoginOutcome> _performGoogleSocialLogin({
    required String idToken,
    required String dateOfBirth,
    String? onboardingId,
  }) async {
    isSocialLoginLoading = true;
    notifyListeners();

    try {
      final payload = {
        "provider": "google",
        "idToken": idToken,
        "dateOfBirth": dateOfBirth,
        if (onboardingId != null && onboardingId.isNotEmpty)
          "onboardingId": onboardingId,
      };

      final response = await AuthApiServices().googleSignUp(data: payload);
      return await response.fold<Future<_GoogleSocialLoginOutcome>>(
        (l) async {
          _onGoogleLoginFailed?.call(l.errorMsg);
          return _GoogleSocialLoginOutcome.failed;
        },
        (r) async {
          final responseData = r['data'];
          if (responseData is! Map) {
            _onGoogleLoginFailed?.call("Invalid login response");
            return _GoogleSocialLoginOutcome.failed;
          }

          final data = Map<String, dynamic>.from(responseData);
          Logger.info("Google Login Response Data: $data");
          await _persistSocialLoginSession(
            data,
            idToken: idToken,
            dateOfBirth: dateOfBirth,
          );

          if (data["session"] == null) {
            return _GoogleSocialLoginOutcome.newAccount;
          }
          return _GoogleSocialLoginOutcome.existingAccount;
        },
      );
    } catch (e) {
      _onGoogleLoginFailed?.call("Failed google login, please try again");
      return _GoogleSocialLoginOutcome.failed;
    } finally {
      isSocialLoginLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistSocialLoginSession(
    Map<String, dynamic> data, {
    required String idToken,
    required String dateOfBirth,
  }) async {
    final onboarding = data["onboarding"];
    if (onboarding is Map && onboarding['onboardingId'] != null) {
      if (onboarding['isCompleted'] == true) {
        await LocalStorageService.instance.clearOnboardingSession();
      } else {
        await LocalStorageService.instance.saveOnboardingId(
          onboarding['onboardingId'].toString(),
        );
      }
    }

    final user = data["user"];
    if (user is Map && user["id"] != null) {
      await LocalStorageService.instance.saveUserId(id: user["id"].toString());
    }

    final session = data["session"];
    if (session is! Map) {
      await LocalStorageService.instance.saveGoogleIdToken(idToken: idToken);
      await LocalStorageService.instance.saveDateOfBirth(dateOfBirth);
      return;
    }

    final accessToken = session["accessToken"]?.toString();
    if (accessToken != null && accessToken.isNotEmpty) {
      await LocalStorageService.instance.saveAuthToken(accessToken);
      DioClient.instance.addToken(accessToken);
      Logger.info("Token saved successfully from login: $accessToken");
    }

    if (session["refreshToken"] != null) {
      await LocalStorageService.instance.saveRefreshToken(
        session["refreshToken"].toString(),
      );
    }

    await LocalStorageService.instance.removeGoogleIdToken();
    await LocalStorageService.instance.removeDateOfBirth();
  }

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

  void toggleGoal(String id) {
    if (!selectedGoalIds.contains(id)) {
      selectedGoalIds.add(id);
      isCustomGoalSelected = false;
    } else {
      selectedGoalIds.remove(id);
    }
    notifyListeners();
  }

  // void updateGoalId(String id) {
  //   if (selectedGoalId == id) {
  //     selectedGoalId = "";
  //   } else {
  //     isCustomGoalSelected = false;
  //     customGoalTitleCtr.clear();
  //     customGoalDesCtr.clear();
  //     selectedGoalId = id;
  //   }
  //   notifyListeners();
  // }

  void toggleCustomGoal() {
    isCustomGoalSelected = !isCustomGoalSelected;
    if (!isCustomGoalSelected) {
      customGoalTitleCtr.clear();
      customGoalDesCtr.clear();
    } else {
      selectedGoalIds.clear();
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
      final data = await loadOnboardingProgress();
      if (data == null) return null;

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
    } catch (e) {
      debugPrint("Onboarding progress error: $e");
      return null;
    }
  }

  OnBoardingProgressModel? _cachedOnboardingProgress;

  OnBoardingProgressModel? get cachedOnboardingProgress =>
      _cachedOnboardingProgress;

  Future<OnBoardingProgressModel?> loadOnboardingProgress() async {
    final onboardingId = LocalStorageService.instance.onboardingId;
    if (onboardingId == null) return null;

    final response = await AuthApiServices().getOnboardingProgress(
      onboardingId: onboardingId,
    );

    if (response != null && response['success'] == true) {
      _cachedOnboardingProgress = OnBoardingProgressModel.fromJson(
        response['data'],
      );
      notifyListeners();
      return _cachedOnboardingProgress;
    }
    return null;
  }

  Future<bool> handleIncompleteOnboardingLogin(
    BuildContext context,
    Map<String, dynamic> response,
  ) async {
    final data = response['data'];
    if (data is! Map || data['requiresOnboarding'] != true) return false;

    final onboarding = data['onboarding'];
    if (onboarding is! Map) return false;

    await _persistOnboardingSessionFromLogin(
      Map<String, dynamic>.from(onboarding),
    );

    final progress = await loadOnboardingProgress();
    if (!context.mounted) return true;

    final step =
        progress?.currentStep?.toString() ??
        onboarding['currentStep']?.toString();
    if (step == null || step.isEmpty) return false;

    decideFirstScreen(context: context, step: step, showResumeMessage: true);
    return true;
  }

  Future<void> _persistOnboardingSessionFromLogin(
    Map<String, dynamic> onboarding,
  ) async {
    final onboardingId = onboarding['onboardingId']?.toString();
    if (onboardingId != null && onboardingId.isNotEmpty) {
      await LocalStorageService.instance.saveOnboardingId(onboardingId);
    }

    final email = onboarding['email']?.toString();
    if (email != null && email.isNotEmpty) {
      await LocalStorageService.instance.setOnboardingEmail(email);
      createAccEmailCtr.text = email;
      signUpEmailCtr.text = email;
      googleLoginEmail = email;
    }

    final dobRaw = onboarding['dateOfBirth']?.toString();
    if (dobRaw != null && dobRaw.isNotEmpty) {
      final parsed = DateTime.tryParse(dobRaw);
      if (parsed != null) {
        selectedDate = parsed;
        googleBirthDate =
            '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
        calculatedAge =
            onboarding['age'] as int? ?? _calculateAgeFromBirthDate(parsed);
        await LocalStorageService.instance.saveDateOfBirth(googleBirthDate);
        await LocalStorageService.instance.setAgeCompleted(true);
      }
    }
    notifyListeners();
  }

  int _calculateAgeFromBirthDate(DateTime birthDate) {
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  //todo
  bool get isUnder16 => calculatedAge < 16;
  bool get isUnder16FromGoogle => _isUnder16FromGoogle;

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

    final dateToSend = calculateDateToSend();
    Logger.info("dateToSend $dateToSend");
    if (dateToSend == null || dateToSend.isEmpty) {
      AppToast.error(context, "Please select your date of birth");
      return;
    }

    isSaveUserAgeLoading = true;
    notifyListeners();

    final response = await AuthApiServices().saveBirthDate(
      onboardingId: onboardingId,
      dateOfBirth: dateToSend,
    );
    response.fold(
      (l) {
        onFailed.call(l.errorMsg);
      },
      (r) async {
        await LocalStorageService.instance.setAgeCompleted(true);
        await LocalStorageService.instance.saveDateOfBirth(dateToSend);
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
      return "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
    }
    if (googleBirthDate.isNotEmpty) {
      return googleBirthDate;
    }
    return null;
  }

  Future<void> finalizeGoogleSignup({
    required BuildContext context,
    required VoidCallback onProfileInfo,
    required VoidCallback onParentEmail,
    required Function(String error) onFailed,
  }) async {
    if (isUnder16) {
      setIsUnder16FromGoogle(value: true);
      setPendingGoogleSignup(false);
      onParentEmail();
      return;
    }

    setIsUnder16FromGoogle(value: false);
    toggleAcceptedTerms(value: true);

    if (createAccPasswordCtr.text.trim().isEmpty) {
      generateStrongPassword();
    }

    final success = await createAccount(
      isTermsAccepted: acceptedTerms,
      context: context,
      onSuccess: onProfileInfo,
    );

    setPendingGoogleSignup(false);

    if (!success && context.mounted) {
      onFailed("Failed to create account. Please try again.");
    }
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
    VoidCallback? onSuccess,
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
      isSocialLoginLoading = false;
      notifyListeners();

      if (response != null && response['success'] == true) {
        setEmailSent(true);
        onSuccess?.call();

        LocalStorageService.instance.saveUserMail(
          mail: createAccEmailCtr.text.trim(),
        );
        LocalStorageService.instance.saveUserPass(
          password: createAccPasswordCtr.text.trim(),
        );
        return true;
      }
      return false;

      // else {
      //   if (response['errors'] != null &&
      //       (response['errors'] as List).isNotEmpty) {
      //     final firstError = response['errors'][0];
      //     final msg = firstError['msg'] ?? "Failed to create account";
      //     Logger.info("1Getted error message: $msg");
      //     final showError = (msg == "Invalid password for existing account")
      //         ? "An account with this information already exists."
      //         : msg;
      //     AppToast.info(context: context, message: showError);
      //   } else {
      //     final msg = response['message'] ?? "Failed to create account";
      //     AppToast.error(context, msg);
      //   }
      //   return false;
      // }
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
            final showError = (msg == "Invalid password for existing account")
                ? "An account with this mail already exists"
                : msg;
            Logger.info("2Getted error message: $msg");

            AppToast.info(context: context, message: showError);
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

  Future<void> fetchDefaultTopics(
    BuildContext context, {
    String? search,
  }) async {
    try {
      isLoadingTopics = true;
      notifyListeners();

      final response = await AuthApiServices().getDefaultTopics(search: search);

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
        // AppToast.success(
        //   context,
        //   response['message'] ?? "Goals saved successfully",
        // );
        selectedGoalIds.clear();
        isCustomGoalSelected = false;
        customGoalTitleCtr.clear();
        customGoalDesCtr.clear();
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
  //
  Future<bool> loginWithMail({required BuildContext context}) async {
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
              await LocalStorageService.instance.saveAuthToken(token!);
              Logger.info(LocalStorageService.instance.getAuthToken.toString());
            }

            // Extract refresh token
            if (session['refreshToken'] != null) {
              await LocalStorageService.instance.saveRefreshToken(
                session['refreshToken'],
              );
            }
          }

          await LocalStorageService.instance.saveUserId(id: data['user']['id']);
          // Fallback to flat structure
          // else if (data['accessToken'] != null) {
          //   token = data['accessToken'];
          // } else if (data['token'] != null) {
          //   token = data['token'];
          // }

          if (token != null) {
            await LocalStorageService.instance.saveAuthToken(token);
            Logger.info(LocalStorageService.instance.getAuthToken.toString());

            DioClient.instance.addToken(token);
            Logger.info("Token saved successfully from login: $token");
          } else {
            Logger.info("No access token found in login response!");
          }

          if (data['onboardingId'] != null) {
            await LocalStorageService.instance.saveOnboardingId(
              data['onboardingId'].toString(),
            );
          }
        }
        context.goNamed(AppRoutes.homeScreen.name);
        AppToast.success(context, response['message'] ?? "Login successful");
        loginEmailCtr.clear();
        loginPasswordCtr.clear();
        return true;
      } else {
        final responseData = response['data'];
        if (responseData is Map &&
            responseData['requiresOnboarding'] == true &&
            context.mounted) {
          final handled = await handleIncompleteOnboardingLogin(
            context,
            Map<String, dynamic>.from(response),
          );
          if (handled) return false;
        }

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

  //todo google sign up
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
        // signUpEmailCtr.text = data["user"]["email"];
        await LocalStorageService.instance.saveOnboardingId(
          data["onboarding"]["onboardingId"],
        );

        onSuccess.call();
      },
    );
  }

  //todo ------------------> login with google
  Future<void> loginWithGoogle({
    VoidCallback? onAccountFound,
    required String? idToken,
    required String dateOfBirth,
    String? onboardingId,
    Function(String error)? onNoAccountFound,
    required Function(String error) onFailed,
  }) async {
    if (idToken == null) {
      isSocialLoginLoading = false;
      notifyListeners();
      return;
    }

    _onGoogleLoginFailed = onFailed;
    final outcome = await _performGoogleSocialLogin(
      idToken: idToken,
      dateOfBirth: dateOfBirth,
      onboardingId: onboardingId,
    );

    if (outcome == _GoogleSocialLoginOutcome.existingAccount) {
      onAccountFound?.call();
      return;
    }
    if (outcome == _GoogleSocialLoginOutcome.newAccount) {
      onNoAccountFound?.call("");
    }
  }

  Future<void> loginWithStoredGoogleToken({
    required BuildContext context,
    required VoidCallback onAccountFound,
    required Function(String error) onFailed,
  }) async {
    final idToken = LocalStorageService.instance.getGoogleIdToken;
    if (idToken.isEmpty) {
      onFailed("Google sign-in session expired. Please login again.");
      return;
    }

    final storedDob = LocalStorageService.instance.getSavedDateOfBirth;
    final dateOfBirth = storedDob.isNotEmpty ? storedDob : calculateDateToSend();
    if (dateOfBirth == null || dateOfBirth.isEmpty) {
      onFailed("Date of birth not found. Please login again.");
      return;
    }

    _onGoogleLoginFailed = onFailed;
    final outcome = await _performGoogleSocialLogin(
      idToken: idToken,
      dateOfBirth: dateOfBirth,
      onboardingId: LocalStorageService.instance.onboardingId,
    );

    if (outcome == _GoogleSocialLoginOutcome.existingAccount) {
      onAccountFound();
      return;
    }

    onFailed("Could not complete Google login. Please try again.");
  }

  bool _isGoogleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_isGoogleSignInInitialized) return;

    await GoogleSignIn.instance.initialize(
      serverClientId: AppConstants.serverClientId,
      clientId: Platform.isIOS ? AppConstants.clientIdIos : null,
    );
    _isGoogleSignInInitialized = true;
  }

  Future<GoogleSignInAccount?> _authenticateWithGoogle({
    required List<String> scopes,
  }) async {
    await _ensureGoogleSignInInitialized();

    try {
      final account = await GoogleSignIn.instance.authenticate(scopeHint: scopes);
      _lastGoogleSignInAccount = account;
      return account;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        Logger.error("User cancelled sign-in");
        return null;
      }
      Logger.error(
        "Google Sign-In error: ${e.code.name} ${e.description ?? ''}",
      );
      rethrow;
    }
  }

  void _populateFieldsFromGoogleAccount(GoogleSignInAccount account) {
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
  }

  Future<String?> _authorizeGoogleAccessToken(
    GoogleSignInAccount account,
    List<String> scopes,
  ) async {
    try {
      final authorization =
          await account.authorizationClient.authorizeScopes(scopes);
      return authorization.accessToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        Logger.error("User cancelled Google authorization");
        return null;
      }
      Logger.error(
        "Google authorization error: ${e.code.name} ${e.description ?? ''}",
      );
      return null;
    }
  }

  //todo google login functions
  //todo Google Sign-In Platform Exception: com.google.android.gms.common.api.ApiException: 16:
  Future<String?> getGoogleIDTokenForLogin() async {
    try {
      isSocialLoginLoading = true;
      notifyListeners();

      const scopes = ['email', 'profile'];
      final account = await _authenticateWithGoogle(scopes: scopes);
      if (account == null) return null;

      _populateFieldsFromGoogleAccount(account);

      final auth = account.authentication;
      final accessToken = await _authorizeGoogleAccessToken(account, scopes);
      Logger.info(account.email);
      Logger.info("Account: /${account.toString()}");
      Logger.info("access Token: ${accessToken ?? 'NULL'}");
      Logger.info("idToken: /${auth.idToken ?? 'NULL'}");
      Logger.info("\nclose");

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
    } finally {
      isSocialLoginLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getGoogleIDToken() async {
    try {
      isSocialLoginLoading = true;
      notifyListeners();

      const scopes = [
        'email',
        'profile',
        _googleBirthdayScope,
      ];

      // Critical: Ensure UI thread is ready (prevents deadlock)
      await Future.delayed(const Duration(milliseconds: 100));

      final account = await _authenticateWithGoogle(scopes: scopes);
      if (account == null) return null;

      _populateFieldsFromGoogleAccount(account);

      Logger.info("Email: ${account.email}");
      Logger.info("Display Name: ${account.displayName?.trim() ?? ''}");

      final auth = account.authentication;
      final accessToken = await _authorizeGoogleAccessToken(account, scopes);

      Logger.info("Access Token: ${accessToken ?? 'NULL'}");
      Logger.info("ID Token: ${auth.idToken ?? 'NULL'}");

      if (auth.idToken == null) {
        Logger.error(
          "⚠️ ID Token is NULL - Check serverClientId configuration!",
        );
        Logger.error(
          "Make sure you're using the Web Client ID, not Android Client ID",
        );
        return null;
      }

      if (accessToken != null) {
        Logger.info("Birthdate API Calling");
        await _fetchGoogleBirthday(accessToken);
      } else {
        googleBirthDate = "";
        Logger.info("Birthday scope not granted; manual DOB entry required");
      }

      generateStrongPassword();

      return auth.idToken;
    } catch (e) {
      Logger.error("Google Sign In error: ${e.toString()}");

      try {
        await GoogleSignIn.instance.signOut();
      } catch (signOutError) {
        Logger.error("Sign out error: $signOutError");
      }

      return null;
    } finally {
      isSocialLoginLoading = false;
      notifyListeners();
    }
  }

  Future<bool> tryFetchGoogleBirthdayFromSignedInAccount() async {
    final account = _lastGoogleSignInAccount;
    if (account == null) {
      Logger.info("No signed-in Google account available for birthday fetch");
      return false;
    }

    final accessToken = await _authorizeGoogleAccessToken(
      account,
      const [_googleBirthdayScope],
    );
    if (accessToken == null) {
      Logger.info("Birthday scope not granted; manual DOB entry required");
      return false;
    }

    return _fetchGoogleBirthday(accessToken);
  }

  //todo fetch google birth date
  Future<bool> _fetchGoogleBirthday(String accessToken) async {
    googleBirthDate = "";
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      final response = await dio.get<Map<String, dynamic>>(
        "https://people.googleapis.com/v1/people/me",
        queryParameters: {"personFields": "birthdays"},
        options: Options(headers: {"Authorization": "Bearer $accessToken"}),
      );

      final data = response.data;
      if (data == null) return false;

      Logger.info("Birthdate response: $data");
      final birthdays = data["birthdays"];
      if (birthdays == null || birthdays is! List || birthdays.isEmpty) {
        Logger.info("No birthday set on Google account");
        return false;
      }

      final date = birthdays.first["date"];
      if (date == null || date is! Map) return false;

      final year = date["year"];
      final month = date["month"];
      final day = date["day"];
      if (year == null || month == null || day == null) {
        Logger.info("Google birthday is missing year, month, or day");
        return false;
      }

      final today = DateTime.now();
      calculatedAge = today.year - (year as int);
      if (today.month < (month as int) ||
          (today.month == month && today.day < (day as int))) {
        calculatedAge--;
      }

      googleBirthDate =
          "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
      Logger.info("Google Birthdate: $googleBirthDate");
      notifyListeners();
      return true;
    } on DioException catch (e) {
      Logger.error(
        "Failed to fetch birthday: ${e.response?.data ?? e.message}",
      );
      return false;
    } catch (e) {
      Logger.error("Failed to fetch birthday: $e");
      return false;
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
    resetAppProvidersForNewUser();
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
    googleBirthDate = "";
    _pendingGoogleSignup = false;
    _pendingGoogleLogin = false;
    _openDatePickerOnAgeScreen = false;
    _pendingGoogleIdToken = null;
    _onGoogleAccountFound = null;
    _onGoogleNoAccountFound = null;
    _onGoogleLoginFailed = null;
    _lastGoogleSignInAccount = null;
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
        if (l.code == "400") {
          onFailed.call(
            "New password should be different from the old password",
          );
        } else {
          onFailed.call(l.errorMsg);
        }
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
    bool showResumeMessage = true,
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
    } else if (step == AppConstants.profileInfo ||
        step == AppConstants.readingGoal ||
        step == AppConstants.interest ||
        step == AppConstants.topics ||
        step == AppConstants.goals) {
      context.goNamed(
        AppRoutes.accountSetupScreen.name,
        extra: step,
      );
    } else if (step == AppConstants.completed) {
      if (LocalStorageService.instance.getAuthToken!.isEmpty) {
        context.goNamed(AppRoutes.loginScreen.name);
      } else {
        context.goNamed(AppRoutes.homeScreen.name);
      }
    }

    if (showResumeMessage && step != AppConstants.completed) {
      AppToast.info(
        context: context,
        durationSecond: 5,
        message: "Please complete your onboarding to access your account.",
      );
    }
  }
}
