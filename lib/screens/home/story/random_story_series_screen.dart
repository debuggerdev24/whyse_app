import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/routes/app_router.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/screens/dashboard.dart';
import 'package:redstreakapp/models/home/topic_progress_model.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/screens/home/story/story_series_screen.dart';
import 'package:redstreakapp/screens/home/widgets/home_section_shimmers.dart';

class RandomTopicReadingScreen extends StatefulWidget {
  final Map<String, dynamic> progressResponse;

  const RandomTopicReadingScreen({
    super.key,
    required this.progressResponse,
  });

  @override
  State<RandomTopicReadingScreen> createState() =>
      _RandomTopicReadingScreenState();
}

class _RandomTopicReadingScreenState extends State<RandomTopicReadingScreen> {
  TopicProgressModel? _progress;
  bool _dialogShown = false;
  bool? _choseResume;
  bool _initialized = false;
  bool _providerSet = false;
  bool _firstStoryGenerationStarted = false;

  @override
  void initState() {
    super.initState();
    _parseProgress();
  }

  void _parseProgress() {
    try {
      final data = widget.progressResponse;
      if (data.isEmpty || data["data"] == null) {
        setState(() => _progress = null);
        return;
      }
      setState(() {
        _progress = TopicProgressModel.fromJson(
          Map<String, dynamic>.from(data as Map),
        );
        _initialized = true;
      });
    } catch (_) {
      setState(() => _progress = null);
    }
  }

  void _ensureProviderSet() {
    if (_progress == null || _providerSet || !mounted) return;
    _providerSet = true;
    context.read<StoryProvider>().setFromTopicProgress(_progress!);
  }

  void _showResumeDialog() {
    if (_progress == null || _dialogShown || !mounted) return;
    if (_progress!.readings.isEmpty) return;

    _dialogShown = true;
    final hasResume = _progress!.hasResume;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        title: AppText(
          text: hasResume
              ? "Resume from where you left off?"
              : "Resume from where you left off?",//"Start from the first story",
          style: AppTextStyles.sfProDisplayBold(fontSize: 18.sp),
        ),
        content: AppText(
          text: hasResume
              ? "Do you want to continue from where you left off?"
              : "Do you want to continue from where you left off?",//"You can start reading from the first story.",
          style: AppTextStyles.sfProDisplayRegular(
            fontSize: 14.sp,
            color: AppColors.black.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ctx.pop();
              if (hasResume) {
                setState(() => _choseResume = true);
                if (context.mounted) {
                  AppToast.info(
                    context: context,
                    durationSecond: 4,
                    message: "It can take few seconds to generate the story",
                  );
                }
                _generateResumeStory();
              } else {
                setState(() => _choseResume = false);
              }
            },
            child: Text(
              "Yes",
              style: AppTextStyles.sfProDisplayRegular(
                color: AppColors.black,
                fontSize: 17.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ctx.pop();
              setState(() => _choseResume = false);
              if (context.mounted) {
                AppToast.info(
                  context: context,
                  durationSecond: 4,
                  message: "It can take few seconds to generate the story",
                );
              }
            },
            child: Text(
              "No",
              style: AppTextStyles.sfProDisplayRegular(
                color: AppColors.black,
                fontSize: 17.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _generateResumeStory() {
    final resume = _progress?.resume;
    if (resume == null || resume.storyIdeaId.isEmpty) {
      setState(() {});
      return;
    }

    final provider = context.read<StoryProvider>();
    final resumeIndex = provider.indexOfReadingByStoryIdeaId(resume.storyIdeaId);
    provider.generateSingleStory(
      storyIdeaId: resume.storyIdeaId,
      context: context,
      onSuccess: () => setState(() {}),
      insertAtIndex: resumeIndex >= 0 ? resumeIndex : null,
      showToast: false,
    );
  }

  void _generateFirstStory() {
    if (_firstStoryGenerationStarted || !mounted) return;

    final provider = context.read<StoryProvider>();
    final ideas = provider.storyIdea?.storyIdeas ?? [];
    if (ideas.isEmpty) return;

    _firstStoryGenerationStarted = true;
    setState(() {});
    provider.generateSingleStory(
      storyIdeaId: ideas.first.id,
      context: context,
      onSuccess: () => setState(() {}),
      showToast: false,
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            text: "Could not load topic progress.",
            style: AppTextStyles.sfProDisplayMedium(
              fontSize: 16.sp,
              color: AppColors.black.withValues(alpha: 0.7),
            ),
          ),
          16.w.verticalSpace,
          TextButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(AppRoutes.homeScreen.name);
                tabIndex.value = 0;
              }
            },
            child: const Text("Go back"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return HomeSectionShimmer.generateStoryIdeasScreenShimmer();
  }

  Widget _buildBody(BuildContext context) {
    if (_progress == null && _initialized) {
      return _buildErrorState();
    }

    if (_progress == null) {
      return _buildLoadingState();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureProviderSet());

    final hasReadings = _progress!.readings.isNotEmpty;
    final waitingForResumeAnswer = hasReadings && _choseResume == null;

    if (waitingForResumeAnswer) {
      if (!_dialogShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showResumeDialog());
      }
      return _buildLoadingState();
    }

    final provider = context.watch<StoryProvider>();
    final isGeneratingResume =
        _choseResume == true && provider.isGenerateSingleStoryLoading;

    if (isGeneratingResume) {
      return _buildLoadingState();
    }

    final needFirstStory =
        (_choseResume == false || !_progress!.hasResume) &&
        (provider.storyIdea?.storyIdeas.isNotEmpty ?? false) &&
        provider.stories.isEmpty;

    if (needFirstStory) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _generateFirstStory());
      return _buildLoadingState();
    }

    return const StoryReadingScreen();
  }

  void showLeaveStoryConfirmation({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(
            "Are you sure you want to quit this story?",
            style: AppTextStyles.textStyle20Regular,
          ),
          actions: [
            TextButton(
              onPressed: () {
                dialogContext.pop();
                final provider = context.read<StoryProvider>();
                provider.clareStoryData();
                provider.clearStoryFields();
                provider.resetStoryPageIndex();
                provider.setCurrentStoryIndex = 0;
                tabIndex.value = 1;
                AppRouter.indexedStackNavigationShell?.goBranch(1);
                AppRouter.goRouter.goNamed(AppRoutes.searchScreen.name);
              },
              child: Text(
                "Quit",
                style: AppTextStyles.sfProDisplayRegular(
                  color: AppColors.redColor,
                  fontSize: 17.sp,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                "Cancel",
                style: AppTextStyles.sfProDisplayRegular(
                  color: AppColors.black,
                  fontSize: 17.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showLeaveStoryConfirmation(context: context);
      },
      child: AppLayout(
        body: SafeArea(
          child: _buildBody(context),
        ),
      ),
    );
  }
}
