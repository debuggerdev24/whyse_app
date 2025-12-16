import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/routes/user_routes.dart';

class ConsentStatusScreen extends StatefulWidget {
  final bool isAccepted;

  const ConsentStatusScreen({super.key, this.isAccepted = true});

  @override
  State<ConsentStatusScreen> createState() => _ConsentStatusScreenState();
}

class _ConsentStatusScreenState extends State<ConsentStatusScreen> {
  late bool currentStatus;

  @override
  void initState() {
    super.initState();

    // Initial status
    currentStatus = widget.isAccepted;

    // Change text after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        currentStatus = false; // Change to Waiting
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              SvgIcon(AppAssets.accepted, size: 144.w),

              42.h.verticalSpace,

              AppText(
                text: "Request sent successfully.",
                style: AppTextStyles.sfProDisplaySemibold(
                  fontSize: 16.sp,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),

              35.h.verticalSpace,

              AppText(
                text: "Consent Status",
                style: AppTextStyles.sfProDisplaySemibold(
                  fontSize: 14.sp,
                  color: AppColors.black.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),

              3.h.verticalSpace,

              AppText(
                text: currentStatus ? "Accepted" : "Waiting for Approval",
                style: AppTextStyles.sfProDisplayBold(
                  fontSize: 16.sp,
                  color: currentStatus ? AppColors.greenColor : AppColors.teal,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              AppButton(
                onPressed: () {
                  context.pushNamed(UserAppRoutes.createAccountScreen.name);
                },
                text: "Continue",
                backgroundColor: AppColors.yellowcolor,
              ),

              10.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
