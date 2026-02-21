import 'package:flutter/material.dart';
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

============================
*/
