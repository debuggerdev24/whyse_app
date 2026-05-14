import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';

import 'package:redstreakapp/core/utils/share_helper.dart';

import 'package:redstreakapp/models/home/story_models/story_idea_model.dart';
import 'package:redstreakapp/models/home/story_models/story_model.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/screens/dashboard.dart';
import 'package:redstreakapp/screens/home/widgets/home_section_shimmers.dart';
import 'package:redstreakapp/core/widgets/global_widgets.dart';

/// Screen for viewing shared topic (from link). Uses [StoryProvider.getStoryByIdea] (fetch only), no generate-from-idea API.
class SharedStoryScreen extends StatefulWidget {
  const SharedStoryScreen({super.key});

  /// When true, [shouldAllowPop] returns true without showing the leave dialog. Set by deep link handler.
  static bool skipLeaveDialogForDeepLink = false;

  /// When true, [shouldAllowPop] returns true without showing any dialog (e.g. user chose "Go to home").
  static bool skipLeaveDialogForHome = false;

  /// Guard: first-story fetch already scheduled (avoids setState during build).
  static bool _firstStoryLoadScheduled = false;

  /// Call before navigating to this screen from a deep link so the first story is always fetched (resets guard).
  static void prepareForDeepLink() {
    skipLeaveDialogForDeepLink = true;
    _firstStoryLoadScheduled = false;
  }

  /// Returns true to allow route pop, false to stay. Used by GoRoute.onExit (system back).
  static Future<bool> shouldAllowPop(BuildContext context) async {
    if (skipLeaveDialogForDeepLink) {
      skipLeaveDialogForDeepLink = false;
      return true;
    }
    if (skipLeaveDialogForHome) {
      skipLeaveDialogForHome = false;
      return true;
    }
    final quit = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return ZoomIn(
          child: AlertDialog(
            backgroundColor: AppColors.white,
            title: Text(
              "Are you sure you want to quit?",
              style: AppTextStyles.textStyle20Regular,
            ),
            actions: [
              SharedStoryScreen.myActionButtonTheme(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                title: "Quit",
              ),
              SharedStoryScreen.myActionButtonTheme(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                title: "Cancel",
              ),
            ],
          ),
        );
      },
    );
    return quit ?? false;
  }

  static Widget myActionButtonTheme({
    required VoidCallback onPressed,
    required String title,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: AppTextStyles.regular(
          color: (title == "Yes" || title == "Quit")
              ? AppColors.redColor
              : AppColors.black,
          fontSize: 17.sp,
        ),
      ),
    );
  }

  @override
  State<SharedStoryScreen> createState() => _SharedStoryScreenState();
}

class _SharedStoryScreenState extends State<SharedStoryScreen> {
  @override
  void dispose() {
    SharedStoryScreen._firstStoryLoadScheduled = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SafeArea(
        child: Consumer<StoryProvider>(
          builder: (context, provider, child) {
            Logger.info("${provider.lessonDuration}");
            if (!context.mounted) return const SizedBox.shrink();
            final storyIdea = provider.storyIdeas;
            final isEmpty = storyIdea == null || storyIdea.storyIdeas.isEmpty;
            final ideas = storyIdea?.storyIdeas ?? [];

            // First story: fetch by idea only (no generate API). Defer to avoid setState during build.
            if (!isEmpty &&
                provider.stories.isEmpty &&
                provider.currentStoryIndex == 0 &&
                !SharedStoryScreen._firstStoryLoadScheduled) {
              SharedStoryScreen._firstStoryLoadScheduled = true;
              final firstIdeaId = ideas.first.id;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                provider.getStoryByIdea(
                  context: context,
                  storyIdea: firstIdeaId,
                  fetchOnly: true,
                  onSuccess: (payload) {
                    if (context.mounted) {
                      provider.addStoryFromGetStoryByIdeaData(payload, 0);
                    }
                  },
                  onStoryNotGenerated: () {},
                );
              });
            }
            final topicTitle =
                (storyIdea != null && storyIdea.topic.title.isNotEmpty)
                ? storyIdea.topic.title
                : "Your Story Ideas";

            final hasStory =
                provider.stories.isNotEmpty &&
                provider.currentStoryIndex < provider.stories.length &&
                provider.stories[provider.currentStoryIndex].pages.isNotEmpty;
            final story = hasStory
                ? provider.stories[provider.currentStoryIndex]
                : null;
            final shouldShowFullScreenShimmer =
                provider.isGenerateStoryIdeasLoading ||
                provider.isGenerateSingleStoryLoading ||
                provider.isGettingStoryByIdeaLoading;

            if (shouldShowFullScreenShimmer) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: AppColors.backgroundColor,
                child: HomeSectionShimmer.generateStoryIdeasScreenShimmer(),
              );
            }
            if (provider.generateStoryError != null && !isEmpty) {
              final currentIndex = provider.currentStoryIndex;
              final currentIdea = currentIndex < ideas.length
                  ? ideas[currentIndex]
                  : null;
              final currentIdeaId = currentIdea?.id;
              final isNotGenerated = currentIdea?.isGenerated == false;
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 56.sp,
                        color: AppColors.black.withValues(alpha: 0.4),
                      ),
                      20.h.verticalSpace,
                      AppText(
                        text: isNotGenerated
                            ? "Story not generated yet."
                            : "Something went wrong. Please try again.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.medium(
                          fontSize: 16.sp,
                          color: AppColors.black.withValues(alpha: 0.8),
                        ),
                      ),
                      28.w.verticalSpace,
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (currentIdeaId == null || isNotGenerated)
                              ? null
                              : () {
                                  provider.getStoryByIdea(
                                    context: context,
                                    storyIdea: currentIdeaId,
                                    fetchOnly: true,
                                    onSuccess: (payload) {
                                      if (context.mounted) {
                                        provider.addStoryFromGetStoryByIdeaData(
                                          payload,
                                          currentIndex,
                                        );
                                      }
                                    },
                                    onStoryNotGenerated: () {},
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Try again",
                            style: AppTextStyles.semibold(
                              fontSize: 16.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (isEmpty) {
              return Center(
                child: AppText(
                  text: "No story ideas yet",
                  style: AppTextStyles.medium(
                    fontSize: 16.sp,
                    color: AppColors.black.withValues(alpha: 0.6),
                  ),
                ),
              );
            }

            final durationMinutes = story != null
                ? (story.lessonDuration ?? provider.lessonDuration).clamp(
                    1,
                    999,
                  )
                : 0;
            final displayMins = story != null
                ? (story.lessonDuration ?? provider.lessonDuration)
                : provider.lessonDuration;
            final displayMinsLabel = displayMins > 0 ? displayMins : 5;
            final currentStoryIdeaId = provider.currentStoryIndex < ideas.length
                ? ideas[provider.currentStoryIndex].id
                : '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    key: ValueKey('story_index_${provider.currentStoryIndex}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (story != null)
                          _StoryViewer(
                            story: story,
                            storyIdeaId: currentStoryIdeaId,
                            topicId: storyIdea.topic.id,
                            topicTitle: storyIdea.topic.title,
                            lessonDuration: durationMinutes > 0
                                ? durationMinutes
                                : provider.lessonDuration,
                            onCloseStory: () {
                              showLeaveStoryConfirmation(context: context);
                            },
                            onHome: () {
                              showHomeConfirmation(context: context);
                            },
                          ),

                        // else if ()
                        //   HomeSectionShimmer.storyReadingScreenShimmer(),
                        16.w.verticalSpace,
                        //* Story Ideas list
                        Padding(
                          padding: EdgeInsets.fromLTRB(24.w, 0.w, 24.w, 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: topicTitle,
                                style: AppTextStyles.bold(
                                  fontSize: 24.sp,
                                  height: 0,
                                  color: AppColors.black,
                                ),
                              ),
                              if (storyIdea.topic.learningGoal
                                  .trim()
                                  .isNotEmpty) ...[
                                8.w.verticalSpace,
                                AppText(
                                  text: storyIdea.topic.learningGoal,
                                  style: AppTextStyles.regular(
                                    fontSize: 14.sp,
                                    color: AppColors.black.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (storyIdea.topic.interests.isNotEmpty) ...[
                                12.w.verticalSpace,
                                _TagsSection(
                                  interests: storyIdea.topic.interests,
                                ),
                              ],
                              8.w.verticalSpace,
                              if (ideas.length > 1)
                                Row(
                                  children: [
                                    _MetaChip(
                                      icon: Icons.menu_book_outlined,
                                      label: "${ideas.length} Ideas",
                                    ),
                                    // if (ideas.length > 1)
                                    12.w.horizontalSpace,
                                    _MetaChip(
                                      icon: Icons.access_time,
                                      label: "$displayMinsLabel mins",
                                    ),
                                  ],
                                ),
                              if (ideas.length > 1) ...[
                                9.w.verticalSpace,
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(bottom: 4.h),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: AppColors.teal,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: AppText(
                                        text: "Ideas",
                                        style: AppTextStyles.semibold(
                                          fontSize: 16.sp,
                                          color: AppColors.teal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (ideas.length > 1)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              children: List.generate(ideas.length, (index) {
                                if (index == provider.currentStoryIndex) {
                                  return const SizedBox.shrink();
                                }
                                return _StoryIdeaTile(
                                  topicImageUrl: storyIdea.topic.thumbnailUrl,
                                  idea: ideas[index],
                                  index: index + 1,
                                  onTap: () {
                                    deBouncer.run(() {
                                      if (index < provider.stories.length) {
                                        provider.setCurrentStoryIndex = index;
                                        return;
                                      }
                                      if (!ideas[index].isGenerated) {
                                        AppToast.info(
                                          context: context,
                                          message: "Story not generated yet.",
                                        );
                                        return;
                                      }
                                      provider.setCurrentStoryIndex = index;
                                      provider.getStoryByIdea(
                                        context: context,
                                        storyIdea: ideas[index].id,
                                        fetchOnly: true,
                                        onSuccess: (payload) {
                                          if (context.mounted) {
                                            provider.addStoryFromGetStoryByIdeaData(
                                              payload,
                                              index,
                                            );
                                          }
                                        },
                                        onStoryNotGenerated: () {
                                          if (context.mounted) {
                                            AppToast.info(
                                              context: context,
                                              message:
                                                  "Story not available yet.",
                                            );
                                          }
                                        },
                                      );
                                    });
                                  },
                                  isGenerating:
                                      provider.isGettingStoryByIdeaLoading &&
                                      index == provider.currentStoryIndex,
                                );
                              }),
                            ),
                          ),

                        24.w.verticalSpace,
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void showLeaveStoryConfirmation({required BuildContext context}) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return ZoomIn(
          child: AlertDialog(
            backgroundColor: AppColors.white,
            title: Text(
              "Are you sure you want to quit?",
              style: AppTextStyles.textStyle20Regular,
            ),
            actions: [
              SharedStoryScreen.myActionButtonTheme(
                onPressed: () {
                  dialogContext.pop();
                  if (!context.mounted) return;
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.goNamed(AppRoutes.homeScreen.name);
                    tabIndex.value = 0;
                  }
                },
                title: "Quit",
              ),
              SharedStoryScreen.myActionButtonTheme(
                onPressed: () => dialogContext.pop(),
                title: "Cancel",
              ),
            ],
          ),
        );
      },
    );
  }

  void showHomeConfirmation({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(
            "Are you sure you want to go to home?",
            style: AppTextStyles.textStyle20Regular,
          ),
          actions: [
            SharedStoryScreen.myActionButtonTheme(
              onPressed: () {
                dialogContext.pop();
                SharedStoryScreen.skipLeaveDialogForHome = true;
                context.goNamed(AppRoutes.homeScreen.name);
                tabIndex.value = 0;
                AppRouter.indexedStackNavigationShell?.goBranch(0);
              },
              title: "Yes",
            ),
            SharedStoryScreen.myActionButtonTheme(
              onPressed: () => dialogContext.pop(),
              title: "Cancel",
            ),
          ],
        );
      },
    );
  }
}

class _ReadingTimerText extends StatelessWidget {
  final int remainingSeconds;

  const _ReadingTimerText({required this.remainingSeconds});

  static String _formatDuration(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: 'Time left: ${_formatDuration(remainingSeconds)}',
      style: AppTextStyles.semibold(fontSize: 16.sp, color: AppColors.teal),
    );
  }
}

/// Horizontal scrollable tags (topic interests) for attractive search/discovery UI.
class _TagsSection extends StatelessWidget {
  final List<Interest> interests;

  const _TagsSection({required this.interests});

  @override
  Widget build(BuildContext context) {
    if (interests.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 36.w,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: 24.w),
        itemCount: interests.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final interest = interests[index];
          final name = interest.name.trim();
          if (name.isEmpty) return const SizedBox.shrink();
          return _TagChip(label: name);
        },
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.teal.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: AppText(
        text: label,
        style: AppTextStyles.semibold(fontSize: 13.sp, color: AppColors.teal),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: AppColors.black.withValues(alpha: 0.5)),
        6.w.horizontalSpace,
        AppText(
          text: label,
          style: AppTextStyles.medium(
            fontSize: 13.sp,
            color: AppColors.black.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _StoryIdeaTile extends StatelessWidget {
  final StoryIdea idea;
  final String topicImageUrl;
  final int index;
  final VoidCallback onTap;
  final bool isGenerating;

  const _StoryIdeaTile({
    required this.idea,
    required this.index,
    required this.onTap,
    required this.topicImageUrl,
    this.isGenerating = false,
  });

  String get _imageUrl {
    final url = idea.thumbnailUrl;
    if (url == null || url.toString().isEmpty) {
      return resolveNetworkImageUrl(topicImageUrl);
    }
    return resolveNetworkImageUrl(url.toString());
  }

  @override
  Widget build(BuildContext context) {
    final showLock = !idea.isGenerated;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.w),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //* Thumbnail (with lock overlay when not generated)
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: _imageUrl.isNotEmpty
                        ? AppNetworkImage(
                            imageUrl: _imageUrl,
                            tag: 'SharedStory.thumbnail',
                            width: 120.w,
                            height: 80.h,
                            placeholder: (_) =>
                                _buildThumbnailPlaceholder(),
                            errorCompact: true,
                            errorIconOnly: true,
                          )
                        : _buildThumbnailPlaceholder(),
                  ),
                  if (showLock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: AppColors.black.withValues(alpha: 0.4),
                        ),
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 28.sp,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                ],
              ),
              14.w.horizontalSpace,

              //* Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 1.5),
                          child: AppText(
                            text: "$index. ",
                            style: AppTextStyles.semibold(
                              fontSize: 14.sp,
                              color: AppColors.black.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: AppText(
                                  text: idea.title,
                                  style: AppTextStyles.semibold(
                                    fontSize: 15.sp,
                                    color: AppColors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (showLock) ...[
                                6.w.horizontalSpace,
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 18.sp,
                                  color: AppColors.black.withValues(
                                    alpha: 0.45,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    4.w.verticalSpace,
                    AppText(
                      text: idea.description,
                      style: AppTextStyles.regular(
                        fontSize: 13.sp,
                        color: AppColors.black.withValues(alpha: 0.65),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    6.h.verticalSpace,
                    AppText(
                      text: DateFormatter.formatDateTimeFrom(idea.createdAt),
                      style: AppTextStyles.regular(
                        fontSize: 12.sp,
                        color: AppColors.black.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),

              5.w.horizontalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
      width: 120.w,
      height: 80.h,
      color: AppColors.shimmerBaseColor,
      child: Icon(
        Icons.auto_stories_outlined,
        size: 32.sp,
        color: AppColors.black.withValues(alpha: 0.2),
      ),
    );
  }
}

//* story viewer: fixed hero image per page, scrollable content below, Start Quiz on last page.
class _StoryViewer extends StatefulWidget {
  final StoryModel story;
  final String storyIdeaId;
  final String topicId;
  final String topicTitle;
  final int lessonDuration;
  final VoidCallback onCloseStory;
  final VoidCallback onHome;
  const _StoryViewer({
    required this.story,
    required this.storyIdeaId,
    required this.topicId,
    required this.topicTitle,
    required this.lessonDuration,
    required this.onCloseStory,
    required this.onHome,
  });

  @override
  State<_StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<_StoryViewer> {
  int _currentPageIndex = 0;
  Timer? _readingTimer;
  late int _remainingSeconds;
  bool _hasStartedReading = false;
  bool _isTimerRunning = false;

  int get _initialSeconds => (widget.lessonDuration.clamp(1, 999)) * 60;

  @override
  void initState() {
    super.initState();
    _resetReadingSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final id = widget.story.id;
      if (id.isEmpty) return;
      context.read<StoryProvider>().prefetchMcqQuizForReading(storyId: id);
    });
  }

  @override
  void didUpdateWidget(covariant _StoryViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.story.id != widget.story.id ||
        oldWidget.lessonDuration != widget.lessonDuration) {
      _currentPageIndex = 0;
      _resetReadingSession();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final id = widget.story.id;
        if (id.isEmpty) return;
        context.read<StoryProvider>().prefetchMcqQuizForReading(storyId: id);
      });
    }
  }

  void _resetReadingSession() {
    _readingTimer?.cancel();
    _readingTimer = null;
    _remainingSeconds = _initialSeconds;
    _hasStartedReading = false;
    _isTimerRunning = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _startTimer() {
    _readingTimer?.cancel();
    _readingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        _readingTimer?.cancel();
        _readingTimer = null;
        setState(() {
          _remainingSeconds = 0;
          _isTimerRunning = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _openQuiz();
          }
        });
        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });
  }

  void _handleStartReading() {
    setState(() {
      _hasStartedReading = true;
      _isTimerRunning = true;
      _remainingSeconds = _initialSeconds;
    });
    _startTimer();
  }

  void _handleResumeReading() {
    if (_remainingSeconds <= 0) {
      _remainingSeconds = _initialSeconds;
    }
    setState(() {
      _hasStartedReading = true;
      _isTimerRunning = true;
    });
    _startTimer();
  }

  void _handleStopReading() {
    _readingTimer?.cancel();
    _readingTimer = null;
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _openQuiz() {
    context.pushNamed(
      AppRoutes.startQuizScreen.name,
      extra: {
        'storyId': widget.story.id,
        'storyTitle': widget.story.title,
        'storyImageUrl': widget.story.thumbnailUrl,
      },
    );
  }

  @override
  void dispose() {
    _readingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.story.pages;
    if (pages.isEmpty) {
      return const Center(child: Text('No story pages'));
    }

    final index = _currentPageIndex.clamp(0, pages.length - 1);
    final page = pages[index];
    final isFirstPage = index == 0;
    final isLastPage = index == pages.length - 1;
    return Column(
      mainAxisSize: MainAxisSize.min,

      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StoryPage(
          page: page,
          pageIndex: index,
          totalPages: pages.length,
          storyTitle: () {
            final n = widget.story.sequenceIndex;
            final prefix = n != null && n > 0 ? '$n. ' : '';
            return '$prefix${widget.story.title}';
          }(),
          storyIdeaId: widget.storyIdeaId,
          topicId: widget.topicId,
          topicTitle: widget.topicTitle,
          lessonDuration: widget.lessonDuration,
          onCloseStory: widget.onCloseStory,
          remainingSeconds: _remainingSeconds,
          hasStartedReading: _hasStartedReading,
          isTimerRunning: _isTimerRunning,
          isLastPage: isLastPage,
          quiz: widget.story.quiz,
          onStartQuiz: _openQuiz,
          onStartReading: _handleStartReading,
          onResumeReading: _handleResumeReading,
          onStopReading: _handleStopReading,
          onHome: widget.onHome,
          onPrevPage: !_hasStartedReading || isFirstPage
              ? null
              : () {
                  setState(() {
                    _currentPageIndex = (_currentPageIndex - 1).clamp(
                      0,
                      pages.length - 1,
                    );
                  });
                },
          onNextPage: !_hasStartedReading || isLastPage
              ? null
              : () {
                  setState(() {
                    _currentPageIndex = (_currentPageIndex + 1).clamp(
                      0,
                      pages.length,
                    );
                  });
                },
        ),
      ],
    );
  }
}

class _StoryPage extends StatelessWidget {
  final StoryPages page;
  final int pageIndex;
  final int totalPages;
  final String storyTitle;
  final String storyIdeaId;
  final String topicId;
  final String topicTitle;
  final int lessonDuration;
  final VoidCallback onCloseStory;
  final int remainingSeconds;
  final bool hasStartedReading;
  final bool isTimerRunning;
  final bool isLastPage;
  final List<StoryQuiz> quiz;
  final VoidCallback onStartQuiz;
  final VoidCallback onStartReading;
  final VoidCallback onResumeReading;
  final VoidCallback onStopReading;
  final VoidCallback? onPrevPage;
  final VoidCallback? onNextPage;
  final VoidCallback onHome;
  const _StoryPage({
    required this.page,
    required this.pageIndex,
    required this.totalPages,
    required this.storyTitle,
    required this.storyIdeaId,
    required this.topicId,
    required this.topicTitle,
    required this.lessonDuration,
    required this.onCloseStory,
    required this.remainingSeconds,
    required this.hasStartedReading,
    required this.isTimerRunning,
    required this.isLastPage,
    required this.quiz,
    required this.onStartQuiz,
    required this.onStartReading,
    required this.onResumeReading,
    required this.onStopReading,
    this.onPrevPage,
    this.onNextPage,
    required this.onHome,
  });

  static String _resolveImageUrl(String url) => resolveNetworkImageUrl(url);

  List<TextSpan> _buildTextSpans(
    String text,
    TextStyle normalStyle,
    TextStyle boldStyle,
  ) {
    String processedText = text
        .replaceAll(RegExp(r'<(strong|b|p)>', caseSensitive: false), '*')
        .replaceAll(RegExp(r'</(strong|b)>', caseSensitive: false), '*');

    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    processedText = processedText.replaceAll(exp, '');

    List<TextSpan> spans = [];
    List<String> parts = processedText.split('*');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        spans.add(TextSpan(text: parts[i], style: boldStyle));
      } else {
        spans.add(TextSpan(text: parts[i], style: normalStyle));
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final isMarkingAsRead = provider.isMarkingStoryAsRead(storyIdeaId);
    final isMarkedAsRead = provider.isStoryMarkedAsRead(storyIdeaId);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        //* Fixed hero image (Netflix-style “video” area)
        _StoryImage(
          imageUrl: _resolveImageUrl(page.imageUrl),
          onHome: onHome,
          //*image height
          height: 270.w,
          pageLabel: 'Page ${pageIndex + 1} of $totalPages',
          onClose: onCloseStory,
        ),
        Container(
          color: AppColors.backgroundColor,
          padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 0.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppText(
                      text: storyTitle,
                      style: AppTextStyles.bold(
                        fontSize: 22.sp,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  12.w.horizontalSpace,
                  GestureDetector(
                    onTap: () => shareTopicLink(topicId: topicId),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Icon(
                        Icons.share_outlined,
                        size: 24.sp,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                ],
              ),
              8.w.verticalSpace,
              //* Page and duration meta info
              Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 16.sp,
                    color: AppColors.black.withValues(alpha: 0.6),
                  ),
                  6.w.horizontalSpace,
                  AppText(
                    text: '$totalPages Pages',
                    style: AppTextStyles.medium(
                      fontSize: 13.sp,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  12.w.horizontalSpace,
                  Icon(
                    Icons.access_time,
                    size: 16.sp,
                    color: AppColors.black.withValues(alpha: 0.6),
                  ),
                  6.w.horizontalSpace,
                  AppText(
                    text: '${lessonDuration > 0 ? lessonDuration : 5} mins',
                    style: AppTextStyles.medium(
                      fontSize: 13.sp,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  if (hasStartedReading)
                    _ReadingTimerText(remainingSeconds: remainingSeconds),
                ],
              ),
              10.w.verticalSpace,
              //* Page number
              AppText(
                text: 'Page ${pageIndex + 1}',
                style: AppTextStyles.semibold(
                  fontSize: 14.sp,
                  color: AppColors.teal,
                ),
              ),
              6.w.verticalSpace,
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: AppTextStyles.regular(
                    fontSize: 16.sp,
                    color: AppColors.black.withValues(alpha: 0.8),
                  ),
                  children: _buildTextSpans(
                    page.text,
                    AppTextStyles.regular(
                      fontSize: 16.sp,
                      color: AppColors.black.withValues(alpha: 0.8),
                    ).copyWith(height: 1.37),
                    AppTextStyles.bold(
                      fontSize: 16.sp,
                      color: AppColors.black,
                    ).copyWith(height: 1.37),
                  ),
                ),
              ),
              12.w.verticalSpace,
              if (onPrevPage != null || onNextPage != null)
                Row(
                  children: [
                    if (onPrevPage != null)
                      Expanded(
                        child: AppOutlinedButton(
                          onTap: onPrevPage,
                          borderColor: AppColors.teal,
                          textStyle: AppTextStyles.semibold(
                            fontSize: 14.sp,
                            color: AppColors.teal,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 4.w,
                            children: [
                              Icon(
                                Icons.arrow_back_ios,
                                size: 16.sp,
                                color: AppColors.teal,
                              ),
                              AppText(
                                text: 'Previous',
                                style: AppTextStyles.semibold(
                                  fontSize: 14.sp,
                                  color: AppColors.teal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (onPrevPage != null && onNextPage != null)
                      12.w.horizontalSpace,
                    if (onNextPage != null)
                      Expanded(
                        child: AppOutlinedButton(
                          onTap: onNextPage,
                          borderColor: AppColors.teal,
                          textStyle: AppTextStyles.semibold(
                            fontSize: 14.sp,
                            color: AppColors.teal,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 4.w,
                            children: [
                              AppText(
                                text: 'Next',
                                style: AppTextStyles.semibold(
                                  fontSize: 14.sp,
                                  color: AppColors.teal,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16.sp,
                                color: AppColors.teal,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

              hasStartedReading
                  ? AppOutlinedButton(
                      margin: EdgeInsets.only(top: 10.w),
                      onTap: isTimerRunning ? onStopReading : onResumeReading,
                      borderColor: AppColors.teal,
                      textStyle: AppTextStyles.semibold(
                        fontSize: 14.sp,
                        color: AppColors.teal,
                      ),
                      child: AppText(
                        text: isTimerRunning ? 'Stop' : 'Resume',
                        style: AppTextStyles.semibold(
                          fontSize: 14.sp,
                          color: AppColors.teal,
                        ),
                      ),
                    )
                  : AppFilledButton(
                      text: 'Start',
                      backgroundColor: AppColors.teal,
                      onTap: onStartReading,
                    ),

              if (isLastPage) ...[
                20.w.verticalSpace,
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.lighttealcolor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.teal.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: 'Finished reading?',
                        style: AppTextStyles.semibold(
                          fontSize: 16.sp,
                          color: AppColors.black,
                        ),
                      ),
                      8.w.verticalSpace,
                      AppText(
                        text: 'Test your understanding with a short quiz.',
                        style: AppTextStyles.regular(
                          fontSize: 14.sp,
                          color: AppColors.black.withValues(alpha: 0.7),
                        ),
                      ),
                      16.w.verticalSpace,

                      SizedBox(
                        width: double.infinity,
                        child: AppOutlinedButton(
                          onTap: isMarkedAsRead || isMarkingAsRead
                              ? null
                              : () {
                                  context.read<StoryProvider>().markStoryAsRead(
                                    storyIdeaId: storyIdeaId,
                                    context: context,
                                  );
                                },
                          borderColor: isMarkedAsRead
                              ? AppColors.teal.withValues(alpha: 0.35)
                              : AppColors.teal,
                          textStyle: AppTextStyles.semibold(
                            fontSize: 14.sp,
                            color: isMarkedAsRead
                                ? AppColors.teal.withValues(alpha: 0.5)
                                : AppColors.teal,
                          ),
                          isLoading: isMarkingAsRead,
                          foregroundColor: AppColors.teal,
                          child: AppText(
                            text: isMarkedAsRead
                                ? 'Marked as Read'
                                : 'Mark as Read',
                            style: AppTextStyles.semibold(
                              fontSize: 14.sp,
                              color: isMarkedAsRead
                                  ? AppColors.teal.withValues(alpha: 0.5)
                                  : AppColors.teal,
                            ),
                          ),
                        ),
                      ),
                      12.w.verticalSpace,
                      AppFilledButton(
                        text: 'Start Quiz',
                        backgroundColor: AppColors.teal,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            useRootNavigator: true,
                            builder: (dialogContext) => ZoomIn(
                              child: AlertDialog(
                                backgroundColor: AppColors.white,
                                title: Text(
                                  "Are you sure you want to start quiz or want to read?",
                                  style: AppTextStyles.textStyle20Regular,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(false),
                                    child: Text(
                                      "Cancel",
                                      style: AppTextStyles.regular(
                                        fontSize: 17.sp,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(true),
                                    child: Text(
                                      "Yes",
                                      style: AppTextStyles.regular(
                                        fontSize: 17.sp,
                                        color: AppColors.redColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          if (confirm == true && context.mounted) onStartQuiz();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StoryImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final String pageLabel;
  final VoidCallback onClose;
  final VoidCallback onHome;
  const _StoryImage({
    required this.imageUrl,
    required this.height,
    required this.pageLabel,
    required this.onClose,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              height: height,
              width: double.infinity,
              progressIndicatorBuilder: (_, __, progress) =>
                  _loadingProgress(height, progress.progress),
              errorWidget: (_, url, error) {
                logNetworkImageError(
                  tag: 'SharedStory.hero',
                  url: url,
                  error: error,
                );
                return _placeholder(height);
              },
              imageBuilder: (context, imageProvider) => Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    height: height,
                    width: double.infinity,
                  ),
                  Positioned(
                    top: 12.w,
                    right: 12.w,
                    child: Row(
                      spacing: 10.w,
                      children: [
                        GlassIconButton(
                          onTap: onHome,
                          child: Icon(
                            Icons.home_rounded,
                            size: 18.sp,
                            color: AppColors.white,
                          ),
                        ),
                        GlassIconButton(
                          onTap: onClose,
                          child: Icon(
                            Icons.close_rounded,
                            size: 18.sp,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      margin: EdgeInsets.all(10.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.w,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: AppText(
                        text: pageLabel,
                        style: AppTextStyles.medium(
                          fontSize: 12.sp,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            _placeholder(height),
        ],
      ),
    );
  }

  static Widget _loadingProgress(double h, double? progress) {
    final value = progress?.clamp(0.0, 1.0);
    final percent = value != null ? (value * 100).round() : null;
    return Container(
      height: h,
      width: double.infinity,
      color: AppColors.shimmerBaseColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 3,
                backgroundColor: AppColors.lighttealcolor,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
              ),
            ),
            12.h.verticalSpace,
            AppText(
              text: percent != null ? '$percent%' : 'Loading...',
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: AppColors.black.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _placeholder(double h) {
    return SizedBox(
      height: h,
      width: double.infinity,
      child: const NoImageFound(compact: true),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double size;
  final BorderRadius borderRadius;

  const GlassIconButton({
    super.key,
    required this.child,
    required this.onTap,
    this.size = 28,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: InkWell(
          onTap: onTap,
          child: Container(
            // height: size,
            // width: size,
            padding: EdgeInsets.all(6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: borderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
