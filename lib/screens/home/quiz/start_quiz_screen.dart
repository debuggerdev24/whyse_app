import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';

class StartQuizScreen extends StatefulWidget {
  final String storyId;
  final String storyTitle;
  final String? storyImageUrl;
  final String? storyIdeaId;
  final bool fromContinueReading;
  final String? continueReadingTopicId;
  final int episodeNumber;
  final String? seriesTitle;
  final int totalEpisodes;
  final String? topicId;

  const StartQuizScreen({
    super.key,
    required this.storyId,
    required this.storyTitle,
    this.storyImageUrl,
    this.storyIdeaId,
    this.fromContinueReading = false,
    this.continueReadingTopicId,
    this.episodeNumber = 1,
    this.seriesTitle,
    this.totalEpisodes = 0,
    this.topicId,
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
        if ((widget.continueReadingTopicId ?? '').isNotEmpty)
          'continueReadingTopicId': widget.continueReadingTopicId,
        'episodeNumber': widget.episodeNumber,
        if ((widget.seriesTitle ?? '').isNotEmpty)
          'seriesTitle': widget.seriesTitle,
        'totalEpisodes': widget.totalEpisodes,
        if ((widget.topicId ?? '').isNotEmpty) 'topicId': widget.topicId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: AppLayout(
        body: ColoredBox(
          color: AppColors.backgroundColor,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Consumer<StoryProvider>(
                builder: (context, provider, _) {
                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GlassIconButton(
                          onTap: () => context.pop(),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.black,
                            size: 22,
                          ),
                        ),
                      ),
                      const Spacer(flex: 2),
                      Image.asset(AppAssets.quiz, height: 92, width: 92),
                      const SizedBox(height: 28),
                      AppText(
                        text: "Time for a quick quiz!",
                        style: AppTextStyles.semibold(
                          fontSize: 28,
                          color: AppColors.black,
                        ).copyWith(height: 1.2),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      AppText(
                        text:
                            "You'll answer a few quick questions about the passage you just read. Let's see what you remember!",
                        style: AppTextStyles.regular(
                          fontSize: 14,
                          color: const Color(0x991A1A1A),
                        ).copyWith(height: 1.45),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(flex: 3),
                      AppFilledButton(
                        text: "Start Quiz",
                        onTap: provider.isCreateQuizLoading
                            ? null
                            : () => _goToQuiz(context),
                        backgroundColor: AppColors.teal,
                        textStyle: AppTextStyles.semibold(
                          fontSize: 14,
                          color: Colors.white,
                        ).copyWith(height: 17 / 14),
                        fixedSize: Size(
                          MediaQuery.sizeOf(context).width - 32,
                          50,
                        ),
                        isLoading: provider.isCreateQuizLoading,
                        loadingColor: Colors.white,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

