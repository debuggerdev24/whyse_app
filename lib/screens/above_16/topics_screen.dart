import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';

import 'package:provider/provider.dart';
import 'package:redstreakapp/providers/auth_provider.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  // Local state for custom topics
  final List<String> customTopics = [];
  final TextEditingController customTopicController = TextEditingController();
  // Store selected IDs (from API) and Custom Strings
  final Set<String> selectedTopicIds = {};
  final Set<String> selectedCustomTopics = {};

  // Map API topic titles to local assets for display
  String _getIconForTopic(String title) {
    String lower = title.toLowerCase();

    // Direct Mappings
    if (lower.contains("space") || lower.contains("planet"))
      return AppAssets.space;
    if (lower.contains("invention") ||
        lower.contains("tech") ||
        lower.contains("science"))
      return AppAssets.inventions;
    if (lower.contains("haunted") ||
        lower.contains("ghost") ||
        lower.contains("horror"))
      return AppAssets.hauntedhouse;
    if (lower.contains("mystery") ||
        lower.contains("detective") ||
        lower.contains("clue"))
      return AppAssets.detativeclue;
    if (lower.contains("wizard") ||
        lower.contains("magic") ||
        lower.contains("fantasy"))
      return AppAssets.wizard;
    if (lower.contains("dragon") ||
        lower.contains("animal") ||
        lower.contains("creature") ||
        lower.contains("nature"))
      return AppAssets.dargon;

    // Looser Mappings for other known categories
    if (lower.contains("comic") || lower.contains("fun"))
      return AppAssets.wizard;
    if (lower.contains("history")) return AppAssets.hauntedhouse;
    if (lower.contains("adventure")) return AppAssets.space;

    // Rotation fallback for any other topics to ensure variety
    List<String> fallbacks = [
      AppAssets.space,
      AppAssets.inventions,
      AppAssets.hauntedhouse,
      AppAssets.detativeclue,
      AppAssets.wizard,
      AppAssets.dargon,
    ];
    // Use hash code to consistently return the same random image for the same title
    return fallbacks[title.hashCode.abs() % fallbacks.length];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchDefaultTopics(context);
    });
  }

  void _toggleApiTopic(String id) {
    setState(() {
      if (selectedTopicIds.contains(id)) {
        selectedTopicIds.remove(id);
      } else {
        selectedTopicIds.add(id);
      }
    });
  }

  void _toggleCustomTopic(String title) {
    setState(() {
      if (selectedCustomTopics.contains(title)) {
        selectedCustomTopics.remove(title);
      } else {
        selectedCustomTopics.add(title);
      }
    });
  }

  void _addCustomTopic(String title) {
    if (title.trim().isEmpty) return;
    if (!customTopics.contains(title)) {
      setState(() {
        customTopics.add(title);
        selectedCustomTopics.add(title); // Auto-select
      });
      customTopicController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final topicsList = authProvider.topicsList;
    final isLoading = authProvider.isLoadingTopics;
    final isSaving = authProvider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      // Fixed bottom button
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 40.h),
        child: AppButton(
          text: "Next",
          backgroundColor: AppColors.yellowcolor,
          isLoading: isSaving,
          onPressed: () async {
            if (selectedTopicIds.isEmpty && selectedCustomTopics.isEmpty) {
              CustomToast.showError(
                context,
                "Please select at least one topic",
              );
              return;
            }

            final success = await authProvider.saveTopics(
              context,
              topicIds: selectedTopicIds.toList(),
              customTopics: selectedCustomTopics.toList(),
            );

            if (success && context.mounted) {
              context.pushNamed(UserAppRoutes.goalsScreen.name);
            }
          },
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingHeader(currentStep: 4, totalSteps: 5),

              AppText(
                text: "Choose Your Favorite Topics",
                style: AppTextStyles.sfProDisplayBold(fontSize: 32.sp),
              ),

              10.h.verticalSpace,

              AppText(
                text:
                    "Here are some topics we think you'll love based on your interests. You can pick the ones that excite you the most!",
                style: AppTextStyles.sfProDisplayMedium(
                  fontSize: 16.sp,
                  color: AppColors.black.withOpacity(0.8),
                ),
              ),

              18.h.verticalSpace,
              // Custom Topic Input
              AppTextField(
                controller: customTopicController,
                hintText: "Add Topic...",
                onFieldSubmitted: (val) => _addCustomTopic(val),
              ),
              37.h.verticalSpace,

              // Loading State
              if (isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.teal),
                  ),
                )
              else
                Expanded(
                  child: GridView(
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20.w,
                      mainAxisSpacing: 25.h,
                      childAspectRatio: 1.4,
                    ),
                    children: [
                      // API Topics
                      ...topicsList.map((topic) {
                        final id = topic['id'];
                        final title = topic['title'];
                        return TopicCard(
                          label: title,
                          assetPath: _getIconForTopic(title),
                          isSelected: selectedTopicIds.contains(id),
                          onTap: () => _toggleApiTopic(id),
                        );
                      }),

                      // Custom Topics
                      ...customTopics.map((title) {
                        return TopicCard(
                          label: title,
                          assetPath: _getIconForTopic(title),
                          isSelected: selectedCustomTopics.contains(title),
                          onTap: () => _toggleCustomTopic(title),
                        );
                      }),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
