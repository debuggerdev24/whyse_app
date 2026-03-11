import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/auth/session_expiry_notifier.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/routes/app_router.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/services/deep_link/deep_link_handler.dart';

class WhyseApp extends StatefulWidget {
  const WhyseApp({super.key});

  @override
  State<WhyseApp> createState() => _WhyseAppState();
}

class _WhyseAppState extends State<WhyseApp> {
  late AuthProvider provider;
  late DeepLinkHandler _deepLinkHandler;
  late VoidCallback _sessionExpiryListener;

  @override
  void initState() {
    super.initState();
    provider = context.read<AuthProvider>();
    _deepLinkHandler = DeepLinkHandler();
    _sessionExpiryListener = _handleSessionExpired;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkHandler.init(context: context, authProvider: provider);
    });
    SessionExpiryNotifier.instance.eventCounter.addListener(_sessionExpiryListener);
  }

  @override
  void dispose() {
    SessionExpiryNotifier.instance.eventCounter.removeListener(
      _sessionExpiryListener,
    );
    _deepLinkHandler.dispose();
    super.dispose();
  }

  void _handleSessionExpired() {
    if (!mounted) return;

    context.read<AuthProvider>().clearAllData();
    context.read<HomeProvider>().clearSessionData();
    context.read<StoryProvider>().clearSessionData();

    final rootContext = AppRouter.rootNavigatorKey.currentContext ?? context;
    AppToast.error(rootContext, "Session expired. Please log in again", 3);
    AppRouter.goRouter.goNamed(AppRoutes.loginScreen.name);
    SessionExpiryNotifier.instance.reset();
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
          routerConfig: AppRouter.goRouter,
        );
      },
    );
  }
}