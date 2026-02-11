import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/custom_toast.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  // Local state for custom interests
  final List<String> customInterests = [];
  final TextEditingController customInterestController =
      TextEditingController(); // Added controller
  // Store selected IDs (from API) and Custom Strings
  final Set<String> selectedInterestIds = {};
  final Set<String> selectedCustomInterests = {};

  // ... (keeping other methods same)

  void _addCustomInterest(String name) {
    if (name.trim().isEmpty) return;
    if (!customInterests.contains(name)) {
      setState(() {
        customInterests.add(name);
        selectedCustomInterests.add(name); // Auto-select when added
      });
      customInterestController.clear(); // Clear text field
    }
  }

  // Map API interest names to local assets for display
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchDefaultInterests(context);
    });
  }

  void _toggleApiInterest(String id) {
    setState(() {
      if (selectedInterestIds.contains(id)) {
        selectedInterestIds.remove(id);
      } else {
        selectedInterestIds.add(id);
      }
    });
  }

  void _toggleCustomInterest(String name) {
    setState(() {
      if (selectedCustomInterests.contains(name)) {
        selectedCustomInterests.remove(name);
      } else {
        selectedCustomInterests.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
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
                      OnboardingHeader(
                        currentStep: (provider.isStoryCreation) ? 2 : 3,
                        totalSteps: (provider.isStoryCreation) ? 4 : 5,
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
                      if (provider.isLoadingInterests)
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.teal,
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              // API Interests
                              ...provider.interestsList.map((interest) {
                                final id = interest['id'];
                                final name = interest['name'];
                                return SelectionOption(
                                  label: name,
                                  isSelected: selectedInterestIds.contains(id),
                                  onTap: () => _toggleApiInterest(id),
                                  iconPath: _getIconForInterest(name),
                                );
                              }),

                              // Custom Interests
                              ...customInterests.map((name) {
                                return SelectionOption(
                                  label: name,
                                  isSelected: selectedCustomInterests.contains(
                                    name,
                                  ),
                                  onTap: () => _toggleCustomInterest(name),
                                  // Fallback icon for custom?
                                  iconPath: AppAssets.adventure,
                                );
                              }),

                              // Custom Interest Input
                              Padding(
                                padding: EdgeInsets.only(top: 10.h),
                                child: AppTextField(
                                  controller: customInterestController,
                                  hintText: "Add Custom Interest...",
                                  onSubmit: (val) {
                                    _addCustomInterest(val);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      AppFilledButton(
                        text: "Next",
                        margin: EdgeInsets.only(bottom: 8.h, top: 12.h),
                        backgroundColor: AppColors.primaryColor,

                        onTap: () async {
                          if (selectedInterestIds.isEmpty &&
                              selectedCustomInterests.isEmpty) {
                            AppToast.error(
                              context,
                              "Please select at least one interest",
                            );
                            return;
                          }

                          final success = await provider.saveInterests(
                            context,

                            interestIds: selectedInterestIds.toList(),
                            customInterests: selectedCustomInterests.toList(),
                          );

                          if (success && context.mounted) {
                            context.pushNamed(AppRoutes.topicsScreen.name);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                if (provider.isSaveInterestLoading) FullPageIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }
}
