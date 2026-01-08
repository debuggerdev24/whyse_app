import 'package:flutter/material.dart';
import 'package:redstreakapp/core/constants/app_color.dart';

class AppLayout extends StatelessWidget {
  final Widget body;
  const AppLayout({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.backgroundColor, body: body);
  }
}
