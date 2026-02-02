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
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/home/story_models/story_model.dart';
import '../../routes/user_routes.dart';
import '../../services/base_api_service.dart';

class ReadingScreen extends StatefulWidget {
  final Story? story;

  const ReadingScreen({super.key, this.story});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> _pages = [];

  @override
  void initState() {
    super.initState();
    // if (widget.story != null) {
    final content = widget.story!.content;
    _pages = content
        .split('</p>')
        .where((e) => e.trim().isNotEmpty)
        .map((e) => _removeAllHtmlTags(e))
        .toList();
    // } else {
    //   _pages = [
    //     "Dinosaurs lived a very long time ago, even before people were on Earth. They were animals that came in many sizes. Some dinosaurs were as big as houses, while others were small, almost like chickens.",
    //     "They lived in many different places, such as forests, swamps, and even deserts. Dinosaurs ruled the Earth for millions of years.",
    //   ];
    // }
  }

  String _removeAllHtmlTags(String htmlText) {
    // Replace bold tags with * for markdown-style bolding
    String processedText = htmlText
        .replaceAll(RegExp(r'<(strong|b)>', caseSensitive: false), '*')
        .replaceAll(RegExp(r'</(strong|b)>', caseSensitive: false), '*');

    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return processedText.replaceAll(exp, '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        showLeaveStoryConfirmation(context: context);
      },

      child: AppLayout(
        body: Stack(
          children: [
            //todo 1. Background Image (Header)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300.h,
              // Approx height
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      AppAssets.dargon,
                    ), // Using dragon/dinosaur asset
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            //todo 2. Main Scrollable Content
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      //todo Spacer for Header Content
                      160.verticalSpace,

                      //todo Header Text Content (Title)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: "AI Generated Text",
                              style: AppTextStyles.sfProDisplayMedium(
                                fontSize: 14.sp,
                                color: AppColors.white,
                                height: 1.2,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: AppText(
                                    text: widget.story?.title ?? "Dinosaurs",
                                    overflow: TextOverflow.visible,
                                    style: AppTextStyles.sfProDisplayBold(
                                      fontSize: 27.5.sp,
                                      color: Colors.white,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 6.h),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (index < _pages.length - 1) {
                                        _pageController.nextPage(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        AppText(
                                          text: "${index + 1}/${_pages.length}",
                                          style:
                                              AppTextStyles.sfProDisplaySemibold(
                                                fontSize: 14.sp,
                                                color: Colors.white.withValues(
                                                  alpha: 0.8,
                                                ),
                                              ),
                                        ),
                                        18.w.horizontalSpace,
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 14.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      50.verticalSpace,

                      //todo Body Content Container (image and story)
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 15.h,
                          ),
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
                              //todo story image
                              Consumer<StoryProvider>(
                                builder: (context, provider, child) {
                                  if (!provider.isCreateStoryImageLoading &&
                                      !provider.isCreateStoryLoading) {
                                    provider.linkImageToStory(
                                      image: provider.createdStoryImagePath,
                                    );
                                  }
                                  return CachedNetworkImage(
                                    height: 280,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        DioClient.baseUrl +
                                        provider.createdStoryImagePath,
                                    errorWidget: (context, url, error) =>
                                        imageShimmer(),
                                    placeholder: (context, url) =>
                                        imageShimmer(),
                                  );
                                },

                                //     Image.network(
                                //   provider.createdStoryImagePath,
                                //   // widget.story != null &&
                                //   //         widget.story!.images.isNotEmpty
                                //   //     ? "http://167.172.45.71${widget.story!.images.first}"
                                //   //     : "https://via.placeholder.com/350x150",
                                //   width: double.infinity,
                                //   height: 180.h,
                                //   fit: BoxFit.cover,
                                //   loadingBuilder:
                                //       (context, child, loadingProgress) {
                                //         if (loadingProgress == null) return child;
                                //         return ShimmerLoading(
                                //           width: double.infinity,
                                //           height: 180.h,
                                //           borderRadius: 0,
                                //         );
                                //       },
                                //   errorBuilder: (context, error, stackTrace) {
                                //     return Image.asset(
                                //       AppAssets.pterodactylus,
                                //       width: double.infinity,
                                //       height: 180.h,
                                //       fit: BoxFit.cover,
                                //     );
                                //   },
                                // ),
                              ),
                              24.h.verticalSpace,
                              //todo story content
                              RichText(
                                textAlign: TextAlign.justify,
                                text: TextSpan(
                                  style: AppTextStyles.sfProDisplayRegular(
                                    fontSize: 16.sp,
                                    color: AppColors.black.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),

                                  children: _buildTextSpans(
                                    _pages[index],
                                    AppTextStyles.sfProDisplayRegular(
                                      fontSize: 16.sp,
                                      color: AppColors.black.withValues(
                                        alpha: 0.8,
                                      ),
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
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            //todo 3. Custom AppBar (Overlay)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                      Row(
                        children: [
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
                    ],
                  ),
                ),
              ),
            ),

            // 4. Fixed Bottom Button (Only on last page)
            if (_currentIndex == _pages.length - 1)
              Positioned(
                bottom: 30.h,
                left: 24.w,
                right: 24.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      text: "Completed Reading?",
                      style: AppTextStyles.sfProDisplaySemibold(
                        fontSize: 12.sp,
                        color: AppColors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    10.h.verticalSpace,
                    AppFilledButton(
                      fixedSize: Size(348.w, 42.h),
                      backgroundColor: AppColors.yellowColor,
                      text: "Take Quiz",
                      onTap: () {
                        context.pushNamed(
                          AppRoutes.startQuizScreen.name,
                          extra: {
                            "quizzes": widget.story?.quiz ?? <Quiz>[],
                            "storyTitle": widget.story?.title ?? "",
                          },
                        );
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => StartQuizScreen(
                        //       quizzes: widget.story?.quiz ?? [],
                        //       storyTitle: widget.story?.title ?? "",
                        //     ),
                        //   ),
                        // );
                      },
                    ),
                  ],
                ),
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
                onPressed: () async {
                  context.pop(dialogContext);
                  context.goNamed(AppRoutes.homeScreen.name);
                  context.read<StoryProvider>().clareStoryData();
                },
                title: "Yes",
              ),
              myActionButtonTheme(
                onPressed: () {
                  context.pop();
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
    if (widget.story != null) {
      // If using our stripped HTML content which might still have some markers or need processing
      // For now, let's just return the text as is if we don't have our * markers
      // But typically we stripped tags.
    }
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
