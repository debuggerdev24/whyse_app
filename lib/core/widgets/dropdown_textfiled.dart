import 'package:flutter/material.dart';
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
        AppText(
          text: widget.label,
          style: AppTextStyles.semibold(
            fontSize: 15,
            color: const Color(0xFF1C1C1E),
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: AppDropdown(
            hint: widget.hint,
            value: selectedValue,
            items: widget.items,
            filled: false,
            onChanged: (value) {
              setState(() {
                selectedValue = value;
              });
              widget.onChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
