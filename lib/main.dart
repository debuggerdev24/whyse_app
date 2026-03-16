import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/utils/shared_pref.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/quiz_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/providers/on_boarding/on_boarding_provider.dart';
import 'package:redstreakapp/whyse_app.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await LocalStorageService.instance.init();
  DioClient.instance.initialize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => OnBoardingProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: ToastificationWrapper(child: const WhyseApp()),
    ),
  );
}

/*
  WHOLE DAY UPDATE

  What was implemented:
  - Story share link (https://whyse.com/story?id=...) was added from My Story Ideas and from the active story in the series, and the share sheet now shares only the link.
  - The deep link handler was updated to handle the /story path and open the Created Story Reading screen, and a skip-leave-dialog flag was added so that opening a story link while a story is already open takes the user to the link’s story instead of showing the “quit and generate new” popup.
  - The leave-story flow was fixed so that when there is nothing to pop (e.g. after opening via deep link or goNamed), quit or back now navigates to Home instead of throwing “There is nothing to pop” on CreatedStoryReadingScreen, story series Quit, and random story Go back.
  - The quiz flow was fixed so that the last question’s Continue button uses pushReplacementNamed to the quiz completed screen and the story leave dialog no longer appears when finishing the quiz.
  - Choose Your Favorite Topics (story_topics_screen and above_16 topics_screen) now show the same topics as the home screen (HomeProvider), with the same 2-column grid and scroll-to-load-more pagination.
  - TopicCard was updated to show a shimmer placeholder while the topic image is loading (CachedNetworkImage with Shimmer for network URLs).

  - Search screen was redesigned with a Netflix-style layout: back button + search bar in a row at the top, section title (“Recommended for you” / “Results for …”), and a vertical list of result rows (thumbnail + title + play button) instead of a horizontal scroll; load-more is triggered by scrolling the main list. Search result and list shimmers were moved to search_section_shimmers.dart (SearchResultRowShimmer, SearchResultListShimmer), mirroring home_section_shimmers.
  - Topic progress (open story from browse/search) still calls HomeApiService.getTopicProgress from the search screen and handles the response there (no provider callback); only the search UI was changed.
  - Vertical spacing convention: use .w for vertical spacing (e.g. verticalSpace, SizedBox height, vertical padding) across browse and search screens and in search_section_shimmers.
  - Home screen was redesigned to a Netflix-style layout: HomeHeader with logo left, “Story Topics” center, search and profile right; StoryTopicsSection shows a featured first topic (FeaturedTopicCard) then “More Story Topics” in a Wrap grid with 3 items per row (no horizontal scroll), plus Load more and Add New Reading. FeaturedTopicCard matches the reference: black block with teal left/right borders, “FEATURED STORY” label, teal angled title, credits line, vertical 3:4 poster with shadow, learning-goal caption, and white outline/filled action buttons (My List, Play, Info). NetflixStyleTopicCard supports an optional width for the grid.
  - The vertically stacked interest/topic selection list (SelectionOption buttons) was removed from InterestsScreen (above_16) and StoryInterestsScreen; users can tap Next without selecting any interest, and unused interest state and handlers were cleaned up.

  */