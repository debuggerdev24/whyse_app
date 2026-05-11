import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/user_avatar_image.dart';
import 'package:redstreakapp/core/widgets/loading_dialog.dart';
import 'package:redstreakapp/providers/profile/edit_profile_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/services/profile/profile_service.dart';

enum _SocialKind { x, instagram, google }

extension on _SocialKind {
  String get _dialogTitle => switch (this) {
    _SocialKind.x => 'X (Twitter)',
    _SocialKind.instagram => 'Instagram',
    _SocialKind.google => 'Google',
  };

  String get _dialogHint => switch (this) {
    _SocialKind.x => '@yourname or profile link',
    _SocialKind.instagram => 'Username or profile link',
    _SocialKind.google => 'Handle or profile link',
  };
}

String? _validateSocialLink(_SocialKind kind, String? value) {
  final t = (value ?? '').trim();
  if (t.isEmpty) return null;

  if (t.length > 120) {
    return 'Use at most 120 characters';
  }

  final asUri = Uri.tryParse(t);
  if (asUri != null && (asUri.scheme == 'http' || asUri.scheme == 'https')) {
    return null;
  }

  return switch (kind) {
    _SocialKind.instagram =>
      RegExp(r'^[a-zA-Z0-9._]{1,30}$').hasMatch(t)
          ? null
          : 'Use letters, numbers, dots, and underscores, or paste a full link',
    _SocialKind.x =>
      RegExp(r'^@?[A-Za-z0-9_]{1,30}$').hasMatch(t)
          ? null
          : 'Use @handle (letters, numbers, underscore) or paste a full link',
    _SocialKind.google =>
      RegExp(r'^[a-zA-Z0-9._@+-]{1,50}$').hasMatch(t)
          ? null
          : 'Use a short handle or paste a full Google profile link',
  };
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profileData = context.read<ProfileProvider>().profileData!;
    context.read<EditProfileProvider>().setInitialValues(
      firstName: profileData.firstName,
      lastName: profileData.lastName,
      username: profileData.username,
      avatarUrl: profileData.avatarUrl,
      email: profileData.email,
      phone: profileData.phone,
      phoneVerified: profileData.phoneVerified,
      country: profileData.country,
      preferredLanguage: profileData.preferredLanguage,
      isPrivate: profileData.isPrivate,
      socialAccounts: profileData.socialAccounts,
      interests: profileData.interests,
    );
    _firstNameController.text = profileData.firstName;
    _lastNameController.text = profileData.lastName;
    _usernameController.text = profileData.username;
    _emailController.text = profileData.email;
    _phoneController.text = profileData.phone;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onUpdateProfile() async {
    final edit = context.read<EditProfileProvider>();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    edit.firstName = _firstNameController.text;
    edit.lastName = _lastNameController.text;
    edit.username = _usernameController.text;

    showLoadingDialog(context);
    final result = await edit.submitUpdate();
    if (!mounted) return;
    context.pop();

    result.fold(
      (err) {
        final msg = err.errorMsg.trim();
        AppToast.error(
          context,
          msg.isEmpty ? 'Could not update your profile. Please try again' : msg,
        );
      },
      (raw) {
        final data = raw['data'];
        if (data is Map<String, dynamic>) {
          context.read<ProfileProvider>().applyProfileAfterUpdate(data);
        }
        final message = raw['message']?.toString().trim();
        AppToast.success(
          context,
          message != null && message.isNotEmpty
              ? message
              : 'Profile updated successfully',
        );
        if (context.canPop()) context.pop();
      },
    );
  }

  Future<void> _pickAvatar() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                14.verticalSpace,
                AppText(
                  text: 'Profile photo',
                  style: AppTextStyles.bold(fontSize: 17.sp),
                  textAlign: TextAlign.center,
                ),
                16.verticalSpace,
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                  leading: Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.black,
                  ),
                  title: AppText(
                    text: 'Take photo',
                    style: AppTextStyles.semibold(fontSize: 16.sp),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImageFromSource(ImageSource.camera);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.black,
                  ),
                  title: AppText(
                    text: 'Choose from gallery',
                    style: AppTextStyles.semibold(fontSize: 16.sp),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImageFromSource(ImageSource.gallery);
                  },
                ),
                8.verticalSpace,
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: AppText(
                    text: 'Cancel',
                    style: AppTextStyles.semibold(
                      fontSize: 16.sp,
                      color: AppColors.black.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 88,
      // Lighter iOS path (recommended by image_picker for gallery/camera reliability).
      requestFullMetadata: defaultTargetPlatform != TargetPlatform.iOS,
    );
    if (!mounted || file == null) return;
    context.read<EditProfileProvider>().setPendingAvatar(file);
  }

  Widget _avatarPreview(EditProfileProvider provider) {
    if (provider.pendingAvatarFile != null) {
      return Image.file(
        File(provider.pendingAvatarFile!.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    final url = profileAvatarAbsoluteUrl(provider.avatarUrl);
    if (url.isNotEmpty) {
      return AppNetworkImage(
        imageUrl: url,
        tag: 'EditProfile.avatar',
        width: double.infinity,
        height: double.infinity,
        placeholder: (_) => UserAvatarShimmerFill(size: 86.w),
        errorBuilder: (_, __, ___) =>
            Image.asset(AppAssets.profile, fit: BoxFit.cover),
      );
    }
    return Image.asset(AppAssets.profile, fit: BoxFit.cover);
  }

  Future<void> _openSocialDialog(_SocialKind kind) async {
    final edit = context.read<EditProfileProvider>();
    final initial = switch (kind) {
      _SocialKind.instagram => edit.socialInstagram,
      _SocialKind.x => edit.socialX,
      _SocialKind.google => edit.socialGoogle,
    };

    final result = await showDialog<String?>(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.black.withValues(alpha: 0.4),
      builder: (dialogContext) {
        return _EditSocialLinkDialog(kind: kind, initialValue: initial);
      },
    );

    if (!mounted || result == null) return;

    switch (kind) {
      case _SocialKind.instagram:
        edit.setSocialInstagram(result);
      case _SocialKind.x:
        edit.setSocialX(result);
      case _SocialKind.google:
        edit.setSocialGoogle(result);
    }
  }

  static String? _validateFirstName(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please enter your first name';
    if (t.length > 50) return 'First name must be at most 50 characters';
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(t)) {
      return 'Use letters, spaces, hyphens, or apostrophes only';
    }
    return null;
  }

  static String? _validateLastName(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please enter your last name';
    if (t.length > 50) return 'Last name must be at most 50 characters';
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(t)) {
      return 'Use letters, spaces, hyphens, or apostrophes only';
    }
    return null;
  }

  static String? _validateUsername(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please enter a username';
    if (t.length < 3) return 'Username must be at least 3 characters';
    if (t.length > 30) return 'Username must be at most 30 characters';
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(t)) {
      return 'Use letters, numbers, underscores, or hyphens only';
    }
    return null;
  }

  static String? _validateCountry(String? displayValue) {
    if (displayValue == null ||
        displayValue == EditProfileProvider.countryMenuItems().first) {
      return 'Please select your country';
    }
    return null;
  }

  static String? _validateLanguage(String? displayValue) {
    if (displayValue == null ||
        displayValue == EditProfileProvider.languageMenuItems().first) {
      return 'Please select a preferred language';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.only(left: 18, right: 18),
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
        child: Consumer<EditProfileProvider>(
          builder: (context, provider, child) {
            return Form(
              key: _formKey,
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
                                GestureDetector(
                                  onTap: _pickAvatar,
                                  child: Container(
                                    width: 92.w,
                                    height: 92.w,
                                    padding: EdgeInsets.all(3.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.teal.withValues(
                                          alpha: 0.7,
                                        ),
                                        width: 1.3,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: SizedBox(
                                        width: 86.w,
                                        height: 86.w,
                                        child: _avatarPreview(provider),
                                      ),
                                    ),
                                  ),
                                ),
                                8.verticalSpace,
                                GestureDetector(
                                  onTap: _pickAvatar,
                                  behavior: HitTestBehavior.opaque,
                                  child: AppText(
                                    text: 'Change Avatar',
                                    style: AppTextStyles.semibold(
                                      fontSize: 14,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          22.verticalSpace,
                          _FieldBlock(
                            label: 'First Name',
                            child: AppTextField(
                              controller: _firstNameController,
                              hintText: 'Enter your first name',
                              validator: _validateFirstName,
                            ),
                          ),
                          14.verticalSpace,
                          _FieldBlock(
                            label: 'Last Name',
                            child: AppTextField(
                              controller: _lastNameController,
                              hintText: 'Enter your last name',
                              validator: _validateLastName,
                            ),
                          ),
                          14.verticalSpace,
                          _FieldBlock(
                            label: 'Username',
                            child: AppTextField(
                              controller: _usernameController,
                              hintText: 'Enter your username',
                              validator: _validateUsername,
                            ),
                          ),
                          14.verticalSpace,
                          _FieldBlock(
                            label: 'Email',
                            child: AppTextField(
                              controller: _emailController,
                              hintText: 'Email',
                              readOnly: true,
                              enabled: false,
                            ),
                          ),
                          14.verticalSpace,
                          _FieldBlock(
                            label: 'Phone',
                            child: AppTextField(
                              controller: _phoneController,
                              hintText: 'Phone number',
                              // readOnly: true,
                              // enabled: false,
                            ),
                          ),
                          16.verticalSpace,
                          AppText(
                            text: 'Social accounts',
                            style: AppTextStyles.bold(fontSize: 16),
                          ),
                          10.verticalSpace,
                          _SocialAccountRow(
                            leading: SvgIcon(AppAssets.xLogo, size: 22.sp),
                            value: provider.socialX,
                            onTap: () => _openSocialDialog(_SocialKind.x),
                          ),
                          8.verticalSpace,
                          _SocialAccountRow(
                            leading: SvgIcon(
                              AppAssets.instagramLogo,
                              size: 22.sp,
                            ),
                            value: provider.socialInstagram,
                            onTap: () =>
                                _openSocialDialog(_SocialKind.instagram),
                          ),
                          8.verticalSpace,
                          _SocialAccountRow(
                            leading: SvgIcon(AppAssets.google, size: 22.sp),
                            value: provider.socialGoogle,
                            onTap: () => _openSocialDialog(_SocialKind.google),
                          ),
                          14.verticalSpace,
                          Row(
                            children: [
                              Expanded(
                                child: AppText(
                                  text: 'Private profile',
                                  style: AppTextStyles.bold(fontSize: 16),
                                ),
                              ),
                              Switch.adaptive(
                                value: provider.isPrivate,
                                activeTrackColor: AppColors.teal.withValues(
                                  alpha: 0.55,
                                ),
                                thumbColor: WidgetStateProperty.resolveWith(
                                  (states) => AppColors.white,
                                ),
                                onChanged: provider.setIsPrivate,
                              ),
                            ],
                          ),
                          8.verticalSpace,
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Logger.info('Interests');
                              context.pushNamed(
                                AppRoutes.editInterestsScreen.name,
                              );
                            },
                            child: Row(
                              children: [
                                AppText(
                                  text: 'Interests',
                                  style: AppTextStyles.bold(fontSize: 16),
                                ),
                                5.horizontalSpace,
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          14.verticalSpace,
                          _FieldBlock(
                            label: 'Country',
                            child: FormField<String>(
                              initialValue: provider.countryDropdownValue(),
                              validator: (_) => _validateCountry(
                                provider.countryDropdownValue(),
                              ),
                              builder: (state) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SimpleDropdown(
                                      value: provider.countryDropdownValue(),
                                      items:
                                          EditProfileProvider.countryMenuItems(),
                                      onChanged: (val) {
                                        provider.selectCountry(val);
                                        state.didChange(val);
                                        state.validate();
                                      },
                                    ),
                                    if (state.hasError) ...[
                                      6.verticalSpace,
                                      AppText(
                                        text: state.errorText ?? '',
                                        style: AppTextStyles.medium(
                                          fontSize: 12,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),
                          14.verticalSpace,
                          _FieldBlock(
                            label: 'Preferred Language',
                            child: FormField<String>(
                              initialValue: provider.languageDropdownValue(),
                              validator: (_) => _validateLanguage(
                                provider.languageDropdownValue(),
                              ),
                              builder: (state) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SimpleDropdown(
                                      value: provider.languageDropdownValue(),
                                      items:
                                          EditProfileProvider.languageMenuItems(),
                                      onChanged: (val) {
                                        provider.selectLanguage(val);
                                        state.didChange(val);
                                        state.validate();
                                      },
                                    ),
                                    if (state.hasError) ...[
                                      6.verticalSpace,
                                      AppText(
                                        text: state.errorText ?? '',
                                        style: AppTextStyles.medium(
                                          fontSize: 12,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ],
                                );
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
                      onTap: _onUpdateProfile,
                      text: 'Update Profile',
                      radius: 40,
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EditSocialLinkDialog extends StatefulWidget {
  const _EditSocialLinkDialog({required this.kind, required this.initialValue});

  final _SocialKind kind;
  final String initialValue;

  @override
  State<_EditSocialLinkDialog> createState() => _EditSocialLinkDialogState();
}

class _EditSocialLinkDialogState extends State<_EditSocialLinkDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final kind = widget.kind;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                text: kind._dialogTitle,
                style: AppTextStyles.bold(fontSize: 18.sp),
              ),
              6.verticalSpace,
              AppText(
                text: 'Add or update how others find you on this platform.',
                style: AppTextStyles.medium(
                  fontSize: 13.sp,
                  color: AppColors.black.withValues(alpha: 0.55),
                ),
              ),
              18.verticalSpace,
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _controller,
                  autofocus: true,
                  maxLength: 120,
                  style: AppTextStyles.regular(
                    color: AppColors.black,
                    fontSize: 16.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: kind._dialogHint,
                    counterText: '',
                    hintStyle: AppTextStyles.semibold(
                      fontSize: 15.sp,
                      color: AppColors.black.withValues(alpha: 0.32),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.22),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.22),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.teal.withValues(alpha: 0.85),
                        width: 1.2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.redColor,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.redColor,
                        width: 1,
                      ),
                    ),
                    errorStyle: AppTextStyles.regular(
                      color: AppColors.redColor,
                      fontSize: 12.sp,
                    ),
                  ),
                  validator: (v) => _validateSocialLink(kind, v),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
              22.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.black,
                          side: BorderSide(
                            color: AppColors.black.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: AppText(
                          text: 'Cancel',
                          style: AppTextStyles.semibold(fontSize: 16.sp),
                        ),
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.black,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: AppText(
                          text: 'Save',
                          style: AppTextStyles.semibold(
                            fontSize: 16.sp,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
  const _SocialAccountRow({
    required this.leading,
    required this.value,
    required this.onTap,
  });

  final Widget leading;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final display = value.trim().isEmpty ? '-' : value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.black.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 26.w,
                child: Center(child: leading),
              ),
              8.horizontalSpace,
              Container(
                width: 1,
                height: 20.h,
                color: AppColors.black.withValues(alpha: 0.16),
              ),
              10.horizontalSpace,
              Expanded(
                child: AppText(
                  text: display,
                  style: AppTextStyles.medium(
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22.sp,
                color: AppColors.black.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
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
                    style: AppTextStyles.medium(
                      fontSize: 16,
                      color: AppColors.black,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
