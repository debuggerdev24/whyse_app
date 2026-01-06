import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/screens/home/quiz_question_screen.dart';

import 'package:redstreakapp/models/story_models/story_model.dart';

class StartQuizScreen extends StatelessWidget {
  final List<Quiz> quizzes;
  final String storyTitle;

  const StartQuizScreen({
    super.key,
    this.quizzes = const [],
    this.storyTitle = "",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: IconButton(onPressed: () {}, icon: Icon(Icons.close)),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 27.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 2),

            Image.asset(AppAssets.quiz, height: 92.h, width: 92.w),
            33.h.verticalSpace,

            // Title
            AppText(
              text: "Time for a quick quiz!",
              style: AppTextStyles.sfProDisplayBold(
                fontSize: 32.sp,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            9.h.verticalSpace,

            // Subtitle
            AppText(
              text:
                  "You’ll answer ${quizzes.length} quick questions about the \npassage you just read. Let’s see what you remember!",
              style: AppTextStyles.sfProDisplayMedium(
                fontSize: 16.sp,
                color: AppColors.black.withOpacity(0.6),
              ).copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            Spacer(flex: 3),

            // Start Quiz Button
            AppButton(
              text: "Start Quiz",
              onPressed: () {
                context.pushNamed(
                  UserAppRoutes.quizQuestionScreen.name,
                  extra: {'quizzes': quizzes, 'storyTitle': storyTitle},
                );
              },
              backgroundColor: AppColors.yellowcolor,
              fixedSize: Size(348.w, 42.h),
            ),
            40.h.verticalSpace,
          ],
        ),
      ),
    );
  }
}
