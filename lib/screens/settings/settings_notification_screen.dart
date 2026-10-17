import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';

class SettingsNotificationScreen extends StatelessWidget {
  const SettingsNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Notifications',
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        children: [
          SettingsNavRow(
            title: 'Reminders',
            subtitle: 'Daily Practice Reminders',
            onTap: () =>
                context.pushNamed(AppRoutes.remindersSettingsScreen.name),
          ),
          const SettingsDivider(),
          SettingsNavRow(
            title: 'Friends',
            subtitle: 'Updates from your friends',
            onTap: () => context.pushNamed(
              AppRoutes.friendsNotificationSettingsScreen.name,
            ),
          ),
          const SettingsDivider(),
          SettingsNavRow(
            title: 'Groups',
            subtitle: 'Updates from groups',
            onTap: () => context.pushNamed(
              AppRoutes.groupsNotificationSettingsScreen.name,
            ),
          ),
          const SettingsDivider(),
          SettingsNavRow(title: 'Announcement', onTap: () {}),
          const SettingsDivider(),
        ],
      ),
    );
  }
}
