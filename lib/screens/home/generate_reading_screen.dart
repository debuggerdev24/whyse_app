import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/constants/thumpaint.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';

import '../../models/home/story_models/story_enums.dart';

class GenerateReadingScreen extends StatefulWidget {
  const GenerateReadingScreen({super.key});

  @override
  State<GenerateReadingScreen> createState() => _GenerateReadingScreenState();
}

class _GenerateReadingScreenState extends State<GenerateReadingScreen> {
  // Form State Variables
  // String _selectedTextType = "";
  // String _selectedLanguage = "";
  // String _selectedTopic = "";
  // double _duration = 10;
  ReadingLevel _readingLevel = ReadingLevel.CEFR_A2;
  // String _selectedAge = "";
  // String _selectedAgSchedule = 'Today';
  bool includeComprehension = true;
  bool includeVocabulary = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchDefaultTopics(context);
    });
  }

  IconData _getIconForSkill(ReadingSkill skill) {
    switch (skill) {
      case ReadingSkill.PHONICS:
        return Icons.text_fields;
      case ReadingSkill.VOCABULARY:
        return Icons.sort_by_alpha;
      case ReadingSkill.COMPREHENSION:
        return Icons.subject;
      case ReadingSkill.GRAMMAR:
        return Icons.rule;
      default:
        return Icons.school;
    }
  }

  String _getIconForTopic(String title) {
    String lower = title.toLowerCase();

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
    List<String> fallbacks = [
      AppAssets.space,
      AppAssets.inventions,
      AppAssets.hauntedhouse,
      AppAssets.detativeclue,
      AppAssets.wizard,
      AppAssets.dargon,
    ];
    return fallbacks[title.hashCode.abs() % fallbacks.length];
  }

  final String _selectedSkill = "";

  @override
  Widget build(BuildContext context) {
    return SizedBox();
    //   Scaffold(
    //   backgroundColor: Colors.white,
    //
    //   body: SafeArea(
    //     child: Column(
    //       children: [
    //         Padding(
    //           padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 10.h),
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               GestureDetector(
    //                 onTap: () {
    //                   context.pop();
    //                 },
    //                 child: SvgIcon(AppAssets.backButton, size: 13.sp),
    //               ),
    //               Row(
    //                 children: [
    //                   SvgIcon(AppAssets.notification, size: 24.w),
    //                   12.w.horizontalSpace,
    //                   CircleAvatar(
    //                     radius: 18.w,
    //                     backgroundImage: AssetImage(AppAssets.profile),
    //                   ),
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //         Expanded(
    //           flex: 2,
    //           child: SingleChildScrollView(
    //             padding: EdgeInsets.symmetric(horizontal: 27.w),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 AppText(
    //                   text: "Customize with AI",
    //                   style: AppTextStyles.sfProDisplayBold(fontSize: 20.sp),
    //                 ),
    //                 4.h.verticalSpace,
    //                 AppText(
    //                   text:
    //                       "Create a reading task tailored just for you with the help of AI",
    //                   style: AppTextStyles.sfProDisplayMedium(
    //                     fontSize: 12.sp,
    //                     color: AppColors.black.withValues(alpha: 0.6),
    //                   ),
    //                 ),
    //                 17.h.verticalSpace,
    //                 AppText(
    //                   text: "What do you want to read about?",
    //                   style: AppTextStyles.textStyle16Bold,
    //                 ),
    //                 12.h.verticalSpace,
    //                 Consumer<AuthProvider>(
    //                   builder: (context, authProvider, _) {
    //                     if (authProvider.isLoadingTopics) {
    //                       return SizedBox(
    //                         height: 100.h,
    //                         child: ListView.separated(
    //                           scrollDirection: Axis.horizontal,
    //                           itemCount: 3,
    //                           separatorBuilder: (context, index) =>
    //                               12.w.horizontalSpace,
    //                           itemBuilder: (context, index) {
    //                             return ShimmerLoading(
    //                               width: 140.w,
    //                               height: 100.h,
    //                               borderRadius: 16,
    //                             );
    //                           },
    //                         ),
    //                       );
    //                     }
    //                     final topics = authProvider.topicsList;
    //                     if (topics.isEmpty) {
    //                       return SizedBox();
    //                     }
    //
    //                     return SizedBox(
    //                       height: 100.h,
    //                       child: ListView.separated(
    //                         clipBehavior: Clip.none,
    //
    //                         scrollDirection: Axis.horizontal,
    //                         itemCount: topics.length,
    //                         separatorBuilder: (context, index) =>
    //                             10.w.horizontalSpace,
    //                         itemBuilder: (context, index) {
    //                           final topic = topics[index];
    //                           final title = topic['title'] ?? 'Unknown';
    //                           // Use helper to get image
    //                           final image = _getIconForTopic(title);
    //                           final isSelected = _selectedTopic == title;
    //
    //                           return SizedBox(
    //                             width: 164.w,
    //                             child: TopicCard(
    //                               label: title,
    //                               assetPath: image,
    //                               isSelected: false,
    //                               onTap: () {},
    //                             ),
    //                           );
    //                         },
    //                       ),
    //                     );
    //                   },
    //                 ),
    //                 24.h.verticalSpace,
    //
    //                 /// Dropdowns
    //                 CustomDropdownField(
    //                   label: "Text Type",
    //                   hint: "Select text type",
    //                   items: TextType.values.map((e) => e.value).toList(),
    //                   onChanged: (value) {
    //                     setState(() => _selectedTextType = value!);
    //                   },
    //                 ),
    //                 20.h.verticalSpace,
    //
    //                 CustomDropdownField(
    //                   label: "Language of Learning",
    //                   hint: "Select language",
    //                   items: Language.values.map((e) => e.value).toList(),
    //                   onChanged: (value) {
    //                     setState(() => _selectedLanguage = value!);
    //                   },
    //                 ),
    //                 20.h.verticalSpace,
    //
    //                 Consumer<AuthProvider>(
    //                   builder: (context, authProvider, _) {
    //                     final topicNames = authProvider.topicsList
    //                         .map((e) => e['title'].toString())
    //                         .toList();
    //
    //                     return CustomDropdownField(
    //                       label: "Reading Topic",
    //                       hint: "Select topic",
    //                       items: topicNames.isNotEmpty
    //                           ? topicNames
    //                           : ["Animals", "Space", "Technology"],
    //                       onChanged: (value) {
    //                         setState(() => _selectedTopic = value!);
    //                       },
    //                     );
    //                   },
    //                 ),
    //
    //                 20.h.verticalSpace,
    //
    //                 // Lesson Duration
    //                 Row(
    //                   children: [
    //                     Container(
    //                       width: 8.w,
    //                       height: 8.w,
    //                       decoration: BoxDecoration(
    //                         color: AppColors.yellowColor,
    //                         shape: BoxShape.circle,
    //                       ),
    //                     ),
    //                     8.w.horizontalSpace,
    //                     AppText(
    //                       text: "Lesson Duration",
    //                       style: AppTextStyles.textStyle16Semibold,
    //                     ),
    //                   ],
    //                 ),
    //
    //                 Divider(
    //                   thickness: 0,
    //                   color: AppColors.black.withValues(alpha: 0.1),
    //                 ),
    //                 10.h.verticalSpace,
    //                 LessonDurationContainer(
    //                   value: _duration,
    //                   onChanged: (val) => setState(() => _duration = val),
    //                 ),
    //
    //                 24.h.verticalSpace,
    //                 Row(
    //                   children: [
    //                     Container(
    //                       width: 8.w,
    //                       height: 8.w,
    //                       decoration: BoxDecoration(
    //                         color: AppColors.yellowColor,
    //                         shape: BoxShape.circle,
    //                       ),
    //                     ),
    //                     8.w.horizontalSpace,
    //                     AppText(
    //                       text: "Reading Skills Focus",
    //                       style: AppTextStyles.textStyle16Semibold,
    //                     ),
    //                   ],
    //                 ),
    //                 Divider(
    //                   thickness: 0,
    //                   color: AppColors.black.withValues(alpha: 0.1),
    //                 ),
    //                 10.h.verticalSpace,
    //                 Wrap(
    //                   spacing: 8.w,
    //                   runSpacing: 8.h,
    //                   children: ReadingSkill.values.map((skill) {
    //                     return ReadingSkillButton(
    //                       title: skill.value,
    //                       icon: _getIconForSkill(skill),
    //                       isSelected: _selectedSkill == skill.value,
    //                       onTap: () =>
    //                           setState(() => _selectedSkill = skill.value),
    //                     );
    //                   }).toList(),
    //                 ),
    //
    //                 24.h.verticalSpace,
    //                 Row(
    //                   children: [
    //                     Container(
    //                       width: 8.w,
    //                       height: 8.w,
    //                       decoration: BoxDecoration(
    //                         color: AppColors.yellowColor,
    //                         shape: BoxShape.circle,
    //                       ),
    //                     ),
    //                     8.w.horizontalSpace,
    //                     AppText(
    //                       text: "Reading Level",
    //                       style: AppTextStyles.textStyle16Semibold,
    //                     ),
    //                   ],
    //                 ),
    //                 Divider(
    //                   thickness: 0,
    //                   color: AppColors.black.withValues(alpha: 0.1),
    //                 ),
    //                 10.h.verticalSpace,
    //
    //                 _ReadingLevelCard(
    //                   readingLevel: _readingLevel,
    //                   onTap: () {
    //                     _showReadingLevelPicker(context);
    //                   },
    //                 ),
    //
    //                 24.h.verticalSpace,
    //
    //                 /// Age
    //                 CustomDropdownField(
    //                   label: "Age",
    //                   hint: "Select age",
    //                   items: const ["10 Years", "12 Years", "14 Years"],
    //                   onChanged: (value) {
    //                     setState(() => _selectedAge = value!);
    //                   },
    //                 ),
    //
    //                 24.h.verticalSpace,
    //                 CustomDropdownField(
    //                   label: "Schedule Reading",
    //                   hint: "Today / Daily / Weekly",
    //                   items: const ["Today", "Daily", "Weekly"],
    //                   onChanged: (value) {
    //                     setState(() => _selectedAgSchedule = value!);
    //                   },
    //                 ),
    //                 24.h.verticalSpace,
    //
    //                 Row(
    //                   children: [
    //                     Container(
    //                       width: 8.w,
    //                       height: 8.w,
    //                       decoration: BoxDecoration(
    //                         color: AppColors.yellowColor,
    //                         shape: BoxShape.circle,
    //                       ),
    //                     ),
    //                     8.w.horizontalSpace,
    //                     AppText(
    //                       text: "Lesson Content Instructions",
    //                       style: AppTextStyles.textStyle16Semibold,
    //                     ),
    //                   ],
    //                 ),
    //                 Divider(
    //                   thickness: 0,
    //                   color: AppColors.black.withValues(alpha: 0.1),
    //                 ),
    //                 10.h.verticalSpace,
    //
    //                 Container(
    //                   padding: EdgeInsets.all(16.w),
    //                   decoration: BoxDecoration(
    //                     color: Colors.white,
    //                     borderRadius: BorderRadius.circular(16.r),
    //                     border: Border.all(
    //                       color: AppColors.black.withValues(alpha: 0.1),
    //                     ),
    //                   ),
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       /// Text Field
    //                       AppTextField(
    //                         controller: _instructionsController,
    //                         maxLines: 4,
    //                         hintText:
    //                             "Describe the reading you want to create!",
    //                       ),
    //
    //                       16.h.verticalSpace,
    //
    //                       /// Include Comprehension
    //                       _InstructionCheckBox(
    //                         title: "Include Comprehension questions",
    //                         value: includeComprehension,
    //                         onChanged: (val) {
    //                           setState(() => includeComprehension = val);
    //                         },
    //                       ),
    //
    //                       10.h.verticalSpace,
    //
    //                       /// Include Vocabulary
    //                       _InstructionCheckBox(
    //                         title: "Include Vocabulary Exercises",
    //                         value: includeVocabulary,
    //                         onChanged: (val) {
    //                           setState(() => includeVocabulary = val);
    //                         },
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //                 32.h.verticalSpace,
    //
    //                 Consumer<AuthProvider>(
    //                   builder: (context, authProvider, _) {
    //                     return AppFilledButton(
    //                       fixedSize: Size(348.w, 42.h),
    //                       isLoading: authProvider.isLoadingStory,
    //                       onTap: () async {
    //                         if (_selectedTopic.isEmpty) {
    //                           AppToast.error(
    //                             context,
    //                             "Please select a reading topic",
    //                           );
    //                           return;
    //                         }
    //                         if (_selectedTextType.isEmpty) {
    //                           AppToast.error(
    //                             context,
    //                             "Please select a text type",
    //                           );
    //                           return;
    //                         }
    //                         if (_selectedLanguage.isEmpty) {
    //                           AppToast.error(
    //                             context,
    //                             "Please select a language",
    //                           );
    //                           return;
    //                         }
    //                         if (_selectedTopic.isEmpty) {
    //                           AppToast.error(
    //                             context,
    //                             "Please select a reading topic",
    //                           );
    //                           return;
    //                         }
    //                         if (_selectedSkill.isEmpty) {
    //                           AppToast.error(
    //                             context,
    //                             "Please select a reading skill focus",
    //                           );
    //                           return;
    //                         }
    //                         if (_selectedAge.isEmpty) {
    //                           AppToast.error(context, "Please select an age");
    //                           return;
    //                         }
    //                         context.pushNamed(
    //                           AppRoutes.interestsScreen.name,
    //                           // extra: story,
    //                         );
    //
    //                         // final request = GenerateStoryRequest(
    //                         //   textType: _selectedTextType,
    //                         //   language: _selectedLanguage,
    //                         //   readingTopic: _selectedTopic,
    //                         //   lessonDuration: _duration.toInt().toString(),
    //                         //   readingSkillFocus: _selectedSkill == 'No Focus'
    //                         //       ? 'Comprehension'
    //                         //       : _selectedSkill,
    //                         //   readingLevel: _readingLevel.value,
    //                         //   age:
    //                         //       int.tryParse(_selectedAge.split(' ')[0]) ??
    //                         //       10,
    //                         //   lessonContentInstructions: _instructionsController
    //                         //       .text
    //                         //       .trim(),
    //                         // );
    //
    //                         // final story = await authProvider.generateStory(
    //                         //   context,
    //                         //   request: request,
    //                         // );
    //                         // log("request========>${request.toJson()}");
    //                         // if (story != null) {
    //                         //  context.pushNamed(
    //                         //                               UserAppRoutes.readingScreen.name,
    //                         //                               // extra: story,
    //                         //                             );
    //
    //                         // }
    //                       },
    //                       text: "Generate Reading Lesson",
    //                       backgroundColor: AppColors.yellowColor,
    //                     );
    //                   },
    //                 ),
    //
    //                 40.h.verticalSpace,
    //               ],
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  void _showReadingLevelPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: "Select Reading Level",
                style: AppTextStyles.textStyle16Bold,
              ),
              16.h.verticalSpace,
              ...ReadingLevel.values.map((level) {
                return ListTile(
                  title: Text(level.value),
                  subtitle: Text(
                    level.description,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  onTap: () {
                    setState(() {
                      _readingLevel = level;
                    });
                    Navigator.pop(context);
                  },
                  trailing: _readingLevel == level
                      ? Icon(Icons.check, color: AppColors.teal)
                      : null,
                );
              }),
              20.h.verticalSpace,
            ],
          ),
        );
      },
    );
  }
}

class LessonDurationContainer extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const LessonDurationContainer({
    super.key,
    required this.value,
    required this.onChanged,
  });

  Color get _activeColor => AppColors.teal.withValues(alpha: 0.8);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.black.withValues(alpha: 0.1),
          width: 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 8.h,
                activeTrackColor: _activeColor,
                inactiveTrackColor: Color(0xFFF2F2F2),
                thumbShape: CircleThumbShape(thumbRadius: 10.r),

                thumbColor: AppColors.black,
                overlayColor: Colors.white,
              ),
              child: Slider(
                min: 5,
                max: 20,
                value: value,
                onChanged: onChanged,
              ),
            ),

            16.h.verticalSpace,

            /// Time labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _time("5 min", value == 5),
                _time("10 min", value == 10),
                _time("20 min", value == 20),
              ],
            ),

            18.h.verticalSpace,

            /// Selected info
            Container(
              padding: EdgeInsets.symmetric(vertical: 17.h),
              decoration: BoxDecoration(
                color: Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, size: 18.sp, color: _activeColor),
                  6.w.horizontalSpace,
                  AppText(
                    text: "${value.toInt()} minutes selected",
                    style: AppTextStyles.sfProDisplaySemibold(
                      fontSize: 14.sp,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _time(String text, bool active) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16.sp,
          color: active ? _activeColor : AppColors.black,
        ),
        1.w.horizontalSpace,
        AppText(
          text: text,
          style: AppTextStyles.sfProDisplaySemibold(
            fontSize: 14.sp,
            color: active ? _activeColor : AppColors.black,
          ),
        ),
      ],
    );
  }
}

class _InstructionCheckBox extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _InstructionCheckBox({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: value ? AppColors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.black),
            ),
            child: value
                ? Icon(Icons.check, size: 16.w, color: Colors.white)
                : null,
          ),
          12.w.horizontalSpace,
          Expanded(
            child: AppText(
              text: title,
              style: AppTextStyles.sfProDisplaySemibold(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingLevelCard extends StatelessWidget {
  final ReadingLevel readingLevel;
  final VoidCallback onTap;

  const _ReadingLevelCard({required this.readingLevel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.black.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                /// Icon
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                12.w.horizontalSpace,

                /// Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(
                            text: readingLevel.value,
                            style: AppTextStyles.textStyle16Bold,
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.black,
                          ),
                        ],
                      ),
                      2.h.verticalSpace,
                      AppText(
                        text: readingLevel.description,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            16.h.verticalSpace,

            /// Progress Bar
            Stack(
              children: [
                Container(
                  height: 6.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: readingLevel.difficulty,
                  child: Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ],
            ),
            8.h.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: "Beginner",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppText(
                  text: "Advance",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
