import 'dart:core';

class EndPoints {
  EndPoints._();
  static const startOnBoarding = "/mobile/auth/start-onboarding";
  static const onBoardingProgress = "/mobile/auth/onboarding-progress";
  static const saveParentEmail = "/mobile/auth/save-parent-email";
  static const logIn = "/mobile/auth/login";
  static const logOut = "/mobile/auth/logout";
  static const saveTopics = "/mobile/auth/save-topics";
  static const saveInterest = "/mobile/auth/save-interests";
  static const saveReadings = "/mobile/auth/save-reading-goal";
  static const saveProfile = "/mobile/auth/save-profile-info";
  static const verifyEmail = "/mobile/auth/verify-email";
  static const createAccount = "/mobile/auth/create-account";
  static const saveAge = "/mobile/auth/save-age";
  static const socialLogin = "/mobile/auth/social-login";
  static const getStoryGoals = "/story-flow/goals";
  static const getStoryInterest = "/story-flow/interests";
  static const getStoryTopics = "/story-flow/topics";
  // static String getSearchTopics({required String query}) => "/api/v1/story-flow/topics?search=$query";
  static const getSearchTopics = "story-flow/topics";
  static const forgotPassword = "/mobile/auth/forgot-password";
  static const resetPassword = "/mobile/auth/reset-password";
}
