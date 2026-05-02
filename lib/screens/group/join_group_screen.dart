import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:pinput/pinput.dart';
import 'package:redstreakapp/providers/profile/group_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';

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
    return AppLayout(
      appBar: AppBar(
        title: AppText(
          text: "Join Group",
          style: AppTextStyles.semiBold(fontSize: 20.sp),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(color: AppColors.black.withValues(alpha: 0.1), height: 1),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: 'Join a group',
                    style: AppTextStyles.bold(
                      fontSize: 20.sp,
                      color: AppColors.black,
                    ),
                  ),

                  AppText(
                    text: 'Type the code from your teacher to join your class!',
                    style: AppTextStyles.medium(
                      fontSize: 14.sp,
                      color: AppColors.black.withValues(alpha: 0.86),
                    ),
                  ),
                  20.w.verticalSpace,
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const int pinLength = 6;
                      final gap = 8.w;
                      final available = constraints.maxWidth;
                      final itemWidth =
                          (available - (gap * (pinLength - 1))) / pinLength;

                      final pinTheme = PinTheme(
                        width: itemWidth,
                        height: itemWidth,
                        textStyle: AppTextStyles.semibold(
                          fontSize: 16.sp,
                          color: AppColors.black,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                        ),
                      );

                      return Pinput(
                        controller: _pinController,
                        focusNode: _pinFocusNode,
                        length: pinLength,
                        defaultPinTheme: pinTheme,
                        focusedPinTheme: pinTheme.copyWith(
                          decoration: pinTheme.decoration!.copyWith(
                            border: Border.all(
                              color: AppColors.black.withValues(alpha: 0.25),
                            ),
                          ),
                        ),
                        submittedPinTheme: pinTheme.copyWith(
                          decoration: pinTheme.decoration!.copyWith(
                            border: Border.all(
                              color: AppColors.black.withValues(alpha: 0.18),
                            ),
                          ),
                        ),
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
                  Spacer(),
                  Selector<GroupProvider, bool>(
                    selector: (p0, p1) => p1.joinGroupLoading,
                    builder: (context, value, child) => AppFilledButton(
                      text: 'Join',
                      loadingColor: AppColors.white,
                      isLoading: value,
                      onTap: () {
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
                      margin: EdgeInsets.only(top: 24.w),
                      backgroundColor: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
