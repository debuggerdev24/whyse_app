import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/utils/de_bouncing.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';

import '../../core/widgets/custom_toast.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().clearSignupFields();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    // height:
                    //     MediaQuery.of(context).size.height -
                    //     MediaQuery.of(context).padding.top,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 30.h,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        88.h.verticalSpace,

                        Column(
                          children: [
                            SvgIcon(AppAssets.welcome),
                            30.h.verticalSpace,
                  
                            AppText(
                              text: 'Welcome to',
                              style: AppTextStyles.sfProDisplayBold(
                                fontSize: 32.sp,
                                color: AppColors.teal,
                              ),
                            ),
                            AppText(
                              text: 'ReadStreakApp',
                              style: AppTextStyles.sfProDisplayBold(
                                fontSize: 32.sp,
                                color: AppColors.teal,
                              ),
                            ),
                  
                            15.h.verticalSpace,
                            AppText(
                              text: 'Read. Learn. Grow.',
                              style: AppTextStyles.textStyle16Semibold,
                            ),
                  
                            61.h.verticalSpace,
                  
                            AppTextField(
                              hintText: "Email",
                              controller: provider.signUpEmailCtr,
                            ),
                  
                            32.h.verticalSpace,
                  
                            AppFilledButton(
                              onTap: () async {
                                deBouncer.run(() async {
                                  await provider.startOnboarding(
                                    context: context,
                                    onSuccess: () {
                                      AppToast.success(
                                        context,
                                        "Onboarding session started",
                                      );
                                      context.pushNamed(
                                        AppRoutes.enterAgeScreen.name,
                                      );
                                    },
                  
                                    onFailed: (error) {
                                      AppToast.error(context, error);
                                    },
                                  );
                                });
                              },
                              text: "Sign up with Email",
                            ),
                  
                            17.h.verticalSpace,
                  
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppText(
                                  text: "Already have an account? ",
                                  style: AppTextStyles.textStyle14Regular,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.pushNamed(
                                      AppRoutes.loginScreen.name,
                                    );
                                  },
                                  child: AppText(
                                    text: "Login",
                                    style: AppTextStyles.textStyle14Bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        32.h.verticalSpace,
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.black.withValues(alpha: 0.2),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: AppText(
                                text: "OR",
                                style: AppTextStyles.textStyle14Semibold,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.black.withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),
                  
                        32.h.verticalSpace,
                  
                        _socialButton(
                          label: "Sign up with Google",
                          icon: AppAssets.google,
                          onTap: () {
                            provider.socialLogin(
                              onSuccess: () async {
                                await provider.startOnboarding(
                                  context: context,
                                  onSuccess: () {
                                    AppToast.success(
                                      context,
                                      "Sign Up Successfully and Onboarding session started",
                                    );
                                    context.pushNamed(
                                      AppRoutes.enterAgeScreen.name,
                                    );
                                  },
                  
                                  onFailed: (error) {
                                    AppToast.error(context, error);
                                  },
                                );
                                // context.goNamed(AppRoutes.enterAgeScreen.name);
                              },
                  
                              onFailed: (error) {
                                AppToast.error(
                                  context,
                                  "Failed google login,\nPlease try again",
                                );
                              },
                            );
                          },
                        ),
                  
                        12.h.verticalSpace,
                  
                        _socialButton(
                          label: "Sign up with Apple",
                          icon: AppAssets.apple,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                if (provider.isStartOnBoardingLoading ||
                    provider.isSocialLoginLoading)
                  FullPageIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }

  /// ---------------- SOCIAL BUTTON ----------------
  Widget _socialButton({
    required String label,
    required String icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lightwhiteColor,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(40.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 24.w),
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// Left icon
              Align(
                alignment: Alignment.centerLeft,
                child: SvgIcon(icon, size: 22.sp),
              ),

              /// Center text
              AppText(text: label, style: AppTextStyles.textStyle14Bold),
            ],
          ),
        ),
      ),
    );
  }
}
