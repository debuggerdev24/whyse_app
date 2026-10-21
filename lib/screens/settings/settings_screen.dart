import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/theme/app_theme_provider.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return SettingsScaffold(
      title: 'Settings',
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 12),
        child: Consumer<AuthProvider>(
          builder: (context, provider, _) {
            return GestureDetector(
              onTap: provider.isLogOutLoading
                  ? null
                  : () {
                      provider.logOutUser(
                        onSuccess: () {
                          context.goNamed(AppRoutes.loginScreen.name);
                        },
                      );
                    },
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: settingsSignOut,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: provider.isLogOutLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : AppText(
                        text: 'Sign Out',
                        style: AppTextStyles.semibold(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
        children: [
          const SettingsSectionLabel('Account'),
          const SizedBox(height: 6),
          SettingsNavRow(
            title: 'Preferences',
            onTap: () => context.pushNamed(AppRoutes.preferencesScreen.name),
          ),
          SettingsNavRow(
            title: 'Profile',
            onTap: () => context.pushNamed(AppRoutes.editProfileScreen.name),
          ),
          SettingsNavRow(
            title: 'Notifications',
            onTap: () =>
                context.pushNamed(AppRoutes.settingsNotificationScreen.name),
          ),
          SettingsNavRow(title: 'Curriculum', onTap: () {}),
          SettingsNavRow(
            title: 'Theme',
            subtitle: context.watch<AppThemeProvider>().palette.name,
            onTap: () => context.pushNamed(AppRoutes.themesScreen.name),
          ),
          const SizedBox(height: 6),
          const SettingsDivider(),
          const SizedBox(height: 18),
          const SettingsSectionLabel('Support'),
          const SizedBox(height: 6),
          SettingsNavRow(title: 'Help Centre', onTap: () {}),
          SettingsNavRow(title: 'Feedback', onTap: () {}),
        ],
      ),
    );
  }
}
