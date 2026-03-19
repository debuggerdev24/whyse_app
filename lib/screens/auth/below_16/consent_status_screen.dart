import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';

class ConsentStatusScreen extends StatefulWidget {
  const ConsentStatusScreen({super.key});

  @override
  State<ConsentStatusScreen> createState() => _ConsentStatusScreenState();
}

class _ConsentStatusScreenState extends State<ConsentStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Consumer<AuthProvider>(
        builder: (context, provider, child) => SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    SvgIcon(AppAssets.accepted, size: 144.w),
                    42.w.verticalSpace,
                    AppText(
                      text: "Request sent to parent successfully.",
                      style: AppTextStyles.sfProDisplaySemibold(
                        fontSize: 16.sp,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    35.w.verticalSpace,
                    AppText(
                      text: "Consent Status",
                      style: AppTextStyles.sfProDisplaySemibold(
                        fontSize: 14.sp,
                        color: AppColors.black.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    3.w.verticalSpace,

                    AppText(
                      text: provider.isConsentRequestApproved
                          ? "Accepted"
                          : "Waiting for Approval!",
                      style: AppTextStyles.sfProDisplayBold(
                        fontSize: 16.sp,
                        color: provider.isConsentRequestApproved
                            ? AppColors.greenColor
                            : AppColors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),

                    AppFilledButton(
                      onTap: () {
                        if (provider.isConsentRequestApproved) {
                          context.pushNamed(AppRoutes.createAccountScreen.name);
                          return;
                        }
                      },
                      text: "Continue",
                      backgroundColor: AppColors.primaryColor,
                    ),

                    10.w.verticalSpace,
                  ],
                ),
              ),
              if (provider.isVerifyConsentRequestLoading) FullPageIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
