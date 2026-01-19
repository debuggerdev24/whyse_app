import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/app_constants.dart';
import 'package:redstreakapp/core/constants/shared_pref.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
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
      final authProvider = context.read<AuthProvider>();
      final step = await authProvider.getOnBoardingProgress();

      //todo logic to check the access token is expire or not
      final token = LocalStorageService.instance.authToken;
      if (token != null && token.isNotEmpty) {
        final response = await HomeApiService.instance.getAllStories();
        response.fold(
          (l) async {
            if (l.code == "401" &&
                l.errorMsg.toLowerCase().contains(AppConstants.unAuthorized)) {
              // AppToast.error(context, "Access token is expired");
              // AppToast.info(
              //   context: context,
              //   message:
              //       "Refresh token : ${LocalStorageService.instance.refreshToken}",
              // );

              final result = await AuthApiServices().refreshToken();

              result.fold(
                (l) async {
                  AppToast.error(
                    context,
                    "Refre. to API failed\n${l.errorMsg}",
                  );
                  // if (l.code.toString() == "401") {
                  //   AppToast.success(context, "Refresh token is expired");
                  //   await LocalStorageService.instance.removeRefreshToken();
                  //   await LocalStorageService.instance.removeAuthToken();
                  //   context.goNamed(AppRoutes.loginScreen.name);
                  //   return;
                  // }
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
      } else {
        context.goNamed(AppRoutes.loginScreen.name);
      }

      if (!mounted) {
        return;
      }

      //todo fetch all the API in init phase of the app.

      if (step == AppConstants.age) {
        context.goNamed(AppRoutes.enterAgeScreen.name);
      } else if (step == AppConstants.email) {
        context.goNamed(AppRoutes.enterAgeScreen.name);
      } else if (step == AppConstants.parentEmail) {
        context.goNamed(AppRoutes.parentEmailScreen.name);
      } else if (step == AppConstants.consentStatus) {
        context.goNamed(AppRoutes.consentStatusScreen.name);
      } else if (step == AppConstants.createAccount) {
        context.goNamed(AppRoutes.createAccountScreen.name);
      } else if (step == AppConstants.profileInfo) {
        context.goNamed(AppRoutes.profileInfoScreen.name);
      } else if (step == AppConstants.readingGoal) {
        context.goNamed(AppRoutes.readingGoalScreen.name);
      } else if (step == AppConstants.interest) {
        context.goNamed(AppRoutes.interestsScreen.name);
      } else if (step == AppConstants.topics) {
        context.goNamed(AppRoutes.topicsScreen.name);
      } else if (step == AppConstants.goals) {
        context.goNamed(AppRoutes.goalsScreen.name);
      } else if (step == AppConstants.completed) {
        if (LocalStorageService.instance.authToken == null) {
          context.goNamed(AppRoutes.loginScreen.name);
        } else {
          context.goNamed(AppRoutes.homeScreen.name);
        }
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
