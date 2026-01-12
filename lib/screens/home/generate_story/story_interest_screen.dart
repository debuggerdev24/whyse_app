import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/custom_toast.dart';

class StoryInterestsScreen extends StatefulWidget {
  const StoryInterestsScreen({super.key});

  @override
  State<StoryInterestsScreen> createState() => _StoryInterestsScreenState();
}

class _StoryInterestsScreenState extends State<StoryInterestsScreen> {
  String _getIconForInterest(String name) {
    if (name.toLowerCase().contains("adventure")) return AppAssets.adventure;
    if (name.toLowerCase().contains("mystery")) return AppAssets.mystery;
    if (name.toLowerCase().contains("science")) return AppAssets.science;
    if (name.toLowerCase().contains("fantasy")) return AppAssets.fantancy;
    if (name.toLowerCase().contains("history")) return AppAssets.histoy;
    if (name.toLowerCase().contains("nature")) return AppAssets.nature;
    if (name.toLowerCase().contains("comics")) return AppAssets.comics;
    // Default or random if not matched? returning adventure as placeholder or null
    return AppAssets.adventure;
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SafeArea(
        child: Consumer<StoryProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OnboardingHeader(
                    currentStep: 2,
                    totalSteps: 4,
                    onBack: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed(AppRoutes.readingGoalScreen.name);
                      }
                    },
                  ),

                  AppText(
                    text: "Pick Your Interests",
                    style: AppTextStyles.sfProDisplayBold(fontSize: 32.sp),
                  ),
                  10.h.verticalSpace,
                  AppText(
                    text:
                        "Choose topics you love to personalize your reading journey.",
                    style: AppTextStyles.sfProDisplayMedium(
                      fontSize: 16.sp,
                      color: AppColors.black.withValues(alpha: 0.8),
                    ),
                  ),

                  20.h.verticalSpace,

                  // Loading State
                  if (provider.isGetInterestLoading)
                    const Expanded(child: Center(child: ApiLoadingIndicator()))
                  else
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // API Interests
                          ...provider.interestsList.map((interest) {
                            final id = interest.id;
                            final name = interest.name;
                            return SelectionOption(
                              label: name,
                              isSelected: provider.selectedInterestIds.contains(
                                id,
                              ),
                              onTap: () => provider.toggleApiInterest(id),
                              iconPath: _getIconForInterest(name),
                            );
                          }),

                          // Custom Interests
                          ...provider.customInterestsList.map((name) {
                            return SelectionOption(
                              label: name,
                              isSelected: provider.selectedCustomInterests
                                  .contains(name),
                              onTap: () => provider.toggleCustomInterest(name),
                              iconPath: AppAssets.adventure,
                            );
                          }),
                          //todo Custom Interest Input
                          // Padding(
                          //   padding: EdgeInsets.only(top: 10.h),
                          //   child: AppTextField(
                          //     controller: provider.customInterestCtr,
                          //     hintText: "Add Custom Interest...",
                          //     onSubmit: (val) {
                          //       provider.addCustomInterest(val);
                          //     },
                          //   ),
                          // ),
                          // 16.h.verticalSpace,
                        ],
                      ),
                    ),

                  AppFilledButton(
                    text: "Next",
                    backgroundColor: AppColors.yellowColor,
                    onTap: () {
                      if (provider.selectedInterestIds.isEmpty &&
                          provider.selectedCustomInterests.isEmpty) {
                        AppToast.error(
                          context,
                          "Please select at least one interest",
                        );
                        return;
                      }

                      context.pushNamed(AppRoutes.storyTopicsScreen.name);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
