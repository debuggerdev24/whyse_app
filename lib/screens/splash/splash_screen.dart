import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/app_constants.dart';
import 'package:redstreakapp/core/constants/shared_pref.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/services/base_api_service.dart';
import 'package:redstreakapp/services/home/home_api_service.dart';

import '../../services/auth/auth_api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Go to next screen after delay
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      // context.pushNamed(AppRoutes.loginScreen.name);
      // return;
      final authProvider = context.read<AuthProvider>();

      final step = await authProvider.getOnBoardingProgress();
      Logger.info(step.toString());
      //todo logic to check the access token is expire or not
      final token = LocalStorageService.instance.getAuthToken;
      if (token != null && token.isNotEmpty) {
        final response = await HomeApiService.instance.getAllStories();
        response.fold(
          (l) async {
            if (l.code == "401" &&
                l.errorMsg.toLowerCase().contains(AppConstants.unAuthorized)) {
              final result = await AuthApiServices().refreshToken();

              result.fold(
                (l) async {
                  context.goNamed(AppRoutes.loginScreen.name);
                },
                (r) {
                  LocalStorageService.instance.saveAuthToken(
                    r["session"]["accessToken"],
                  );
                  LocalStorageService.instance.saveRefreshToken(
                    r["session"]["refreshToken"],
                  );
                  DioClient.instance.addToken(r["session"]["accessToken"]);
                  context.goNamed(AppRoutes.homeScreen.name);
                },
              );
            }
          },
          (r) {
            context.goNamed(AppRoutes.homeScreen.name);
          },
        );
        return;
      }
      if (!mounted) {
        return;
      }
      if (step != null) {
        authProvider.decideFirstScreen(context: context, step: step!);
        return;
      } else {
        context.goNamed(AppRoutes.loginScreen.name);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teal,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SvgIcon(AppAssets.splascreen, size: 120.w),
        ),
      ),
    );
  }
}
