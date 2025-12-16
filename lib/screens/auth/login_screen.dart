import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/providers/auth_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/routes/user_routes.dart';

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
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(flex: 2),
                  SvgIcon(AppAssets.welcome),

                  36.h.verticalSpace,

                  AppText(
                    text: 'Welcome Back!',
                    style: AppTextStyles.sfProDisplayBold(
                      fontSize: 32.sp,
                      color: AppColors.teal,
                    ),
                  ),

                  15.h.verticalSpace,
                  AppText(
                    text: 'Login',
                    style: AppTextStyles.sfProDisplaySemibold(
                      fontSize: 16.sp,
                      color: AppColors.black,
                    ),
                  ),

                  37.h.verticalSpace,
                  8.h.verticalSpace,
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Column(
                        children: [
                          AppTextField(
                            hintText: "Email",
                            controller: authProvider.emailController,
                          ),
                          8.h.verticalSpace,
                          AppTextField(
                            hintText: "Password",
                            obSecureText: _isObscure,
                            controller: authProvider.passwordController,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                                child: _isObscure
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
                          32.h.verticalSpace,
                          AppButton(
                            isLoading: authProvider.isLoading,
                            onPressed: () async {
                              final success = await authProvider.login(context);
                              if (success && context.mounted) {
                                context.goNamed(UserAppRoutes.tabScreen.name);
                              }
                            },
                            text: "Login with Email",
                          ),
                        ],
                      );
                    },
                  ),

                  17.h.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.textStyle14Regular,
                      ),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(UserAppRoutes.signUpScreen.name);
                        },
                        child: Text(
                          'Create Account',
                          style: AppTextStyles.textStyle14Bold,
                        ),
                      ),
                    ],
                  ),

                  36.h.verticalSpace,

                  // ---- OR Divider ----
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppColors.black.withOpacity(0.2)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'OR',
                          style: AppTextStyles.textStyle14Semibold,
                        ),
                      ),
                      Expanded(
                        child: Divider(color: AppColors.black.withOpacity(0.2)),
                      ),
                    ],
                  ),

                  32.h.verticalSpace,
                  // Google Login
                  _socialButton(
                    label: "Login with Google",
                    icon: AppAssets.google,
                  ),

                  8.h.verticalSpace,
                  // Apple Login
                  _socialButton(
                    label: "Login with Apple",
                    icon: AppAssets.apple,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton({required String label, required String icon}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lightwhiteColor,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(40.r),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 28.w),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SvgIcon(icon, size: 20.sp),
              ),

              AppText(text: label, style: AppTextStyles.textStyle14Bold),
            ],
          ),
        ),
      ),
    );
  }
}
