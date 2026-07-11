import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';

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
    this.contentBottomPadding,
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

  /// Inset below the title / bottom row before the hero edge (vertical).
  final double? contentBottomPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 310.w,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(imageUrl: imageUrl, tag: 'StoryHeroHeader'),
          Padding(
            padding: EdgeInsets.fromLTRB(
              14.w,
              18.w,
              14.w,
              contentBottomPadding ?? 14.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  child: Row(
                    children: [
                      topLeft,
                      const Spacer(),
                      ?topRight,
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: titleStyle),
                          if (titleBottomSpacing != null)
                            SizedBox(height: titleBottomSpacing),
                          ?bottomWidget,
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
