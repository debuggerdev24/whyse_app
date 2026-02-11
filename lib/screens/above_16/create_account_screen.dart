import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/app_constants.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';

import '../../core/widgets/custom_toast.dart';

class CreateAccountScreen extends StatefulWidget {
  final String? consentStatus;
  const CreateAccountScreen({super.key, this.consentStatus});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Logger.info(
        "Consent for create account status: ${widget.consentStatus ?? "null"}",
      );
      if (widget.consentStatus == AppConstants.trueSt) {
        AppToast.success(
          context,
          "Parent consent verify successfully. \nCreate your account.",
        );
        return;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      resizeToAvoidBottomInset: false,
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
                      //todo
                      Column(
                        spacing: 8.h,
                        children: [
                          AppTextField(
                            hintText: "First Name",
                            controller: provider.firstNameCtr,
                          ),
                          AppTextField(
                            hintText: "Last Name",
                            controller: provider.lastNameCtr,
                          ),
                          AppTextField(
                            hintText: "Email",
                            controller: provider.createAccEmailCtr,
                          ),
                          AppTextField(
                            hintText: "Password",
                            obSecureText: provider.isPasswordObscure,
                            controller: provider.createAccPasswordCtr,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: GestureDetector(
                                onTap: () {
                                  provider.togglePasswordVisibility();
                                },
                                child: provider.isPasswordObscure
                                    ? SvgIcon(
                                        AppAssets.password,
                                        size: 24.w,
                                        color: AppColors.black,
                                      )
                                    : SvgIcon(
                                        AppAssets.eye,
                                        size: 24.w,
                                        color: AppColors.black,
                                      ),
                              ),
                            ),
                          ),
                          AppTextField(
                            hintText: "Confirm Password",
                            controller: provider.confirmPasswordCtr,
                            obSecureText: provider.isConfirmPasswordObscure,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: GestureDetector(
                                onTap: () {
                                  provider.toggleConfirmPasswordVisibility();
                                },
                                child: provider.isConfirmPasswordObscure
                                    ? SvgIcon(
                                        AppAssets.password,
                                        size: 24.w,
                                        color: AppColors.black,
                                      )
                                    : SvgIcon(
                                        AppAssets.eye,
                                        size: 24.w,
                                        color: AppColors.black,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      22.h.verticalSpace,
                      //todo agree to policy check box
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          provider.toggleAcceptedTerms();
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
                                color: provider.acceptedTerms
                                    ? AppColors.primaryColor
                                    : Colors.transparent,
                              ),
                              child: provider.acceptedTerms
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
                                      text: "I accept WhyseApp’s ",
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
                          text: "Next", //provider.isEmailSent ? "Verify" :
                          backgroundColor: AppColors.primaryColor,
                          // onTap: () async {
                          //   if (provider.isEmailSent) {
                          //     final success = await provider.verifyEmail(
                          //       context,
                          //     );
                          //
                          //     if (success && context.mounted) {
                          //       context.pushNamed(
                          //         AppRoutes.profileInfoScreen.name,
                          //       );
                          //     }
                          //   } else {
                          //     final success = await provider.createAccount(
                          //       context,
                          //       isTermsAccepted: provider.acceptedTerms,
                          //     );
                          //     if (success && context.mounted) {
                          //       provider.isEmailSent = true;
                          //
                          //       // CustomToast.showToastMessage(
                          //       //   context,
                          //       //   "Please verify your email to continue",
                          //       //   true,
                          //       // );
                          //     }
                          //   }
                          // },
                          onTap: () => provider.createAccount(
                            isTermsAccepted: provider.acceptedTerms,
                            context: context,
                            onSuccess: () {
                              AppToast.success(
                                context,
                                "Account created successfully, please verify your mail.",
                              );
                            },
                          ),
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

  Widget signUpForm(AuthProvider provider) {
    return Column(
      spacing: 8.h,
      children: [
        AppTextField(hintText: "First Name", controller: provider.firstNameCtr),
        AppTextField(hintText: "Last Name", controller: provider.lastNameCtr),
        AppTextField(hintText: "Email", controller: provider.createAccEmailCtr),
        AppTextField(
          hintText: "Password",
          obSecureText: provider.isPasswordObscure,
          controller: provider.createAccPasswordCtr,
          suffixIcon: Padding(
            padding: const EdgeInsets.all(13.0),
            child: GestureDetector(
              onTap: () {
                provider.togglePasswordVisibility();
              },
              child: provider.isPasswordObscure
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
          controller: provider.confirmPasswordCtr,
          obSecureText: provider.isConfirmPasswordObscure,
          suffixIcon: Padding(
            padding: const EdgeInsets.all(13.0),
            child: GestureDetector(
              onTap: () {
                provider.toggleConfirmPasswordVisibility();
              },
              child: provider.isConfirmPasswordObscure
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
