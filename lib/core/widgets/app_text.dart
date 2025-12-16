import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final int? maxLines;

  const AppText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.overflow,
    this.decoration,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: style?.copyWith(decoration: decoration),
    );
  }
}
