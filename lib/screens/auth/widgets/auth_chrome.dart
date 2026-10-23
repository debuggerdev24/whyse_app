import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';

/// Visual tokens taken from the Whyse auth mockups.
class AuthChrome {
  AuthChrome._();

  static const Color background = Color(0xFFF2F2F7);
  static const Color title = Color(0xFF121212);
  static const Color body = Color(0xFF1A1A1A);
  static const Color subtitle = Color(0xFF6C6C6E);
  static const Color hint = Color(0xFFA3A3A6);
  static const Color teal = Color(0xFF157B7F);
  static const Color link = Color(0xFF167C80);
  static const Color divider = Color(0xFFDCDCE1);
  static const Color field = Color(0xFFFFFFFF);

  static Widget logo({required double width}) {
    return Image.asset(
      AppAssets.whyseLogo,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }

  static Widget backButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
              return;
            }
            context.goNamed(AppRoutes.loginScreen.name);
          },
          child: SizedBox(
            width: 40.w,
            height: 40.w,
            child: Icon(
              Icons.chevron_left_rounded,
              size: 28.sp,
              color: body,
            ),
          ),
        ),
      ),
    );
  }

  static Widget titleText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.bold(fontSize: 28.sp, color: title, height: 1.2),
    );
  }

  static Widget subtitleText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.medium(
        fontSize: 15.sp,
        color: subtitle,
        height: 1.35,
      ),
    );
  }

  static Widget fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTextStyles.semibold(fontSize: 14.sp, color: body),
      ),
    );
  }

  static Widget textField({
    required String hintText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    final radius = BorderRadius.circular(14.r);
    return AppTextField(
      controller: controller,
      hintText: hintText,
      keyboardType: keyboardType,
      obSecureText: obscureText,
      suffixIcon: suffixIcon,
      cursorColor: teal,
      fillColor: field,
      contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      hintStyle: AppTextStyles.regular(fontSize: 15.sp, color: hint),
      border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: teal, width: 1.2),
      ),
    );
  }

  static Widget primaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.r),
          ),
          splashFactory: NoSplash.splashFactory,
        ),
        child: Text(
          text,
          style: AppTextStyles.semibold(fontSize: 16.sp, color: Colors.white),
        ),
      ),
    );
  }

  static Widget footerLink({
    required String prefix,
    required String action,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prefix,
          style: AppTextStyles.regular(fontSize: 14.sp, color: body),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: AppTextStyles.semibold(fontSize: 14.sp, color: link),
          ),
        ),
      ],
    );
  }

  static Widget orDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: divider, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Text(
            'OR',
            style: AppTextStyles.medium(fontSize: 13.sp, color: subtitle),
          ),
        ),
        const Expanded(child: Divider(color: divider, thickness: 1)),
      ],
    );
  }

  static Widget socialButton({
    required String label,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.r),
        side: const BorderSide(color: Color(0xFFE6E6EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(40.r),
        onTap: onTap,
        child: SizedBox(
          height: 52.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              10.w.horizontalSpace,
              Text(
                label,
                style: AppTextStyles.semibold(fontSize: 15.sp, color: body),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
