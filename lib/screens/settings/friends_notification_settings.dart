import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';
import 'package:redstreakapp/screens/settings/widget/text_with_switch.dart';

class FriendsNotificationSettingsScreen extends StatefulWidget {
  const FriendsNotificationSettingsScreen({super.key});

  @override
  State<FriendsNotificationSettingsScreen> createState() =>
      _FriendsNotificationSettingsScreenState();
}

class _FriendsNotificationSettingsScreenState
    extends State<FriendsNotificationSettingsScreen> {
  bool _friendActivity = true;
  bool _friendRequest = false;

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Friends',
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        children: [
          TextWithSwitch(
            title: 'Friend Activity',
            value: _friendActivity,
            onChanged: (value) {
              setState(() => _friendActivity = value);
            },
          ),
          const SettingsDivider(),
          TextWithSwitch(
            title: 'Friend Request',
            value: _friendRequest,
            onChanged: (value) {
              setState(() => _friendRequest = value);
            },
          ),
        ],
      ),
    );
  }
}
