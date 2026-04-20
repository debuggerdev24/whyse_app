import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_switch_button.dart';

class TextWithSwitch extends StatelessWidget {
  const TextWithSwitch({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppText(text: title, style: AppTextStyles.bold(fontSize: 16)),
        ),
        AppSwitchButton(
          trackHeight: 12,
          trackWidth: 28,
          thumbDiameter: 22,
          value: value,
          onChanged: onChanged,
        ),
        // CupertinoSwitch(
        //   value: value,
        //   onChanged: onChanged,
        //   activeTrackColor: AppColors.primaryColor,
        //   inactiveTrackColor: const Color(0xFFF1F1F1),
        //   thumbColor: value ? AppColors.black : const Color(0xFFD0D0D0),
        // ),
      ],
    );
  }
}
