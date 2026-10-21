import 'package:flutter/widgets.dart';

/// Rebuilds the current screens after a theme change so widgets that read
/// [AppColors] pick up the new palette without resetting navigation.
class ThemeRefresh extends StatefulWidget {
  const ThemeRefresh({super.key, required this.themeId, required this.child});

  final String themeId;
  final Widget child;

  @override
  State<ThemeRefresh> createState() => _ThemeRefreshState();
}

class _ThemeRefreshState extends State<ThemeRefresh> {
  @override
  void didUpdateWidget(ThemeRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeId == widget.themeId) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      void walk(Element element) {
        element.visitChildren((child) {
          if (!child.mounted) return;
          child.markNeedsBuild();
          walk(child);
        });
      }

      walk(context as Element);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
