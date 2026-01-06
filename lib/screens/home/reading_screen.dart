import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/widgets/custom_shimmer.dart';
import 'package:redstreakapp/screens/home/start_quiz_screen.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/models/story_models/story_model.dart';

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
    if (widget.story != null) {
      final content = widget.story!.content;
      _pages = content
          .split('</p>')
          .where((e) => e.trim().isNotEmpty)
          .map((e) => _removeAllHtmlTags(e))
          .toList();
    } else {
      _pages = [
        "Dinosaurs lived a very long time ago, even before people were on Earth. They were animals that came in many sizes. Some dinosaurs were as big as houses, while others were small, almost like chickens.",
        "They lived in many different places, such as forests, swamps, and even deserts. Dinosaurs ruled the Earth for millions of years.",
      ];
    }
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
    // final provider = context.watch<HomeProvider>(); // Removing dependency on HomeProvider for content if using story

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Background Image (Header)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300.h, // Approx height
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

          // 2. Main Scrollable Content
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
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Spacer for Header Content
                      SizedBox(height: 150.h),

                      // Header Text Content (Title)
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
                                      fontSize: 32.sp,
                                      color: Colors.white,
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
                                                color: Colors.white.withOpacity(
                                                  0.8,
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

                      24.h.verticalSpace,

                      // Body Content Container
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 32.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              widget.story != null &&
                                      widget.story!.images.isNotEmpty
                                  ? "http://167.172.45.71${widget.story!.images.first}"
                                  : "https://via.placeholder.com/350x150",
                              width: double.infinity,
                              height: 180.h,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return ShimmerLoading(
                                      width: double.infinity,
                                      height: 180.h,
                                      borderRadius: 0,
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  AppAssets.pterodactylus,
                                  width: double.infinity,
                                  height: 180.h,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                            24.h.verticalSpace,

                            RichText(
                              textAlign: TextAlign.justify,
                              text: TextSpan(
                                style: AppTextStyles.sfProDisplayRegular(
                                  fontSize: 16.sp,
                                  color: AppColors.black.withOpacity(0.8),
                                ).copyWith(height: 1.8),
                                children: _buildTextSpans(
                                  _pages[index],
                                  AppTextStyles.sfProDisplayRegular(
                                    fontSize: 16.sp,
                                    color: AppColors.black.withOpacity(0.8),
                                  ).copyWith(height: 1.8),
                                  AppTextStyles.sfProDisplayBold(
                                    fontSize: 16.sp,
                                    decoration: TextDecoration.underline,
                                    color: AppColors.black,
                                  ).copyWith(height: 1.6),
                                ),
                              ),
                            ),
                            100.h.verticalSpace,
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 3. Custom AppBar (Overlay)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlassIconButton(
                      onTap: () => Navigator.pop(context),
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
                      color: AppColors.black.withOpacity(0.6),
                    ),
                  ),
                  10.h.verticalSpace,
                  AppButton(
                    fixedSize: Size(348.w, 42.h),
                    backgroundColor: AppColors.yellowcolor,
                    text: "Take Quiz",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StartQuizScreen(
                            quizzes: widget.story?.quiz ?? [],
                            storyTitle: widget.story?.title ?? "",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
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
              color: Colors.black.withOpacity(0.35),
              borderRadius: borderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
