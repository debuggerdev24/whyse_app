import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';

import '../../core/widgets/custom_toast.dart';

class CreateAccountScreen extends StatefulWidget {
  final bool? isFromSuccessConsent;
  const CreateAccountScreen({super.key, this.isFromSuccessConsent});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool acceptedTerms = false;
  bool isEmailSent = false;
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  @override
  void initState() {
    Logger.info("CReate Account status${widget.isFromSuccessConsent}");
    if (widget.isFromSuccessConsent ?? false) {
      AppToast.success(
        context,
        "Parent consent verify successfully.Create account.",
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundColor,
      body: Consumer<AuthProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            bottom: false,

            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 25.h,
                  ),
                  // physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "Create Account",
                        style: AppTextStyles.sfProDisplayBold(fontSize: 32.sp),
                      ),
                      5.h.verticalSpace,
                      AppText(
                        text: "Enter your details to start learning.",
                        style: AppTextStyles.sfProDisplayMedium(
                          fontSize: 16.sp,
                          color: AppColors.black.withValues(alpha: 0.8),
                        ),
                      ),
                      26.h.verticalSpace,

                      signUpForm(authProvider),

                      22.h.verticalSpace,
                      //todo agree to policy check box
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() => acceptedTerms = !acceptedTerms);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 24.w,
                              width: 24.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: AppColors.black.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                                color: acceptedTerms
                                    ? AppColors.yellowColor
                                    : Colors.transparent,
                              ),
                              child: acceptedTerms
                                  ? Icon(
                                      Icons.check,
                                      size: 18.w,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),

                            8.w.horizontalSpace,
                            Expanded(
                              child: RichText(
                                textScaler: const TextScaler.linear(1),
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "I accept RedStreakApp’s ",
                                      style: AppTextStyles.sfProDisplayMedium(
                                        height: 1.25,

                                        fontSize: 14.sp,
                                        color: AppColors.lightblackColor
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Terms of Service",
                                      style: AppTextStyles.sfProDisplayBold(
                                        height: 1.2,
                                        fontSize: 14.sp,
                                        decoration: TextDecoration.underline,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " and ",
                                      style: AppTextStyles.sfProDisplayMedium(
                                        height: 1.2,

                                        fontSize: 14.sp,
                                        color: AppColors.lightblackColor
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Privacy Policy",
                                      style: AppTextStyles.sfProDisplayBold(
                                        fontSize: 14.sp,
                                        height: 1.2,

                                        decoration: TextDecoration.underline,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ".",
                                      style: AppTextStyles.sfProDisplayMedium(
                                        fontSize: 14.sp,
                                        height: 1.2,

                                        color: AppColors.lightblackColor
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: AppFilledButton(
                          text: isEmailSent ? "Verify" : "Next",
                          backgroundColor: AppColors.yellowColor,
                          onTap: () async {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            if (isEmailSent) {
                              final success = await authProvider.verifyEmail(
                                context,
                              );

                              if (success && context.mounted) {
                                context.pushNamed(
                                  AppRoutes.profileInfoScreen.name,
                                );
                              }
                            } else {
                              final success = await authProvider.createAccount(
                                context,
                                isTermsAccepted: acceptedTerms,
                              );
                              if (success && context.mounted) {
                                setState(() {
                                  isEmailSent = true;
                                });
                                // CustomToast.showToastMessage(
                                //   context,
                                //   "Please verify your email to continue",
                                //   true,
                                // );
                              }
                            }
                          },
                          isLoading: context.watch<AuthProvider>().isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
                if (provider.isCreateAccountLoading ||
                    provider.isVerifyEmailLoading)
                  FullPageIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }

  Column signUpForm(AuthProvider authProvider) {
    return Column(
      spacing: 8.h,
      children: [
        AppTextField(
          hintText: "First Name",
          controller: authProvider.firstNameController,
        ),
        AppTextField(
          hintText: "Last Name",
          controller: authProvider.lastNameController,
        ),
        AppTextField(
          hintText: "Email",
          controller: authProvider.signupEmailController,
        ),
        AppTextField(
          hintText: "Password",
          obSecureText: _isPasswordObscure,
          controller: authProvider.passwordController,
          suffixIcon: Padding(
            padding: const EdgeInsets.all(13.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isPasswordObscure = !_isPasswordObscure;
                });
              },
              child: _isPasswordObscure
                  ? SvgIcon(
                      AppAssets.password,
                      size: 24.w,
                      color: AppColors.black,
                    )
                  : SvgIcon(AppAssets.eye, size: 24.w, color: AppColors.black),
            ),
          ),
        ),
        AppTextField(
          hintText: "Confirm Password",
          controller: authProvider.confirmPasswordController,
          obSecureText: _isConfirmPasswordObscure,
          suffixIcon: Padding(
            padding: const EdgeInsets.all(13.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
                });
              },
              child: _isConfirmPasswordObscure
                  ? SvgIcon(
                      AppAssets.password,
                      size: 24.w,
                      color: AppColors.black,
                    )
                  : SvgIcon(AppAssets.eye, size: 24.w, color: AppColors.black),
            ),
          ),
        ),
      ],
    );
  }
}
