import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/routes/app_router.dart';
import 'package:redstreakapp/services/deep_link/deep_link_handler.dart';

class WhyseApp extends StatefulWidget {
  const WhyseApp({super.key});

  @override
  State<WhyseApp> createState() => _WhyseAppState();
}

class _WhyseAppState extends State<WhyseApp> {
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
}