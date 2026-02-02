import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.labelText = '',
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.hintText,
    this.controller,
    this.autoValidateMode = AutovalidateMode.onUserInteraction,
    this.keyboardType,
    this.inputFormatters,
    this.prefixText,
    this.onTap,
    this.obSecureText,
    this.style,
    this.labelStyle,
    this.border,
    this.contentPadding,
    this.maxLength,
    this.suffix,
    this.prefix,
    this.errorBorder,
    this.maxLines,
    this.outlineInputBorder,
    this.hintStyle,
    this.enabled,
    this.isRequired = false,
    this.bottomText,
    this.bottomTextStyle,
    this.readOnly = false,
    this.onSubmit, this.onTapOutside,
  });

  final String? labelText;
  final bool isRequired;
  final Widget? prefixIcon;
  final String? prefixText;
  final Widget? suffixIcon;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final Function(String value)? onChanged;
  final void Function()? onTap;
  final AutovalidateMode? autoValidateMode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool? obSecureText;
  final InputBorder? border;
  final InputBorder? errorBorder;
  final OutlineInputBorder? outlineInputBorder;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLength;
  final Widget? suffix;
  final Widget? prefix;
  final int? maxLines;
  final bool? enabled;
  final String? bottomText;
  final TextStyle? bottomTextStyle;
  final bool readOnly;
  final ValueChanged<String>? onSubmit;
  final Function()? onTapOutside;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          enabled: enabled ?? true,
          expands: false,
          readOnly: readOnly,
          maxLength: maxLength,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          controller: controller,
          obscureText: obSecureText ?? false,
          cursorColor: AppColors.black,
          showCursor: true,
          style: AppTextStyles.sfProDisplayRegular(
            color: AppColors.black,
            fontSize: 16.sp,
          ),
          onTap: onTap,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
            onTapOutside?.call();
            
          },

          decoration: InputDecoration(
            errorStyle: AppTextStyles.sfProDisplayRegular(
              color: AppColors.redColor,
              fontSize: 14.sp,
            ),
            filled: false,
            prefixIcon: prefixIcon,
            prefixText: prefixText,
            prefixStyle: style,
            suffixIcon: suffixIcon,
            suffix: suffix,
            prefix: prefix,
            hintText: hintText,
            hintStyle:
                hintStyle ??
                AppTextStyles.sfProDisplaySemibold(
                  color: AppColors.black.withValues(alpha: 0.3),
                  fontSize: 15.sp,
                ),
            contentPadding:
                contentPadding ??
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            border: InputBorder.none,
            enabledBorder:
                border ??
                OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.black.withValues(alpha: 0.25),
                    width: 1.w,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
            focusedBorder:
                border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    width: 1.w,
                    color: AppColors.black.withValues(alpha: 0.45),
                  ),
                ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.redColor, width: 1.w),
            ), // Op ,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),

              borderSide: BorderSide(color: AppColors.redColor, width: 1.w),
            ), // Optional: Added for error styling
          ),
          onChanged: onChanged,
          maxLines: maxLines ?? 1, // Optional: Default to 1
          //todo autovalidateMode: autoValidateMode, // Forward for real-time validation
          onFieldSubmitted: onSubmit,
        ),
      ],
    );
  }
}
