import 'dart:io';

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
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:shimmer/shimmer.dart';

class StoryTopicsScreen extends StatefulWidget {
  const StoryTopicsScreen({super.key});

  @override
  State<StoryTopicsScreen> createState() => _StoryTopicsScreenState();
}

class _StoryTopicsScreenState extends State<StoryTopicsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final story = context.read<StoryProvider>();
      if (story.topicsList.isEmpty && !story.isGetTopicsLoading) {
        story.getStoryTopics(onFailed: (_) {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

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
        bottom: (Platform.isIOS) ? false : true,
        child: Consumer<StoryProvider>(
          builder: (context, storyProvider, child) {
            final searchEmpty = storyProvider.searchTopicCtr.text
                .trim()
                .isEmpty;
            final showDefaultTopics =
                searchEmpty && !storyProvider.isGetSearchedTopicsLoading;

            return Padding(
              padding: EdgeInsets.fromLTRB(24.w, 10.w, 24.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      storyProvider.toggleApiTopic("", "");
                      context.pushNamed(AppRoutes.customTopicScreen.name);
                    },
                  ),
                  AppText(
                    text: "Choose Your Favorite Topics",
                    style: AppTextStyles.bold(height: 1.2, fontSize: 32.sp),
                  ),
                  10.w.verticalSpace,
                  AppText(
                    text:
                        "Here are some topics we think you'll love based on your interests. You can pick the ones that excite you the most!",
                    style: AppTextStyles.medium(
                      fontSize: 16.sp,
                      color: AppColors.black.withValues(alpha: 0.8),
                    ),
                  ),
                  18.w.verticalSpace,
                  AppTextField(
                    controller: storyProvider.searchTopicCtr,
                    hintText: "Search Topic...",
                    onChanged: (value) {
                      deBouncer.run(() {
                        storyProvider.getSearchedStoryTopics(
                          onFailed: (error) {
                            AppToast.error(context, error);
                          },
                        );
                      });
                    },
                  ),
                  18.w.verticalSpace,
                  if (showDefaultTopics) ...[
                    Expanded(
                      child: storyProvider.isGetTopicsLoading
                          ? Center(child: ApiLoadingIndicator())
                          : storyProvider.topicsList.isEmpty
                          ? Padding(
                              padding: EdgeInsets.only(top: 50.h),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text("No topics available"),
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.only(
                                left: 10.w,
                                right: 10.w,
                                bottom: 20.w,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 20.w,
                                    mainAxisSpacing: 25.h,
                                    childAspectRatio: 1.4,
                                  ),
                              itemCount: storyProvider.topicsList.length,
                              itemBuilder: (context, index) {
                                final topic = storyProvider.topicsList[index];
                                final title = topic.title;
                                final id = topic.id;
                                final thumb =
                                    topic.thumbnailUrl.trim().isNotEmpty
                                    ? topic.thumbnailUrl
                                    : null;
                                return TopicCard(
                                  label: title,
                                  imagePath: thumb ?? _getIconForTopic(title),
                                  isSelected:
                                      storyProvider.selectedTopicId == id,
                                  onTap: () =>
                                      storyProvider.toggleApiTopic(id, title),
                                );
                              },
                            ),
                    ),
                  ] else if (storyProvider.isGetSearchedTopicsLoading)
                    Expanded(child: _shimmer())
                  else if (storyProvider.searchedTopicsList.isNotEmpty)
                    Expanded(
                      child: GridView(
                        padding: EdgeInsets.only(
                          left: 10.w,
                          right: 10.w,
                          bottom: 20.w,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20.w,
                          mainAxisSpacing: 25.h,
                          childAspectRatio: 1.4,
                        ),
                        children: [
                          ...storyProvider.searchedTopicsList.map((topic) {
                            final title = topic.title;
                            return TopicCard(
                              label: title,
                              imagePath: _getIconForTopic(title),
                              isSelected:
                                  storyProvider.selectedTopicId == topic.id,
                              onTap: () =>
                                  storyProvider.toggleApiTopic(topic.id, title),
                            );
                          }),
                        ],
                      ),
                    )
                  else if (storyProvider.searchedTopicsList.isEmpty &&
                      storyProvider.searchTopicCtr.text.trim().isNotEmpty)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50.h),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text("No Topics Found!"),
                        ),
                      ),
                    ),

                  AppFilledButton(
                    text: "Next",
                    backgroundColor: AppColors.orangeColor,
                    margin: EdgeInsets.only(top: 4.3.w, bottom: 18.w),
                    onTap: () async {
                      if (storyProvider.selectedTopicId.isEmpty) {
                        AppToast.error(
                          context,
                          "Please select at least one topic",
                        );
                        return;
                      }
                      storyProvider.setSelectedReadingDuration = "5 mins";
                      context.pushNamed(AppRoutes.storyReadingGoalScreen.name);
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
