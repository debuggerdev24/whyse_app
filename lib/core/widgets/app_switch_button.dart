import 'package:redstreakapp/core/utils/app_imports.dart';

/// A custom toggle switch that matches the design:
/// - ON:  orange track + dark (near-black) thumb on the right
/// - OFF: light-gray track + light-gray thumb on the left
///
/// The thumb is intentionally larger than the track height so it
/// overflows on both top and bottom, exactly like the reference image.
class AppSwitchButton extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  // Track dimensions
  final double trackWidth;
  final double trackHeight;

  // Thumb diameter — larger than track height to create the overflow look
  final double thumbDiameter;

  // Colors
  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final Color activeThumbColor;
  final Color inactiveThumbColor;

  // Animation
  final Duration animationDuration;
  final Curve animationCurve;

  const AppSwitchButton({
    super.key,
    required this.value,
    this.onChanged,
    this.trackWidth = 110,
    this.trackHeight = 54,
    this.thumbDiameter = 80,
    this.activeTrackColor = const Color(0xFFE8891A), // orange
    this.inactiveTrackColor = const Color(0xFFE0E0E0), // light gray
    this.activeThumbColor = const Color(0xFF1C1C1C), // near-black
    this.inactiveThumbColor = const Color(0xFFBDBDBD), // medium gray
    this.animationDuration = const Duration(milliseconds: 280),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<AppSwitchButton> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<AppSwitchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _thumbPositionAnim;
  late Animation<Color?> _trackColorAnim;
  late Animation<Color?> _thumbColorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: widget.value ? 1.0 : 0.0,
    );
    _buildAnimations();
  }

  void _buildAnimations() {
    _thumbPositionAnim = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );

    _trackColorAnim =
        ColorTween(
          begin: widget.inactiveTrackColor,
          end: widget.activeTrackColor,
        ).animate(
          CurvedAnimation(parent: _controller, curve: widget.animationCurve),
        );

    _thumbColorAnim =
        ColorTween(
          begin: widget.inactiveThumbColor,
          end: widget.activeThumbColor,
        ).animate(
          CurvedAnimation(parent: _controller, curve: widget.animationCurve),
        );
  }

  @override
  void didUpdateWidget(AppSwitchButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onChanged?.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    // The thumb overflows the track, so the total widget height = thumbDiameter.
    // Track is vertically centred within that height.
    final double totalHeight = widget.thumbDiameter;
    final double totalWidth =
        widget.trackWidth +
        widget.thumbDiameter; // track + one thumb radius on each side

    // How far the thumb centre can travel (from left edge to right edge).
    // At OFF: thumb centre is at thumbDiameter/2
    // At ON:  thumb centre is at totalWidth - thumbDiameter/2
    final double thumbTravelDistance =
        widget.trackWidth - widget.thumbDiameter * 0; // simplified below

    // We'll position with AnimatedBuilder + custom painting for pixel-perfect control.
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final Color trackColor = _trackColorAnim.value!;
          final Color thumbColor = _thumbColorAnim.value!;

          // Thumb X centre:
          //   OFF → left side: thumbDiameter/2
          //   ON  → right side: totalWidth - thumbDiameter/2
          final double thumbCentreX = Tween<double>(
            begin: widget.thumbDiameter / 2,
            end: totalWidth - widget.thumbDiameter / 2,
          ).evaluate(_thumbPositionAnim);

          return SizedBox(
            width: totalWidth,
            height: totalHeight,
            child: CustomPaint(
              painter: _SwitchPainter(
                trackColor: trackColor,
                thumbColor: thumbColor,
                trackWidth: widget.trackWidth,
                trackHeight: widget.trackHeight,
                thumbDiameter: widget.thumbDiameter,
                thumbCentreX: thumbCentreX,
                totalHeight: totalHeight,
                totalWidth: totalWidth,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SwitchPainter extends CustomPainter {
  final Color trackColor;
  final Color thumbColor;
  final double trackWidth;
  final double trackHeight;
  final double thumbDiameter;
  final double thumbCentreX;
  final double totalHeight;
  final double totalWidth;

  _SwitchPainter({
    required this.trackColor,
    required this.thumbColor,
    required this.trackWidth,
    required this.trackHeight,
    required this.thumbDiameter,
    required this.thumbCentreX,
    required this.totalHeight,
    required this.totalWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double trackTop = (totalHeight - trackHeight) / 2;
    final double trackLeft = thumbDiameter / 2;

    // --- Draw track ---
    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;

    final RRect trackRRect = RRect.fromLTRBR(
      trackLeft,
      trackTop,
      trackLeft + trackWidth,
      trackTop + trackHeight,
      Radius.circular(trackHeight / 2),
    );
    canvas.drawRRect(trackRRect, trackPaint);

    // --- Draw thumb (circle) ---
    final Paint thumbPaint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(thumbCentreX, totalHeight / 2),
      thumbDiameter / 2,
      thumbPaint,
    );
  }

  @override
  bool shouldRepaint(_SwitchPainter oldDelegate) =>
      oldDelegate.trackColor != trackColor ||
      oldDelegate.thumbColor != thumbColor ||
      oldDelegate.thumbCentreX != thumbCentreX;
}
