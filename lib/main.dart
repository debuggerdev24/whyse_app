import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/shared_pref.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/home/quiz_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/providers/on_boarding/on_boarding_provider.dart';
import 'package:redstreakapp/routes/app_router.dart';
import 'package:redstreakapp/services/base_api_service.dart';
import 'package:redstreakapp/services/deep_link/deep_link_handler.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.instance.init();
  await DioClient.instance.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => OnBoardingProvider()),
      ],
      child: ToastificationWrapper(child: const MyApp()),
    ),
  );
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthProvider provider;
  late DeepLinkHandler _deepLinkHandler;

  @override
  void initState() {
    super.initState();
    provider = context.read<AuthProvider>();
    _deepLinkHandler = DeepLinkHandler();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkHandler.init(context: context, authProvider: provider);
    });
  }

  @override
  void dispose() {
    _deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(402, 874),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: UserAppRoute.goRouter,
        );
      },
    );
  }
  // void _handleIncomingLinks() {
  //   Logger.info("Deep Linking initialize");
  //
  //   _sub = _appLinks.stringLinkStream.listen(
  //         (String? link) {
  //       if (link != null && !_isProcessingLink) {
  //         final uri = Uri.parse(link);
  //         Logger.info("Incoming Link: $link");
  //         _handleDeepLink(uri);
  //       }
  //     },
  //     onError: (err) {
  //       Logger.error("Error in incoming app link: $err");
  //     },
  //   );
  //   Logger.info("Deep Linking Success");
  // }

  // void _handleDeepLink(Uri uri) {
  //   if (_isProcessingLink) {
  //     Logger.info("Already processing a link, skipping...");
  //     return;
  //   }
  //
  //   _isProcessingLink = true;
  //
  //   try {
  //     Logger.info("URI -> $uri\nscheme -> ${uri.scheme}\nhost -> ${uri.host}\npath -> ${uri.path}");
  //
  //
  //
  //
  //     //todo Password Reset Link
  //     if (uri.host == AppConstants.domain &&
  //         uri.path == AppConstants.forgotPasswordPath) {
  //       Logger.info("Navigation triggered from verify-reset-password link");
  //       final token = uri.queryParameters["token"];
  //
  //       if (token != null && token.isNotEmpty) {
  //         provider.setResetPasswordToken = token;
  //         Logger.info("Reset Password Token: $token");
  //
  //         context.pushNamed(AppRoutes.forgotPasswordScreen.name);
  //       } else {
  //         Logger.error("No token found in password reset link");
  //       }
  //       _isProcessingLink = false;
  //       return;
  //     }
  //
  //     //todo ------------------ Parent Consent Link -------------------
  //     if (uri.host == AppConstants.domain &&
  //         uri.path == AppConstants.parentConsentPath) {
  //       Logger.info("Navigation triggered from verify-parent-consent link");
  //       final token = uri.queryParameters["token"];
  //
  //       if (token != null && token.isNotEmpty) {
  //         provider.setParentEmailToken = token;
  //         Logger.info("Parent Consent Token: $token");
  //
  //         //todo Navigate after a short delay
  //         provider.verifyConsentRequest(
  //           onSuccess: () {
  //             UserAppRoute.goRouter.goNamed(
  //               AppRoutes.createAccountScreen.name,
  //               extra: true,
  //             );
  //           },
  //           onFailed: (e) {
  //             AppToast.error(context, e.errorMsg);
  //           },
  //         );
  //         _isProcessingLink = false;
  //       } else {
  //         Logger.error("No token found in parent consent link");
  //         _isProcessingLink = false;
  //       }
  //       return;
  //     }
  //
  //     Logger.info("No matching route found for URI: $uri");
  //     _isProcessingLink = false;
  //   } catch (e, st) {
  //     Logger.error("Deep link error -> $e\nStackTrace -> $st");
  //     _isProcessingLink = false;
  //   }
  // }
}

/*
I am unable to
*/
