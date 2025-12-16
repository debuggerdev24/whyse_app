import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/providers/auth_provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/routes/user_routes.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool acceptedTerms = false;
  bool isEmailSent = false;
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().clearCreateAccountFields();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 40.h),
        child: AppButton(
          text: isEmailSent ? "Verified" : "Next",
          backgroundColor: AppColors.yellowcolor,
          onPressed: () async {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            if (!isEmailSent) {
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
            } else {
              final success = await authProvider.createAccount(
                context,
                isTermsAccepted: acceptedTerms,
                isVerificationCheck: true,
              );

              if (success && context.mounted) {
                context.pushNamed(UserAppRoutes.profileInfoScreen.name);
              }
            }
          },
          isLoading: context.watch<AuthProvider>().isLoading,
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
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
                    color: AppColors.black.withOpacity(0.8),
                  ),
                ),
                26.h.verticalSpace,

                Column(
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
                      controller: authProvider.confirmPasswordController,
                      obSecureText: _isConfirmPasswordObscure,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isConfirmPasswordObscure =
                                  !_isConfirmPasswordObscure;
                            });
                          },
                          child: _isConfirmPasswordObscure
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

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => acceptedTerms = !acceptedTerms);
                      },
                      child: Container(
                        height: 24.w,
                        width: 24.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: AppColors.black.withOpacity(0.2),
                            width: 1.5,
                          ),
                          color: acceptedTerms
                              ? AppColors.yellowcolor
                              : Colors.transparent,
                        ),
                        child: acceptedTerms
                            ? Icon(Icons.check, size: 18.w, color: Colors.white)
                            : null,
                      ),
                    ),
                    8.w.horizontalSpace,
                    Expanded(
                      child: RichText(
                        textScaler: const TextScaler.linear(1),
                        text: TextSpan(
                          text: "I accept RedStreakApp’s ",
                          style: AppTextStyles.sfProDisplayMedium(
                            fontSize: 14.sp,
                            color: AppColors.lightblackColor.withOpacity(0.6),
                          ),
                          children: [
                            TextSpan(
                              text: "Terms of Service",
                              style: AppTextStyles.sfProDisplayBold(
                                fontSize: 14.sp,
                                decoration: TextDecoration.underline,
                                color: AppColors.black,
                              ),
                            ),
                            TextSpan(
                              text: " and ",
                              style: AppTextStyles.sfProDisplayMedium(
                                fontSize: 14.sp,
                                color: AppColors.lightblackColor.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                            TextSpan(
                              text: "Privacy Policy",
                              style: AppTextStyles.sfProDisplayBold(
                                fontSize: 14.sp,
                                decoration: TextDecoration.underline,
                                color: AppColors.black,
                              ),
                            ),
                            TextSpan(
                              text: ".",
                              style: AppTextStyles.sfProDisplayMedium(
                                fontSize: 14.sp,
                                color: AppColors.lightblackColor.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
