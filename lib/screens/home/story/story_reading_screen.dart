import 'dart:async';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/models/home/story_models/story_history_model.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/screens/home/widgets/home_section_shimmers.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/helper/log_helper.dart';
import '../../../core/network/base_api_service.dart';
import '../../../routes/user_routes.dart';

class CreatedStoryReadingScreen extends StatefulWidget {
  final StoryHistoryModel? initialStory;
  final String? storyIdeaId;

  const CreatedStoryReadingScreen({
    super.key,
    this.initialStory,
    this.storyIdeaId,
  });

  @override
  State<CreatedStoryReadingScreen> createState() =>
      _CreatedStoryReadingScreenState();
}

class _CreatedStoryReadingScreenState extends State<CreatedStoryReadingScreen> {
  final PageController _pageController = PageController();
  int _remainingSeconds = 0;
  bool _timerStarted = false;
  bool _isTimerRunning = false;
  Timer? _countdownTimer;
  bool _fetchStarted = false;
  bool _storyNotGenerated = false;
  StoryHistoryModel? _story;

  StoryHistoryModel? get _activeStory => _story ?? context.read<HomeProvider>().story;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _story = widget.initialStory;
    _initForStory();
    _fetchStoryIfNeeded();
  }

  @override
  void didUpdateWidget(CreatedStoryReadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldStoryId = oldWidget.initialStory?.id ?? oldWidget.storyIdeaId;
    final newStoryId = widget.initialStory?.id ?? widget.storyIdeaId;
    if (oldStoryId != newStoryId) {
      _story = widget.initialStory;
      _fetchStarted = false;
      _storyNotGenerated = false;
      _timerStarted = false;
      _isTimerRunning = false;
      _countdownTimer?.cancel();
      _countdownTimer = null;
      _pageController.jumpToPage(0);
      _initForStory();
      _fetchStoryIfNeeded();
    }
  }

  void _fetchStoryIfNeeded() {
    if (_story != null || widget.storyIdeaId == null || _fetchStarted) return;
    _fetchStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
     
      context.read<HomeProvider>().getStoryByIdea(
        context: context,
        storyIdea: widget.storyIdeaId!,
        onSuccess: (story) {
          if (!mounted) return;
          setState(() {
            _story = story;
            _storyNotGenerated = false;
          });
          _initForStory();
        },
        onStoryNotGenerated: () {
          if (!mounted) return;
          setState(() => _storyNotGenerated = true);
        },
      );
    });
  }

  void _initForStory() {
    final activeStory = _activeStory;
    if (activeStory == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<StoryProvider>();
      provider.resetStoryPageIndex();

      final fromStory = activeStory.lessonDuration ?? 0;
      final fromProvider = provider.lessonDuration;
      final durationMinutes = (fromStory > 0 ? fromStory : fromProvider) > 0
          ? (fromStory > 0 ? fromStory : fromProvider)
          : 5;

      setState(() {
        _remainingSeconds = durationMinutes * 60;
        _timerStarted = false;
        _isTimerRunning = false;
      });
    });
  }

  void _startCountdownTimer() {
    if (_timerStarted) return;

    final activeStory = _activeStory;
    if (activeStory == null) return;
    final fromStory = activeStory.lessonDuration;
    final fromProvider = context.read<StoryProvider>().lessonDuration;
    final durationMinutes = (fromStory ?? fromProvider) > 0
        ? (fromStory ?? fromProvider)
        : 5;
    setState(() {
      _timerStarted = true;
      _isTimerRunning = true;
      _remainingSeconds = durationMinutes * 60;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_remainingSeconds <= 0) {
        t.cancel();
        _countdownTimer = null;
        if (mounted) {
          setState(() {
            _isTimerRunning = false;
          });
          _openQuiz(activeStory);
        }
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _pauseCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (!mounted) return;
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resumeCountdownTimer() {
    if (_isTimerRunning || _remainingSeconds <= 0) return;

    final activeStory = _activeStory;
    if (activeStory == null) return;

    setState(() {
      _isTimerRunning = true;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_remainingSeconds <= 0) {
        t.cancel();
        _countdownTimer = null;
        if (mounted) {
          setState(() {
            _isTimerRunning = false;
          });
          _openQuiz(activeStory);
        }
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _openQuiz(StoryHistoryModel activeStory) {
    context.read<StoryProvider>().resetStoryPageIndex();
    _pageController.jumpToPage(0);
    context.pushNamed(
      AppRoutes.startQuizScreen.name,
      extra: {
        "quizzes": activeStory.quiz,
        "storyTitle": activeStory.title,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final provider = context.watch<StoryProvider>();
    final activeStory = _story ?? homeProvider.story;

    if (activeStory == null) {
      final isCreatingOrFetching = homeProvider.isGettingStoryLoading ||
          provider.isGenerateSingleStoryLoading;
      return AppLayout(
        body: isCreatingOrFetching
            ? Container(
                width: double.infinity,
                height: double.infinity,
                color: AppColors.backgroundColor,
                child: HomeSectionShimmer.storyReadingScreenShimmer(),
              )
            : Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _storyNotGenerated
                            ? Icons.auto_stories_outlined
                            : Icons.error_outline_rounded,
                        size: 48.sp,
                        color: AppColors.black.withValues(alpha: 0.5),
                      ),
                      16.w.verticalSpace,
                      AppText(
                        text: _storyNotGenerated
                            ? "Story not created yet.\nThe author hasn't generated this story."
                            : "Could not load story. Please try again.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.sfProDisplayMedium(
                          fontSize: 16.sp,
                          color: AppColors.black.withValues(alpha: 0.7),
                        ),
                      ),
                      24.w.verticalSpace,
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text("Go back"),
                      ),
                    ],
                  ),
                ),
              ),
      );
    }

    final totalPages = activeStory.pages.length;
    final currentPageIndex = provider.currentStoryPageIndex.clamp(
      0,
      totalPages - 1,
    );
    final durationMinutes = (() {
      final fromStory = activeStory.lessonDuration ?? 0;
      final fromProvider = provider.lessonDuration;
      return (fromStory > 0 ? fromStory : fromProvider) > 0
          ? (fromStory > 0 ? fromStory : fromProvider)
          : 10;
    })();
    final isLastPage = currentPageIndex == totalPages - 1;
    final hasPreviousPage = currentPageIndex > 0;
    final showReadingControls = _timerStarted && !isLastPage;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showLeaveStoryConfirmation(context: context);
      },
      child: AppLayout(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: totalPages,
                  onPageChanged: (index) {
                    Logger.info(
                      "Image $index: ${activeStory.pages[index].imageUrl}",
                    );
                    context.read<StoryProvider>().setCurrentStoryPageIndex(
                      index,
                    );
                  },
                  itemBuilder: (context, index) {
                    final page = activeStory.pages[index];
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Stack(
                          children: [
                            _StoryImage(
                              imageUrl: page.imageUrl,
                              isFirstPage: index == 0,
                              onClose: () {
                                showLeaveStoryConfirmation(context: context);
                              },
                            ),
                            Positioned(
                              left: 12.w,
                              bottom: 12.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.w,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: AppText(
                                  text: "Page ${index + 1} of $totalPages",
                                  style: AppTextStyles.sfProDisplaySemibold(
                                    fontSize: 11.sp,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 14.w, 16.w, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: activeStory.title,
                                style: AppTextStyles.sfProDisplayBold(
                                  fontSize: 28.sp,
                                  height: 1.15,
                                  color: AppColors.black,
                                ),
                              ),
                              8.w.verticalSpace,
                              Row(
                                children: [
                                  Icon(
                                    Icons.menu_book_outlined,
                                    size: 15.sp,
                                    color: AppColors.black.withValues(
                                      alpha: 0.55,
                                    ),
                                  ),
                                  5.w.horizontalSpace,
                                  AppText(
                                    text: "$totalPages pages",
                                    style: AppTextStyles.sfProDisplayMedium(
                                      fontSize: 13.sp,
                                      color: AppColors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                  14.w.horizontalSpace,
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 15.sp,
                                    color: AppColors.black.withValues(
                                      alpha: 0.55,
                                    ),
                                  ),
                                  5.w.horizontalSpace,
                                  AppText(
                                    text: "$durationMinutes mins",
                                    style: AppTextStyles.sfProDisplayMedium(
                                      fontSize: 13.sp,
                                      color: AppColors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                  if (_timerStarted) ...[
                                    const Spacer(),
                                    AppText(
                                      text:
                                          "Time left: ${_formatDuration(_remainingSeconds)}",
                                      style: AppTextStyles.sfProDisplaySemibold(
                                        fontSize: 16.sp,
                                        color: AppColors.teal,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              12.w.verticalSpace,
                              AppText(
                                text: "Page ${index + 1}",
                                style: AppTextStyles.sfProDisplaySemibold(
                                  fontSize: 14.sp,
                                  color: AppColors.teal,
                                ),
                              ),
                              10.w.verticalSpace,
                              RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  style: AppTextStyles.sfProDisplayRegular(
                                    fontSize: 16.sp,
                                    color: AppColors.black.withValues(
                                      alpha: 0.82,
                                    ),
                                  ),
                                  children: _buildTextSpans(
                                    page.text,
                                    AppTextStyles.sfProDisplayRegular(
                                      fontSize: 16.sp,
                                      color: AppColors.black.withValues(
                                        alpha: 0.82,
                                      ),
                                    ).copyWith(height: 1.45),
                                    AppTextStyles.sfProDisplayBold(
                                      fontSize: 16.sp,
                                      color: AppColors.black,
                                    ).copyWith(height: 1.45),
                                  ),
                                ),
                              ),
                              24.w.verticalSpace,
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_timerStarted)
                        AppFilledButton(
                          backgroundColor: AppColors.teal,
                          text: "Start",
                          onTap: _startCountdownTimer,
                        )
                      else if (!_isTimerRunning)
                        AppOutlinedButton(
                          onTap: _resumeCountdownTimer,
                          borderColor: AppColors.teal,
                          textStyle: AppTextStyles.sfProDisplaySemibold(
                            fontSize: 14.sp,
                            color: AppColors.teal,
                          ),
                          child: AppText(
                            text: "Resume",
                            style: AppTextStyles.sfProDisplaySemibold(
                              fontSize: 14.sp,
                              color: AppColors.teal,
                            ),
                          ),
                        )
                      else if (showReadingControls)
                        AppOutlinedButton(
                          onTap: _pauseCountdownTimer,
                          borderColor: AppColors.teal,
                          textStyle: AppTextStyles.sfProDisplaySemibold(
                            fontSize: 14.sp,
                            color: AppColors.teal,
                          ),
                          child: AppText(
                            text: "Stop",
                            style: AppTextStyles.sfProDisplaySemibold(
                              fontSize: 14.sp,
                              color: AppColors.teal,
                            ),
                          ),
                        )
                      else
                        AppFilledButton(
                          backgroundColor: AppColors.teal,
                          text: "Take Quiz",
                          onTap: () {
                            _openQuiz(activeStory);
                          },
                        ),
                      if (showReadingControls) ...[
                        12.h.verticalSpace,
                        Row(
                          children: [
                            Expanded(
                              child: AppOutlinedButton(
                                onTap: hasPreviousPage
                                    ? () {
                                        _pageController.previousPage(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    : null,
                                borderColor: AppColors.teal,
                                textStyle: AppTextStyles.sfProDisplaySemibold(
                                  fontSize: 14.sp,
                                  color: hasPreviousPage
                                      ? AppColors.teal
                                      : AppColors.teal.withValues(alpha: 0.35),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 16.sp,
                                      color: hasPreviousPage
                                          ? AppColors.teal
                                          : AppColors.teal.withValues(
                                              alpha: 0.35,
                                            ),
                                    ),
                                    4.w.horizontalSpace,
                                    AppText(
                                      text: "Previous",
                                      style: AppTextStyles.sfProDisplaySemibold(
                                        fontSize: 14.sp,
                                        color: hasPreviousPage
                                            ? AppColors.teal
                                            : AppColors.teal.withValues(
                                                alpha: 0.35,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            12.w.horizontalSpace,
                            Expanded(
                              child: AppFilledButton(
                                backgroundColor: AppColors.teal,
                                text: "See Next Page",
                                onTap: () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showLeaveStoryConfirmation({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ZoomIn(
          child: AlertDialog(
            backgroundColor: AppColors.backgroundColor,
            title: Text(
              "Are you sure you want to quit this story?",
              style: AppTextStyles.textStyle20Regular,
            ),
            actions: [
              myActionButtonTheme(
                onPressed: () {
                  dialogContext.pop();
                  final provider = context.read<StoryProvider>();
                  provider.clareStoryData();
                  provider.clearStoryFields();
                  provider.resetStoryPageIndex();
                  provider.setCurrentStoryIndex = 0;
                  context.pop();
                  // AppRouter.indexedStackNavigationShell?.goBranch(1);
                  // AppRouter.goRouter.goNamed(AppRoutes.searchScreen.name);
                },
                title: "Quit",
              ),
              myActionButtonTheme(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                title: "Cancel",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget myActionButtonTheme({
    required VoidCallback onPressed,
    required String title,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: AppTextStyles.sfProDisplayRegular(
          color: (title == "Home" || title == "Quit")
              ? AppColors.redColor
              : AppColors.black,
          fontSize: 17.sp,
        ),
      ),
    );
  }

  Shimmer imageShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        height: 220.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
    );
  }

  List<TextSpan> _buildTextSpans(
    String text,
    TextStyle normalStyle,
    TextStyle boldStyle,
  ) {
    String processedText = text
        .replaceAll(RegExp(r'<(strong|b)>', caseSensitive: false), '*')
        .replaceAll(RegExp(r'</(strong|b)>', caseSensitive: false), '*');

    final exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
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

  String _formatDuration(int totalSeconds) {
    final safeSeconds = totalSeconds.clamp(0, 999 * 60);
    final minutes = safeSeconds ~/ 60;
    final seconds = safeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Resolves and displays a story page image with retry on error.
class _StoryImage extends StatefulWidget {
  final String imageUrl;
  final bool isFirstPage;
  final VoidCallback onClose;

  const _StoryImage({
    required this.imageUrl,
    required this.isFirstPage,
    required this.onClose,
  });

  @override
  State<_StoryImage> createState() => _StoryImageState();
}

class _StoryImageState extends State<_StoryImage> {
  int _retryKey = 0;

  String get _resolvedUrl {
    final url = widget.imageUrl.trim();
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return DioClient.baseUrl + url;
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;

    if (url.isEmpty) {
      return _buildErrorWidget();
    }

    return CachedNetworkImage(
      key: ValueKey('$url-$_retryKey'),
      height: 270.w,
      width: double.infinity,
      fit: BoxFit.cover,
      imageUrl: url,
      httpHeaders: const {
        'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp/1.0)',
      },
      placeholder: (context, url) => _buildShimmer(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      imageBuilder: (context, imageProvider) => Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: imageProvider,
            fit: BoxFit.cover,
            height: 280,
            width: double.infinity,
          ),
          Positioned(
            top: 12.w,
            left: 12.w,
            child: GlassIconButton(
              onTap: widget.onClose,
              child: Icon(
                Icons.close_rounded,
                size: 18.sp,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: Colors.grey[500],
          ),
          8.verticalSpace,
          Text(
            'Image could not load',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          8.verticalSpace,
          GestureDetector(
            onTap: () {
              CachedNetworkImage.evictFromCache(widget.imageUrl);
              setState(() => _retryKey++);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
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
    this.size = 36,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: size,
            width: size,
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