import 'dart:math' as math;

import 'package:redstreakapp/core/utils/app_imports.dart';

const Color profileViewAllColor = Color(0xFFF6A01A);
const Color profileMintFill = Color(0xFFDDF4F1);

class ProfileDashedAddButton extends StatelessWidget {
  const ProfileDashedAddButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = 64.w;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: const _DashedCirclePainter(color: AppColors.teal),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(Icons.add, color: AppColors.teal, size: 28.sp),
        ),
      ),
    );
  }
}

class ProfileMintButton extends StatelessWidget {
  const ProfileMintButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: profileMintFill,
          borderRadius: BorderRadius.circular(28),
        ),
        child: AppText(
          text: label,
          style: AppTextStyles.semibold(fontSize: 16, color: AppColors.teal),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    const dash = 4.0;
    const gap = 3.5;
    final radius = (size.shortestSide / 2) - 1.2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * math.pi * radius;
    final count = (circumference / (dash + gap)).floor();
    final sweep = (dash / circumference) * 2 * math.pi;
    final gapSweep = (gap / circumference) * 2 * math.pi;
    var start = -math.pi / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    for (var i = 0; i < count; i++) {
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep + gapSweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}
