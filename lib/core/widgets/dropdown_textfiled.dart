import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_dropdown.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';

class CustomDropDown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const CustomDropDown({
    super.key,
    required this.hint,
    required this.items,
    this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppDropdown(
      hint: hint,
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}

class CustomDropdownField extends StatefulWidget {
  final String label;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: AppColors.orangeColor,
                shape: BoxShape.circle,
              ),
            ),
            8.w.horizontalSpace,
            AppText(
              text: widget.label,
              style: AppTextStyles.textStyle16Semibold,
            ),
          ],
        ),

        Divider(thickness: 0, color: AppColors.black.withValues(alpha: 0.1)),

        6.verticalSpace,

        AppDropdown(
          hint: widget.hint,
          value: selectedValue,
          items: widget.items,
          onChanged: (value) {
            setState(() {
              selectedValue = value;
            });
            widget.onChanged(value);
          },
        ),
      ],
    );
  }
}
