import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';
import 'package:redstreakapp/screens/settings/widget/text_with_switch.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _soundEffectsEnabled = true;
  bool _hapticFeedbackEnabled = false;

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Preferences',
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        children: [
          TextWithSwitch(
            title: 'Sound Effects',
            value: _soundEffectsEnabled,
            onChanged: (value) {
              setState(() => _soundEffectsEnabled = value);
            },
          ),
          const SettingsDivider(),
          TextWithSwitch(
            title: 'Haptic Feedback',
            value: _hapticFeedbackEnabled,
            onChanged: (value) {
              setState(() => _hapticFeedbackEnabled = value);
            },
          ),
        ],
      ),
    );
  }
}
