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

// ─── Client update (whole day) ─────────────────────────────────────────────
// A flow was added so that when the user taps "Generate entire series again" they are taken to the Goals screen to start fresh and create a new series from there.
// A small menu (three dots) was added on the story screen so the user can choose to regenerate just the current story or the whole series again.
// The quit behaviour was updated so that the close icon and back button only show "Are you sure you want to quit?" with Quit and Cancel, and the quit popup was removed when the user chooses to regenerate the series.
// The flow was changed so that after the user taps Generate on the reading goal screen they are taken straight to the story screen and see a loading animation there until the story is ready.
// The story screen was simplified while loading and how the ideas line is shown (e.g. "Ideas · 3 stories · 20 mins" in one line).
// The random story screen was fixed so that pressing the back button shows only one "Are you sure you want to quit?" message instead of two.
// A blue message was added when a story is not ready yet and the user is taken back to the Search screen.
// A 1‑minute timeout was added on story generation and one automatic retry with a "Taking too long, retrying..." message.
// The progress bar above the topic was split into parts (one per story idea) and at 100% shows "તમે બધી story complete કરી નાખી છે".
// The "See Stories" button was made full width and spacing between elements was fixed across the app.
// ───────────────────────────────────────────────────────────────────────────

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