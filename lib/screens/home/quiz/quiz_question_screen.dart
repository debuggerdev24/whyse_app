import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';

import '../../../models/home/story_models/story_model.dart';
import '../../../providers/home/quiz_provider.dart';
class QuizQuestionScreen extends StatefulWidget {
  final List<StoryQuiz>? quizzes;
  final String? storyTitle;
  final String? storyImageUrl;

  const QuizQuestionScreen({
    super.key,
    this.quizzes,
    this.storyTitle,
    this.storyImageUrl,
  });

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

// Dummy quiz data used when no real quizzes are provided
List<StoryQuiz> _dummyQuizzes() => [
      StoryQuiz(
        question: "Where did dinosaurs live?",
        options: [
          "Only in forests",
          "Forests, swamps, and deserts",
          "Only in deserts",
          "In cities",
        ],
        answer: "Forests, swamps, and deserts",
        correctAnswer: 1,
        questionType: "multiple_choice",
      ),
      StoryQuiz(
        question: "What did some dinosaurs eat?",
        options: ["Only meat", "Only plants", "Plants or meat", "Only fish"],
        answer: "Plants or meat",
        correctAnswer: 2,
        questionType: "multiple_choice",
      ),
      StoryQuiz(
        question: "What do scientists study to learn about dinosaurs?",
        options: [
          "Their fossils and bones",
          "Their pictures",
          "Their houses",
          "Their clothes",
        ],
        answer: "Their fossils and bones",
        correctAnswer: 0,
        questionType: "multiple_choice",
      ),
    ];

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizzes = (widget.quizzes == null || widget.quizzes!.isEmpty)
          ? _dummyQuizzes()
          : widget.quizzes!;
      context.read<QuizProvider>().initQuiz(quizzes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quiz, _) {
        if (quiz.questions.isEmpty) {
          return AppLayout(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.teal,
              ),
            ),
          );
        }

        final currentQuestion = quiz.questions[quiz.currentQuestionIndex];
        final options = currentQuestion['options'] as List<String>;
        final correctIndex = currentQuestion['correctIndex'] as int;

        return AppLayout(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 27.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.w.verticalSpace,

                  /// Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            showLeaveQuizConfirmation(context: context),
                        child: SvgIcon(
                          AppAssets.disable,
                          color: Colors.black,
                          size: 30.sp,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Row(
                            children: List.generate(quiz.questions.length, (
                              index,
                            ) {
                              Color color;
                              if (index < quiz.currentQuestionIndex) {
                                color = AppColors.orangeColor;
                              } else if (index == quiz.currentQuestionIndex) {
                                color = AppColors.orangeColor;
                              } else {
                                color = Colors.grey.withValues(alpha: 0.2);
                              }

                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),

                  19.w.verticalSpace,

                  /// Question
                  AppText(
                    text: currentQuestion['question'],
                    style: AppTextStyles.bold(
                      fontSize: 32.sp,
                      color: AppColors.black,
                    ).copyWith(height: 1.2),
                  ),

                  31.w.verticalSpace,

                  /// Options
                  ...List.generate(
                    options.length,
                    (index) => OptionCard(
                      text: options[index],
                      isSelected: quiz.selectedOptionIndex == index,
                      isCorrect: index == correctIndex,
                      isChecked: quiz.isChecked,
                      onTap: !quiz.isChecked
                          ? () => quiz.selectOption(index)
                          : null,
                    ),
                  ),

                  Spacer(),

                  Center(
                    child: AppText(
                      text:
                          "${quiz.currentQuestionIndex + 1} / ${quiz.questions.length}",
                      style: AppTextStyles.regular(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  16.w.verticalSpace,

                  /// Button
                  quiz.isChecked
                      ? AppFilledButton(
                          text: "Continue",
                          onTap: () {
                            if (quiz.currentQuestionIndex <
                                quiz.questions.length - 1) {
                              quiz.continueQuiz();
                            } else {
                              context.goNamed(
                                AppRoutes.quizCompletedScreen.name,
                                extra: {
                                  'score': quiz.score,
                                  'total': quiz.questions.length,
                                  'storyTitle': widget.storyTitle,
                                  'storyImageUrl': widget.storyImageUrl,
                                },
                              );
                            }
                          },
                          backgroundColor: Color(0xFF00796B),
                          fixedSize: Size(348.w, 42.h),
                        )
                      : AppFilledButton(
                          text: "Check",
                          onTap: quiz.selectedOptionIndex != null
                              ? quiz.checkAnswer
                              : () {},
                          backgroundColor: quiz.selectedOptionIndex != null
                              ? AppColors.black
                              : Colors.grey,
                          fixedSize: Size(348.w, 42.h),
                        ),

                  24.w.verticalSpace,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void showLeaveQuizConfirmation({required BuildContext context}) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return ZoomIn(
        child: AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          title: Text(
            "Are you sure you want to quit this quizzes?",
            style: AppTextStyles.textStyle20Regular,
          ),
          actions: [
            myActionButtonTheme(
              onPressed: () {
                dialogContext.pop();
              },
              title: "Cancel",
            ),
            myActionButtonTheme(
              onPressed: () {
                dialogContext.pop();
                // final prov = context.read<StoryProvider>();
                // WidgetsBinding.instance.addPostFrameCallback((_) {
                // prov.clareStoryData();
                if (context.mounted) {
                  context.pop();
                }
                // });
              },
              title: "Yes",
            ),
          ],
        ),
      );
    },
  );
}

Widget myActionButtonTheme({
  required VoidCallback onPressed,
  required String title,
}) {
  return TextButton(
    onPressed: onPressed,
    child: Text(
      title,
      style: AppTextStyles.regular(
        color: title == "Yes" ? AppColors.redColor : AppColors.black,
        fontSize: 17.sp,
      ),
    ),
  );
}

// import 'package:animate_do/animate_do.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:redstreakapp/core/constants/app_assets.dart';
// import 'package:redstreakapp/core/constants/app_color.dart';
// import 'package:redstreakapp/core/constants/text_style.dart';
// import 'package:redstreakapp/core/widgets/app_button.dart';
// import 'package:redstreakapp/core/widgets/app_layout.dart';
// import 'package:redstreakapp/core/widgets/app_text.dart';
// import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
// import 'package:redstreakapp/routes/user_routes.dart';
//
// import '../../models/home/story_models/story_model.dart';
// import '../../providers/home/story_provider.dart';
//
// class QuizQuestionScreen extends StatefulWidget {
//   final List<Quiz>? quizzes;
//   final String? storyTitle;
//
//   const QuizQuestionScreen({super.key, this.quizzes, this.storyTitle});
//
//   @override
//   State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
// }
//
// class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
//   int? _selectedOptionIndex;
//   bool _isChecked = false;
//   int _currentQuestionIndex = 0;
//   int _score = 0;
//
//   List<Map<String, dynamic>> _questions = [];
//
//   @override
//   void initState() {
//     super.initState();
//     // if (widget.quizzes!.isNotEmpty) {
//     _questions = widget.quizzes!
//         .map(
//           (q) => {
//             "question": q.question,
//             "options": q.options,
//             "correctIndex": q.correctAnswer,
//           },
//         )
//         .toList();
//     // } else {
//     //   // Fallback/Test data
//     //   _questions = [
//     //     {
//     //       "question": "Where did dinosaurs\nlive?",
//     //       "options": [
//     //         "Only in forests",
//     //         "Forests, swamps, and deserts",
//     //         "Only in deserts",
//     //         "In cities",
//     //       ],
//     //       "correctIndex": 1,
//     //     },
//     //     {
//     //       "question": "What did some\ndinosaurs eat?",
//     //       "options": [
//     //         "Only pizza",
//     //         "Plants (leaves and ferns)",
//     //         "Only rocks",
//     //         "Insects only",
//     //       ],
//     //       "correctIndex": 1,
//     //     },
//     //     {
//     //       "question": "What do scientists\nstudy to learn about\ndinosaurs?",
//     //       "options": [
//     //         "Their fossils/bones",
//     //         "Their pictures",
//     //         "Their houses",
//     //         "Their clothes",
//     //       ],
//     //       "correctIndex": 0,
//     //     },
//     //   ];
//     // }
//   }
//
//   void _checkAnswer() {
//     setState(() {
//       _isChecked = true;
//       if (_selectedOptionIndex ==
//           _questions[_currentQuestionIndex]['correctIndex']) {
//         _score++;
//       }
//     });
//   }
//
//   void _continue() {
//     if (_currentQuestionIndex < _questions.length - 1) {
//       setState(() {
//         _currentQuestionIndex++;
//         _selectedOptionIndex = null;
//         _isChecked = false;
//       });
//     } else {
//       context.pushNamed(
//         AppRoutes.quizCompletedScreen.name,
//         extra: {
//           'score': _score,
//           'total': _questions.length,
//           'storyTitle': widget.storyTitle,
//         },
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentQuestion = _questions[_currentQuestionIndex];
//     final options = currentQuestion['options'] as List<String>;
//     final correctIndex = currentQuestion['correctIndex'] as int;
//
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) {
//         showLeaveQuizConfirmation(context: context);
//       },
//       child: AppLayout(
//         body: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 27.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 16.w.verticalSpace,
//                 //todo Top Bar
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     GestureDetector(
//                       onTap: () => showLeaveQuizConfirmation(context: context),
//                       child: SvgIcon(
//                         AppAssets.disable,
//                         color: Colors.black,
//                         size: 30.sp,
//                       ),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 4.w),
//                         child: Row(
//                           children: List.generate(_questions.length, (index) {
//                             Color color;
//                             if (index < _currentQuestionIndex) {
//                               color = AppColors.yellowColor;
//                             } else if (index == _currentQuestionIndex) {
//                               color = AppColors.yellowColor;
//                             } else {
//                               color = Colors.grey.withValues(alpha: 0.2);
//                             }
//
//                             return Expanded(
//                               child: Container(
//                                 margin: EdgeInsets.symmetric(horizontal: 4.w),
//                                 height: 4.h,
//                                 decoration: BoxDecoration(
//                                   color: color,
//                                   borderRadius: BorderRadius.circular(2),
//                                 ),
//                               ),
//                             );
//                           }),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 19.w.verticalSpace,
//
//                 //todo Question
//                 AppText(
//                   text: currentQuestion['question'],
//                   style: AppTextStyles.sfProDisplayBold(
//                     fontSize: 32.sp,
//                     color: AppColors.black,
//                   ).copyWith(height: 1.2),
//                 ),
//                 31.w.verticalSpace,
//
//                 //todo Options
//                 ...List.generate(
//                   options.length,
//                   (index) => OptionCard(
//                     text: options[index],
//                     isSelected: _selectedOptionIndex == index,
//                     isCorrect: index == correctIndex,
//                     isChecked: _isChecked,
//                     onTap: !_isChecked
//                         ? () {
//                             setState(() {
//                               _selectedOptionIndex = index;
//                             });
//                           }
//                         : null,
//                   ),
//                 ),
//                 Spacer(),
//                 Center(
//                   child: AppText(
//                     text: "${_currentQuestionIndex + 1} / ${_questions.length}",
//                     style: AppTextStyles.sfProDisplayRegular(
//                       fontSize: 14.sp,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//                 16.w.verticalSpace,
//
//                 // Button
//                 if (_isChecked)
//                   AppFilledButton(
//                     text: "Continue",
//                     onTap: _continue,
//                     backgroundColor: Color(0xFF00796B),
//                     fixedSize: Size(348.w, 42.h),
//                   )
//                 else
//                   AppFilledButton(
//                     text: "Check",
//                     onTap: _selectedOptionIndex != null ? _checkAnswer : () {},
//                     backgroundColor: _selectedOptionIndex != null
//                         ? AppColors.black
//                         : Colors.grey,
//                     fixedSize: Size(348.w, 42.h),
//                   ),
//                 24.w.verticalSpace,
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void showLeaveQuizConfirmation({required BuildContext context}) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return ZoomIn(
//           child: AlertDialog(
//             backgroundColor: AppColors.backgroundColor,
//             title: Text(
//               "Are you sure you want to quit this quizzes?",
//               style: AppTextStyles
//                   .textStyle20Regular, //regular(color: AppColors.black, fontSize: 19.sp),
//             ),
//             actions: [
//               myActionButtonTheme(
//                 onPressed: () async {
//                   context.pop(dialogContext);
//                   context.goNamed(AppRoutes.homeScreen.name);
//                   context.read<StoryProvider>().clareStoryData();
//                 },
//                 title: "Yes",
//               ),
//               myActionButtonTheme(
//                 onPressed: () {
//                   context.pop();
//                 },
//                 title: "Cancel",
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget myActionButtonTheme({
//     required VoidCallback onPressed,
//     required String title,
//   }) {
//     return TextButton(
//       onPressed: onPressed,
//       child: Text(
//         title,
//         style: AppTextStyles.sfProDisplayRegular(
//           color: (title == "Yes") ? AppColors.redColor : AppColors.black,
//           fontSize: 17.sp,
//         ),
//       ),
//     );
//   }
// }
