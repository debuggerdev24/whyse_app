import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/widgets/global_widgets.dart';
import 'package:shimmer/shimmer.dart';

class StoryHeroHeader extends StatelessWidget {
  const StoryHeroHeader({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.topLeft,
    this.topRight,
    this.bottomRight,
    this.height,
    this.titleStyle,
    this.titleBottomSpacing,
    this.bottomWidget,
  });

  final String imageUrl;
  final String title;
  final Widget topLeft;
  final Widget? topRight;
  final Widget? bottomRight;
  final double? height;
  final TextStyle? titleStyle;
  final double? titleBottomSpacing;
  final Widget? bottomWidget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 310.w,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: AppColors.shimmerBaseColor,
                highlightColor: AppColors.shimmerHighlightColor,
                child: Container(color: AppColors.shimmerBaseColor),
              ),
              errorWidget: (context, url, error) => const NoImageFound(),
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
                      topLeft,
                      const Spacer(),
                      if (topRight != null) topRight!,
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: titleStyle),
                            if (titleBottomSpacing != null)
                              SizedBox(height: titleBottomSpacing),
                            if (bottomWidget != null) bottomWidget!,
                          ],
                        ),
                      ),
                      if (bottomRight != null) ...[
                        10.w.horizontalSpace,
                        bottomRight!,
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StoryCircleButton extends StatelessWidget {
  const StoryCircleButton({
    super.key,
    required this.child,
    required this.onTap,
    this.size,
    this.backgroundColor,
  });

  final Widget child;
  final VoidCallback onTap;
  final double? size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? 32.w;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
