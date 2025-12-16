import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/routes/user_routes.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              /// ---------- MAIN CONTENT CENTER ----------
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppAssets.success, width: 254.w),
                      30.h.verticalSpace,

                      AppText(
                        text: "You’re all set!",
                        style: AppTextStyles.sfProDisplayBold(fontSize: 32.sp),
                      ),

                      8.h.verticalSpace,
                      AppText(
                        textAlign: TextAlign.center,
                        text:
                            "Your reading journey starts today — let’s build your first streak!",
                        style: AppTextStyles.sfProDisplayMedium(
                          fontSize: 16.sp,
                          color: AppColors.black.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// ---------- BUTTON AT BOTTOM ----------
              AppButton(
                text: "proccesing",
                onPressed: () {
                  context.pushNamed(UserAppRoutes.tabScreen.name);
                },
              ),

              10.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
