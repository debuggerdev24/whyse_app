import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/enums/app_enums.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/utils/de_bouncing.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';

import '../../../core/widgets/dropdown_textfiled.dart';
import '../../../models/home/story_models/story_enums.dart';

class StoryReadingGoalScreen extends StatefulWidget {
  const StoryReadingGoalScreen({super.key});

  @override
  State<StoryReadingGoalScreen> createState() => _StoryReadingGoalScreenState();
}

class _StoryReadingGoalScreenState extends State<StoryReadingGoalScreen> {
  final List<String> options = ['5 mins', '10 mins', '20 mins', 'Custom'];

  @override
  Widget build(BuildContext context) {
    final pr = context.read<StoryProvider>();
    return PopScope(
      canPop: pr.isCreateStoryImageLoading || pr.isCreateStoryLoading
          ? false
          : true,
      child: AppLayout(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Consumer<StoryProvider>(
            builder: (context, provider, child) => Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
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
                        style: AppTextStyles.sfProDisplayBold(fontSize: 32.sp),
                      ),

                      8.h.verticalSpace,

                      AppText(
                        text:
                            "Choose how much time you want to read \neach day to keep your streak alive and earn rewards.",
                        style: AppTextStyles.sfProDisplayMedium(
                          fontSize: 16.sp,
                          color: AppColors.black.withValues(alpha: 0.8),
                        ),
                      ),

                      18.h.verticalSpace,

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.black.withValues(alpha: 0.1),
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(options.length, (index) {
                            final option = options[index];
                            final isSelected =
                                provider.selectedReadingDuration == option;
                            return Row(
                              children: [
                                _buildOptionButton(
                                  text: option,
                                  isSelected: isSelected,
                                  onTap: (String text) {
                                    provider.setSelectedReadingDuration = text;
                                  },
                                ),
                                if (index != options.length - 1)
                                  Container(
                                    width: 1.w,
                                    height: 22.h,
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                              ],
                            );
                          }),
                        ),
                      ),

                      if (provider.selectedReadingDuration.toLowerCase() ==
                          AppEnum.custom.name) ...[
                        20.h.verticalSpace,
                        AppTextField(
                          hintText: "Enter minutes",
                          controller: provider.customReadingDurationCtr,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ],

                      25.h.verticalSpace,
                      CustomDropdownField(
                        label: "Text Type",
                        hint: "Select text type",
                        items: TextType.values.map((e) => e.value).toList(),
                        onChanged: (value) {
                          provider.setSelectedTextType = value!;
                          // setState(() => _selectedTextType = value!);
                        },
                      ),
                      20.h.verticalSpace,
                      CustomDropdownField(
                        label: "Age Range",
                        hint: "Select age",
                        items: const ["6-8", "9-11", "12-14", "15-17", "18+"],
                        onChanged: (value) {
                          provider.setSelectedAgeRange = value!;

                          // setState(() => _selectedAge = value!);
                        },
                      ),
                      20.h.verticalSpace,

                      CustomDropdownField(
                        label: "Language of Learning",
                        hint: "Select language",
                        items: Language.values.map((e) => e.value).toList(),
                        onChanged: (value) {
                          provider.setSelectedLanguage = value!;
                          // setState(() => _selectedLanguage = value!);
                        },
                      ),
                      Spacer(),

                      AppFilledButton(
                        text: "Create Story",
                        backgroundColor: AppColors.yellowColor,
                        onTap: () async {
                          deBouncer.run(() {
                            Future.wait([
                              //todo create story image
                              provider.createStoryImage(
                                onSuccess: () {
                                  AppToast.success(
                                    context,
                                    "Image Created Successfully.",
                                  );
                                },
                                onFailed: (error) {
                                  AppToast.error(context, error);
                                },
                              ),
                              //todo create story
                              provider.createStory(
                                onStarted: () {
                                  Future.delayed(Duration(seconds: 2), () {
                                    AppToast.info(
                                      context: context,
                                      message: "It can take few seconds",
                                      durationSecond: 5,
                                    );
                                  });
                                },
                                onFailed: (error) {
                                  Logger.error(error);
                                  AppToast.error(context, error);
                                },
                                onSuccess: () {
                                  AppToast.success(
                                    context,
                                    "Story Created Successfully.",
                                  );
                                },
                                context: context,
                              ),
                            ]);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (provider.isCreateStoryLoading) FullPageIndicator(),
              ],
            ),
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
          style: AppTextStyles.sfProDisplaySemibold(
            fontSize: isSelected ? 16.sp : 14.sp,
            color: isSelected
                ? Colors.white
                : AppColors.black.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
