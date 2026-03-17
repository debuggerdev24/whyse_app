import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/utils/field_validator.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';

import '../../core/constants/app_color.dart';
import '../../core/widgets/app_textfiled.dart';

class ResetPasswordScreen extends StatelessWidget {
  final bool? isVerified;
  const ResetPasswordScreen({super.key, this.isVerified});

  @override
  Widget build(BuildContext context) {
    // GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return AppLayout(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, provider, child) => Stack(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    26.h.verticalSpace,

                    Text(
                      "Reset Password",
                      style: AppTextStyles.sfProDisplayBold(
                        fontSize: 32.sp,
                        color: AppColors.teal,
                      ),
                    ),
                    15.h.verticalSpace,
                    Text(
                      textAlign: TextAlign.center,
                      "Enter new password below to reset.",
                      style: AppTextStyles.textStyle16Semibold,
                    ),
                    55.verticalSpace,
                    AppTextField(
                      controller: provider.newPasswordCtr,
                      hintText: "New Password",
                    ),
                    15.h.verticalSpace,
                    AppTextField(
                      controller: provider.resetConfirmPasswordCtr,
                      hintText: "Confirm Password",
                    ),
                    Spacer(),
                    AppFilledButton(
                      margin: EdgeInsets.only(bottom: 20.h),
                      text: "Confirm",
                      onTap: () {
                        // if (formKey.currentState!.validate()) {
                        // provider.resetPassword(context: context);
                        // }
                        final passText = provider.newPasswordCtr.text.trim();
                        final confPassText = provider
                            .resetConfirmPasswordCtr
                            .text
                            .trim();
                        if (passText.isEmpty || confPassText.isEmpty) {
                          AppToast.error(
                            context,
                            "${(passText.isEmpty) ? "Password" : "Confirm Password"} is required",
                          );
                          return;
                        }
                        final error = FieldValidators().password(passText);
                        if (error != null) {
                          AppToast.error(context, error);
                          return;
                        }

                        if (passText != confPassText) {
                          return AppToast.error(
                            context,
                            "Passwords do not match",
                          );
                        }
                        provider.resetPassword(
                          onSuccess: () {
                            context.goNamed(AppRoutes.loginScreen.name);
                            AppToast.success(
                              context,
                              "Your password has been reset successfully.",
                            );
                          },
                          onFailed: (error) {
                            AppToast.error(context, error);
                          },
                        );

                        // context.goNamed(AppRoutes.loginScreen.name);
                      },
                    ),
                  ],
                ),
              ),
              if (provider.isResetPasswordLoading) FullPageIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
