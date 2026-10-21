import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppAssets.celebratoryFlag,
                        width: 240,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 28),
                      AppText(
                        text: "You're all set!",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bold(
                          fontSize: 28,
                          color: const Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 10),
                      AppText(
                        textAlign: TextAlign.center,
                        text:
                            "Your reading journey starts today — let's build your first streak!",
                        style: AppTextStyles.regular(
                          fontSize: 16,
                          color: const Color(0xFF1C1C1E),
                        ).copyWith(height: 1.35),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed(AppRoutes.subscriptionScreen.name);
                },
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: AppText(
                    text: 'Choose a Plan',
                    style: AppTextStyles.semibold(
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
