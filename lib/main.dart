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
      providers: [
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
todo update

============================
-> Implemented on-demand story generation, allowing users to load new stories from the "See Next Story" button or the Ideas list Play button.
-> Built layout-matching shimmer loaders to provide a smooth Netflix-style loading experience.
-> Fixed a sequential navigation bug on the Quiz screen to ensure stories load in the correct order.
-> Redesigned the "Today's Reading" card on the Home screen and expanded the description area.
-> Improved API model handling to prevent infinite loading when backend data is missing.
-> Fixed state issues so stories always open on the first page and properly parse bold text.
-> Improved the story reading flow with better loading states, fresh story regeneration, and cleaner navigation.
-> Added controlled reading controls with Start, Stop, Resume, and proper timer reset for each new story.
-> Refined the story and home UI to better match the design and handle content loading more smoothly.

Note: I would like to inform you that I have designed the Netflix-style story UI and am currently working on the browse section. I will provide you with the updated release as soon as possible, or within the next couple of days after proper testing.
============================

*/