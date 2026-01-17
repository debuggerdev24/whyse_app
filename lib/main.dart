import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/shared_pref.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/routes/app_router.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/services/base_api_service.dart';

import 'core/constants/app_constants.dart';
import 'core/helper/log_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.instance.init();
  await DioClient.instance.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;
  final AppLinks _appLinks = AppLinks();
  late AuthProvider provider;
  bool _isProcessingLink = false; // Prevent duplicate processing

  @override
  void initState() {
    super.initState();
    // Delay to ensure router is ready
    provider = context.read<AuthProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _handleInitialLink();
      _handleIncomingLinks();
    });
  }

  // Future<void> _handleInitialLink() async {
  //   try {
  //     final initialLink = await _appLinks.getInitialLinkString();
  //     if (initialLink != null && !_isProcessingLink) {
  //       Logger.info("Initial Link: $initialLink");
  //       _handleDeepLink(Uri.parse(initialLink));
  //     }
  //   } catch (e) {
  //     Logger.error("Failed to get initial app link: $e");
  //   }
  // }

  void _handleIncomingLinks() {
    Logger.info("Deep Linking initialize");

    _sub = _appLinks.stringLinkStream.listen(
      (String? link) {
        if (link != null && !_isProcessingLink) {
          final uri = Uri.parse(link);
          Logger.info("Incoming Link: $link");
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        Logger.error("Error in incoming app link: $err");
      },
    );
    Logger.info("Deep Linking Success");
  }

  void _handleDeepLink(Uri uri) {
    if (_isProcessingLink) {
      Logger.info("Already processing a link, skipping...");
      return;
    }

    _isProcessingLink = true;

    try {
      Logger.info("URI -> $uri");
      Logger.info("scheme -> ${uri.scheme}");
      Logger.info("host -> ${uri.host}");
      Logger.info("path -> ${uri.path}");

      // Password Reset Link
      if (uri.host == AppConstants.domain &&
          uri.path == AppConstants.forgotPasswordPath) {
        Logger.info("Navigation triggered from verify-reset-password link");
        final token = uri.queryParameters["token"];

        if (token != null && token.isNotEmpty) {
          context.read<AuthProvider>().setResetPasswordToken = token;
          Logger.info("Reset Password Token: $token");

          // Navigate after a short delay
          Future.delayed(const Duration(milliseconds: 350), () {
            context.pushNamed(AppRoutes.forgotPasswordScreen.name);
            _isProcessingLink = false;
          });
        } else {
          Logger.error("No token found in password reset link");
          _isProcessingLink = false;
        }
        return;
      }

      //todo ------------------ Parent Consent Link -------------------
      if (uri.host == AppConstants.domain &&
          uri.path == AppConstants.parentEmailPath) {
        Logger.info("Navigation triggered from verify-parent-consent link");
        final token = uri.queryParameters["token"];

        if (token != null && token.isNotEmpty) {
          context.read<AuthProvider>().setParentEmailToken = token;
          Logger.info("Parent Consent Token: $token");

          //todo Navigate after a short delay
          // Future.delayed(const Duration(milliseconds: 100), () {
          // context.pushNamed(AppRoutes.consentStatusScreen.name);
          provider.verifyConsentRequest(
            onSuccess: () {
              UserAppRoute.goRouter.goNamed(
                AppRoutes.createAccountScreen.name,
                extra: true,
              );
              // AppToast.success(
              //   context,
              //   "Parent consent verify successfully.Create account.",
              // );
              // context.pushNamed(
              //   AppRoutes.createAccountScreen.name,
              //   extra: true,
              // );
            },
            onFailed: (e) {
              AppToast.error(context, e.errorMsg);
            },
          );
          _isProcessingLink = false;
          // });
        } else {
          Logger.error("No token found in parent consent link");
          _isProcessingLink = false;
        }
        return;
      }

      Logger.info("No matching route found for URI: $uri");
      _isProcessingLink = false;
    } catch (e, st) {
      Logger.error("Deep link error -> $e\nStackTrace -> $st");
      _isProcessingLink = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
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
}

/*

*/
