import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/utils/date_formatter.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/models/home/story_models/story_summary_model.dart';
import 'package:redstreakapp/screens/home/widgets/home_section_shimmers.dart';

class StoryIdeasHeaderCard extends StatelessWidget {
  final StoryIdeaModel summary;

  const StoryIdeasHeaderCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(28.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: _StoryIdeasArtwork(
              imageUrl: summary.topicThumbnailUrl,
              title: summary.topicTitle,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.30),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: AppText(
                    text: "Story Collection",
                    style: AppTextStyles.sfProDisplaySemibold(
                      fontSize: 12.sp,
                      color: AppColors.white,
                    ),
                  ),
                ),
                78.h.verticalSpace,
                AppText(
                  text: summary.topicTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sfProDisplayBold(
                    fontSize: 28.sp,
                    height: 1.1,
                    color: AppColors.white,
                  ),
                ),
                10.h.verticalSpace,
                if (summary.topicLearningGoal.trim().isNotEmpty)
                  AppText(
                    text: summary.topicLearningGoal,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sfProDisplayMedium(
                      fontSize: 14.sp,
                      height: 1.4,
                      color: AppColors.white.withValues(alpha: 0.84),
                    ),
                  ),
                14.h.verticalSpace,
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: [
                    _HeaderMetaChip(
                      icon: Icons.movie_filter_outlined,
                      label: "${summary.storyIdeas.length} Stories",
                    ),
                    _HeaderMetaChip(
                      icon: Icons.category_outlined,
                      label: summary.topicType.isEmpty
                          ? "Stories"
                          : summary.topicType,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoryIdeaEpisodeCard extends StatelessWidget {
  final StoryIdea story;
  final int index;
  final String topicImageUrl;
  final VoidCallback onTap;

  const StoryIdeaEpisodeCard({
    super.key,
    required this.story,
    required this.index,
    required this.topicImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final createdLabel = _formattedCreatedLabel(story.createdOn);
    final imageUrl = story.thumbnailUrl.trim().isNotEmpty
        ? story.thumbnailUrl
        : topicImageUrl;

    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow:[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: SizedBox(
                    width: double.infinity,
                    height: 150.w,
                    child: _StoryIdeasArtwork(
                      imageUrl: imageUrl,
                      title: story.storyTitle,
                    ),
                  ),
                ),
                10.w.verticalSpace,
                AppText(
                  text: "Story ${index.toString().padLeft(2, '0')}",
                  style: AppTextStyles.sfProDisplaySemibold(
                    fontSize: 12.sp,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
          ),
          14.w.horizontalSpace,
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: story.storyTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sfProDisplayBold(
                    fontSize: 18.sp,
                    height: 1.2,
                    color: AppColors.black,
                  ),
                ),
                8.h.verticalSpace,
                AppText(
                  text: story.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sfProDisplayMedium(
                    fontSize: 14.sp,
                    height: 1.45,
                    color: AppColors.black.withValues(alpha: 0.68),
                  ),
                ),
                10.h.verticalSpace,
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _EpisodeMetaPill(
                      icon: Icons.access_time_rounded,
                      label: createdLabel,
                    ),
                    if (story.language.trim().isNotEmpty)
                      _EpisodeMetaPill(
                        icon: Icons.language_rounded,
                        label: story.language,
                      ),
                  ],
                ),
                14.h.verticalSpace,
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(999),
                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formattedCreatedLabel(String createdOn) {
    final parsedDate = DateTime.tryParse(createdOn);
    if (parsedDate == null) return "Recently added";
    return DateFormatter.formatDateTime(parsedDate.toIso8601String());
  }
}

class StoryIdeasEmptyState extends StatelessWidget {
  const StoryIdeasEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.theaters_outlined, color: AppColors.teal, size: 42.sp),
            14.h.verticalSpace,
            AppText(
              text: "No stories found",
              style: AppTextStyles.sfProDisplayBold(fontSize: 20.sp),
            ),
            8.h.verticalSpace,
            AppText(
              text:
                  "Story ideas will appear here once this topic has episodes ready to read.",
              textAlign: TextAlign.center,
              style: AppTextStyles.sfProDisplayMedium(
                fontSize: 14.sp,
                height: 1.45,
                color: AppColors.black.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: AppColors.white),
          6.w.horizontalSpace,
          AppText(
            text: label,
            style: AppTextStyles.sfProDisplaySemibold(
              fontSize: 12.sp,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EpisodeMetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EpisodeMetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.extealighttealcolor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.teal),
          5.w.horizontalSpace,
          AppText(
            text: label,
            style: AppTextStyles.sfProDisplaySemibold(
              fontSize: 12.sp,
              color: AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryIdeasArtwork extends StatelessWidget {
  final String imageUrl;
  final String title;

  const _StoryIdeasArtwork({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = _resolveImageUrl(imageUrl);
    if (resolvedImageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: resolvedImageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const StoryIdeasImageShimmer(),
        errorWidget: (context, url, error) => _ArtworkFallback(title: title),
      );
    }
    return _ArtworkFallback(title: title);
  }

  String _resolveImageUrl(String url) {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) return "";
    if (trimmedUrl.startsWith("http://") || trimmedUrl.startsWith("https://")) {
      return trimmedUrl;
    }
    return DioClient.baseUrl + trimmedUrl;
  }
}

class _ArtworkFallback extends StatelessWidget {
  final String title;

  const _ArtworkFallback({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bluecolor, AppColors.black, AppColors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Icon(
            Icons.movie_creation_outlined,
            color: AppColors.white.withValues(alpha: 0.88),
            size: 34.sp,
          ),
        ),
      ),
    );
  }
}
