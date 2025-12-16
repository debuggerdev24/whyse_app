import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/extensions/routes_extensions.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/screens/above_16/create_account_screen.dart';
import 'package:redstreakapp/screens/above_16/subscription_screen.dart';
import 'package:redstreakapp/screens/above_16/success_screen.dart';
import 'package:redstreakapp/screens/auth/enter_age_screen.dart';
import 'package:redstreakapp/screens/auth/login_screen.dart';
import 'package:redstreakapp/screens/auth/signup_screen.dart';
import 'package:redstreakapp/screens/home/home_screen.dart';
import 'package:redstreakapp/screens/splash/splash_screen.dart';

import 'package:redstreakapp/screens/above_16/goals_screen.dart';
import 'package:redstreakapp/screens/above_16/interests_screen.dart';
import 'package:redstreakapp/screens/above_16/profile_info_screen.dart';
import 'package:redstreakapp/screens/above_16/reading_goal_screen.dart';
import 'package:redstreakapp/screens/above_16/topics_screen.dart';
import 'package:redstreakapp/screens/tabs/tab.dart';

class UserAppRoute {
  static final GoRouter goRouter = GoRouter(
    initialLocation: UserAppRoutes.splashScreen.path,
    routes: routes,
  );

  static final List<RouteBase> routes = [
    GoRoute(
      path: UserAppRoutes.splashScreen.path,
      name: UserAppRoutes.splashScreen.name,
      builder: (context, state) {
        return SplashScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.loginScreen.path,
      name: UserAppRoutes.loginScreen.name,
      builder: (context, state) {
        return LoginScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.signUpScreen.path,
      name: UserAppRoutes.signUpScreen.name,
      builder: (context, state) {
        return SignupScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.enterAgeScreen.path,
      name: UserAppRoutes.enterAgeScreen.name,
      builder: (context, state) {
        return AgeEntryScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.createAccountScreen.path,
      name: UserAppRoutes.createAccountScreen.name,
      builder: (context, state) {
        return CreateAccountScreen();
      },
    ),
    // Below 16 Routes
    // GoRoute(
    //   path: UserAppRoutes.parentEmailScreen.path,
    //   name: UserAppRoutes.parentEmailScreen.name,
    //   builder: (context, state) {
    //     return ParentEmailScreen();
    //   },
    // ),
    // GoRoute(
    //   path: UserAppRoutes.consentStatusScreen.path,
    //   name: UserAppRoutes.consentStatusScreen.name,
    //   builder: (context, state) {
    //     // Optional: Parse extra for testing/demo purposes if we want to toggle state
    //     // final bool isAccepted = state.extra as bool? ?? true;
    //     return ConsentStatusScreen();
    //   },
    // ),
    // Onboarding Routes
    GoRoute(
      path: UserAppRoutes.profileInfoScreen.path,
      name: UserAppRoutes.profileInfoScreen.name,
      builder: (context, state) {
        return ProfileInfoScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.readingGoalScreen.path,
      name: UserAppRoutes.readingGoalScreen.name,
      builder: (context, state) {
        return ReadingGoalScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.interestsScreen.path,
      name: UserAppRoutes.interestsScreen.name,
      builder: (context, state) {
        return InterestsScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.topicsScreen.path,
      name: UserAppRoutes.topicsScreen.name,
      builder: (context, state) {
        return TopicsScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.goalsScreen.path,
      name: UserAppRoutes.goalsScreen.name,
      builder: (context, state) {
        return GoalsScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.successScreen.path,
      name: UserAppRoutes.successScreen.name,
      builder: (context, state) {
        return SuccessScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.subScriptionScreen.path,
      name: UserAppRoutes.subScriptionScreen.name,
      builder: (context, state) {
        return SubScriptionScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.tabScreen.path,
      name: UserAppRoutes.tabScreen.name,
      builder: (context, state) {
        return TabScreen();
      },
    ),
  ];
}
