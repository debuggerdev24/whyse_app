import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';

const Color _dropdownInk = Color(0xFF1C1C1E);
const Color _dropdownMuted = Color(0xFF8E8E93);
const Color _dropdownLine = Color(0xFFE5E5EA);
const Color _dropdownSelectedFill = Color(0xFFE7F4F4);

/// White dropdown field. The open list is a rounded card with the same
/// type, spacing, and teal selection used on the rest of the new screens.
class AppDropdown extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.filled = true,
  });

  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? value;
  final String? hint;

  /// When false, only the row is painted so a parent card can supply the fill.
  final bool filled;

  Future<void> _open(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final overlay = Navigator.of(context).overlay?.context.findRenderObject()
        as RenderBox?;
    if (box == null || overlay == null || !box.hasSize) return;

    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final bottomRight = box.localToGlobal(
      box.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    final rect = Rect.fromPoints(topLeft, bottomRight);

    final selected = await Navigator.of(context).push<String>(
      _AppDropdownRoute(
        anchor: rect,
        items: items,
        selectedValue: value,
      ),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final shown = (value ?? '').trim();
    final hasValue = shown.isNotEmpty;

    final field = Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: _dropdownSelectedFill,
      ),
      child: PopupMenuTheme(
        data: PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 12,
          shadowColor: const Color(0x26000000),
          menuPadding: EdgeInsets.symmetric(vertical: 6.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Builder(
          builder: (menuContext) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: items.isEmpty ? null : () => _open(menuContext),
              child: SizedBox(
                height: 52.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: hasValue ? shown : (hint ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.regular(
                            fontSize: 16,
                            color: hasValue ? _dropdownInk : _dropdownMuted,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22.sp,
                        color: _dropdownInk.withValues(alpha: 0.72),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    if (!filled) return field;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: field,
    );
  }
}

class _AppDropdownRoute extends PopupRoute<String> {
  _AppDropdownRoute({
    required this.anchor,
    required this.items,
    required this.selectedValue,
  });

  final Rect anchor;
  final List<String> items;
  final String? selectedValue;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 140);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: CustomSingleChildLayout(
        delegate: _DropdownMenuLayout(anchor: anchor),
        child: _DropdownMenuCard(items: items, selectedValue: selectedValue),
      ),
    );
  }
}

class _DropdownMenuLayout extends SingleChildLayoutDelegate {
  _DropdownMenuLayout({required this.anchor});

  final Rect anchor;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxHeight = math.min(300.0, constraints.maxHeight - 24);
    return BoxConstraints(
      minWidth: anchor.width,
      maxWidth: anchor.width,
      maxHeight: maxHeight < 44 ? 44 : maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    var top = anchor.bottom + 6;
    if (top + childSize.height > size.height - 12) {
      final above = anchor.top - 6 - childSize.height;
      top = above >= 12 ? above : 12;
    }
    var left = anchor.left;
    if (left + childSize.width > size.width - 12) {
      left = size.width - childSize.width - 12;
    }
    if (left < 12) left = 12;
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(covariant _DropdownMenuLayout oldDelegate) {
    return anchor != oldDelegate.anchor;
  }
}

class _DropdownMenuCard extends StatefulWidget {
  const _DropdownMenuCard({required this.items, required this.selectedValue});

  final List<String> items;
  final String? selectedValue;

  @override
  State<_DropdownMenuCard> createState() => _DropdownMenuCardState();
}

class _DropdownMenuCardState extends State<_DropdownMenuCard> {
  static const double _rowHeight = 44;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final index = widget.items.indexOf(widget.selectedValue ?? '');
      if (index <= 2) return;
      final target = (index - 2) * (_rowHeight + 1);
      final max = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(target.clamp(0, max));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(16.r),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 4),
        shrinkWrap: true,
        itemCount: widget.items.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, thickness: 1, color: _dropdownLine),
        itemBuilder: (context, index) {
          final label = widget.items[index];
          final selected = label == widget.selectedValue;
          return InkWell(
            onTap: () => Navigator.of(context).pop(label),
            child: ColoredBox(
              color: selected ? _dropdownSelectedFill : Colors.white,
              child: SizedBox(
                height: _rowHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: selected
                              ? AppTextStyles.semibold(
                                  fontSize: 15,
                                  color: AppColors.teal,
                                )
                              : AppTextStyles.regular(
                                  fontSize: 15,
                                  color: _dropdownInk,
                                ),
                        ),
                      ),
                      if (selected)
                        Icon(
                          Icons.check_rounded,
                          size: 18.sp,
                          color: AppColors.teal,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
