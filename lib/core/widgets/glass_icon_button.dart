import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:redstreakapp/core/constants/app_color.dart';

/// Frosted surface used by the bottom bar and the round icon buttons.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.borderRadius,
    required this.child,
  });

  final BorderRadius borderRadius;
  final Widget child;

  BorderRadius get _innerRadius {
    Radius shrink(Radius radius) {
      return Radius.elliptical(
        (radius.x - 1.4).clamp(0, radius.x),
        (radius.y - 1.4).clamp(0, radius.y),
      );
    }

    return BorderRadius.only(
      topLeft: shrink(borderRadius.topLeft),
      topRight: shrink(borderRadius.topRight),
      bottomLeft: shrink(borderRadius.bottomLeft),
      bottomRight: shrink(borderRadius.bottomRight),
    );
  }

  @override
  Widget build(BuildContext context) {
    final edge = AppColors.isDark ? const Color(0xFF8FB4B6) : Colors.white;
    final fill = AppColors.isDark ? const Color(0xFF1A2C2E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(1.4),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            edge.withValues(alpha: AppColors.isDark ? 0.55 : 0.95),
            edge.withValues(alpha: 0.18),
            edge.withValues(alpha: AppColors.isDark ? 0.35 : 0.78),
          ],
          stops: const [0.0, 0.46, 1.0],
        ),
      ),
      child: ClipRRect(
        borderRadius: _innerRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        fill.withValues(alpha: AppColors.isDark ? 0.92 : 0.96),
                        fill.withValues(alpha: AppColors.isDark ? 0.78 : 0.92),
                        fill.withValues(alpha: AppColors.isDark ? 0.88 : 0.94),
                      ],
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const Positioned(
              top: 0,
              left: 18,
              right: 18,
              height: 1,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x00FFFFFF),
                        Color(0xF5FFFFFF),
                        Color(0x00FFFFFF),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// Round icon button with the same glass as the profile control in the tab bar.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.onTap,
    required this.child,
    this.size = 48,
  });

  final VoidCallback onTap;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: GlassSurface(
          borderRadius: BorderRadius.circular(size),
          child: Center(child: child),
        ),
      ),
    );
  }
}
