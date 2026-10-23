import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/utils/de_bouncing.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/screens/auth/widgets/auth_chrome.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';

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
    return Scaffold(
      backgroundColor: AuthChrome.background,
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
                    padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthChrome.backButton(context),
                        12.h.verticalSpace,
                        Center(child: AuthChrome.logo(width: 150.w)),
                        22.h.verticalSpace,
                        AuthChrome.titleText('Welcome to Whyse'),
                        8.h.verticalSpace,
                        AuthChrome.subtitleText('Read. Learn. Grow.'),
                        32.h.verticalSpace,
                        AuthChrome.fieldLabel('Email ID'),
                        8.h.verticalSpace,
                        AuthChrome.textField(
                          hintText: 'Enter email id',
                          controller: provider.signUpEmailCtr,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        22.h.verticalSpace,
                        AuthChrome.primaryButton(
                          text: 'Sign up with Email',
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
                        ),
                        16.h.verticalSpace,
                        AuthChrome.footerLink(
                          prefix: 'Already have an account? ',
                          action: 'Login',
                          onTap: () {
                            if (Navigator.of(context).canPop()) {
                              context.pop();
                              return;
                            }
                            context.goNamed(AppRoutes.loginScreen.name);
                          },
                        ),
                        // 32.w.verticalSpace,
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: Divider(
                        //         color: AppColors.black.withValues(alpha: 0.2),
                        //       ),
                        //     ),
                        //     Padding(
                        //       padding: EdgeInsets.symmetric(horizontal: 12.w),
                        //       child: AppText(
                        //         text: "OR",
                        //         style: AppTextStyles.textStyle14Semibold,
                        //       ),
                        //     ),
                        //     Expanded(
                        //       child: Divider(
                        //         color: AppColors.black.withValues(alpha: 0.2),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        //
                        // 32.w.verticalSpace,
                        //
                        // _socialButton(
                        //   label: "Sign up with Google",
                        //   icon: AppAssets.google,
                        //   onTap: () async {
                        //     // Prevent multiple taps
                        //     if (provider.isSocialLoginLoading) return;
                        //     try {
                        //       final String? idToken = await provider
                        //           .getGoogleIDToken();
                        //
                        //       // Check if sign-in was cancelled or failed
                        //       if (idToken == null) {
                        //         if (context.mounted) {
                        //           AppToast.info(
                        //             context: context,
                        //             message: "Google Sign-In cancelled",
                        //           );
                        //         }
                        //         return;
                        //       }
                        //
                        //       if (!context.mounted) return;
                        //
                        //       await provider.googleSignUp(
                        //         idToken: idToken,
                        //         onSuccess: () async {
                        //           if (!context.mounted) return;
                        //           await provider.saveAge(
                        //             context: context,
                        //             onSuccess: () async {
                        //               if (!context.mounted) return;
                        //               if (provider.isUnder16) {
                        //                 provider.setIsUnder16FromGoogle(
                        //                   value: true,
                        //                 );
                        //                 context.pushNamed(
                        //                   AppRoutes.parentEmailScreen.name,
                        //                 );
                        //                 return;
                        //               }
                        //               provider.setIsUnder16FromGoogle(
                        //                 value: false,
                        //               );
                        //
                        //               provider.toggleAcceptedTerms(value: true);
                        //               final success = await provider
                        //                   .createAccount(
                        //                     isTermsAccepted:
                        //                         provider.acceptedTerms,
                        //                     context: context,
                        //                   );
                        //               if (success && context.mounted) {
                        //                 context.pushNamed(
                        //                   AppRoutes.profileInfoScreen.name,
                        //                 );
                        //                 AppToast.success(
                        //                   context,
                        //                   "Please complete your on-boarding session",
                        //                 );
                        //               }
                        //             },
                        //             onFailed: (error) {
                        //               if (!context.mounted) return;
                        //               AppToast.error(context, error);
                        //             },
                        //           );
                        //           // await provider.startOnboarding(
                        //           //   context: context,
                        //           //   onSuccess: () async {
                        //           //     if (!context.mounted) return;
                        //           //    await provider.saveAge(
                        //           //                                         context: context,
                        //           //                                         onSuccess: () async {
                        //           //                                           if (!context.mounted) return;
                        //           //                                           if (provider.isUnder16) {
                        //           //                                             context.pushNamed(
                        //           //                                               AppRoutes.parentEmailScreen.name,
                        //           //                                             );
                        //           //                                             return;
                        //           //                                           }
                        //           //
                        //           //                                           provider.toggleAcceptedTerms(
                        //           //                                             value: true,
                        //           //                                           );
                        //           //                                           final success = await provider
                        //           //                                               .createAccount(
                        //           //                                                 isTermsAccepted:
                        //           //                                                     provider.acceptedTerms,
                        //           //                                                 context: context,
                        //           //                                               );
                        //           //                                           if (success && context.mounted) {
                        //           //                                             context.pushNamed(
                        //           //                                               AppRoutes.profileInfoScreen.name,
                        //           //                                             );
                        //           //                                           }
                        //           //                                         },
                        //           //                                         onFailed: (error) {
                        //           //                                           if (!context.mounted) return;
                        //           //                                           AppToast.error(context, error);
                        //           //                                         },
                        //           //                                       );
                        //           //
                        //           //   },
                        //           //   onFailed: (error) {
                        //           //     if (!context.mounted) return;
                        //           //     AppToast.error(
                        //           //       context,
                        //           //       "Start onboarding error: $error",
                        //           //     );
                        //           //   },
                        //           // );
                        //         },
                        //
                        //         onFailed: (error) {
                        //           if (!context.mounted) return;
                        //           AppToast.error(
                        //             context,
                        //             "Google sign-up failed. Please try again.",
                        //           );
                        //         },
                        //       );
                        //     } catch (e) {
                        //       Logger.error("Google Sign-In Button Error: $e");
                        //       if (context.mounted) {
                        //         AppToast.error(
                        //           context,
                        //           "An unexpected error occurred. Please try again.",
                        //         );
                        //       }
                        //     }
                        //   },
                        //   // onTap: () async {
                        //   //   final String? idToken = await provider
                        //   //       .getGoogleSignInIDToken();
                        //   //   provider.socialLogin(
                        //   //     idToken: idToken,
                        //   //     onSuccess: () async {
                        //   //       await provider.startOnboarding(
                        //   //         context: context,
                        //   //         onSuccess: () async {
                        //   //           AppToast.success(
                        //   //             context,
                        //   //             "Sign Up Successfully and Onboarding session started",
                        //   //           );
                        //   //           await provider.saveAge(
                        //   //             context: context,
                        //   //             onSuccess: () {
                        //   //               if (provider.isUnder16) {
                        //   //                 context.pushNamed(
                        //   //                   AppRoutes.parentEmailScreen.name,
                        //   //                 );
                        //   //                 return;
                        //   //               }
                        //   //               context.pushNamed(
                        //   //                 AppRoutes.createAccountScreen.name,
                        //   //               );
                        //   //               provider.toggleAcceptedTerms();
                        //   //               provider.createAccount(
                        //   //                 isTermsAccepted:
                        //   //                     provider.acceptedTerms,
                        //   //                 context: context,
                        //   //               );
                        //   //             },
                        //   //             onFailed: (error) {
                        //   //               AppToast.success(context, error);
                        //   //             },
                        //   //           );
                        //   //           // context.pushNamed(AppRoutes.enterAgeScreen.name);
                        //   //         },
                        //   //         onFailed: (error) {
                        //   //           AppToast.error(
                        //   //             context,
                        //   //             "Start on boarding error: ${error}",
                        //   //           );
                        //   //         },
                        //   //       );
                        //   //     },
                        //   //     onFailed: (error) {
                        //   //       AppToast.error(
                        //   //         context,
                        //   //         "Failed google sign up,\nPlease try again",
                        //   //       );
                        //   //     },
                        //   //   );
                        //   // },
                        // ),
                        //
                        // 12.w.verticalSpace,
                        //
                        // _socialButton(
                        //   label: "Sign up with Apple",
                        //   icon: AppAssets.apple,
                        //   onTap: () {},
                        // ),
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

  // /// ---------------- SOCIAL BUTTON ----------------
  // Widget _socialButton({
  //   required String label,
  //   required String icon,
  //   required VoidCallback onTap,
  // }) {
  //   return Container(
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color: AppColors.lightwhiteColor,
  //       borderRadius: BorderRadius.circular(40.r),
  //     ),
  //     child: InkWell(
  //       borderRadius: BorderRadius.circular(40.r),
  //       onTap: onTap,
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 24.w),
  //         child: Stack(
  //           alignment: Alignment.center,
  //           children: [
  //             /// Left icon
  //             Align(
  //               alignment: Alignment.centerLeft,
  //               child: SvgIcon(icon, size: 22.sp),
  //             ),

  //             /// Center text
  //             AppText(text: label, style: AppTextStyles.textStyle14Bold),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
