import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';

Color get explorePageColor => AppColors.backgroundColor;
Color get exploreTeal => AppColors.teal;

Color parseInterestColor(String raw) {
  var hex = raw.trim();
  if (hex.startsWith('#')) hex = hex.substring(1);
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length == 8) {
    final value = int.tryParse(hex, radix: 16);
    if (value != null) return Color(value);
  }
  return const Color(0xFF8E8E93);
}

class ExploreInterestCard extends StatelessWidget {
  const ExploreInterestCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.fallbackColor,
    required this.onTap,
  });

  final String title;
  final String imageUrl;
  final Color fallbackColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Cover(imageUrl: imageUrl, fallbackColor: fallbackColor),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC000000)],
                  stops: [0.42, 1],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  AppText(
                    text: title,
                    maxLines: 3,
                    style: AppTextStyles.bold(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  10.h.verticalSpace,
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreMediaCard extends StatelessWidget {
  const ExploreMediaCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
    this.fallbackColor = const Color(0xFF8E8E93),
  });

  final String title;
  final String imageUrl;
  final VoidCallback onTap;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _Cover(imageUrl: imageUrl, fallbackColor: fallbackColor),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xD9000000)],
                    stops: [0.45, 1],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 14.h),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: AppText(
                    text: title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExploreSectionHeader extends StatelessWidget {
  const ExploreSectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppText(
            text: title,
            style: AppTextStyles.bold(fontSize: 20, color: AppColors.black),
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: AppText(
                text: 'See all',
                style: AppTextStyles.semibold(
                  fontSize: 15,
                  color: AppColors.orangeColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ExploreModeSwitch extends StatelessWidget {
  const ExploreModeSwitch({
    super.key,
    required this.seriesSelected,
    required this.onChanged,
  });

  final bool seriesSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.accentFill(const Color(0xFFE6E6EB)),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          _ModeChip(
            label: 'Series',
            selected: seriesSelected,
            onTap: () => onChanged(true),
          ),
          _ModeChip(
            label: 'Spark',
            selected: !seriesSelected,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? exploreTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: AppText(
            text: label,
            style: AppTextStyles.bold(
              fontSize: 16,
              color: selected ? Colors.white : AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.imageUrl, required this.fallbackColor});

  final String imageUrl;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return ColoredBox(color: fallbackColor);
    }
    return AppNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      errorCompact: true,
      placeholder: (_) => ColoredBox(color: fallbackColor),
    );
  }
}
