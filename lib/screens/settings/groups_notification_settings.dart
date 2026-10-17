import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';
import 'package:redstreakapp/screens/settings/widget/text_with_switch.dart';

class GroupsNotificationSettingsScreen extends StatefulWidget {
  const GroupsNotificationSettingsScreen({super.key});

  @override
  State<GroupsNotificationSettingsScreen> createState() => _GroupState();
}

class _GroupState extends State<GroupsNotificationSettingsScreen> {
  bool _topicShared = true;
  bool _joiningGroup = false;

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Groups',
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        children: [
          TextWithSwitch(
            title: 'Topics Shared',
            value: _topicShared,
            onChanged: (value) {
              setState(() => _topicShared = value);
            },
          ),
          const SettingsDivider(),
          TextWithSwitch(
            title: 'Joining Group',
            value: _joiningGroup,
            onChanged: (value) {
              setState(() => _joiningGroup = value);
            },
          ),
        ],
      ),
    );
  }
}
