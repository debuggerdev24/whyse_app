import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/extensions/routes_extensions.dart';
import 'package:redstreakapp/screens/auth/above_16/create_account_screen.dart';
import 'package:redstreakapp/screens/auth/above_16/goals_screen.dart';
import 'package:redstreakapp/screens/auth/above_16/interests_screen.dart';
import 'package:redstreakapp/screens/auth/above_16/profile_info_screen.dart';
import 'package:redstreakapp/screens/auth/above_16/reading_goal_screen.dart';
import 'package:redstreakapp/screens/auth/above_16/subscription_screen.dart';
import 'package:redstreakapp/screens/auth/above_16/success_screen.dart';
import 'package:redstreakapp/screens/auth/above_16/topics_screen.dart';
import 'package:redstreakapp/screens/auth/above_16/what_intrest_screen.dart';
import 'package:redstreakapp/screens/auth/enter_age_screen.dart';
import 'package:redstreakapp/screens/auth/forgot_password_screen.dart';
import 'package:redstreakapp/screens/auth/login_screen.dart';
import 'package:redstreakapp/screens/auth/reset_password_screen.dart';
import 'package:redstreakapp/screens/auth/signup_screen.dart';
import 'package:redstreakapp/screens/auth/verify_mail_screen.dart';
import 'package:redstreakapp/screens/group/add_members_screen.dart';
import 'package:redstreakapp/screens/group/create_group_screen.dart';
import 'package:redstreakapp/screens/group/group_details_screen.dart';
import 'package:redstreakapp/screens/group/group_list_screen.dart';
import 'package:redstreakapp/screens/group/join_group_screen.dart';
import 'package:redstreakapp/screens/group/share_stories_in_group_screen.dart';
import 'package:redstreakapp/screens/group/streak_ranking_screen.dart';
import 'package:redstreakapp/screens/group/view_group_screen.dart';
import 'package:redstreakapp/screens/home/curiosity_reading/curiosity_reading_screen.dart';
import 'package:redstreakapp/screens/notification/notification_screen.dart';
import 'package:redstreakapp/screens/profile/profile_screen.dart';
import 'package:redstreakapp/screens/profile/your_books_screen.dart';
import 'package:redstreakapp/screens/search/search_screen.dart';
import 'package:redstreakapp/screens/home/story/custom_story_topic_screen.dart';

import 'package:redstreakapp/screens/home/story/story_goals_screen.dart';
import 'package:redstreakapp/screens/home/story/created_story_reading_screen.dart';
import 'package:redstreakapp/screens/home/story/shared_story_screen.dart';
import 'package:redstreakapp/screens/home/story/random_story_series_screen.dart';
import 'package:redstreakapp/screens/home/story/story_reading_goal_screen.dart';
import 'package:redstreakapp/screens/home/story/story_topics_screen.dart';
import 'package:redstreakapp/screens/home/home_screen.dart';
import 'package:redstreakapp/screens/home/quiz/quiz_completed_screen.dart';
import 'package:redstreakapp/screens/home/quiz/quiz_question_screen.dart';
import 'package:redstreakapp/screens/home/quiz/enter_quiz_number.dart';
import 'package:redstreakapp/screens/home/quiz/start_quiz_screen.dart';
import 'package:redstreakapp/models/home/browse_topic_model.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/screens/practice/practice_zone.dart';
import 'package:redstreakapp/screens/settings/friends_notification_settings.dart';
import 'package:redstreakapp/screens/settings/groups_notification_settings.dart';
import 'package:redstreakapp/screens/settings/reminders_settings_screen.dart';
import 'package:redstreakapp/screens/settings/settings_screen.dart';
import 'package:redstreakapp/screens/settings/preferences_screen.dart';
import 'package:redstreakapp/screens/settings/settings_notification_screen.dart';
import 'package:redstreakapp/screens/settings/edit_profile_screen.dart';
import 'package:redstreakapp/screens/your_book/find_your_books_screen.dart';
import 'package:redstreakapp/screens/your_book/book_details_screen.dart';

import '../../screens/auth/below_16/consent_status_screen.dart';
import '../../screens/auth/below_16/parent_email_screen.dart';
import '../../screens/dashboard.dart';
import '../../screens/home/story/story_interest_screen.dart';
import '../../screens/home/story/home_ideas_list.dart';
import '../../screens/home/my_story_ideas_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../models/home/story_models/story_model.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static StatefulNavigationShell? indexedStackNavigationShell;

  static final GoRouter goRouter = GoRouter(
    navigatorKey: rootNavigatorKey,

    initialLocation: AppRoutes.splashScreen.path,
    routes: [
      ...routes,
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          indexedStackNavigationShell = navigationShell;
          return UserDashBoard(
            // key: state.pageKey,
            navigationShell: indexedStackNavigationShell!,
          );
        },
        branches: <StatefulShellBranch>[
          //* Home tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.homeScreen.path,
                name: AppRoutes.homeScreen.name,
                builder: (context, state) => HomeScreen(),
              ),
              GoRoute(
                path: AppRoutes.notificationScreen.path,
                name: AppRoutes.notificationScreen.name,
                builder: (context, state) => NotificationScreen(),
              ),
            ],
          ),
          //* Search tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.findYourBooksScreen.path,
                name: AppRoutes.findYourBooksScreen.name,
                builder: (context, state) => FindYourBooksScreen(),
              ),
            ],
          ),
          //* Practice Zone tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.practiceZoneScreen.path,
                name: AppRoutes.practiceZoneScreen.name,
                builder: (context, state) => PracticeZoneSection(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.searchScreen.path,
                name: AppRoutes.searchScreen.name,
                builder: (context, state) => SearchScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
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
        final String status = (state.extra as String?) ?? "false";

        return CreateAccountScreen(consentStatus: status);
      },
    ),

    //* Below 16 Routes
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
        return ConsentStatusScreen();
      },
    ),
    //* Onboarding Routes
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
      path: AppRoutes.enterQuizNumbersScreen.path,
      name: AppRoutes.enterQuizNumbersScreen.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return EnterQuizNumbersScreen(
          storyId: extra["storyId"] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.startQuizScreen.path,
      name: AppRoutes.startQuizScreen.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return StartQuizScreen(
          storyId: extra["storyId"] as String? ?? "",
          storyTitle: extra["storyTitle"] as String? ?? "",
        );
      },
    ),

    GoRoute(
      path: AppRoutes.quizQuestionScreen.path,
      name: AppRoutes.quizQuestionScreen.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final quizzes = extra?['quizzes'] as List<StoryQuiz>? ?? [];
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
        return WhatInterestScreen();
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
        final bool status = (state.extra as bool?) ?? false;
        return ResetPasswordScreen(isVerified: status);
      },
    ),
    GoRoute(
      path: AppRoutes.storyGoalsScreen.path,
      name: AppRoutes.storyGoalsScreen.name,
      builder: (context, state) {
        final extra = state.extra;
        final openedFromCreatedIdeas =
            extra is Map && extra['openedFromCreatedIdeas'] == true;
        return StoryGoalsScreen(openedFromCreatedIdeas: openedFromCreatedIdeas);
      },
    ),
    GoRoute(
      path: AppRoutes.storyInterestScreen.path,
      name: AppRoutes.storyInterestScreen.name,
      builder: (context, state) {
        return StoryInterestsScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.customTopicScreen.path,
      name: AppRoutes.customTopicScreen.name,
      builder: (context, state) {
        return CustomStoryTopicScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.storyTopicsScreen.path,
      name: AppRoutes.storyTopicsScreen.name,
      builder: (context, state) {
        return StoryTopicsScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.storyReadingGoalScreen.path,
      name: AppRoutes.storyReadingGoalScreen.name,
      builder: (context, state) {
        return StoryReadingGoalScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.goalsScreen.path,
      name: AppRoutes.goalsScreen.name,
      builder: (context, state) {
        return GoalScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.createdStorySummaryScreen.path,
      name: AppRoutes.createdStorySummaryScreen.name,
      builder: (context, state) {
        return MyStoryIdeasScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.storyIdeasScreen.path,
      name: AppRoutes.storyIdeasScreen.name,
      builder: (context, state) {
        return const HomeIdeasListScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.storyReadingScreen.path,
      name: AppRoutes.storyReadingScreen.name,
      // onExit: (context, state) async {
      // },
      builder: (context, state) {
        return const CreatedStoryReadingScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.createdStoryReadingScreen.path,
      name: AppRoutes.createdStoryReadingScreen.name,
      builder: (context, state) {
        return const CreatedStoryReadingScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.sharedStoryScreen.path,
      name: AppRoutes.sharedStoryScreen.name,
      onExit: (context, state) async {
        return SharedStoryScreen.shouldAllowPop(context);
      },
      builder: (context, state) {
        return const SharedStoryScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.randomStorySeriesScreen.path,
      name: AppRoutes.randomStorySeriesScreen.name,
      builder: (context, state) {
        final extra = state.extra;
        final isFromSearch = extra is Map && extra["progress"] != null;
        final progressResponse = isFromSearch
            ? (extra["progress"] as Map<String, dynamic>)
            : (extra as Map<String, dynamic>? ?? {});
        BrowseTopicModel? searchTopic;
        if (isFromSearch && extra["searchTopic"] != null) {
          try {
            final map = extra["searchTopic"];
            searchTopic = map is Map
                ? BrowseTopicModel.fromJson(Map<String, dynamic>.from(map))
                : null;
          } catch (_) {
            searchTopic = null;
          }
        }
        return RandomTopicReadingScreen(
          progressResponse: progressResponse,
          searchTopic: searchTopic,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.yourBooksScreen.path,
      name: AppRoutes.yourBooksScreen.name,
      builder: (context, state) {
        return const YourEBooksScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.createdIdeasListScreen.path,
      name: AppRoutes.createdIdeasListScreen.name,
      builder: (context, state) {
        final extra = state.extra;
        final preferGeneratedData =
            extra is Map && extra['preferGeneratedData'] == true;
        return MyStoryIdeasScreen(preferGeneratedData: preferGeneratedData);
      },
    ),
    GoRoute(
      path: AppRoutes.bookDetailsScreen.path,
      name: AppRoutes.bookDetailsScreen.name,
      builder: (context, state) {
        return const BookDetailsScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.profileScreen.path,
      name: AppRoutes.profileScreen.name,
      builder: (context, state) => ProfileScreen(),
      routes: [
        GoRoute(
          path: AppRoutes.settingsScreen.name,
          name: AppRoutes.settingsScreen.name,
          builder: (context, state) {
            return const SettingsScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.preferencesScreen.name,
          name: AppRoutes.preferencesScreen.name,
          builder: (context, state) {
            return const PreferencesScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.settingsNotificationScreen.name,
          name: AppRoutes.settingsNotificationScreen.name,
          builder: (context, state) {
            return const SettingsNotificationScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.editProfileScreen.name,
          name: AppRoutes.editProfileScreen.name,
          builder: (context, state) {
            return const EditProfileScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.remindersSettingsScreen.name,
          name: AppRoutes.remindersSettingsScreen.name,
          builder: (context, state) {
            return const RemindersSettingsScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.friendsNotificationSettingsScreen.name,
          name: AppRoutes.friendsNotificationSettingsScreen.name,
          builder: (context, state) {
            return const FriendsNotificationSettingsScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.groupsNotificationSettingsScreen.name,
          name: AppRoutes.groupsNotificationSettingsScreen.name,
          builder: (context, state) {
            return const GroupsNotificationSettingsScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.createGroupScreen.name,
          name: AppRoutes.createGroupScreen.name,
          builder: (context, state) {
            return const CreateGroupScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.addMembersScreen.name,
          name: AppRoutes.addMembersScreen.name,
          builder: (context, state) {
            return const AddMembersScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.groupListScreen.name,
          name: AppRoutes.groupListScreen.name,
          builder: (context, state) {
            return const GroupListScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.viewGroupScreen.name,
          name: AppRoutes.viewGroupScreen.name,
          builder: (context, state) {
            return ViewGroupScreen(
              params: state.extra as GroupDetailsScreenParams,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.groupDetailsScreen.name,
          name: AppRoutes.groupDetailsScreen.name,
          builder: (context, state) {
            return GroupDetailsScreen(
              params: state.extra as GroupDetailsScreenParams,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.streakRankingScreen.name,
          name: AppRoutes.streakRankingScreen.name,
          builder: (context, state) {
            return const StreakRankingScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.joinGroupScreen.name,
          name: AppRoutes.joinGroupScreen.name,
          builder: (context, state) {
            return const JoinGroupScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.curiosityReadingScreen.name,
          name: AppRoutes.curiosityReadingScreen.name,
          builder: (context, state) {
            return const CuriosityReadingScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.shareStoriesInGroupScreen.name,
          name: AppRoutes.shareStoriesInGroupScreen.name,
          builder: (context, state) {
            return const ShareStoriesInGroupScreen();
          },
        ),
      ],
    ),
  ];
}
