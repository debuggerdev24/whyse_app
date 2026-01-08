import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/providers/auth_provider.dart';

import '../../core/constants/app_color.dart';
import '../../core/utils/field_validator.dart';
import '../../core/widgets/app_textfiled.dart';
import '../../routes/user_routes.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return AppLayout(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, provider, child) => Stack(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 24.w),
                child: Form(
                  key: formKey,
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
                      55.h.verticalSpace,
                      AppTextField(
                        controller: provider.newPasswordCtr,
                        hintText: "New Password",
                        validator: FieldValidators().password,
                      ),
                      15.h.verticalSpace,
                      AppTextField(
                        controller: provider.resetConfirmPasswordCtr,
                        hintText: "Confirm Password",
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            if (provider.newPasswordCtr.text.trim() !=
                                provider.resetConfirmPasswordCtr.text.trim()) {
                              return "Confirm Password should match with new Password!";
                            }
                          }

                          return FieldValidators().required(
                            value,
                            "Confirm Password",
                          );
                        },
                      ),
                      Spacer(),
                      AppFilledButton(
                        margin: EdgeInsets.only(bottom: 20.h),
                        text: "Confirm",
                        onTap: () {
                          // if (formKey.currentState!.validate()) {
                          // provider.resetPassword(context: context);
                          // }
                          context.goNamed(AppRoutes.loginScreen.name);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
