import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/home/story_models/story_model.dart';
import 'package:redstreakapp/screens/home/quiz/quiz_question_screen.dart';

class StartQuizScreen extends StatelessWidget {
  final String storyId;
  final String storyTitle;
  final String? storyImageUrl;

  const StartQuizScreen({
    super.key,
    required this.storyId,
    required this.storyTitle,
    this.storyImageUrl,
  });

  void _goToQuiz(BuildContext context) {
    context.pushNamed(
      AppRoutes.quizQuestionScreen.name,
      extra: {
        'quizzes': <StoryQuiz>[],
        'storyTitle': storyTitle,
        'storyImageUrl': storyImageUrl,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        showLeaveQuizConfirmation(context: context);
      },
      child: AppLayout(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          leading: IconButton(
            onPressed: () => showLeaveQuizConfirmation(context: context),
            icon: const Icon(Icons.close),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              Image.asset(AppAssets.quiz, height: 92.h, width: 92.w),
              33.w.verticalSpace,

              AppText(
                text: "Time for a quick quiz!",
                style: AppTextStyles.bold(
                  fontSize: 32.sp,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              9.w.verticalSpace,

              AppText(
                text:
                    "You'll answer a few quick questions about the \npassage you just read. Let's see what you remember!",
                style: AppTextStyles.medium(
                  fontSize: 16.sp,
                  color: AppColors.black.withValues(alpha: 0.6),
                ).copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),

              AppFilledButton(
                text: "Start Quiz",
                onTap: () => _goToQuiz(context),
                backgroundColor: AppColors.orangeColor,
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
