import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/shared_pref.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/routes/app_router.dart';
import 'package:redstreakapp/services/base_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.instance.init();
  await DioClient.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(402, 874),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return const DeepLinkWrapper(); // ✅ NEW
        },
      ),
    );
  }
}




import 'package:app_links/app_links.dart';

class DeepLinkWrapper extends StatefulWidget {
  const DeepLinkWrapper({super.key});

  @override
  State<DeepLinkWrapper> createState() => _DeepLinkWrapperState();
}

class _DeepLinkWrapperState extends State<DeepLinkWrapper> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    _appLinks = AppLinks();

    // Case 1: App already open, user taps email link
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    });

    // Case 2: App was CLOSED and opened via link
    final Uri? initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      //
      _handleDeepLink(initialLink);
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint("🔗 Opened Link: $uri");

    String? token;

    // --- CASE A: token is in ?access_token= ---
    if (uri.queryParameters.containsKey("access_token")) {
      token = uri.queryParameters["access_token"];
    }

    // --- CASE B: token is in #access_token= (your current case) ---
    else if (uri.fragment.contains("access_token=")) {
      token = uri.fragment
          .split("access_token=")[1]
          .split("&")[0];
    }

    if (token != null) {
      debugPrint("✅ Extracted Token: $token");

      // Send token to AuthProvider
      final auth = context.read<AuthProvider>();
      auth.setRecoveryToken(token);

      // Navigate to Verify Screen (optional)
      UserAppRoute.goRouter.go('/verify-email');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: UserAppRoute.goRouter,
    );
  }
}


/*
todo update


*/

//forgot success but not sending link
//parent save email is also same
