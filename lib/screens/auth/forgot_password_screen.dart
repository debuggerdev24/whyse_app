import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/core/utils/field_validator.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/screens/auth/widgets/auth_chrome.dart';

import '../../core/utils/custom_loader.dart';
import '../../core/utils/de_bouncing.dart';
import '../../providers/auth/auth_provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
                  padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthChrome.backButton(context),
                      12.h.verticalSpace,
                      Center(child: AuthChrome.logo(width: 150.w)),
                      22.h.verticalSpace,
                      AuthChrome.titleText('Forgot password?'),
                      8.h.verticalSpace,
                      AuthChrome.subtitleText(
                        'We will send you a link to the email address you signed up with.',
                      ),
                      28.h.verticalSpace,
                      AuthChrome.fieldLabel('Email ID'),
                      8.h.verticalSpace,
                      AuthChrome.textField(
                        hintText: 'Enter email id',
                        controller: provider.forgotPasswordEmailCtr,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      22.h.verticalSpace,
                      // if (provider.isSendForgotPassVerification)
                      //   AppOutlinedButton(
                      //     margin: EdgeInsets.only(bottom: 10),
                      //     onTap: () {
                      //       provider.verifyForgotPasswordEmail(
                      //         onFailed: (error) {
                      //           AppToast.error(context, error.errorMsg);
                      //         },
                      //         onSuccess: () {
                      //           AppToast.success(
                      //             context,
                      //             "Email verify successfully.",
                      //           );
                      //           context.pushNamed(
                      //             AppRoutes.resetPasswordScreen.name,
                      //           );
                      //         },
                      //       );
                      //     },
                      //     text: "Verify Email",
                      //   ),
                      AuthChrome.primaryButton(
                        text: (provider.isResendTimerRunning)
                            ? "Resend in ${provider.resendSeconds}s"
                            : "Send Reset Link",
                        onTap: (provider.isResendTimerRunning)
                            ? () {}
                            : () {
                                deBouncer.run(() {
                                  final error = FieldValidators().email(
                                    provider.forgotPasswordEmailCtr.text.trim(),
                                  );
                                  if (error != null) {
                                    AppToast.error(context, error);
                                    return;
                                  }

                                  provider.sendLinkForgotPass(
                                    onFailed: (error) {
                                      AppToast.error(context, error);
                                    },
                                    onSuccess: () {
                                      AppToast.success(
                                        context,
                                        "A verification link has been sent to your email address.\nplease verify.",
                                      );
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
                    ],
                  ),
                ),
                if (provider.isSendLinkForgotPassLoading ||
                    provider.isVerifyForgotPassMailLoading)
                  FullPageIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }
}
