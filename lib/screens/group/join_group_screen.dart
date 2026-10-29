import 'package:pinput/pinput.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/profile/group_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Join Group',
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'Join a group',
              style: AppTextStyles.bold(fontSize: 22, color: settingsInk),
            ),
            SizedBox(height: 6.h),
            AppText(
              text: 'Type the code from your teacher to join your class!',
              style: AppTextStyles.regular(fontSize: 14, color: settingsMuted),
            ),
            SizedBox(height: 22.h),
            LayoutBuilder(
              builder: (context, constraints) {
                const pinLength = 6;
                final gap = 8.w;
                final itemWidth =
                    (constraints.maxWidth - (gap * (pinLength - 1))) /
                    pinLength;
                final pinTheme = PinTheme(
                  width: itemWidth,
                  height: itemWidth,
                  textStyle: AppTextStyles.semibold(
                    fontSize: 18,
                    color: settingsInk,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                );

                return Pinput(
                  controller: _pinController,
                  focusNode: _pinFocusNode,
                  length: pinLength,
                  defaultPinTheme: pinTheme,
                  focusedPinTheme: pinTheme.copyWith(
                    decoration: pinTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.teal, width: 1.4),
                    ),
                  ),
                  submittedPinTheme: pinTheme,
                  separatorBuilder: (_) => SizedBox(width: gap),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value?.length != pinLength) {
                      return 'Please enter valid code';
                    }
                    return null;
                  },
                  onCompleted: (_) => FocusScope.of(context).unfocus(),
                );
              },
            ),
            SizedBox(height: 22.h),
            Selector<GroupProvider, bool>(
              selector: (_, provider) => provider.joinGroupLoading,
              builder: (context, loading, _) {
                return _GroupPillButton(
                  label: 'Join',
                  filled: true,
                  loading: loading,
                  onTap: loading
                      ? null
                      : () {
                          context.read<GroupProvider>().joinGroupByCode(
                            code: _pinController.text.trim(),
                            onSuccess: () {
                              _pinController.clear();
                              AppToast.success(context, 'Joined Successfully');
                              context.read<ProfileProvider>().getGroupsList();
                              context.read<GroupProvider>().getGroupsList();
                              context.pop();
                            },
                            onError: (error) {
                              AppToast.error(context, error);
                            },
                          );
                        },
                );
              },
            ),
            SizedBox(height: 12.h),
            _GroupPillButton(
              label: 'Create Group',
              filled: false,
              onTap: () =>
                  context.pushNamed(AppRoutes.createGroupScreen.name),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupPillButton extends StatelessWidget {
  const _GroupPillButton({
    required this.label,
    required this.filled,
    this.onTap,
    this.loading = false,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.teal : AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: filled
              ? null
              : Border.all(color: AppColors.divider),
        ),
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: filled ? AppColors.onFill : AppColors.teal,
                  strokeWidth: 2,
                ),
              )
            : AppText(
                text: label,
                style: AppTextStyles.semibold(
                  fontSize: 16,
                  color: filled ? AppColors.onFill : settingsInk,
                ),
              ),
      ),
    );
  }
}
