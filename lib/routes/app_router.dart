import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/extensions/routes_extensions.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/screens/above_16/create_account_screen.dart';
import 'package:redstreakapp/screens/above_16/interests_screen.dart';
import 'package:redstreakapp/screens/above_16/profile_info_screen.dart';
import 'package:redstreakapp/screens/above_16/reading_goal_screen.dart';
import 'package:redstreakapp/screens/above_16/subscription_screen.dart';
import 'package:redstreakapp/screens/above_16/success_screen.dart';
import 'package:redstreakapp/screens/above_16/topics_screen.dart';
import 'package:redstreakapp/screens/above_16/what_goals_screen.dart';
import 'package:redstreakapp/screens/above_16/what_intrest_screen.dart';
import 'package:redstreakapp/screens/auth/enter_age_screen.dart';
import 'package:redstreakapp/screens/auth/forgot_password_screen.dart';
import 'package:redstreakapp/screens/auth/login_screen.dart';
import 'package:redstreakapp/screens/auth/reset_password_screen.dart';
import 'package:redstreakapp/screens/auth/signup_screen.dart';
import 'package:redstreakapp/screens/auth/verify_otp_screen.dart';
import 'package:redstreakapp/screens/home/generate_reading_screen.dart';
import 'package:redstreakapp/screens/home/quiz_completed_screen.dart';
import 'package:redstreakapp/screens/home/quiz_question_screen.dart';
import 'package:redstreakapp/screens/home/reading_screen.dart';
import 'package:redstreakapp/screens/home/start_quiz_screen.dart';

import '../models/home/story_models/story_model.dart';
import '../screens/below_16/consent_status_screen.dart';
import '../screens/below_16/parent_email_screen.dart';
import '../screens/dashboard.dart';
import '../screens/splash/splash_screen.dart';

class UserAppRoute {
  static final GoRouter goRouter = GoRouter(
    initialLocation: AppRoutes.splashScreen.path,
    routes: routes,
  );

  static final List<RouteBase> routes = [
    GoRoute(
      path: AppRoutes.splashScreen.path,
      name: AppRoutes.splashScreen.name,
      builder: (context, state) {
        return SplashScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.loginScreen.path,
      name: AppRoutes.loginScreen.name,
      builder: (context, state) {
        return LoginScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.signUpScreen.path,
      name: AppRoutes.signUpScreen.name,
      builder: (context, state) {
        return SignupScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.enterAgeScreen.path,
      name: AppRoutes.enterAgeScreen.name,
      builder: (context, state) {
        return AgeEntryScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.createAccountScreen.path,
      name: AppRoutes.createAccountScreen.name,
      builder: (context, state) {
        return CreateAccountScreen();
      },
    ),
    // Below 16 Routes
    GoRoute(
      path: AppRoutes.parentEmailScreen.path,
      name: AppRoutes.parentEmailScreen.name,
      builder: (context, state) {
        return ParentEmailScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.consentStatusScreen.path,
      name: AppRoutes.consentStatusScreen.name,
      builder: (context, state) {
        // Optional: Parse extra for testing/demo purposes if we want to toggle state
        // final bool isAccepted = state.extra as bool? ?? true;
        return ConsentStatusScreen();
      },
    ),
    // Onboarding Routes
    GoRoute(
      path: AppRoutes.profileInfoScreen.path,
      name: AppRoutes.profileInfoScreen.name,
      builder: (context, state) {
        return ProfileInfoScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.readingGoalScreen.path,
      name: AppRoutes.readingGoalScreen.name,
      builder: (context, state) {
        return ReadingGoalScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.interestsScreen.path,
      name: AppRoutes.interestsScreen.name,
      builder: (context, state) {
        return InterestsScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.topicsScreen.path,
      name: AppRoutes.topicsScreen.name,
      builder: (context, state) {
        return TopicsScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.goalsScreen.path,
      name: AppRoutes.goalsScreen.name,
      builder: (context, state) {
        return GoalsScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.successScreen.path,
      name: AppRoutes.successScreen.name,
      builder: (context, state) {
        return SuccessScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.subscriptionScreen.path,
      name: AppRoutes.subscriptionScreen.name,
      builder: (context, state) {
        return SubScriptionScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.tabScreen.path,
      name: AppRoutes.tabScreen.name,
      builder: (context, state) {
        return TabScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.bookReadingScreen.path,
      name: AppRoutes.bookReadingScreen.name,
      builder: (context, state) {
        return GenerateReadingScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.readingScreen.path,
      name: AppRoutes.readingScreen.name,
      builder: (context, state) {
        final story = state.extra as Story?;
        return ReadingScreen(story: story);
      },
    ),
    GoRoute(
      path: AppRoutes.startQuizScreen.path,
      name: AppRoutes.startQuizScreen.name,
      builder: (context, state) {
        return StartQuizScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.quizQuestionScreen.path,
      name: AppRoutes.quizQuestionScreen.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final quizzes = extra?['quizzes'] as List<Quiz>? ?? [];
        final storyTitle = extra?['storyTitle'] as String? ?? "";
        return QuizQuestionScreen(quizzes: quizzes, storyTitle: storyTitle);
      },
    ),
    GoRoute(
      path: AppRoutes.quizCompletedScreen.path,
      name: AppRoutes.quizCompletedScreen.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final score = extra?['score'] as int? ?? 0;
        final total = extra?['total'] as int? ?? 0;
        final storyTitle = extra?['storyTitle'] as String? ?? "";
        return QuizCompletedScreen(
          score: score,
          total: total,
          storyTitle: storyTitle,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.whatInterestScreen.path,
      name: AppRoutes.whatInterestScreen.name,
      builder: (context, state) {
        return WhatInatestScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.forgotPasswordScreen.path,
      name: AppRoutes.forgotPasswordScreen.name,
      builder: (context, state) {
        return ForgotPasswordScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.verifyOtpScreen.path,
      name: AppRoutes.verifyOtpScreen.name,
      builder: (context, state) {
        return VerifyOtpScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.resetPasswordScreen.path,
      name: AppRoutes.resetPasswordScreen.name,
      builder: (context, state) {
        return ResetPasswordScreen();
      },
    ),

    // GoRoute(
    //   path: UserAppRoutes.whatInterestScreen.path,
    //   name: UserAppRoutes.whatInterestScreen.name,
    //   builder: (context, state) {
    //     return WhatInatestScreen();
    //   },
    // ),
  ];
}
