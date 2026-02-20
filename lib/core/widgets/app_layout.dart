import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/features/dashboard.dart';

class AppLayout extends StatelessWidget {
  final Widget body;
  final bool? resizeToAvoidBottomInset;
  final AppBar? appBar;
  const AppLayout({
    super.key,
    required this.body,
    this.resizeToAvoidBottomInset,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: AppColors.backgroundColor,
      body: ValueListenableBuilder<int>(
        valueListenable: tabIndex,
        builder: (context, value, child) =>
            FadeInUp(key: ValueKey(value), from: 10.5, child: body),
      ),
    );
  }
}
