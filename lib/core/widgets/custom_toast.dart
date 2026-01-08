import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:toastification/toastification.dart';

class AppToast {
  static void success(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      type: ToastificationType.success,
      primaryColor: AppColors.greenColor,
      icon: Icons.check_circle_outline,
    );
  }

  static void error(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      type: ToastificationType.error,
      primaryColor:
          Colors.red, // Using standard red for errors for better visibility
      icon: Icons.error_outline,
    );
  }

  static void info({
    required BuildContext context,
    required String message,
    int? durationSecond,
  }) {
    _show(
      context: context,
      message: message,
      type: ToastificationType.info,
      primaryColor: Colors.blue,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required ToastificationType type,
    required Color primaryColor,
    IconData? icon,
  }) {
    try {
      toastification.show(
        context: context,
        alignment: Alignment.topCenter,
        showProgressBar: false,
        title: Text(
          message,
          maxLines: 2,
          style: AppTextStyles.sfProDisplayMedium(
            fontSize: 15.sp,
            color: AppColors.white,
          ),
        ),
        style: ToastificationStyle.fillColored,
        backgroundColor: primaryColor,
        type: type,
        primaryColor: primaryColor,
        icon: Icon(icon, color: AppColors.white),
        autoCloseDuration: const Duration(seconds: 3),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } catch (e) {
      debugPrint("Toast Error: $e");
    }
  }
}
