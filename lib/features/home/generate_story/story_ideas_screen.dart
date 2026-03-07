import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/utils/date_formatter.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/features/home/widgets/home_section_shimmers.dart';
import 'package:redstreakapp/models/home/story_models/story_idea_model.dart';
import 'package:redstreakapp/models/home/story_models/story_model.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';

class StoryIdeasScreen extends StatelessWidget {
  const StoryIdeasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SafeArea(
        child: Consumer<StoryProvider>(
          builder: (context, provider, child) {
            Logger.info("${provider.lessonDuration}");
            if (!context.mounted) return const SizedBox.shrink();
            final storyIdea = provider.storyIdea;
            final isEmpty = storyIdea == null || storyIdea.storyIdeas.isEmpty;
            final ideas = storyIdea?.storyIdeas ?? [];
            final topicTitle =
                (storyIdea != null && storyIdea.topic.title.isNotEmpty)
                ? storyIdea.topic.title
                : "Your Story Ideas";

            final hasStory =
                provider.stories.isNotEmpty &&
                provider.stories.first.pages.isNotEmpty;
            final story = hasStory ? provider.stories.first : null;

            if (provider.isGenerateStoryIdeasLoading) {
              return HomeSectionShimmer.generateStoryIdeasScreenShimmer();
            }
            if (isEmpty) {
              return Center(
                child: AppText(
                  text: "No story ideas yet",
                  style: AppTextStyles.sfProDisplayMedium(
                    fontSize: 16.sp,
                    color: AppColors.black.withValues(alpha: 0.6),
                  ),
                ),
              );
            }

            final durationMinutes = story != null
                ? (story.lessonDuration ?? provider.lessonDuration).clamp(1, 999)
                : 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (story != null && durationMinutes > 0)
                  _ReadingTimerBar(
                    durationMinutes: durationMinutes,
                    story: story,
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (story != null)
                          _StoryViewer(
                            story: story,
                            lessonDuration: provider.lessonDuration,
                          ),
                        10.w.verticalSpace,
                        //* Story Ideas list
                        Padding(
                          padding: EdgeInsets.fromLTRB(24.w, 0.w, 24.w, 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: topicTitle,
                                style: AppTextStyles.sfProDisplayBold(
                                  fontSize: 24.sp,
                                  height: 0,
                                  color: AppColors.black,
                                ),
                              ),
                              8.w.verticalSpace,
                              Row(
                                children: [
                                  _MetaChip(
                                    icon: Icons.menu_book_outlined,
                                    label: "${ideas.length} Ideas",
                                  ),
                                  12.w.horizontalSpace,
                                  _MetaChip(
                                    icon: Icons.access_time,
                                    label: "${provider.lessonDuration} mins",
                                  ),
                                ],
                              ),
                              20.w.verticalSpace,
                              Row(
                                children: [
                                  Expanded(
                                    child: AppFilledButton(
                                      text: "Start Reading",
                                      backgroundColor: AppColors.teal,
                                      onTap: () {
                                        //* navigate to story in next command
                                      },
                                    ),
                                  ),
                                  12.w.horizontalSpace,
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      //* generate more
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      size: 20.sp,
                                      color: AppColors.teal,
                                    ),
                                    label: AppText(
                                      text: "More",
                                      style: AppTextStyles.sfProDisplaySemibold(
                                        fontSize: 14.sp,
                                        color: AppColors.teal,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: AppColors.teal),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                    ),
                                  ),
                                ],
                              ),
                              20.h.verticalSpace,
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
                                      style: AppTextStyles.sfProDisplaySemibold(
                                        fontSize: 16.sp,
                                        color: AppColors.teal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Column(
                            children: List.generate(
                              ideas.length,
                              (index) => _StoryIdeaTile(
                                topicImageUrl: storyIdea.topic.thumbnailUrl,
                                idea: ideas[index],
                                index: index + 1,
                                onTap: () {},
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.w),
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
}

/// Timer bar for story ideas screen: shows total duration and countdown.
/// Starts when screen is shown; restarts with updated duration from API.
/// On completion, navigates to start quiz screen.
class _ReadingTimerBar extends StatefulWidget {
  final int durationMinutes;
  final StoryModel story;

  const _ReadingTimerBar({
    required this.durationMinutes,
    required this.story,
  });

  @override
  State<_ReadingTimerBar> createState() => _ReadingTimerBarState();
}

class _ReadingTimerBarState extends State<_ReadingTimerBar> {
  late int _remainingSeconds;
  Timer? _timer;

  int get _totalSeconds => widget.durationMinutes * 60;

  static String _formatDuration(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = _totalSeconds.clamp(1, 999 * 60);
    if (mounted) setState(() {});
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        _timer = null;
        if (!mounted) return;
        context.pushNamed(
          AppRoutes.startQuizScreen.name,
          extra: {
            'quizzes': widget.story.quiz,
            'storyTitle': widget.story.title,
          },
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _totalSeconds.clamp(1, 999 * 60);
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _ReadingTimerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.durationMinutes != widget.durationMinutes) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      color: AppColors.teal.withValues(alpha: 0.12),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 20.sp, color: AppColors.teal),
          8.w.horizontalSpace,
          AppText(
            text: 'Total: ${widget.durationMinutes} mins',
            style: AppTextStyles.sfProDisplayMedium(
              fontSize: 14.sp,
              color: AppColors.black.withValues(alpha: 0.8),
            ),
          ),
          const Spacer(),
          AppText(
            text: 'Time left: ${_formatDuration(_remainingSeconds)}',
            style: AppTextStyles.sfProDisplaySemibold(
              fontSize: 14.sp,
              color: AppColors.teal,
            ),
          ),
        ],
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
          style: AppTextStyles.sfProDisplayMedium(
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

  const _StoryIdeaTile({
    required this.idea,
    required this.index,
    required this.onTap,
    required this.topicImageUrl,
  });

  String get _imageUrl {
    final url = idea.thumbnailUrl;
    if (url == null || url.toString().isEmpty) return topicImageUrl;
    final s = url.toString();
    return s.startsWith('http') ? s : DioClient.baseUrl + s;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.w),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //* Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: _imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: _imageUrl,
                        width: 120.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildThumbnailPlaceholder(),
                        errorWidget: (_, __, ___) =>
                            _buildThumbnailPlaceholder(),
                      )
                    : _buildThumbnailPlaceholder(),
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
                            style: AppTextStyles.sfProDisplaySemibold(
                              fontSize: 14.sp,
                              color: AppColors.black.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AppText(
                            text: idea.title,
                            style: AppTextStyles.sfProDisplaySemibold(
                              fontSize: 15.sp,
                              color: AppColors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    4.h.verticalSpace,
                    AppText(
                      text: idea.description,
                      style: AppTextStyles.sfProDisplayRegular(
                        fontSize: 13.sp,
                        color: AppColors.black.withValues(alpha: 0.65),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    6.h.verticalSpace,
                    AppText(
                      text: DateFormatter.formatDateTimeFrom(idea.createdAt),
                      style: AppTextStyles.sfProDisplayRegular(
                        fontSize: 12.sp,
                        color: AppColors.black.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),

              5.w.horizontalSpace,
              //* Action Icons
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.info_outline,
                      size: 22.sp,
                      color: AppColors.black.withValues(alpha: 0.5),
                    ),

                    // constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                  ),

                  GestureDetector(
                    onTap: onTap,
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 28.sp,
                      color: AppColors.teal,
                    ),
                    // padding: EdgeInsets.zero,
                    // constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                  ),
                ],
              ),
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
  final int lessonDuration;

  const _StoryViewer({required this.story, required this.lessonDuration});

  @override
  State<_StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<_StoryViewer> {
  int _currentPageIndex = 0;

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
          storyTitle: widget.story.title,
          lessonDuration: widget.lessonDuration,
          isLastPage: isLastPage,
          quiz: widget.story.quiz,
          onStartQuiz: () {
            context.pushNamed(
              AppRoutes.startQuizScreen.name,
              extra: {
                'quizzes': widget.story.quiz,
                'storyTitle': widget.story.title,
              },
            );
          },
          onPrevPage: isFirstPage
              ? null
              : () {
                  setState(() {
                    _currentPageIndex = (_currentPageIndex - 1).clamp(
                      0,
                      pages.length - 1,
                    );
                  });
                },
          onNextPage: isLastPage
              ? null
              : () {
                  setState(() {
                    _currentPageIndex = (_currentPageIndex + 1).clamp(
                      0,
                      pages.length - 1,
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
  final int lessonDuration;
  final bool isLastPage;
  final List<StoryQuiz> quiz;
  final VoidCallback onStartQuiz;
  final VoidCallback? onPrevPage;
  final VoidCallback? onNextPage;

  const _StoryPage({
    required this.page,
    required this.pageIndex,
    required this.totalPages,
    required this.storyTitle,
    required this.lessonDuration,
    required this.isLastPage,
    required this.quiz,
    required this.onStartQuiz,
    this.onPrevPage,
    this.onNextPage,
  });

  static String _resolveImageUrl(String url) {
    final s = url.trim();
    if (s.isEmpty) return '';
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    return DioClient.baseUrl + s;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final heroHeight = width * (9 / 16);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        //* Fixed hero image (Netflix-style “video” area)
        _StoryImage(
          imageUrl: _resolveImageUrl(page.imageUrl),
          height: heroHeight,
          pageLabel: 'Page ${pageIndex + 1} of $totalPages',
        ),
        Container(
          color: AppColors.backgroundColor,
          padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 0.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: storyTitle,
                style: AppTextStyles.sfProDisplayBold(
                  fontSize: 22.sp,
                  color: AppColors.black,
                ),
              ),
              8.w.verticalSpace,
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
                    style: AppTextStyles.sfProDisplayMedium(
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
                    style: AppTextStyles.sfProDisplayMedium(
                      fontSize: 13.sp,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              14.w.verticalSpace,
              if (onPrevPage != null || onNextPage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    children: [
                      if (onPrevPage != null)
                        Expanded(
                          child: AppOutlinedButton(
                            onTap: onPrevPage,
                            borderColor: AppColors.teal,
                            textStyle: AppTextStyles.sfProDisplaySemibold(
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
                                  style: AppTextStyles.sfProDisplaySemibold(
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
                            textStyle: AppTextStyles.sfProDisplaySemibold(
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
                                  style: AppTextStyles.sfProDisplaySemibold(
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
                ),
              // 5.w.verticalSpace,
              AppText(
                text: 'Page ${pageIndex + 1}',
                style: AppTextStyles.sfProDisplaySemibold(
                  fontSize: 14.sp,
                  color: AppColors.teal,
                ),
              ),
              8.h.verticalSpace,
              AppText(
                text: page.text,
                style: AppTextStyles.sfProDisplayRegular(
                  fontSize: 15.sp,
                  color: AppColors.black.withValues(alpha: 0.85),
                ),
              ),
              if (isLastPage) ...[
                32.h.verticalSpace,
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
                        style: AppTextStyles.sfProDisplaySemibold(
                          fontSize: 16.sp,
                          color: AppColors.black,
                        ),
                      ),
                      8.h.verticalSpace,
                      AppText(
                        text: 'Test your understanding with a short quiz.',
                        style: AppTextStyles.sfProDisplayRegular(
                          fontSize: 14.sp,
                          color: AppColors.black.withValues(alpha: 0.7),
                        ),
                      ),
                      16.h.verticalSpace,
                      SizedBox(
                        width: double.infinity,
                        child: AppFilledButton(
                          text: 'Start Quiz',
                          backgroundColor: AppColors.teal,
                          onTap: onStartQuiz,
                        ),
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

  const _StoryImage({
    required this.imageUrl,
    required this.height,
    required this.pageLabel,
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
              progressIndicatorBuilder: (_, __, progress) =>
                  _loadingProgress(height, progress.progress),
              errorWidget: (_, __, ___) => _placeholder(height),
            )
          else
            _placeholder(height),

          //* Page label (e.g. “Page 1 of 3”)
          Align(
            alignment: AlignmentGeometry.bottomLeft,
            child: Container(
              margin: EdgeInsets.all(10.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: AppText(
                text: pageLabel,
                style: AppTextStyles.sfProDisplayMedium(
                  fontSize: 12.sp,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _loadingProgress(double h, double? progress) {
    final value = progress != null ? progress.clamp(0.0, 1.0) : null;
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
              style: AppTextStyles.sfProDisplayMedium(
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
    return Container(
      height: h,
      color: AppColors.lightwhiteColor,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        color: AppColors.black.withValues(alpha: 0.3),
      ),
    );
  }
}
