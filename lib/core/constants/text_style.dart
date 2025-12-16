import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles {
  AppTextStyles._();

  // SF Pro Display Styles
  static TextStyle sfProDisplayRegular({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w400,
      fontSize: fontSize?.sp ?? 16.sp,
      color: color,
    );
  }

  static TextStyle sfProDisplayMedium({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w500,
      fontSize: fontSize?.sp ?? 16.sp,
      color: color,
    );
  }

  static TextStyle sfProDisplaySemibold({double? fontSize, Color? color}) {
    return TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w600,
      fontSize: fontSize?.sp ?? 16.sp,
      color: color,
    );
  }

  static TextStyle sfProDisplayBold({
    double? fontSize,
    Color? color,
    TextDecoration? decoration,
    double letterSpacing = 0.0,
  }) {
    return TextStyle(
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

  static TextStyle sfProTextSemibold({double? fontSize, Color? color}) {
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
  static TextStyle get textStyle14Regular => sfProDisplayRegular(fontSize: 14.sp);
  static TextStyle get textStyle14Medium => sfProDisplayMedium(fontSize: 14.sp);
  static TextStyle get textStyle14Semibold =>
      sfProDisplaySemibold(fontSize: 14.sp);
  static TextStyle get textStyle14Bold => sfProDisplayBold(fontSize: 14.sp);

  static TextStyle get textStyle16Regular => sfProDisplayRegular(fontSize: 16.sp);
  static TextStyle get textStyle16Medium => sfProDisplayMedium(fontSize: 16.sp);
  static TextStyle get textStyle16Semibold =>
      sfProDisplaySemibold(fontSize: 16);
  static TextStyle get textStyle16Bold => sfProDisplayBold(fontSize: 16.sp);

  static TextStyle get textStyle18Regular => sfProDisplayRegular(fontSize: 18.sp);
  static TextStyle get textStyle18Medium => sfProDisplayMedium(fontSize: 18.sp);
  static TextStyle get textStyle18Semibold =>
      sfProDisplaySemibold(fontSize: 18);
  static TextStyle get textStyle18Bold => sfProDisplayBold(fontSize: 18.sp);

  static TextStyle get textStyle20Regular => sfProDisplayRegular(fontSize: 20.sp);
  static TextStyle get textStyle20Medium => sfProDisplayMedium(fontSize: 20.sp);
  static TextStyle get textStyle20Semibold =>
      sfProDisplaySemibold(fontSize: 20);
  static TextStyle get textStyle20Bold => sfProDisplayBold(fontSize: 20.sp);

  static TextStyle get textStyle24Regular => sfProDisplayRegular(fontSize: 24.sp);
  static TextStyle get textStyle24Medium => sfProDisplayMedium(fontSize: 24.sp);
  static TextStyle get textStyle24Semibold =>
      sfProDisplaySemibold(fontSize: 24.sp);
  static TextStyle get textStyle24Bold => sfProDisplayBold(fontSize: 24.sp);

  static TextStyle get textStyle28Regular => sfProDisplayRegular(fontSize: 28.sp);
  static TextStyle get textStyle28Medium => sfProDisplayMedium(fontSize: 28.sp);
  static TextStyle get textStyle28Semibold =>
      sfProDisplaySemibold(fontSize: 28);
  static TextStyle get textStyle28Bold => sfProDisplayBold(fontSize: 28.sp);
}
