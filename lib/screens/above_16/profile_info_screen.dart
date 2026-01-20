import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/widgets/dropdown_textfiled.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';

import '../../providers/on_boarding/on_boarding_provider.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Consumer2<AuthProvider, OnBoardingProvider>(
          builder: (context, authProvider, onBoardingProvider, child) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const OnboardingHeader(currentStep: 1, totalSteps: 5),
                      AppText(
                        text: "Profile Information",
                        style: AppTextStyles.sfProDisplayBold(fontSize: 32.sp),
                      ),
                      8.h.verticalSpace,
                      AppText(
                        text:
                            "Complete your profile to personalize your reading journey.",
                        style: AppTextStyles.sfProDisplayMedium(
                          fontSize: 16.sp,
                          color: AppColors.black.withValues(alpha: 0.8),
                        ),
                      ),

                      20.h.verticalSpace,

                      CustomDropDown(
                        hint: "Country",
                        value: onBoardingProvider.selectedCountry,
                        items: ["India", "USA", "Canada", "UK"],
                        onChanged: (value) {
                          onBoardingProvider.setCountry(value);
                        },
                      ),

                      20.h.verticalSpace,

                      // Language Dropdown
                      CustomDropDown(
                        hint: "Preferred Reading Language",
                        value: onBoardingProvider.selectedLanguage,
                        items: ["English", "Hindi", "Arabic", "French"],
                        onChanged: (value) {
                          onBoardingProvider.setLanguage(value);
                        },
                      ),

                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: AppFilledButton(
                          text: "Next",
                          backgroundColor: AppColors.yellowColor,
                          onTap: () async {
                            if (onBoardingProvider.selectedCountry == null) {
                              AppToast.error(
                                context,
                                "Please select your country",
                              );
                              return;
                            }
                            if (onBoardingProvider.selectedLanguage == null) {
                              AppToast.error(
                                context,
                                "Please select your preferred language",
                              );
                              return;
                            }

                            final success = await authProvider.saveProfileInfo(
                              context,
                              country: onBoardingProvider.selectedCountry!,
                              preferredLanguage:
                                  onBoardingProvider.selectedLanguage!,
                            );

                            if (success && context.mounted) {
                              context.pushNamed(
                                AppRoutes.readingGoalScreen.name,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (authProvider.isSaveProfileLoading) FullPageIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }
}
