import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController(text: 'Stacey');
  final _lastNameController = TextEditingController(text: 'Abrams');
  final _usernameController = TextEditingController(text: '@StaceyAbs21');
  final _emailController = TextEditingController(text: 'debuggerdev.dds@gmail.com');
  final _phoneController = TextEditingController(text: '9548687716');

  String _country = 'India';
  String _language = 'English';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 18),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.pop(),
              child: SvgIcon(AppAssets.backButton, size: 13.sp),
            ),
          ),
        ),
        centerTitle: true,
        title: AppText(
          text: 'Edit Profile',
          style: AppTextStyles.semibold(fontSize: 20),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(
            color: AppColors.black.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 92.w,
                            height: 92.w,
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.teal.withValues(alpha: 0.7),
                                width: 1.3,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(AppAssets.profile, fit: BoxFit.cover),
                            ),
                          ),
                          8.verticalSpace,
                          AppText(
                            text: 'Change Avatar',
                            style: AppTextStyles.semibold(
                              fontSize: 14,
                              color: AppColors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    22.verticalSpace,
                    _FieldBlock(
                      label: 'First Name',
                      child: AppTextField(controller: _firstNameController),
                    ),
                    14.verticalSpace,
                    _FieldBlock(
                      label: 'Last Name',
                      child: AppTextField(controller: _lastNameController),
                    ),
                    14.verticalSpace,
                    _FieldBlock(
                      label: 'Username',
                      child: AppTextField(controller: _usernameController),
                    ),
                    14.verticalSpace,
                    _FieldBlock(
                      label: 'Email',
                      child: AppTextField(controller: _emailController),
                    ),
                    14.verticalSpace,
                    _FieldBlock(
                      label: 'Phone',
                      child: AppTextField(
                        controller: _phoneController,
                        suffix: Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: AppText(
                            text: 'Verify',
                            style: AppTextStyles.semibold(
                              fontSize: 14,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    16.verticalSpace,
                    AppText(
                      text: 'Social Accounts',
                      style: AppTextStyles.bold(fontSize: 16),
                    ),
                    10.verticalSpace,
                    const _SocialAccountRow(
                      icon: Icons.close_rounded,
                      link: 'https://x.com/example',
                    ),
                    8.verticalSpace,
                    const _SocialAccountRow(
                      icon: Icons.camera_alt_outlined,
                      link: 'https://instagram.com/example/aos...',
                    ),
                    8.verticalSpace,
                    const _SocialAccountRow(
                      icon: Icons.g_mobiledata_rounded,
                      link: 'https://google.com/as5dv3a6a2',
                    ),
                    14.verticalSpace,
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: Row(
                        children: [
                          AppText(
                            text: 'Interests',
                            style: AppTextStyles.bold(fontSize: 16),
                          ),
                          5.horizontalSpace,
                          Icon(Icons.arrow_forward_ios_rounded, size: 12.sp),
                        ],
                      ),
                    ),
                    14.verticalSpace,
                    _FieldBlock(
                      label: 'Country',
                      child: _SimpleDropdown(
                        value: _country,
                        items: const ['India', 'United States', 'Canada'],
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            _country = val;
                          });
                        },
                      ),
                    ),
                    14.verticalSpace,
                    _FieldBlock(
                      label: 'Preferred Language',
                      child: _SimpleDropdown(
                        value: _language,
                        items: const ['English', 'Hindi', 'Spanish'],
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            _language = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
              child: AppOutlinedButton(
                onTap: () {},
                text: 'Sign out',
                radius: 40,
                padding: EdgeInsets.symmetric(vertical: 13.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(text: label, style: AppTextStyles.bold(fontSize: 16)),
        8.verticalSpace,
        child,
      ],
    );
  }
}

class _SocialAccountRow extends StatelessWidget {
  const _SocialAccountRow({required this.icon, required this.link});

  final IconData icon;
  final String link;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.black.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: AppColors.black),
          10.horizontalSpace,
          Container(
            width: 1,
            height: 20.h,
            color: AppColors.black.withValues(alpha: 0.16),
          ),
          10.horizontalSpace,
          Expanded(
            child: AppText(
              text: link,
              style: AppTextStyles.medium(fontSize: 14, color: AppColors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleDropdown extends StatelessWidget {
  const _SimpleDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.black.withValues(alpha: 0.12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 22.sp,
            color: AppColors.black.withValues(alpha: 0.72),
          ),
          style: AppTextStyles.medium(fontSize: 16, color: AppColors.black),
          onChanged: onChanged,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: AppText(
                    text: item,
                    style: AppTextStyles.medium(fontSize: 16, color: AppColors.black),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
