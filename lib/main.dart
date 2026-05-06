import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/utils/shared_pref.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/profile/edit_profile_provider.dart';
import 'package:redstreakapp/providers/profile/group_provider.dart';
import 'package:redstreakapp/providers/home/curiosity_reading_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/saved_series_provider.dart';
import 'package:redstreakapp/providers/home/quiz_provider.dart';
import 'package:redstreakapp/providers/home/reading_appearance_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/providers/on_boarding/on_boarding_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';
import 'package:redstreakapp/providers/profile/your_books_provider.dart';
import 'package:redstreakapp/services/profile/group_api_service.dart';
import 'package:redstreakapp/services/profile/profile_service.dart';
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
        ChangeNotifierProvider(create: (_) => ReadingAppearanceProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => OnBoardingProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SavedSeriesProvider()),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            ProfileService(BaseApiHelper.instance),
            GroupApiService(BaseApiHelper.instance),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => GroupProvider(GroupApiService(BaseApiHelper.instance)),
        ),
        ChangeNotifierProvider(create: (_) => CuriosityReadingProvider()),
        ChangeNotifierProvider(create: (_) => YourBooksProvider()),
        ChangeNotifierProvider(create: (_) => FriendProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              EditProfileProvider(ProfileService(BaseApiHelper.instance)),
        ),
      ],
      child: ToastificationWrapper(child: const WhyseApp()),
    ),
  );
}