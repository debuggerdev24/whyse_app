import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/routes/app_router.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';
import 'package:redstreakapp/providers/home/curiosity_reading_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/quiz_provider.dart';
import 'package:redstreakapp/providers/home/saved_series_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/providers/on_boarding/on_boarding_provider.dart';
import 'package:redstreakapp/providers/profile/edit_profile_provider.dart';
import 'package:redstreakapp/providers/profile/group_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/providers/profile/your_books_provider.dart';

/// Clears in-memory user data from all [ChangeNotifier] providers so the next
/// login starts with a clean slate. Uses [context] if provided, otherwise
/// [AppRouter.rootNavigatorKey] (must be under [MultiProvider]).
void resetAppProvidersForNewUser([BuildContext? context]) {
  final ctx = context ?? AppRouter.rootNavigatorKey.currentContext;
  if (ctx == null) return;

  ctx.read<HomeProvider>().clearSessionData();
  ctx.read<StoryProvider>().clearSessionData();
  ctx.read<SavedSeriesProvider>().clearSessionData();
  ctx.read<ProfileProvider>().clearSessionData();
  ctx.read<GroupProvider>().clearSessionData();
  ctx.read<FriendProvider>().clearSessionData();
  ctx.read<QuizProvider>().clearSessionData();
  ctx.read<EditProfileProvider>().clearSessionData();
  ctx.read<YourBooksProvider>().clearSessionData();
  ctx.read<OnBoardingProvider>().clearSelections();
  ctx.read<CuriosityReadingProvider>().resetForNewSession();
}
