import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/widgets/dropdown_textfiled.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/providers/auth_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  String? selectedCountry;
  String? selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, provider, child) {
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
                        value: selectedCountry,
                        items: ["India", "USA", "Canada", "UK"],
                        onChanged: (value) {
                          setState(() {
                            selectedCountry = value;
                          });
                        },
                      ),

                      20.h.verticalSpace,

                      // Language Dropdown
                      CustomDropDown(
                        hint: "Preferred Reading Language",
                        value: selectedLanguage,
                        items: ["English", "Hindi", "Arabic", "French"],
                        onChanged: (value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: AppFilledButton(
                          text: "Next",
                          backgroundColor: AppColors.yellowColor,
                          onTap: () async {
                            if (selectedCountry == null) {
                              AppToast.error(
                                context,
                                "Please select your country",
                              );
                              return;
                            }
                            if (selectedLanguage == null) {
                              AppToast.error(
                                context,
                                "Please select your preferred language",
                              );
                              return;
                            }

                            final success = await provider.saveProfileInfo(
                              context,
                              country: selectedCountry!,
                              preferredLanguage: selectedLanguage!,
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
                if (provider.isSaveProfileLoading) FullPageIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }
}
