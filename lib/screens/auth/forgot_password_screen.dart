import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/routes/user_routes.dart';

import '../../core/constants/app_color.dart';
import '../../core/utils/de_bouncing.dart';
import '../../core/utils/field_validator.dart';
import '../../core/widgets/app_textfiled.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return AppLayout(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: formKey,
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
                          "We will send you an OTP to the email address you signed up with.",
                          style: AppTextStyles.textStyle16Semibold,
                        ),
                        26.h.verticalSpace,
                        AppTextField(
                          controller: provider.forgotPasswordCtr,
                          hintText: "Email",
                          validator: FieldValidators().email,
                          // errorStyle: medium(
                          //   fontSize: (context.isBrowserMobile) ? 25.sp : 12.sp,
                          //   color: AppColors.red,
                          // ),
                          // hintStyle: medium(
                          //   fontSize: (context.isBrowserMobile) ? 28.sp : 14.sp,
                          //   color: AppColors.primary.withValues(alpha: 0.4),
                          // ),
                          onSubmit: (value) {
                            deBouncer.run(() {
                              if (formKey.currentState!.validate()) {
                                // provider.sendOTP(context: context);
                              }
                            });
                          },
                        ),
                        Spacer(),
                        AppFilledButton(
                          margin: EdgeInsets.only(bottom: 20.h),
                          text: "Send OTP",

                          onTap: () {
                            deBouncer.run(() {
                              if (true) {
                                //formKey.currentState!.validate()
                                context.pushNamed(
                                  AppRoutes.verifyOtpScreen.name,
                                );
                                // provider.sendOTP(context: context);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // if (provider.isForgotPassLoading) FullPageIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }
}
