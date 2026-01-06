import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';

import 'package:redstreakapp/models/story_models/story_model.dart';

class QuizQuestionScreen extends StatefulWidget {
  final List<Quiz> quizzes;
  final String storyTitle;

  const QuizQuestionScreen({
    super.key,
    this.quizzes = const [],
    this.storyTitle = "",
  });

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  int? _selectedOptionIndex;
  bool _isChecked = false;
  int _currentQuestionIndex = 0;
  int _score = 0;

  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    if (widget.quizzes.isNotEmpty) {
      _questions = widget.quizzes
          .map(
            (q) => {
              "question": q.question,
              "options": q.options,
              "correctIndex": q.correctAnswer,
            },
          )
          .toList();
    } else {
      // Fallback/Test data
      _questions = [
        {
          "question": "Where did dinosaurs\nlive?",
          "options": [
            "Only in forests",
            "Forests, swamps, and deserts",
            "Only in deserts",
            "In cities",
          ],
          "correctIndex": 1,
        },
        {
          "question": "What did some\ndinosaurs eat?",
          "options": [
            "Only pizza",
            "Plants (leaves and ferns)",
            "Only rocks",
            "Insects only",
          ],
          "correctIndex": 1,
        },
        {
          "question": "What do scientists\nstudy to learn about\ndinosaurs?",
          "options": [
            "Their fossils/bones",
            "Their pictures",
            "Their houses",
            "Their clothes",
          ],
          "correctIndex": 0,
        },
      ];
    }
  }

  void _checkAnswer() {
    setState(() {
      _isChecked = true;
      if (_selectedOptionIndex ==
          _questions[_currentQuestionIndex]['correctIndex']) {
        _score++;
      }
    });
  }

  void _continue() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isChecked = false;
      });
    } else {
      context.pushNamed(
        UserAppRoutes.quizCompletedScreen.name,
        extra: {
          'score': _score,
          'total': _questions.length,
          'storyTitle': widget.storyTitle,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final options = currentQuestion['options'] as List<String>;
    final correctIndex = currentQuestion['correctIndex'] as int;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.h.verticalSpace,
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                        children: List.generate(_questions.length, (index) {
                          Color color;
                          if (index < _currentQuestionIndex) {
                            color = AppColors.yellowcolor;
                          } else if (index == _currentQuestionIndex) {
                            color = AppColors.yellowcolor;
                          } else {
                            color = Colors.grey.withOpacity(0.2);
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
              19.h.verticalSpace,

              // Question
              AppText(
                text: currentQuestion['question'],
                style: AppTextStyles.sfProDisplayBold(
                  fontSize: 32.sp,
                  color: AppColors.black,
                ).copyWith(height: 1.2),
              ),
              31.h.verticalSpace,

              // Options
              ...List.generate(
                options.length,
                (index) => OptionCard(
                  text: options[index],
                  isSelected: _selectedOptionIndex == index,
                  isCorrect: index == correctIndex,
                  isChecked: _isChecked,
                  onTap: !_isChecked
                      ? () {
                          setState(() {
                            _selectedOptionIndex = index;
                          });
                        }
                      : null,
                ),
              ),
              Spacer(),
              Center(
                child: AppText(
                  text: "${_currentQuestionIndex + 1} / ${_questions.length}",
                  style: AppTextStyles.sfProDisplayRegular(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
              16.h.verticalSpace,

              // Button
              if (_isChecked)
                AppButton(
                  text: "Continue",
                  onPressed: _continue,
                  backgroundColor: Color(0xFF00796B),
                  fixedSize: Size(348.w, 42.h),
                )
              else
                AppButton(
                  text: "Check",
                  onPressed: _selectedOptionIndex != null
                      ? _checkAnswer
                      : () {},
                  backgroundColor: _selectedOptionIndex != null
                      ? AppColors.black
                      : Colors.grey,
                  fixedSize: Size(348.w, 42.h),
                ),
              24.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
