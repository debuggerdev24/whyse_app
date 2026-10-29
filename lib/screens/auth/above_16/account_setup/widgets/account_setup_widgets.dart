import 'package:redstreakapp/core/constants/app_constants.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_dropdown.dart';

Color get accountSetupBackground => AppColors.backgroundColor;
Color get accountSetupInk => AppColors.black;
Color get accountSetupMuted => AppColors.muted;

class AccountSetupHeader extends StatelessWidget {
  const AccountSetupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, top + 8, 20, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AppText(
          text: 'Account Setup',
          style: AppTextStyles.bold(fontSize: 32, color: accountSetupInk),
        ),
      ),
    );
  }
}

class AccountSetupBotBubble extends StatelessWidget {
  const AccountSetupBotBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 0.86.sw),
        child: _BubbleShell(
          color: AppColors.surface,
          alignEnd: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: 'Chat Assistant',
                style: AppTextStyles.semibold(
                  fontSize: 14,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(height: 6),
              _BoldAwareText(
                text: text,
                style: AppTextStyles.regular(
                  fontSize: 15,
                  color: accountSetupInk,
                ).copyWith(height: 1.35),
                boldStyle: AppTextStyles.bold(
                  fontSize: 15,
                  color: accountSetupInk,
                ).copyWith(height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountSetupUserBubble extends StatelessWidget {
  const AccountSetupUserBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 0.72.sw),
        child: _BubbleShell(
          color: AppColors.buttonBackground,
          alignEnd: true,
          child: AppText(
            text: text,
            style: AppTextStyles.regular(
              fontSize: 15,
              color: AppColors.onFill,
            ).copyWith(height: 1.35),
          ),
        ),
      ),
    );
  }
}

class _BubbleShell extends StatelessWidget {
  const _BubbleShell({
    required this.color,
    required this.alignEnd,
    required this.child,
  });

  final Color color;
  final bool alignEnd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
        Padding(
          padding: EdgeInsets.only(left: alignEnd ? 0 : 18, right: alignEnd ? 18 : 0),
          child: CustomPaint(
            size: const Size(14, 8),
            painter: _TailPainter(color: color, pointRight: alignEnd),
          ),
        ),
      ],
    );
  }
}

class _TailPainter extends CustomPainter {
  const _TailPainter({required this.color, required this.pointRight});

  final Color color;
  final bool pointRight;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointRight) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(0, size.height)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TailPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pointRight != pointRight;
  }
}

class _BoldAwareText extends StatelessWidget {
  const _BoldAwareText({
    required this.text,
    required this.style,
    required this.boldStyle,
  });

  final String text;
  final TextStyle style;
  final TextStyle boldStyle;

  @override
  Widget build(BuildContext context) {
    final parts = text.split('**');
    if (parts.length == 1) {
      return AppText(text: text, style: style);
    }

    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < parts.length; i++)
            TextSpan(
              text: parts[i],
              style: i.isOdd ? boldStyle : style,
            ),
        ],
      ),
    );
  }
}

class AccountSetupDropdownField extends StatelessWidget {
  const AccountSetupDropdownField({
    super.key,
    required this.hint,
    required this.items,
    this.value,
    required this.onChanged,
  });

  final String hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final wide = hint.length > 18;
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: wide ? 0.72.sw : 0.55.sw,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E4E8)),
          ),
          child: AppDropdown(
            hint: hint,
            items: items,
            value: value,
            filled: false,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class AccountSetupReadingPills extends StatelessWidget {
  const AccountSetupReadingPills({
    super.key,
    required this.options,
    required this.onSelected,
    this.selected,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final option in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => onSelected(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: option == selected ? AppColors.teal : AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: option == selected
                        ? AppColors.teal
                        : AppColors.divider,
                  ),
                ),
                child: AppText(
                  text: option,
                  style: AppTextStyles.semibold(
                    fontSize: 15,
                    color: option == selected ? AppColors.onFill : accountSetupInk,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AccountSetupInterestChip extends StatelessWidget {
  const AccountSetupInterestChip({
    super.key,
    required this.label,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.teal : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Row(
          children: [
            _AccountSetupChipIcon(path: iconPath, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                text: label,
                style: AppTextStyles.semibold(
                  fontSize: 16,
                  color: accountSetupInk,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AccountSetupTopicChip extends StatelessWidget {
  const AccountSetupTopicChip({
    super.key,
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isSelected ? AppColors.teal : const Color(0xFFE4E4E4),
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AccountSetupTopicThumb(
                imagePath: imagePath,
                label: label,
                size: 22,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: AppText(
                  text: label,
                  style: AppTextStyles.semibold(
                    fontSize: 15,
                    color: accountSetupInk,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountSetupTopicThumb extends StatelessWidget {
  const _AccountSetupTopicThumb({
    required this.imagePath,
    required this.label,
    required this.size,
  });

  final String imagePath;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _topicFallbackIcon(label, size),
        ),
      );
    }

    if (imagePath.endsWith('.svg')) {
      return SizedBox(
        width: size,
        height: size,
        child: SvgIcon(imagePath, size: size),
      );
    }

    return Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => _topicFallbackIcon(label, size),
    );
  }

  Widget _topicFallbackIcon(String label, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Icon(Icons.auto_stories_outlined, size: size, color: accountSetupInk),
    );
  }
}

class AccountSetupGoalCard extends StatelessWidget {
  const AccountSetupGoalCard({
    super.key,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.teal : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: title,
              style: AppTextStyles.bold(fontSize: 16, color: accountSetupInk),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              AppText(
                text: description,
                style: AppTextStyles.regular(
                  fontSize: 14,
                  color: accountSetupMuted,
                ).copyWith(height: 1.3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AccountSetupInputBar extends StatelessWidget {
  const AccountSetupInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
    this.sendEnabled = true,
    this.hintText = 'Type here',
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  final bool sendEnabled;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.paddingOf(context).bottom + 10,
      ),
      child: Container(
        height: 54,
        padding: const EdgeInsets.only(left: 18, right: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE6E6EA)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (sendEnabled) onSend();
                },
                style: AppTextStyles.regular(fontSize: 16, color: accountSetupInk),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: AppTextStyles.regular(
                    fontSize: 16,
                    color: accountSetupMuted,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: sendEnabled ? onSend : null,
              child: Opacity(
                opacity: sendEnabled ? 1 : 0.45,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String iconForInterestName(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('adventure')) return AppAssets.adventure;
  if (lower.contains('mystery')) return AppAssets.mystery;
  if (lower.contains('science')) return AppAssets.science;
  if (lower.contains('fantasy')) return AppAssets.fantancy;
  if (lower.contains('history')) return AppAssets.histoy;
  if (lower.contains('nature')) return AppAssets.nature;
  if (lower.contains('comics')) return AppAssets.comics;
  return AppAssets.adventure;
}

class _AccountSetupChipIcon extends StatelessWidget {
  const _AccountSetupChipIcon({required this.path, required this.size});

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (path.endsWith('.svg')) {
      return SvgIcon(path, size: size);
    }

    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) {
        return Icon(Icons.category_outlined, size: size * 0.7, color: AppColors.teal);
      },
    );
  }
}

String imageForTopicTitle(String title) {
  final lower = title.toLowerCase();
  if (lower.contains('space') || lower.contains('planet')) {
    return AppAssets.space;
  }
  if (lower.contains('invention') || lower.contains('technology')) {
    return AppAssets.inventions;
  }
  if (lower.contains('haunted')) return AppAssets.hauntedhouse;
  if (lower.contains('detective') || lower.contains('clue')) {
    return AppAssets.detativeclue;
  }
  if (lower.contains('wizard') || lower.contains('spell')) {
    return AppAssets.wizard;
  }
  if (lower.contains('mythical') || lower.contains('creature')) {
    return AppAssets.dargon;
  }
  return AppAssets.story1;
}

List<String> get accountSetupCountries => AppConstants.countries;

List<String> get accountSetupLanguages => AppConstants.preferredLanguages;
