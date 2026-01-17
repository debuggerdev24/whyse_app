import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/app_constants.dart';
import 'package:redstreakapp/core/constants/shared_pref.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';

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
      final step = await authProvider.getOnBoardingProgress(
        // onFailed: (error) {
        //   AppToast.error(context, error);
        // },
      );

      if (!mounted) {
        return;
      }
      //todo fetch all the API in init phase of the app.

      if (step == "AGE") {
        // if (isAgeDone) {
        //   context.goNamed(UserAppRoutes.createAccountScreen.name);
        // } else {
        context.goNamed(AppRoutes.enterAgeScreen.name);
        // }
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
        if (LocalStorage.instance.authToken != null) {
          context.goNamed(AppRoutes.loginScreen.name);
        } else {
          context.goNamed(AppRoutes.homeScreen.name);
        }
      } else {
        // Check if user is already logged in
        final token = LocalStorage.instance.authToken;
        if (token != null && token.isNotEmpty) {
          context.goNamed(AppRoutes.homeScreen.name);
        } else {
          context.goNamed(AppRoutes.loginScreen.name);
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
