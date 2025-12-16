import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:toastification/toastification.dart';

class CustomToast {
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message,
      ToastificationType.success,
      AppColors.greenColor,
      Icons.check_circle_outline,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message,
      ToastificationType.error,
      Colors.red, // Using standard red for errors for better visibility
      Icons.error_outline,
    );
  }

  static void _show(
    BuildContext context,
    String message,
    ToastificationType type,
    Color primaryColor,
    IconData icon,
  ) {
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
            color: primaryColor.withOpacity(0.3),
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
