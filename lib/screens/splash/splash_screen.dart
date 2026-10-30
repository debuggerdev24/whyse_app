import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/utils/shared_pref.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/services/home/story_api_service.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/text_style.dart';
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
        final response = await StoryApiService.instance.getAllStories();
        response.fold(
          (l) async {
            if (l.code == "401"
            // &&    l.errorMsg.toLowerCase().contains(AppConstants.unAuthorized)
            ) {
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
      // context.goNamed(AppRoutes.loginScreen.name);

      if (step != null) {
        authProvider.decideFirstScreen(context: context, step: step);
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

  static const Color _background = Color(0xFF17C2C7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Upper-left glow, matched to the splash screenshot. Its box
          // sits mostly off the left edge of the 402×874 design.
          const _SplashEllipse(left: -700, top: 80, width: 880, height: 520),
          // Ellipse 108: 749×699 at left 124, top 500.
          const _SplashEllipse(left: 124, top: 500, width: 749, height: 699),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppAssets.whyseWordmark,
                    width: 267.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Curiosity today. A brighter tomorrow.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.medium(
                      fontSize: 20,
                      color: const Color(0xFF000E41),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Oval glow. Coordinates are in the 402×874 design space.
class _SplashEllipse extends StatelessWidget {
  const _SplashEllipse({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  static const LinearGradient _glow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(81, 251, 255, 0.2),
      Color.fromRGBO(23, 194, 199, 0),
    ],
    stops: [0.0006, 0.6329],
  );

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left.w,
      top: top.h,
      width: width.w,
      height: height.h,
      child: const ClipOval(
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: _glow),
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}
