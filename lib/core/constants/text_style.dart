import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles {
  AppTextStyles._();

  // SF Pro Display Styles
  static TextStyle regular({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w400,
      fontSize: fontSize?.sp ?? 16.sp,
      color: color,
    );
  }

  static TextStyle medium({
    double? fontSize,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      height: height,
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w500,
      fontSize: fontSize?.sp ?? 16.sp,
      color: color,
    );
  }

  static TextStyle semibold({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w600,
      fontSize: fontSize?.sp ?? 16.sp,
      color: color,
    );
  }

  static TextStyle bold({
    double? fontSize,
    Color? color,
    double? height,
    TextDecoration? decoration,
    double letterSpacing = 0.0,
  }) {
    return TextStyle(
      height: height,
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w700,
      fontSize: fontSize?.sp ?? 16.sp,
      color: color,
      decoration: decoration,
      letterSpacing: letterSpacing,
    );
  }

  // SF Pro Text Styles
  static TextStyle sfProTextRegular({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: 'SFProText',
      fontWeight: FontWeight.w400,
      fontSize: fontSize?.sp ?? 16.sp,
      color: color,
    );
  }

  static TextStyle sfProTextMedium({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: 'SFProText',
      fontWeight: FontWeight.w500,
      fontSize: fontSize?.sp ?? 16.sp,
      color: color,
    );
  }

  static TextStyle semiBold({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: 'SFProText',
      fontWeight: FontWeight.w600,
      fontSize: fontSize?.sp ?? 16.sp,
      color: color,
    );
  }

  static TextStyle sfProTextBold({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: 'SFProText',
      fontWeight: FontWeight.w700,
      fontSize: fontSize?.sp ?? 16.sp,
      color: color,
    );
  }

  // Common text styles (using SF Pro Display as default)
  static TextStyle get textStyle14Regular =>
      regular(fontSize: 14.sp);
  static TextStyle get textStyle14Medium => medium(fontSize: 14.sp);
  static TextStyle get textStyle14Semibold =>
      semibold(fontSize: 14.sp);
  static TextStyle get textStyle14Bold => bold(fontSize: 14.sp);

  static TextStyle get textStyle16Regular =>
      regular(fontSize: 16.sp);
  static TextStyle get textStyle16Medium => medium(fontSize: 16.sp);
  static TextStyle get textStyle16Semibold =>
      semibold(fontSize: 16);
  static TextStyle get textStyle16Bold => bold(fontSize: 16.sp);

  static TextStyle get textStyle18Regular =>
      regular(fontSize: 18.sp);
  static TextStyle get textStyle18Medium => medium(fontSize: 18.sp);
  static TextStyle get textStyle18Semibold =>
      semibold(fontSize: 18);
  static TextStyle get textStyle18Bold => bold(fontSize: 18.sp);

  static TextStyle get textStyle20Regular =>
      regular(fontSize: 20.sp);
  static TextStyle get textStyle20Medium => medium(fontSize: 20.sp);
  static TextStyle get textStyle20Semibold =>
      semibold(fontSize: 20);
  static TextStyle get textStyle20Bold => bold(fontSize: 20.sp);

  static TextStyle get textStyle22Regular =>
      regular(fontSize: 22.sp);
  static TextStyle get textStyle22Medium => medium(fontSize: 22.sp);
  static TextStyle get textStyle22Semibold =>
      semibold(fontSize: 22.sp);
  static TextStyle get textStyle22Bold => bold(fontSize: 22.sp);

  static TextStyle get textStyle24Regular =>
      regular(fontSize: 24.sp);
  static TextStyle get textStyle24Medium => medium(fontSize: 24.sp);
  static TextStyle get textStyle24Semibold =>
      semibold(fontSize: 24.sp);
  static TextStyle get textStyle24Bold => bold(fontSize: 24.sp);

  static TextStyle get textStyle28Regular =>
      regular(fontSize: 28.sp);
  static TextStyle get textStyle28Medium => medium(fontSize: 28.sp);
  static TextStyle get textStyle28Semibold =>
      semibold(fontSize: 28);
  static TextStyle get textStyle28Bold => bold(fontSize: 28.sp);
}
