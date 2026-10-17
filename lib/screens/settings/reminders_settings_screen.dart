import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';
import 'package:redstreakapp/screens/settings/widget/text_with_switch.dart';

class RemindersSettingsScreen extends StatefulWidget {
  const RemindersSettingsScreen({super.key});

  @override
  State<RemindersSettingsScreen> createState() =>
      _RemindersSettingsScreenState();
}

class _RemindersSettingsScreenState extends State<RemindersSettingsScreen> {
  bool _practiceReminder = true;
  bool _weeklyProgress = false;

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Reminders',
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        children: [
          TextWithSwitch(
            title: 'Practice Reminder',
            value: _practiceReminder,
            onChanged: (value) {
              setState(() => _practiceReminder = value);
            },
          ),
          const SettingsDivider(),
          TextWithSwitch(
            title: 'Weekly Progress',
            value: _weeklyProgress,
            onChanged: (value) {
              setState(() => _weeklyProgress = value);
            },
          ),
        ],
      ),
    );
  }
}
