import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';

import '../../core/constants/app_color.dart';
import '../../core/constants/text_style.dart';
import '../../core/routes/user_routes.dart';

class VerifyOtpScreen extends StatelessWidget {
  const VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      26.w.verticalSpace,
                      Text(
                        "Verify OTP",
                        style: AppTextStyles.bold(
                          fontSize: 32.sp,
                          color: AppColors.teal,
                        ),
                      ),
                      28.w.verticalSpace,
                      Text(
                        textAlign: TextAlign.center,
                        "Enter the OTP received on your registered email address to reset password.",
                        style: AppTextStyles.textStyle16Semibold,
                      ),
                      28.w.verticalSpace,
                      Pinput(
                        controller: provider.otpCtr,
                        length: 4,
                        separatorBuilder: (index) => 14.w.horizontalSpace,

                        defaultPinTheme: buildPinTheme(
                          // textStyle: AppTextStyles.textStyle20Medium,
                          borderColor: AppColors.black.withValues(alpha: 0.25),
                        ),

                        focusedPinTheme: buildPinTheme(
                          textStyle: AppTextStyles.textStyle22Regular,
                          borderColor: AppColors.black.withValues(alpha: 0.45),
                          borderWidth: 2,
                        ),

                        submittedPinTheme: buildPinTheme(
                          textStyle: AppTextStyles.textStyle22Medium,

                          borderColor: Colors.grey.shade400,
                        ),

                        keyboardType: TextInputType.number,
                        onCompleted: (code) {},
                      ),
                      Spacer(),
                      Text(
                        "Didn’t receive OTP?",
                        style: AppTextStyles.semibold(
                          fontSize: 15.sp,
                        ),
                      ),
                      AppOutlinedButton(
                        text: "Re-Send",
                        // provider.isResendOtpLoading
                        // ? "Resending..."
                        //     : provider.canResendOtp
                        // ? "Re-Send"
                        //     : "Resend OTP in ${provider.resendSeconds}s",
                        onTap: () {
                          // if (provider.canResendOtp &&
                          // !provider.isResendOtpLoading) {
                          // provider.resendOtp(context: context);
                          // }
                        },

                        margin: EdgeInsets.only(top: 10.h, bottom: 12.h),
                      ),
                      AppFilledButton(
                        margin: EdgeInsets.only(bottom: 20.h),
                        text: "Verify",

                        onTap: () {
                          // provider.verifyOtp(context: context);
                          context.pushNamed(AppRoutes.resetPasswordScreen.name);
                        },
                      ),
                    ],
                  ),
                ),
                // if(provider.isSendOtpLoading) FullPageIndicator()
              ],
            );
          },
        ),
      ),
    );
  }

  PinTheme buildPinTheme({
    // required double height,
    // required double width,
    TextStyle? textStyle,
    Color? borderColor,
    double borderWidth = 1,
    double borderRadius = 8,
  }) {
    return PinTheme(
      height: 55.h,
      width: 70.w,
      textStyle: textStyle,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Colors.grey,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
