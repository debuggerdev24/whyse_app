import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/enums/app_enums.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/utils/de_bouncing.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:toastification/toastification.dart';

import '../../../core/widgets/dropdown_textfiled.dart';
import '../../../models/home/story_models/story_enums.dart';

class StoryReadingGoalScreen extends StatefulWidget {
  const StoryReadingGoalScreen({super.key});

  @override
  State<StoryReadingGoalScreen> createState() => _StoryReadingGoalScreenState();
}

class _StoryReadingGoalScreenState extends State<StoryReadingGoalScreen> {
  @override
  Widget build(BuildContext context) {
    final pr = context.read<StoryProvider>();

    return PopScope(
      canPop: pr.isCreateStoryLoading ? false : true,
      child: AppLayout(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: Consumer<StoryProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      OnboardingHeader(
                        currentStep: 4,
                        totalSteps: 4,
                        onBack: () {
                          context.pop();
                        },
                      ),

                      /// TITLE
                      AppText(
                        text: "Set Your Daily Reading Goal",
                        style: AppTextStyles.bold(height: 1.2, fontSize: 32.sp),
                      ),

                      6.w.verticalSpace,

                      AppText(
                        text:
                            "Choose how much time you want to read \neach day to keep your streak alive and earn rewards.",
                        style: AppTextStyles.medium(
                          fontSize: 16.sp,
                          color: AppColors.black.withValues(alpha: 0.8),
                        ),
                      ),

                      18.w.verticalSpace,

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.black.withValues(alpha: 0.1),
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              provider.readingDurations.length,
                              (index) {
                                final option = provider.readingDurations[index];
                                final isSelected =
                                    provider.selectedReadingDuration == option;
                                return Row(
                                  children: [
                                    _buildOptionButton(
                                      text: option,
                                      isSelected: isSelected,
                                      onTap: (String text) {
                                        provider.setSelectedReadingDuration =
                                            text;
                                      },
                                    ),
                                    if (index !=
                                        provider.readingDurations.length - 1)
                                      Container(
                                        width: 1.w,
                                        height: 22.h,
                                        color: Colors.grey.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      if (provider.selectedReadingDuration.toLowerCase() ==
                          AppEnum.custom.name) ...[
                        20.w.verticalSpace,
                        AppTextField(
                          hintText: "Enter minutes",
                          controller: provider.customReadingDurationCtr,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ],

                      25.w.verticalSpace,
                      CustomDropdownField(
                        label: "Text Type",
                        hint: "Select text type",
                        items: TextType.values.map((e) => e.value).toList(),
                        onChanged: (value) {
                          provider.setSelectedTextType = value!;
                        },
                      ),
                      20.w.verticalSpace,
                      CustomDropdownField(
                        label: "Age Range",
                        hint: "Select age",
                        items: provider.ageRanges,
                        onChanged: (value) {
                          provider.setSelectedAgeRange = value!;
                        },
                      ),
                      20.w.verticalSpace,
                      CustomDropdownField(
                        label: "Language of Learning",
                        hint: "Select language",
                        items: Language.values.map((e) => e.value).toList(),
                        onChanged: (value) {
                          provider.setSelectedLanguage = value!;
                          // setState(() => _selectedLanguage = value!);
                        },
                      ),
                      20.w.verticalSpace,
                      CustomDropdownField(
                        label: "Number of Stories",
                        hint: "Select number of stories",
                        items: ["1", "2", "3", "4", "5"],
                        onChanged: (value) {
                          provider.setNoOfStories = value!;
                        },
                      ),

                      AppFilledButton(
                        margin: EdgeInsets.only(top: 20.h),
                        text: "Generate",

                        backgroundColor: AppColors.orangeColor,
                        onTap: () {
                          deBouncer.run(() {
                            // if (!provider.validateCreateStoryInput(context)) {
                            //   return;
                            // }
                            provider.setGenerateStoryIdeasLoading(true);

                            // Capture HomeProvider before navigating away so
                            // the reference stays valid after this screen is unmounted.
                            final homeProvider =
                                context.read<HomeProvider>();

                            // Dismiss any visible toasts before navigating so
                            // their internal Dismissible widgets don't crash
                            // when the overlay is replaced by the new route.
                            toastification.dismissAll(
                              delayForAnimation: false,
                            );

                            context.goNamed(AppRoutes.homeScreen.name);
                            context.pushNamed(
                              AppRoutes.createdIdeasListScreen.name,
                              extra: const {'preferGeneratedData': true},
                            );
                            provider.createStoryIdeas(
                              onFailed: (error) {
                                Logger.error(error);
                                if (context.mounted) {
                                  AppToast.error(context, error);
                                }
                              },
                              context: context,
                              forceRegenerate:
                                  provider.forceRegenerateTopicId != null,
                              topicId: provider.forceRegenerateTopicId,
                              onSuccess: () {
                                if (context.mounted) {
                                  AppToast.success(
                                    context,
                                    "Story Ideas created successfully.",
                                  );
                                }
                                // Always refresh the home series list regardless
                                // of whether this screen is still mounted.
                                homeProvider.getMyTopics();
                              },
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String text,
    required bool isSelected,
    required Function(String error) onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap.call(text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),

        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: AppText(
          text: text,
          style: AppTextStyles.semibold(
            fontSize: isSelected ? 15.sp : 13.sp,
            color: isSelected
                ? Colors.white
                : AppColors.black.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
