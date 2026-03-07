import 'dart:async';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/models/home/story_models/readable_story.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/helper/log_helper.dart';
import '../../../core/network/base_api_service.dart';
import '../../../models/home/story_models/story_model.dart';
import '../../../routes/user_routes.dart';

class ReadingScreen extends StatefulWidget {
  final IReadableStory story;

  const ReadingScreen({super.key, required this.story});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final PageController _pageController = PageController();
  int _remainingSeconds = 0;
  bool _timerStarted = false;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initForStory();
  }

  @override
  void didUpdateWidget(ReadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.story.id != widget.story.id) {
      _timerStarted = false;
      _countdownTimer?.cancel();
      _countdownTimer = null;
      _pageController.jumpToPage(0);
      _initForStory();
    }
  }

  void _initForStory() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<StoryProvider>();
      provider.resetStoryPageIndex();

      final fromStory = widget.story.lessonDuration ?? 0;
      final fromProvider = provider.lessonDuration;
      final durationMinutes = (fromStory > 0 ? fromStory : fromProvider) > 0
          ? (fromStory > 0 ? fromStory : fromProvider)
          : 5;

      setState(() {
        _remainingSeconds = durationMinutes * 60;
      });
    });
  }

  void _startCountdownTimer() {
    if (_timerStarted) return;
    _timerStarted = true;

    final fromStory = widget.story.lessonDuration;
    final fromProvider = context.read<StoryProvider>().lessonDuration;
    final durationMinutes = (fromStory ?? fromProvider) > 0
        ? (fromStory ?? fromProvider)
        : 5;
    setState(() => _remainingSeconds = durationMinutes * 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_remainingSeconds <= 0) {
        t.cancel();
        if (mounted) {
          context.read<StoryProvider>().resetStoryPageIndex();
          _pageController.jumpToPage(0);
          context.pushNamed(
            AppRoutes.startQuizScreen.name,
            extra: {
              "quizzes": widget.story.quiz ?? <StoryQuiz>[],
              "storyTitle": widget.story.title ?? "",
            },
          );
          // context.read<StoryProvider>().resetStoryPageIndex();
          // _pageController.jumpToPage(0);
          // context.pushNamed(
          //   AppRoutes.startQuizScreen.name,
          //   extra: {
          //     "quizzes": widget.story.quiz ?? <StoryQuiz>[],
          //     "storyTitle": widget.story.title ?? "",
          //   },
          // );
        }
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showLeaveStoryConfirmation(context: context);
      },
      child: AppLayout(
        body: Column(
          children: [
            //* 1. Background Image (Header)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                // height: 210,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      AppAssets.dargon,
                    ), // Using dragon/dinosaur asset
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: [
                            GlassIconButton(
                              onTap: () =>
                                  showLeaveStoryConfirmation(context: context),
                              child: SvgIcon(
                                AppAssets.close,
                                color: Colors.white,
                                size: 40.sp,
                              ),
                            ),

                            Spacer(),
                            SvgIcon(
                              AppAssets.font,
                              color: Colors.white,
                              size: 40.sp,
                            ),
                            12.w.horizontalSpace,

                            GlassIconButton(
                              onTap: () {},
                              child: SvgIcon(
                                AppAssets.bookmark,
                                color: Colors.white,
                                size: 40.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //todo Header Text Content (Title)
                    Padding(
                      padding: EdgeInsets.fromLTRB(22.w, 0, 22.w, 12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 11.5,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: AppText(
                                    text: widget.story.title,
                                    overflow: TextOverflow.visible,
                                    style: AppTextStyles.sfProDisplayBold(
                                      fontSize: 22.sp,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ),

                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                spacing: 5,
                                children: [
                                  8.w.verticalSpace,
                                  //* Story page number
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      // if (index < _pages.length - 1) {
                                      _pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                      // }
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 6,
                                      // mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        AppText(
                                          text:
                                              "${provider.currentStoryPageIndex + 1}/${widget.story.pages.length}",
                                          style:
                                              AppTextStyles.sfProDisplaySemibold(
                                                fontSize: 15.sp,
                                                color: Colors.white.withValues(
                                                  alpha: 0.8,
                                                ),
                                              ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 15.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                  //* countdown timer (top of story image)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 20.sp,
                                        color: AppColors.white,
                                      ),
                                      6.w.horizontalSpace,
                                      AppText(
                                        text:
                                            '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                                        style:
                                            AppTextStyles.sfProDisplaySemibold(
                                              fontSize: 18.sp,
                                              color: AppColors.white,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //* 2. Main Scrollable Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.story.pages.length,
                onPageChanged: (index) {
                  Logger.info(
                    "Image $index: ${widget.story.pages[index].imageUrl}",
                  );

                  context.read<StoryProvider>().setCurrentStoryPageIndex(index);
                },
                itemBuilder: (context, index) {
                  final page = widget.story.pages[index];
                  //todo Body Content Container (image and story)
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.fromLTRB(24.w, 10, 24.w, 0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                      ),
                    ),

                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        5.verticalSpace,
                        _StoryImage(
                          imageUrl: page.imageUrl,
                          isFirstPage: index == 0,
                          onFirstImageLoaded: _startCountdownTimer,
                        ),
                        //todo story image ai base images logic
                        // Consumer<StoryProvider>(
                        //   builder: (context, provider, child) {
                        //     //* Safely access image list to avoid RangeError
                        //     // final hasImageForIndex =
                        //     //     provider.createdStoryImagePaths.length >
                        //     //         index &&
                        //     //     provider
                        //     //         .createdStoryImagePaths[index]
                        //     //         .isNotEmpty;
                        //     if (provider.createdStoryImages.isEmpty) {
                        //       return imageShimmer();
                        //     }
                        //     final storyIndex = provider.currentStoryIndex.clamp(
                        //       0,
                        //       provider.createdStoryImages.length - 1,
                        //     );
                        //     final images = provider
                        //         .createdStoryImages[storyIndex]["images"];
                        //     if (images == null || images.isEmpty) {
                        //       return imageShimmer();
                        //     }
                        //     // final imageIndex = index >= images.length
                        //     //     ? images.length - 1
                        //     //     : index;
                        //     final imagePath = images[index];
                        //     if (imagePath.isEmpty) {
                        //       return imageShimmer();
                        //     }

                        //     return CachedNetworkImage(
                        //       height: 280,
                        //       width: double.infinity,
                        //       fit: BoxFit.cover,
                        //       imageUrl: DioClient.baseUrl + imagePath,
                        //       errorWidget: (context, url, error) =>
                        //           imageShimmer(),
                        //       placeholder: (context, url) => imageShimmer(),
                        //       imageBuilder: index == 0
                        //           ? (context, imageProvider) {
                        //               WidgetsBinding.instance
                        //                   .addPostFrameCallback((_) {
                        //                     _startCountdownTimer();
                        //                   });
                        //               return Image(
                        //                 image: imageProvider,
                        //                 fit: BoxFit.cover,
                        //                 height: 280,
                        //                 width: double.infinity,
                        //               );
                        //             }
                        //           : null,
                        //     );
                        //   },
                        //   ),
                        24.h.verticalSpace,
                        //todo story content
                        RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            style: AppTextStyles.sfProDisplayRegular(
                              fontSize: 16.sp,
                              color: AppColors.black.withValues(alpha: 0.8),
                            ),

                            children: _buildTextSpans(
                              widget.story.pages[index].text,
                              AppTextStyles.sfProDisplayRegular(
                                fontSize: 16.sp,
                                color: AppColors.black.withValues(alpha: 0.8),
                              ).copyWith(height: 1.37),
                              AppTextStyles.sfProDisplayBold(
                                fontSize: 16.sp,
                                decoration: TextDecoration.underline,
                                color: AppColors.black,
                              ).copyWith(height: 1.37),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            //todo 3. Custom AppBar (Overlay)
            // Positioned(
            //   top: 0,
            //   left: 0,
            //   right: 0,
            //   child:
            // ),
            // 4. Fixed Bottom Button (Only on last page)
            if (provider.currentStoryPageIndex == widget.story.pages.length - 1)
              SafeArea(
                top: false,

                // bottom: 30.h,
                // left: 24.w,
                // right: 24.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8.w,
                  children: [
                    AppText(
                      text: "Completed Reading?",
                      style: AppTextStyles.sfProDisplaySemibold(
                        fontSize: 14.sp,
                        color: AppColors.black.withValues(alpha: 0.6),
                      ),
                    ),

                    AppFilledButton(
                      margin: EdgeInsets.only(bottom: 20.w),
                      backgroundColor: AppColors.primaryColor,
                      text: "Take Quiz",
                      onTap: () {
                        // provider.setCurrentStoryIndex =
                        //         provider.currentStoryIndex + 1;

                        context.pushNamed(
                          AppRoutes.startQuizScreen.name,
                          extra: {
                            "quizzes": widget.story.quiz ?? <StoryQuiz>[],
                            "storyTitle": widget.story.title ?? "",
                          },
                        );
                        context.read<StoryProvider>().resetStoryPageIndex();
                        _pageController.jumpToPage(0);
                        //     .then((_) {
                        //   if (mounted) {
                        //
                        //   }
                        // });
                      },
                    ),
                  ],
                ),
              )
            else
              AppFilledButton(
                margin: EdgeInsets.only(bottom: 20.w),
                backgroundColor: AppColors.primaryColor,

                text: "See Next Page",
                onTap: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
          ],
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
              style: AppTextStyles
                  .textStyle20Regular, //regular(color: AppColors.black, fontSize: 19.sp),
            ),
            actions: [
              myActionButtonTheme(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<StoryProvider>().clareStoryData();
                  context.goNamed(AppRoutes.homeScreen.name);
                },
                title: "Yes",
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
          color: (title == "Yes") ? AppColors.redColor : AppColors.black,
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
    List<TextSpan> spans = [];
    List<String> parts = text.split('*');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        spans.add(TextSpan(text: parts[i], style: boldStyle));
      } else {
        spans.add(TextSpan(text: parts[i], style: normalStyle));
      }
    }
    return spans;
  }
}

/// Resolves and displays a story page image with retry on error.
class _StoryImage extends StatefulWidget {
  final String imageUrl;
  final bool isFirstPage;
  final VoidCallback? onFirstImageLoaded;

  const _StoryImage({
    required this.imageUrl,
    required this.isFirstPage,
    this.onFirstImageLoaded,
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
      height: 280,
      width: double.infinity,
      fit: BoxFit.cover,
      imageUrl: url,
      httpHeaders: const {
        'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp/1.0)',
      },
      placeholder: (context, url) => _buildShimmer(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      imageBuilder: widget.isFirstPage
          ? (context, imageProvider) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onFirstImageLoaded?.call();
              });
              return Image(
                image: imageProvider,
                fit: BoxFit.cover,
                height: 280,
                width: double.infinity,
              );
            }
          : null,
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
