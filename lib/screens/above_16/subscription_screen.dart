import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/plan_card.dart';
import 'package:redstreakapp/routes/user_routes.dart';

class SubScriptionScreen extends StatefulWidget {
  const SubScriptionScreen({super.key});

  @override
  State<SubScriptionScreen> createState() => _SubScriptionScreenState();
}

class _SubScriptionScreenState extends State<SubScriptionScreen> {
  String selectedPlan = "Free";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                AppAssets.subscriptionbackground,
                width: double.infinity,
                fit: BoxFit.cover,

                height: 299.h,
              ),

              Positioned(
                top: 69.h,
                left: 20.w,
                right: 20.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Row(
                        children: [
                          SvgIcon(
                            AppAssets.backButton,
                            size: 13.sp,
                            color: AppColors.white,
                          ),
                          12.w.horizontalSpace,
                          AppText(
                            text: "Back",
                            style: AppTextStyles.textStyle14Semibold.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    31.h.verticalSpace,
                    AppText(
                      text: "Choose your plan",
                      style: AppTextStyles.sfProDisplayBold(
                        fontSize: 32.sp,
                        color: AppColors.white,
                      ),
                    ),
                    8.h.verticalSpace,
                    Text(
                      "Pick a plan that fits your reading goals and\nstart learning your way.",
                      style: AppTextStyles.sfProDisplayRegular(
                        fontSize: 16.sp,
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 27.h),
              child: ListView(
                padding: EdgeInsets.zero,

                children: [
                  /// FREE PLAN
                  PlanCard(
                    title: "Free Plan (with ads)",
                    price: "\$0/mo",
                    features: ["Ad Supported", "Limited AI learning"],
                    isSelected: selectedPlan == "Free",
                    onTap: () => setState(() => selectedPlan = "Free"),
                  ),

                  15.h.verticalSpace,

                  /// PREMIUM PLAN
                  PlanCard(
                    title: "Premium Plan (no ads)",
                    price: "\$12.99/mo",
                    features: [
                      "Ad Free",
                      "Full AI Features",
                      "Progress Reports",
                    ],
                    isSelected: selectedPlan == "Premium",
                    onTap: () => setState(() => selectedPlan = "Premium"),
                  ),

                  15.h.verticalSpace,

                  /// FAMILY PLAN
                  PlanCard(
                    title: "Family Plan",
                    price: "\$24.99/mo",
                    features: [
                      "Everything in Premium",
                      "Up to 5 Profiles",
                      "One Subscription",
                    ],
                    isSelected: selectedPlan == "Family",
                    onTap: () => setState(() => selectedPlan = "Family"),
                  ),

                  20.h.verticalSpace,
                ],
              ),
            ),
          ),

          AppButton(
            onPressed: () {
              context.pushNamed(UserAppRoutes.tabScreen.name);
            },
            text: "Subscribe",
            backgroundColor: AppColors.teal,
          ),
          30.h.verticalSpace,
        ],
      ),
    );
  }
}
