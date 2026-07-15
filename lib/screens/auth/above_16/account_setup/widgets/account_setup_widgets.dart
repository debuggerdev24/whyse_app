import 'package:redstreakapp/core/constants/app_constants.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';

const Color accountSetupBackground = Color(0xFFF5F5F5);
const Color accountSetupInputBg = Color(0xFFEFEFEF);

class AccountSetupHeader extends StatelessWidget {
  const AccountSetupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF28518),
            Color(0xFFF2A94A),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          child: Center(
            child: AppText(
              text: 'Account Setup',
              style: AppTextStyles.bold(
                fontSize: 20.sp,
                color: AppColors.white,
              ),
            ),
          ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(4.w),
          child: Image.asset(AppAssets.robot, fit: BoxFit.contain),
        ),
        SizedBox(width: 10.w),
        Flexible(
          child: Container(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'Chat Assistant',
                  style: AppTextStyles.semiBold(
                    fontSize: 13.sp,
                    color: AppColors.teal,
                  ),
                ),
                SizedBox(height: 6.h),
                _BoldAwareText(
                  text: text,
                  style: AppTextStyles.regular(
                    fontSize: 15.sp,
                    color: AppColors.black,
                  ).copyWith(height: 1.35),
                  boldStyle: AppTextStyles.bold(
                    fontSize: 15.sp,
                    color: AppColors.black,
                  ).copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ),
      ],
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
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.teal,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(4.r),
          ),
        ),
        child: AppText(
          text: text,
          style: AppTextStyles.regular(
            fontSize: 15.sp,
            color: AppColors.white,
          ).copyWith(height: 1.3),
        ),
      ),
    );
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
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 0.82.sw,
        child: Container(
          height: 52.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.black.withValues(alpha: 0.85)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.black,
                size: 22.sp,
              ),
              hint: AppText(
                text: hint,
                style: AppTextStyles.medium(
                  fontSize: 15.sp,
                  color: AppColors.black.withValues(alpha: 0.35),
                ),
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: AppText(
                        text: item,
                        style: AppTextStyles.medium(fontSize: 15.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
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
  });

  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: options
          .map(
            (option) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: GestureDetector(
                onTap: () => onSelected(option),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(999.r),
                    border: Border.all(color: AppColors.teal, width: 1.2),
                  ),
                  child: AppText(
                    text: option,
                    style: AppTextStyles.semiBold(
                      fontSize: 15.sp,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
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
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 0.82.sw),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.teal
                    : AppColors.black.withValues(alpha: 0.08),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _AccountSetupChipIcon(path: iconPath, size: 28.w),
                SizedBox(width: 10.w),
                Expanded(
                  child: AppText(
                    text: label,
                    style: AppTextStyles.semiBold(fontSize: 15.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
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
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 0.82.sw),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.teal
                    : AppColors.black.withValues(alpha: 0.08),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: _AccountSetupTopicThumb(
                    imagePath: imagePath,
                    label: label,
                    size: 32.w,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: AppText(
                    text: label,
                    style: AppTextStyles.semiBold(fontSize: 15.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
      return Image.network(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _topicFallbackIcon(label, size),
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
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _topicFallbackIcon(label, size),
    );
  }

  Widget _topicFallbackIcon(String label, double size) {
    return Container(
      width: size,
      height: size,
      color: AppColors.lighttealcolor,
      alignment: Alignment.center,
      child: AppText(
        text: label.isNotEmpty ? label[0] : '?',
        style: AppTextStyles.bold(fontSize: 14.sp, color: AppColors.teal),
      ),
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
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 0.82.sw,
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.teal
                  : AppColors.black.withValues(alpha: 0.12),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: title,
                style: AppTextStyles.bold(fontSize: 15.sp),
              ),
              if (description.isNotEmpty) ...[
                SizedBox(height: 4.h),
                AppText(
                  text: description,
                  style: AppTextStyles.regular(
                    fontSize: 14.sp,
                    color: AppColors.black.withValues(alpha: 0.75),
                  ).copyWith(height: 1.3),
                ),
              ],
            ],
          ),
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
    this.hintText = 'Type here',
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: accountSetupBackground,
      padding: EdgeInsets.fromLTRB(
        20.w,
        8.h,
        20.w,
        MediaQuery.of(context).padding.bottom + 12.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: accountSetupInputBg,
                borderRadius: BorderRadius.circular(24.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (enabled) onSend();
                },
                style: AppTextStyles.regular(fontSize: 16.sp),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: AppTextStyles.regular(
                    fontSize: 16.sp,
                    color: AppColors.black.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: enabled ? onSend : null,
            child: Opacity(
              opacity: enabled ? 1 : 0.45,
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: const BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: AppColors.white,
                  size: 22.w,
                ),
              ),
            ),
          ),
        ],
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
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.lighttealcolor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.category_outlined, size: size * 0.6, color: AppColors.teal),
        );
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
