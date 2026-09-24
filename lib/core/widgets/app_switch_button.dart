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

  // Colors. Null uses the active app palette.
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? activeThumbColor;
  final Color? inactiveThumbColor;

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
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.animationDuration = const Duration(milliseconds: 280),
    this.animationCurve = Curves.easeInOut,
  });

  Color get _activeTrackColor => activeTrackColor ?? AppColors.orangeColor;
  Color get _inactiveTrackColor => inactiveTrackColor ?? AppColors.border;
  Color get _activeThumbColor => activeThumbColor ?? AppColors.onImage;
  Color get _inactiveThumbColor => inactiveThumbColor ?? AppColors.darkGrey;

  @override
  State<AppSwitchButton> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<AppSwitchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _thumbPositionAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: widget.value ? 1.0 : 0.0,
    );
    _thumbPositionAnim = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
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

    // We'll position with AnimatedBuilder + custom painting for pixel-perfect control.
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final Color trackColor = Color.lerp(
            widget._inactiveTrackColor,
            widget._activeTrackColor,
            _controller.value,
          )!;
          final Color thumbColor = Color.lerp(
            widget._inactiveThumbColor,
            widget._activeThumbColor,
            _controller.value,
          )!;

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
