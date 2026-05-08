import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/share_helper.dart';
import 'package:redstreakapp/core/widgets/global_widgets.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/services/home/story_api_service.dart';
import 'package:redstreakapp/screens/home/widgets/home_section_shimmers.dart';
import 'package:shimmer/shimmer.dart';

class MyStoryReadingScreen extends StatefulWidget {
  const MyStoryReadingScreen({super.key});

  @override
  State<MyStoryReadingScreen> createState() => _MyStoryReadingScreenState();
}

class _MyStoryReadingScreenState extends State<MyStoryReadingScreen> {
  int _currentPageIndex = 0;
  Timer? _readingTimer;
  int _remainingSeconds = 0;
  bool _hasStartedReading = false;
  bool _isTimerRunning = false;
  bool _timeUpDialogShown = false;

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startReadingTimer(int lessonDurationMinutes) {
    _readingTimer?.cancel();
    final initialMinutes = lessonDurationMinutes > 0
        ? lessonDurationMinutes
        : 10;
    setState(() {
      _hasStartedReading = true;
      _isTimerRunning = true;
      _remainingSeconds = initialMinutes * 60;
    });

    _readingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isTimerRunning) return;
      if (_remainingSeconds <= 1) {
        _readingTimer?.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isTimerRunning = false;
        });
        _showTimeUpDialog();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _showTimeUpDialog() {
    if (!mounted) return;
    if (_timeUpDialogShown) return;
    _timeUpDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(20.w, 18.w, 20.w, 0),
          contentPadding: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 0),
          actionsPadding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 20.w),
          title: AppText(
            text: "Time’s up",
            style: AppTextStyles.bold(
              fontSize: 18.sp,
              color: AppColors.black,
            ),
          ),
          content: AppText(
            text: "We’ll save your progress and take you back.",
            style: AppTextStyles.medium(
              fontSize: 14.sp,
              color: AppColors.black.withValues(alpha: 0.7),
            ),
          ),
          actions: [
            AppFilledButton(
              text: "Save & exit",
              onTap: () {
                dialogContext.pop();
                if (!mounted) return;
                _saveProgressAndExit();
              },
              backgroundColor: AppColors.teal,
              fixedSize: Size(double.infinity, 44.h),
            ),
          ],
        );
      },
    );
  }

  void _saveProgressAndExit() {
    final provider = context.read<StoryProvider>();
    if (provider.stories.isEmpty) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed(AppRoutes.homeScreen.name);
      }
      return;
    }

    final story = provider.stories.first;
    final pages = story.pages;
    final totalPages = pages.length;
    if (totalPages > 0) {
      final safeIndex = _currentPageIndex.clamp(0, totalPages - 1);
      final isLastPage = safeIndex >= totalPages - 1;
      // Keep the same rule as the other reader: don't count last page as read
      // just by viewing it (it should be confirmed via Next/Take Quiz).
      if (!isLastPage) {
        StoryApiService.instance.updatePageProgress(
          storyIdeaId: story.id,
          pageIndex: safeIndex,
        );
      }
    }

    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.homeScreen.name);
    }
  }

  void _togglePauseResume() {
    if (!_hasStartedReading) return;
    setState(() => _isTimerRunning = !_isTimerRunning);
  }

  void _goToNextPage(int totalPages) {
    if (_currentPageIndex >= totalPages - 1) return;
    setState(() => _currentPageIndex++);
  }

  void _goToPreviousPage() {
    if (_currentPageIndex <= 0) return;
    setState(() => _currentPageIndex--);
  }

  @override
  void dispose() {
    _readingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Consumer<StoryProvider>(
        builder: (context, provider, child) {
          if (provider.isCreateStoryLoading ||
              provider.isGenerateSingleStoryLoading) {
            return HomeSectionShimmer.createdStoryReadingUIShimmer();
          }
          if (provider.stories.isEmpty) {
            final raw = provider.generateStoryError;
            final msg = () {
              final m = (raw ?? '').trim();
              if (m.isEmpty) return "We couldn’t load this story right now.";
              final lower = m.toLowerCase();
              if (lower.contains('timeout') || lower.contains('timed out')) {
                return "This is taking longer than expected. Please try again.";
              }
              if (lower.contains('socket') ||
                  lower.contains('network') ||
                  lower.contains('internet') ||
                  lower.contains('connection')) {
                return "No internet connection. Please check your network and try again.";
              }
              return "We couldn’t load this story right now. Please try again.";
            }();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 56.w,
                        color: AppColors.black.withValues(alpha: 0.35),
                      ),
                      14.w.verticalSpace,
                      AppText(
                        text: msg,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.medium(
                          fontSize: 16.sp,
                          color: AppColors.black.withValues(alpha: 0.75),
                        ),
                      ),
                      20.w.verticalSpace,
                      AppFilledButton(
                        text: "Back",
                        onTap: () {
                          if (!context.mounted) return;
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.goNamed(AppRoutes.homeScreen.name);
                          }
                        },
                        backgroundColor: AppColors.teal,
                        fixedSize: Size(320.w, 44.h),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final story = provider.stories.first;
          final pages = story.pages;
          if (pages.isEmpty) {
            return const Center(child: AppText(text: "No pages available"));
          }

          final safePageIndex = _currentPageIndex.clamp(0, pages.length - 1);
          final page = pages[safePageIndex];
          final isFirstPage = safePageIndex == 0;
          final isLastPage = safePageIndex == pages.length - 1;
          final heroImageUrl = page.imageUrl.trim().isNotEmpty
              ? page.imageUrl
              : story.thumbnailUrl.trim();

          return Column(
            children: [
              SizedBox(
                height: 310.w,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (heroImageUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: heroImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: AppColors.shimmerBaseColor,
                          highlightColor: AppColors.shimmerHighlightColor,
                          child: Container(color: AppColors.shimmerBaseColor),
                        ),
                        errorWidget: (_, __, ___) => const NoImageFound(),
                      )
                    else
                      const NoImageFound(),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(14.w, 18.w, 14.w, 14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _MyStoryCircleButton(
                                  onTap: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.goNamed(
                                        AppRoutes
                                            .createdStorySummaryScreen
                                            .name,
                                      );
                                    }
                                  },
                                  child: SvgIcon(
                                    AppAssets.backButton,
                                    size: 12.w,
                                    color: AppColors.black,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: AppText(
                                    text:
                                        'Page ${safePageIndex + 1} of ${pages.length}',
                                    style: AppTextStyles.bold(
                                      fontSize: 12.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: AppText(
                                    text:
                                        '${safePageIndex + 1}. ${story.title}',
                                    style: AppTextStyles.bold(
                                      fontSize: 24,
                                      color: AppColors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                10.w.horizontalSpace,
                                if (_hasStartedReading) ...[
                                  _MyStoryCircleButton(
                                    onTap: _togglePauseResume,
                                    child: Icon(
                                      _isTimerRunning
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 18.w,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  8.w.horizontalSpace,
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: AppText(
                                      text: _formatDuration(_remainingSeconds),
                                      style: AppTextStyles.bold(
                                        fontSize: 15.sp,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                ] else
                                  _MyStoryCircleButton(
                                    onTap: () =>
                                        shareSingleStory(storyIdeaId: story.id),
                                    child: SvgIcon(
                                      AppAssets.shareIcon,
                                      size: 18.w,
                                      color: AppColors.black,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 12.w, 16.w, 10.w),
                  child: Column(
                    children: [
                      AppText(
                        text: page.text,
                        style: AppTextStyles.medium(
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                      ),
                      16.w.verticalSpace,
                      CachedNetworkImage(
                        imageUrl: page.imageUrl,
                        height: 210.w,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: AppColors.shimmerBaseColor,
                          highlightColor: AppColors.shimmerHighlightColor,
                          child: Container(color: AppColors.shimmerBaseColor),
                        ),
                        errorWidget: (_, __, ___) => const NoImageFound(),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_hasStartedReading)
                      AppButton(
                        text: "Start Reading",
                        onTap: () =>
                            _startReadingTimer(story.lessonDuration ?? 10),
                        fontSize: 14.sp,
                      )
                    else ...[
                      AppButton(
                        text: isLastPage ? "Take Quiz" : "Next Page",
                        onTap: isLastPage
                            ? () {
                              context.pushReplacementNamed(
                                AppRoutes.startQuizScreen.name,
                                extra: {
                                  'storyId': story.id,
                                  'storyTitle': story.title,
                                  'storyImageUrl': story.thumbnailUrl,
                                },
                              );
                            }
                            : () => _goToNextPage(pages.length),
                        fontSize: 14.sp,
                      ),
                      if (!isFirstPage) ...[
                        8.w.verticalSpace,
                        GestureDetector(
                          onTap: _goToPreviousPage,
                          child: AppText(
                            text: "Previous Page",
                            style: AppTextStyles.medium(
                              fontSize: 12,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                      ],
                    ],
                    8.w.verticalSpace,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MyStoryCircleButton extends StatelessWidget {
  const _MyStoryCircleButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 32.w,
          height: 32.w,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
