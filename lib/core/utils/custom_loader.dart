import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_color.dart';

class FullPageIndicator extends StatelessWidget {
  const FullPageIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: AppColors.black.withValues(alpha: 0.4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(7).r,
        ),
        padding: EdgeInsets.all(12.r),
        child: CupertinoActivityIndicator(
          radius: 19.w,
          color: AppColors
          .indicatorColor,
        ),
      ),
    );
  }
}

class ApiLoadingIndicator extends StatelessWidget {
  const ApiLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12).r,
        child: CupertinoActivityIndicator(
          radius: 20.w,
          color: AppColors
              .indicatorColor,
        ),
      ),
    );
  }
}
