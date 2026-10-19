import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/utils/shared_pref.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/widgets/plan_card.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';

class SubScriptionScreen extends StatefulWidget {
  const SubScriptionScreen({super.key});

  @override
  State<SubScriptionScreen> createState() => _SubScriptionScreenState();
}

class _SubScriptionScreenState extends State<SubScriptionScreen> {
  String selectedPlan = "Free";

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Consumer<AuthProvider>(
        builder: (context, provider, child) => Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: Image.asset(
                    AppAssets.dreamyCloudscape,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                  ),
                ),
                const Expanded(child: ColoredBox(color: Color(0xFFF5F5F7))),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, top + 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: Color(0xFF1C1C1E),
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      AppText(
                        text: 'Choose your Plan',
                        style: AppTextStyles.bold(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        text:
                            'Pick a plan that fits your reading goals\nand start learning your way.',
                        style: AppTextStyles.regular(
                          fontSize: 15,
                          color: Colors.white,
                        ).copyWith(height: 1.35),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                    children: [
                      PlanCard(
                        title: "Free Plan (with ads)",
                        price: "\$0/mo",
                        features: ["Ad Supported", "Limited AI learning"],
                        isSelected: selectedPlan == "Free",
                        onTap: () => setState(() => selectedPlan = "Free"),
                      ),
                      const SizedBox(height: 12),
                      PlanCard(
                        title: "Premium Plan (no ads)",
                        price: "\$12.99/mo",
                        features: [
                          "Ad Free",
                          "Full AI",
                          "Progress Reports",
                        ],
                        isSelected: selectedPlan == "Premium",
                        onTap: () => setState(() => selectedPlan = "Premium"),
                      ),
                      const SizedBox(height: 12),
                      PlanCard(
                        title: "Family Plan",
                        price: "\$24.99/mo",
                        features: [
                          "Everything in the Premium Plan",
                          "Upto 5 Profiles",
                          "One Subscription",
                        ],
                        isSelected: selectedPlan == "Family",
                        onTap: () => setState(() => selectedPlan = "Family"),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    MediaQuery.paddingOf(context).bottom + 12,
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      if (context.mounted) {
                        final googleIdToken =
                            LocalStorageService.instance.getGoogleIdToken;
                        final resgisteredUserMail =
                            LocalStorageService.instance.getRegisteredUserMail;
                        if (googleIdToken.isNotEmpty) {
                          await provider.loginWithStoredGoogleToken(
                            context: context,
                            onFailed: (error) {
                              AppToast.error(context, error);
                            },
                            onAccountFound: () {
                              if (!context.mounted) return;
                              AppToast.success(context, "Login Successfully.");
                              provider.navigateToHomeScreen(context);
                            },
                          );
                          return;
                        }
                        if (resgisteredUserMail.isNotEmpty) {
                          provider.loginEmailCtr.text = LocalStorageService
                              .instance
                              .getRegisteredUserMail;
                          provider.loginPasswordCtr.text = LocalStorageService
                              .instance
                              .getRegisteredUserPassword;
                          provider.loginWithMail(context: context);
                          return;
                        }
                      }
                    },
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: AppText(
                        text: 'Subscribe',
                        style: AppTextStyles.semibold(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (provider.isSocialLoginLoading || provider.isLoginLoading)
              const FullPageIndicator(),
          ],
        ),
      ),
    );
  }
}
