import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: title,
              style: AppTextStyles.bold(fontSize: 17, color: settingsInk),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: settingsSwitchOn,
            inactiveTrackColor: AppColors.isDark
                ? const Color(0xFF3A4A4C)
                : const Color(0xFFE9E9EB),
            thumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
