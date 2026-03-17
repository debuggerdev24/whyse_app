import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/utils/field_validator.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/text_style.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../../core/widgets/onboarding_widgets.dart';

class CustomStoryTopicScreen extends StatelessWidget {
  const CustomStoryTopicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),

          child: Consumer<StoryProvider>(
            builder: (context, provider, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OnboardingHeader(
                  currentStep: 3,
                  totalSteps: 4,
                  onBack: () {
                    context.pop();
                  },
                ),
                AppText(
                  text: "Add Your Favorite Topic",
                  style: AppTextStyles.sfProDisplayBold(
                    height: 1.2,
                    fontSize: 32.sp,
                  ),
                ),
                10.h.verticalSpace,
                AppText(
                  text: "What are you interested to read or learn about?",
                  style: AppTextStyles.sfProDisplayMedium(
                    fontSize: 16.sp,
                    color: AppColors.black.withValues(alpha: 0.8),
                  ),
                ),

                20.h.verticalSpace,
                AppTextField(
                  controller: provider.customTopicCtr,
                  hintText: "I want to learn about...",
                  validator: (value) =>
                      FieldValidators().required(value, "Topic Description"),
                ),
                Spacer(),
                //todo next button
                AppFilledButton(
                  text: "Next",
                  backgroundColor: AppColors.primaryColor,
                  margin: EdgeInsetsGeometry.only(top: 4.3.h),
                  onTap: () async {
                    if (provider.customTopicCtr.text.isEmpty) {
                      AppToast.error(context, "Please add the description");
                      return;
                    }

                    provider.setSelectedReadingDuration = "5 mins";
                    provider.customReadingDurationCtr.clear();
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
          ),
        ),
      ),
    );
  }
}
