import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/utils/de_bouncing.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:shimmer/shimmer.dart';

class StoryTopicsScreen extends StatefulWidget {
  const StoryTopicsScreen({super.key});

  @override
  State<StoryTopicsScreen> createState() => _StoryTopicsScreenState();
}

class _StoryTopicsScreenState extends State<StoryTopicsScreen> {
  String _getIconForTopic(String title) {
    String lower = title.toLowerCase();

    // Direct Mappings
    if (lower.contains("space") || lower.contains("planet")) {
      return AppAssets.space;
    }
    if (lower.contains("invention") ||
        lower.contains("tech") ||
        lower.contains("science")) {
      return AppAssets.inventions;
    }
    if (lower.contains("haunted") ||
        lower.contains("ghost") ||
        lower.contains("horror")) {
      return AppAssets.hauntedhouse;
    }
    if (lower.contains("mystery") ||
        lower.contains("detective") ||
        lower.contains("clue")) {
      return AppAssets.detativeclue;
    }
    if (lower.contains("wizard") ||
        lower.contains("magic") ||
        lower.contains("fantasy")) {
      return AppAssets.wizard;
    }
    if (lower.contains("dragon") ||
        lower.contains("animal") ||
        lower.contains("creature") ||
        lower.contains("nature")) {
      return AppAssets.dargon;
    }

    // Looser Mappings for other known categories
    if (lower.contains("comic") || lower.contains("fun")) {
      return AppAssets.wizard;
    }
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
  Widget build(BuildContext context) {
    return AppLayout(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Consumer<StoryProvider>(
          builder: (context, provider, child) {
            if (provider.isGetTopicsLoading) {
              return Center(child: ApiLoadingIndicator());
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(24.w, 10.w, 24.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //todo progress step
                  OnboardingHeader(
                    currentStep: 3,
                    totalSteps: 4,
                    onBack: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed(AppRoutes.interestsScreen.name);
                      }
                    },
                    onSkip: () {
                      provider.toggleApiTopic("");
                      context.pushNamed(AppRoutes.customTopicScreen.name);
                    },
                  ),
                  AppText(
                    text: "Choose Your Favorite Topics",
                    style: AppTextStyles.sfProDisplayBold(
                      height: 1.2,
                      fontSize: 32.sp,
                    ),
                  ),
                  10.h.verticalSpace,
                  AppText(
                    text:
                        "Here are some topics we think you'll love based on your interests. You can pick the ones that excite you the most!",
                    style: AppTextStyles.sfProDisplayMedium(
                      fontSize: 16.sp,
                      color: AppColors.black.withValues(alpha: 0.8),
                    ),
                  ),

                  //todo Custom Topic Input
                  18.h.verticalSpace,
                  AppTextField(
                    controller: provider.searchTopicCtr,
                    hintText: "Search Topic...",
                    onChanged: (value) {
                      deBouncer.run(() {
                        provider.getSearchedStoryTopics(
                          onFailed: (error) {
                            AppToast.error(context, error);
                          },
                        );
                      });
                    },
                  ),
                  18.h.verticalSpace,
                  if (provider.searchTopicCtr.text.trim().isEmpty &&
                      !provider.isGetSearchedTopicsLoading)
                    Expanded(
                      child: (provider.isGetTopicsLoading)
                          ? Center(child: ApiLoadingIndicator())
                          : GridView(
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 20.w,
                                    mainAxisSpacing: 25.h,
                                    childAspectRatio: 1.4,
                                  ),
                              children: [
                                //todo  API Topics
                                ...provider.topicsList.map((topic) {
                                  final id = topic.id;
                                  final title = topic.title;
                                  return TopicCard(
                                    label: title,
                                    assetPath: _getIconForTopic(title),
                                    isSelected: provider.selectedTopicId == id,
                                    onTap: () => provider.toggleApiTopic(id),
                                  );
                                }),
                              ],
                            ),
                    )
                  else if (provider.isGetSearchedTopicsLoading)
                    Expanded(child: _shimmer())
                  else if (provider.searchedTopicsList.isNotEmpty)
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
                          //todo  API Topics
                          ...provider.searchedTopicsList.map((topic) {
                            final id = topic.id;
                            final title = topic.title;
                            return TopicCard(
                              label: title,
                              assetPath: _getIconForTopic(title),
                              isSelected: provider.selectedTopicId == id,
                              onTap: () => provider.toggleApiTopic(id),
                            );
                          }),

                        ],
                      ),
                    )
                  else if (provider.searchedTopicsList.isEmpty &&
                      provider.searchTopicCtr.text.trim().isNotEmpty)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsGeometry.only(top: 50.h),
                        child: Align(
                          alignment: AlignmentGeometry.topCenter,
                          child: Text("No Topics Found!"),
                        ),
                      ),
                    ),

                  //todo next button

                  AppFilledButton(
                    text: "Next",
                    backgroundColor: AppColors.primaryColor,
                    margin: EdgeInsetsGeometry.only(top: 4.3.w,bottom: 18.w),
                    onTap: () async {
                      if (provider.selectedTopicId.isEmpty) {
                        AppToast.error(
                          context,
                          "Please select at least one topic",
                        );
                        return;
                      }
                      provider.setSelectedReadingDuration = "5 mins";
context.pushNamed(AppRoutes.storyReadingGoalScreen.name);
                      // final success = await provider.saveTopics(
                      //   context,
                      //   topicIds: selectedTopicIds.toList(),
                      //   customTopics: selectedCustomTopics.toList(),
                      // );
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

  Widget _shimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20.w,
          mainAxisSpacing: 25.h,
          childAspectRatio: 1.4,
        ),
        itemCount: 6, // ✅ 6 shimmer items
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          );
        },
      ),
    );
  }
}
