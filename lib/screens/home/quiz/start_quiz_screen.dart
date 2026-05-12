import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';

class StartQuizScreen extends StatefulWidget {
  final String storyId;
  final String storyTitle;
  final String? storyImageUrl;
  final String? storyIdeaId;
  final bool fromContinueReading;

  const StartQuizScreen({
    super.key,
    required this.storyId,
    required this.storyTitle,
    this.storyImageUrl,
    this.storyIdeaId,
    this.fromContinueReading = false,
  });

  @override
  State<StartQuizScreen> createState() => _StartQuizScreenState();
}

class _StartQuizScreenState extends State<StartQuizScreen> {
  Future<void> _goToQuiz(BuildContext context) async {
    final provider = context.read<StoryProvider>();
    final quizzes = await provider.generateMcqQuiz(
      storyId: widget.storyId,
      quizMcqCount: 5,
      replaceExisting: false,
    );
    if (!context.mounted) return;
    if (quizzes == null || quizzes.isEmpty) {
      final msg = provider.quizError ?? "Unable to generate quiz.";
      AppToast.error(context, msg);
      return;
    }
    context.pushReplacementNamed(
      AppRoutes.quizQuestionScreen.name,
      extra: {
        'quizzes': quizzes,
        'storyTitle': widget.storyTitle,
        'storyImageUrl': widget.storyImageUrl,
        'storyIdeaId': widget.storyIdeaId,
        'storyId': widget.storyId,
        'fromContinueReading': widget.fromContinueReading,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: false,
      // onPopInvokedWithResult: (didPop, result) {
      //   showLeaveQuizConfirmation(context: context);
      // },
      child: AppLayout(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          leading: IconButton(
            // onPressed: () => showLeaveQuizConfirmation(context: context),
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Consumer<StoryProvider>(
            builder: (context, provider, _) {
              return Column(
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
                    onTap: provider.isCreateQuizLoading
                        ? null
                        : () => _goToQuiz(context),
                    backgroundColor: AppColors.orangeColor,
                    fixedSize: Size(348.w, 42.w),
                    isLoading: provider.isCreateQuizLoading,
                  ),
                  40.w.verticalSpace,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
