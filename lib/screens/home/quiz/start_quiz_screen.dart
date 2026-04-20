import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';

import 'package:redstreakapp/screens/home/quiz/quiz_question_screen.dart';

class StartQuizScreen extends StatelessWidget {
  final String storyId;
  final String storyTitle;

  const StartQuizScreen({
    super.key,
    required this.storyId,
    required this.storyTitle,
  });

  @override
  Widget build(BuildContext context) {
    Logger.info("Start quiz for storyId: $storyId");
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

              //* Title
              AppText(
                text: "Time for a quick quiz!",
                style: AppTextStyles.bold(
                  fontSize: 32.sp,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              9.w.verticalSpace,

              //* Subtitle
              AppText(
                text:
                    "You’ll answer a few quick questions about the \npassage you just read. Let’s see what you remember!",
                style: AppTextStyles.medium(
                  fontSize: 16.sp,
                  color: AppColors.black.withValues(alpha: 0.6),
                ).copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
              Spacer(flex: 3),
              //* Start Quiz Button
              AppFilledButton(
                text: "Start Quiz",
                onTap: () {
                  final provider = context.read<StoryProvider>();
                  provider.getQuiz(storyId: storyId);
                  // provider.createQuiz(quizzes);
                  // context.pushNamed(
                  //   AppRoutes.quizQuestionScreen.name,
                  //   extra: {'quizzes': quizzes, 'storyTitle': storyTitle},
                  // );
                },
                backgroundColor: AppColors.primaryColor,
                fixedSize: Size(348.w, 42.w),
              ),
              40.w.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
