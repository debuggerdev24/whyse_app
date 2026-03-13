import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/utils/date_formatter.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/models/home/story_models/story_idea_model.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';
import 'package:redstreakapp/screens/home/widgets/home_section_shimmers.dart';

class IdeasListScreen extends StatelessWidget {
  const IdeasListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SafeArea(
        child: Consumer<StoryProvider>(
          builder: (context, provider, child) {
            final isShimmerRunning = provider.isGenerateStoryIdeasLoading ||
                provider.isGenerateSingleStoryLoading;
            return Stack(
              children: [
                if (isShimmerRunning)
                  HomeSectionShimmer.ideasListScreenShimmer()
                else ...[
                  _buildContent(context, provider),
                ],
                if (!isShimmerRunning)
                  Positioned(
                    top: 12.w,
                    right: 12.w,
                    child: GlassIconButton(
                      onTap: () => context.pop(),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: AppColors.black,
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

  Widget _buildContent(BuildContext context, StoryProvider provider) {
    final storyIdea = provider.storyIdea;
    final ideas = storyIdea?.storyIdeas ?? [];
    final isEmpty = storyIdea == null || ideas.isEmpty;

    if (isEmpty) {
      return _EmptyState(
        onBack: () => context.pop(),
      );
    }

    final topicTitle = storyIdea.topic.title.isNotEmpty
        ? storyIdea.topic.title
        : "Your Story Ideas";
    final topicThumb = storyIdea.topic.thumbnailUrl;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.h.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: AppText(
                  text: "Pick a story to read",
                  style: AppTextStyles.sfProDisplayBold(
                    fontSize: 22.sp,
                    color: AppColors.black,
                  ),
                ),
              ),
              8.h.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: AppText(
                  text: topicTitle,
                  style: AppTextStyles.sfProDisplayMedium(
                    fontSize: 16.sp,
                    color: AppColors.black.withValues(alpha: 0.7),
                  ),
                ),
              ),
              20.h.verticalSpace,
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final idea = ideas[index];
              return _IdeaCard(
                idea: idea,
                topicThumbUrl: topicThumb,
                displayIndex: index + 1,
                onTap: () => _onIdeaTap(context, provider, idea, index),
              );
            },
            childCount: ideas.length,
          ),
        ),
        SliverToBoxAdapter(
          child: 24.h.verticalSpace,
        ),
      ],
    );
  }

  void _onIdeaTap(
    BuildContext context,
    StoryProvider provider,
    StoryIdea idea,
    int listIndex,
  ) {
    if (provider.isGenerateSingleStoryLoading) return;
    provider.setCurrentStoryIndex = listIndex;
    // provider.beginGenerateSingleStoryLoading();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.pushNamed(AppRoutes.storySeriesScreen.name);
      provider.generateSingleStory(
        storyIdeaId: idea.id,
        context: context,
        onSuccess: () {},
        showToast: true,
        insertAtIndex: listIndex,
      );
    });
  }

  void _showLeaveConfirmation({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ZoomIn(
          child: AlertDialog(
            backgroundColor: AppColors.white,
            title: Text(
              "Are you sure you want to quit?",
              style: AppTextStyles.textStyle20Regular,
            ),
            content: Text(
              "You can generate and read the story later.",
              style: AppTextStyles.sfProDisplayRegular(
                fontSize: 14.sp,
                color: AppColors.black.withValues(alpha: 0.7),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.pop();
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
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  "Cancel",
                  style: AppTextStyles.sfProDisplayRegular(
                    color: AppColors.black,
                    fontSize: 17.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onBack;

  const _EmptyState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            80.h.verticalSpace,
            Icon(
              Icons.auto_stories_outlined,
              size: 72.sp,
              color: AppColors.black.withValues(alpha: 0.2),
            ),
            24.h.verticalSpace,
            AppText(
              text: "No story ideas yet",
              textAlign: TextAlign.center,
              style: AppTextStyles.sfProDisplayBold(
                fontSize: 20.sp,
                color: AppColors.black,
              ),
            ),
            12.h.verticalSpace,
            AppText(
              text: "Go back and generate ideas from your reading goal.",
              textAlign: TextAlign.center,
              style: AppTextStyles.sfProDisplayRegular(
                fontSize: 14.sp,
                color: AppColors.black.withValues(alpha: 0.6),
              ),
            ),
            32.h.verticalSpace,
            TextButton(
              onPressed: onBack,
              child: Text(
                "Go back",
                style: AppTextStyles.sfProDisplaySemibold(
                  color: AppColors.teal,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  final StoryIdea idea;
  final String topicThumbUrl;
  final int displayIndex;
  final VoidCallback onTap;

  const _IdeaCard({
    required this.idea,
    required this.topicThumbUrl,
    required this.displayIndex,
    required this.onTap,
  });

  String get _imageUrl {
    final url = idea.thumbnailUrl;
    if (url == null || url.toString().trim().isEmpty) {
      final t = topicThumbUrl.trim();
      if (t.isEmpty) return '';
      return t.startsWith('http') ? t : DioClient.baseUrl + t;
    }
    final s = url.toString().trim();
    return s.startsWith('http') ? s : DioClient.baseUrl + s;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _imageUrl.isEmpty
                        ? Container(
                            color: AppColors.shimmerBaseColor,
                            child: Icon(
                              Icons.auto_stories_outlined,
                              size: 48.sp,
                              color: AppColors.black.withValues(alpha: 0.2),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: _imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.shimmerBaseColor,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.shimmerBaseColor,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.black.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12.w,
                    bottom: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: AppText(
                        text: "Story ${displayIndex.toString().padLeft(2, '0')}",
                        style: AppTextStyles.sfProDisplaySemibold(
                          fontSize: 12.sp,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(16.w),
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: idea.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sfProDisplayBold(
                        fontSize: 17.sp,
                        color: AppColors.black,
                      ),
                    ),
                    8.h.verticalSpace,
                    if (idea.description.trim().isNotEmpty)
                      AppText(
                        text: idea.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sfProDisplayRegular(
                          fontSize: 13.sp,
                          color: AppColors.black.withValues(alpha: 0.65),
                        ),
                      ),
                    8.h.verticalSpace,
                    AppText(
                      text: DateFormatter.formatDateTimeFrom(idea.createdAt),
                      style: AppTextStyles.sfProDisplayRegular(
                        fontSize: 12.sp,
                        color: AppColors.black.withValues(alpha: 0.45),
                      ),
                    ),
                    14.h.verticalSpace,
                    Material(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          alignment: Alignment.center,
                          child: AppText(
                            text: "Read Story",
                            style: AppTextStyles.sfProDisplayBold(
                              fontSize: 14.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: borderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
