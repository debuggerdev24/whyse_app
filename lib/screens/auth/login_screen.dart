import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/screens/auth/widgets/auth_chrome.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().clearLoginFields();
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
          builder: (context, provider, child) => Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: AuthChrome.logo(width: 150.w)),
                    18.h.verticalSpace,
                    AuthChrome.titleText('Welcome back!'),
                    8.h.verticalSpace,
                    AuthChrome.subtitleText(
                      'Sign in to continue your learning journey.',
                    ),
                    28.h.verticalSpace,
                    AuthChrome.fieldLabel('Email ID'),
                    8.h.verticalSpace,
                    AuthChrome.textField(
                      hintText: 'Enter email id',
                      controller: provider.loginEmailCtr,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    16.h.verticalSpace,
                    AuthChrome.fieldLabel('Password'),
                    8.h.verticalSpace,
                    AuthChrome.textField(
                      hintText: 'Enter password',
                      controller: provider.loginPasswordCtr,
                      obscureText: _isObscure,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _isObscure = !_isObscure);
                        },
                        icon: SvgIcon(
                          _isObscure ? AppAssets.password : AppAssets.eye,
                          size: 22.w,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ),
                    8.h.verticalSpace,
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.pushNamed(
                            AppRoutes.forgotPasswordScreen.name,
                          );
                          provider.forgotPasswordEmailCtr.clear();
                        },
                        child: Text(
                          'Forget Password?',
                          style: AppTextStyles.semibold(
                            fontSize: 14.sp,
                            color: AuthChrome.link,
                          ),
                        ),
                      ),
                    ),
                    22.h.verticalSpace,
                    AuthChrome.primaryButton(
                      text: 'Login with Email',
                      onTap: () async {
                        await provider.loginWithMail(context: context);
                      },
                    ),
                    16.h.verticalSpace,
                    AuthChrome.footerLink(
                      prefix: "Don't have an account? ",
                      action: 'Create Account',
                      onTap: () {
                        provider.clearLoginFields();
                        context.pushNamed(AppRoutes.signUpScreen.name);
                      },
                    ),
                    22.h.verticalSpace,
                    AuthChrome.orDivider(),
                    22.h.verticalSpace,
                    AuthChrome.socialButton(
                      label: 'Login with Google',
                      icon: SvgIcon(AppAssets.google, size: 20.sp),
                      onTap: () async {
                          //todo getting id token
                          final idToken = await provider.getGoogleIDTokenForLogin();
                          if (idToken == null) {
                            if (context.mounted) {
                              AppToast.info(
                                context: context,
                                message: "You have cancelled Google Sign-In",
                              );
                            }
                            return;
                          }
                          await provider.beginGoogleSocialLogin(
                            context: context,
                            idToken: idToken,
                            onAccountFound: () {
                              if (!context.mounted) return;
                              AppToast.success(context, "Login Successfully.");
                              provider.navigateToHomeScreen(context);
                            },
                            onNoAccountFound: () async {
                              if (!context.mounted) return;
                              await provider.finalizeGoogleSignup(
                                context: context,
                                onProfileInfo: () {
                                  context.pushNamed(
                                    AppRoutes.profileInfoScreen.name,
                                  );
                                  AppToast.success(
                                    context,
                                    "Please complete your on-boarding session",
                                  );
                                },
                                onParentEmail: () {
                                  context.pushNamed(
                                    AppRoutes.parentEmailScreen.name,
                                  );
                                },
                                onFailed: (error) {
                                  if (!context.mounted) return;
                                  AppToast.error(context, error);
                                },
                              );
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
                    AuthChrome.socialButton(
                      label: 'Login with Apple',
                      icon: SvgIcon(AppAssets.apple, size: 20.sp),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              if (provider.isLoginLoading || provider.isSocialLoginLoading)
                FullPageIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
