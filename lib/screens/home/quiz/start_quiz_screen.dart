import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/screens/home/quiz/quiz_question_screen.dart';

import '../../../models/home/story_models/story_model.dart';

class StartQuizScreen extends StatelessWidget {
  final List<StoryQuiz> quizzes;
  final String storyTitle;

  const StartQuizScreen({
    super.key,
    required this.quizzes,
    required this.storyTitle,
  });

  @override
  Widget build(BuildContext context) {
    Logger.info("From parameter: ${quizzes.length}");
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        showLeaveQuizConfirmation(context: context);
      },
      child: AppLayout(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          leading: IconButton(
            onPressed: () {  
              // context.pop();
              showLeaveQuizConfirmation(context: context);
            },
            icon: Icon(Icons.close),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 2),

              Image.asset(AppAssets.quiz, height: 92.h, width: 92.w),
              33.w.verticalSpace,

              // Title
              AppText(
                text: "Time for a quick quiz!",
                style: AppTextStyles.sfProDisplayBold(
                  fontSize: 32.sp,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              9.w.verticalSpace,

              // Subtitle
              AppText(
                text:
                    "You’ll answer ${quizzes.length} quick questions about the \npassage you just read. Let’s see what you remember!",
                style: AppTextStyles.sfProDisplayMedium(
                  fontSize: 16.sp,
                  color: AppColors.black.withValues(alpha: 0.6),
                ).copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
              Spacer(flex: 3),

              //todo Start Quiz Button
              AppFilledButton(
                text: "Start Quiz",
                onTap: () {
                  context.pushNamed(
                    AppRoutes.quizQuestionScreen.name,
                    extra: {'quizzes': quizzes, 'storyTitle': storyTitle},
                  );
                },
                backgroundColor: AppColors.primaryColor,
                fixedSize: Size(348.w, 42.h),
              ),
              40.w.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
