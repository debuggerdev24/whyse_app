import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/routes/user_routes.dart';

import '../../core/constants/app_color.dart';
import '../../core/helper/log_helper.dart';
import '../../core/utils/custom_loader.dart';
import '../../core/utils/de_bouncing.dart';
import '../../core/widgets/app_textfiled.dart';
import '../../providers/auth/auth_provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      26.h.verticalSpace,
                      Text(
                        "Forgot Password",
                        style: AppTextStyles.sfProDisplayBold(
                          fontSize: 32.sp,
                          color: AppColors.teal,
                        ),
                      ),
                      28.h.verticalSpace,
                      Text(
                        textAlign: TextAlign.center,
                        "We will send you a link to the email address you signed up with.",
                        style: AppTextStyles.textStyle16Semibold,
                      ),
                      26.h.verticalSpace,
                      AppTextField(
                        controller: provider.forgotPasswordEmailCtr,
                        hintText: "Email",
                      ),

                      Spacer(),
                      AppFilledButton(
                        margin: EdgeInsets.only(bottom: 10),
                        onTap: () {
                          Logger.info(
                            "TRecovery Token: ${provider.recoveryToken}",
                          );
                        },
                        text: "check token",
                      ),
                      if (provider.isSendForgotPassVerification)
                        AppOutlinedButton(
                          margin: EdgeInsets.only(bottom: 10),
                          onTap: () {
                            provider.verifyForgotPasswordEmail(
                              onFailed: (error) {
                                // if(error){
                                //
                                // }
                                AppToast.error(context, error.errorMsg);
                              },
                              onSuccess: () {
                                AppToast.success(
                                  context,
                                  "Email verify successfully.",
                                );
                                context.pushNamed(
                                  AppRoutes.resetPasswordScreen.name,
                                );
                              },
                            );
                          },
                          text: "Verify Email",
                        ),
                      AppFilledButton(
                        margin: EdgeInsets.only(bottom: 20.h),
                        text: (provider.isResendTimerRunning)
                            ? "Resend in ${provider.resendSeconds}s"
                            : "Send Link",
                        onTap: (provider.isResendTimerRunning)
                            ? () {}
                            : () {
                                deBouncer.run(() {
                                  if (provider.forgotPasswordEmailCtr.text
                                      .trim()
                                      .isEmpty) {
                                    AppToast.error(
                                      context,
                                      "Please enter email",
                                    );
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
                    ],
                  ),
                ),
                if (provider.isForgotPasswordLoading ||
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
