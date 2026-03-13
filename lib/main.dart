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

-> Fixed quit confirmation on system back so the leave dialog shows once using GoRoute onExit.
-> Updated the generating-story leave flow with “Quit and generate new one?” and Yes to regenerate or Cancel to continue.
-> Updated the random/topic-progress leave flow with “Are you sure you want to quit?” and Quit/Cancel options.
-> Removed the duplicate close (X) button on the random story series screen so only one close icon shows.
-> Hid the Ideas chip, label, and list when there is only one idea; shown when there are two or more.
-> Fixed story switching so scrolling resets to the top and the current story is visible when switching back.
https://whyse.com/story?id=5c8cee08-a658-44e5-9ef7-d87494991097
*/