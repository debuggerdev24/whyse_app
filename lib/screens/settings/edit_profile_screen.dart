import 'dart:io';

import 'package:dartz/dartz.dart' hide State;
import 'package:image_picker/image_picker.dart';
import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_dropdown.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/user_avatar_image.dart';
import 'package:redstreakapp/core/widgets/loading_dialog.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/profile/edit_profile_provider.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';
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

  late String _initialEmail;
  late String _initialPhone;
  late String _initialFirstName;
  late String _initialLastName;
  late String _initialUsername;
  late String _initialCountry;
  late String _initialLanguage;
  late String _initialSocialX;
  late String _initialSocialInstagram;
  late String _initialSocialGoogle;
  String? _sessionVerifiedEmail;
  String? _sessionVerifiedPhone;

  void _onContactFieldChanged() {
    if (mounted) setState(() {});
  }

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
    _initialEmail = profileData.email.trim();
    _initialPhone = _normalizePhoneForE164(profileData.phone);
    _initialFirstName = profileData.firstName.trim();
    _initialLastName = profileData.lastName.trim();
    _initialUsername = profileData.username.trim();
    final edit = context.read<EditProfileProvider>();
    _initialCountry = edit.countryDropdownValue();
    _initialLanguage = edit.languageDropdownValue();
    _initialSocialX = edit.socialX;
    _initialSocialInstagram = edit.socialInstagram;
    _initialSocialGoogle = edit.socialGoogle;
    _emailController.addListener(_onContactFieldChanged);
    _phoneController.addListener(_onContactFieldChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onContactFieldChanged);
    _phoneController.removeListener(_onContactFieldChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _emailsMatch(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  /// Strips separators, maps `00…` → `+…`, and prefixes `+` when the rest is digits only.
  static String _normalizePhoneForE164(String raw) {
    var s = raw.trim();
    s = s.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
    if (s.startsWith('00')) {
      s = '+${s.substring(2)}';
    }
    if (s.isNotEmpty &&
        !s.startsWith('+') &&
        RegExp(r'^[0-9]+$').hasMatch(s)) {
      s = '+$s';
    }
    return s;
  }

  bool _phonesMatch(String a, String b) =>
      _normalizePhoneForE164(a) == _normalizePhoneForE164(b);

  bool get _emailUnchangedFromInitial =>
      _emailsMatch(_emailController.text, _initialEmail);

  bool get _phoneUnchangedFromInitial =>
      _phonesMatch(_phoneController.text, _initialPhone);

  bool get _emailVerifiedForCurrent =>
      _sessionVerifiedEmail != null &&
      _emailsMatch(_emailController.text, _sessionVerifiedEmail!);

  bool get _phoneVerifiedForCurrent =>
      _sessionVerifiedPhone != null &&
      _phonesMatch(_phoneController.text, _sessionVerifiedPhone!);

  bool _profileIsDirty(EditProfileProvider edit) {
    return _firstNameController.text.trim() != _initialFirstName ||
        _lastNameController.text.trim() != _initialLastName ||
        _usernameController.text.trim() != _initialUsername ||
        !_emailsMatch(_emailController.text, _initialEmail) ||
        !_phonesMatch(_phoneController.text, _initialPhone) ||
        edit.countryDropdownValue() != _initialCountry ||
        edit.languageDropdownValue() != _initialLanguage ||
        edit.socialX != _initialSocialX ||
        edit.socialInstagram != _initialSocialInstagram ||
        edit.socialGoogle != _initialSocialGoogle ||
        edit.pendingAvatarFile != null;
  }

  Future<void> _onBack() async {
    final edit = context.read<EditProfileProvider>();
    if (!_profileIsDirty(edit)) {
      if (mounted) context.pop();
      return;
    }
    final valid = _formKey.currentState?.validate() ?? false;
    final emailOk = _emailUnchangedFromInitial || _emailVerifiedForCurrent;
    final phoneOk = _phoneUnchangedFromInitial || _phoneVerifiedForCurrent;
    if (!valid || !emailOk || !phoneOk) {
      if (mounted) context.pop();
      return;
    }
    await _onUpdateProfile();
  }

  Future<void> _onSignOut() async {
    context.read<AuthProvider>().logOutUser(
      onSuccess: () {
        if (!mounted) return;
        context.goNamed(AppRoutes.loginScreen.name);
      },
    );
  }

  Widget _buildEmailVerificationFooter() {
    if (_emailUnchangedFromInitial) return const SizedBox.shrink();
    if (_emailVerifiedForCurrent) {
      return Padding(
        padding: EdgeInsets.only(top: 6.h),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AppText(
            text: 'Verified',
            style: AppTextStyles.semibold(
              fontSize: 13.sp,
              color: AppColors.teal,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: _onVerifyEmail,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: AppText(
            text: 'Verify email',
            style: AppTextStyles.semibold(
              fontSize: 14.sp,
              color: AppColors.teal,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onVerifyEmail() async {
    final email = _emailController.text.trim();
    final err = _validateEmail(email);
    if (err != null) {
      AppToast.error(context, err);
      return;
    }
    if (!mounted) return;
    showLoadingDialog(context);
    late final Either<ApiException, Map<String, dynamic>> result;
    try {
      result =
          await context.read<EditProfileProvider>().requestEmailChange(email);
    } finally {
      if (mounted) context.pop();
    }
    if (!mounted) return;
    final errMsg = result.fold<String?>(
      (e) => e.errorMsg.trim().isEmpty ? 'Could not send verification code' : e.errorMsg,
      (_) => null,
    );
    if (errMsg != null) {
      AppToast.error(context, errMsg);
      return;
    }
    final verified = await context.pushNamed<bool>(
      AppRoutes.verifyProfileContactScreen.name,
      extra: <String, dynamic>{
        'kind': 'email',
        'destination': email,
        'otpLength': 6,
      },
    );
    if (!mounted) return;
    if (verified == true) {
      setState(() => _sessionVerifiedEmail = email);
    }
  }

  Future<void> _onVerifyPhone() async {
    final phone = _normalizePhoneForE164(_phoneController.text);
    final err = _validatePhoneField(phone);
    if (err != null) {
      AppToast.error(context, err);
      return;
    }
    if (!mounted) return;
    showLoadingDialog(context);
    late final Either<ApiException, Map<String, dynamic>> result;
    try {
      result =
          await context.read<EditProfileProvider>().requestPhoneChange(phone);
    } finally {
      if (mounted) context.pop();
    }
    if (!mounted) return;
    final errMsg = result.fold<String?>(
      (e) => e.errorMsg.trim().isEmpty ? 'Could not send verification code' : e.errorMsg,
      (_) => null,
    );
    if (errMsg != null) {
      AppToast.error(context, errMsg);
      return;
    }
    final verified = await context.pushNamed<bool>(
      AppRoutes.verifyProfileContactScreen.name,
      extra: <String, dynamic>{
        'kind': 'phone',
        'destination': phone,
        'otpLength': 6,
      },
    );
    if (!mounted) return;
    if (verified == true) {
      setState(() {
        _sessionVerifiedPhone = phone;
        if (_phoneController.text.trim() != phone) {
          _phoneController.text = phone;
          _phoneController.selection = TextSelection.collapsed(
            offset: _phoneController.text.length,
          );
        }
      });
    }
  }

  /// International (E.164-style): 7–15 digits after optional `+` (added automatically when omitted).
  String? _validatePhoneField(String? v) {
    final t = _normalizePhoneForE164(v ?? '');
    if (t.isEmpty) {
      return _normalizePhoneForE164(_initialPhone).isEmpty
          ? null
          : 'Please enter your phone number';
    }
    if (!RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(t)) {
      return 'Enter a valid phone number with country code (7–15 digits)';
    }
    return null;
  }

  static String? _validateEmail(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  Future<void> _onUpdateProfile() async {
    final edit = context.read<EditProfileProvider>();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final emailOk =
        _emailUnchangedFromInitial || _emailVerifiedForCurrent;
    final phoneOk =
        _phoneUnchangedFromInitial || _phoneVerifiedForCurrent;
    if (!emailOk || !phoneOk) {
      final String msg;
      if (!emailOk && !phoneOk) {
        msg = 'Please verify email and phone number first';
      } else if (!emailOk) {
        msg = 'Please verify email';
      } else {
        msg = 'Please verify phone number';
      }
      AppToast.error(context, msg);
      return;
    }

    edit.firstName = _firstNameController.text;
    edit.lastName = _lastNameController.text;
    edit.username = _usernameController.text;
    edit.email = _emailController.text.trim();
    edit.phone = _normalizePhoneForE164(_phoneController.text);

    showLoadingDialog(context);
    final result = await edit.submitUpdate();
    if (!mounted) return;
    context.pop();

    await result.fold<Future<void>>(
      (err) async {
        final msg = err.errorMsg.trim();
        AppToast.error(
          context,
          msg.isEmpty ? 'Could not update your profile. Please try again' : msg,
        );
      },
      (raw) async {
        final profile = context.read<ProfileProvider>();
        await profile.getProfile();
        if (!mounted) return;
        if (profile.getProfileState == DataState.failed) {
          final data = raw['data'];
          if (data is Map<String, dynamic>) {
            profile.applyProfileAfterUpdate(data);
          }
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
    if (!RegExp(r"^[a-zA-Z0-9\s'-]+$").hasMatch(t)) {
      return 'Use letters, numbers, spaces, hyphens, or apostrophes only';
    }
    return null;
  }

  static String? _validateLastName(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please enter your last name';
    if (t.length > 50) return 'Last name must be at most 50 characters';
    if (!RegExp(r"^[a-zA-Z0-9\s'-]+$").hasMatch(t)) {
      return 'Use letters, numbers, spaces, hyphens, or apostrophes only';
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
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    const fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide.none,
    );

    return Scaffold(
      backgroundColor: settingsPageColor,
      body: Consumer2<EditProfileProvider, AuthProvider>(
          builder: (context, provider, auth, child) {
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, top + 6, 16, 4),
                    child: SizedBox(
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GlassIconButton(
                              size: 44,
                              onTap: () {
                                _onBack();
                              },
                              child: Icon(
                                Icons.chevron_left_rounded,
                                size: 28,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          AppText(
                            text: 'Edit Profile',
                            style: AppTextStyles.bold(
                              fontSize: 18,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                                        color: AppColors.teal,
                                        width: 2,
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
                              hintText: 'First name',
                              validator: _validateFirstName,
                              border: fieldBorder,
                            ),
                          ),
                          14.verticalSpace,
                          _FieldBlock(
                            label: 'Last Name',
                            child: AppTextField(
                              controller: _lastNameController,
                              hintText: 'Last name',
                              validator: _validateLastName,
                              border: fieldBorder,
                            ),
                          ),
                          14.verticalSpace,
                          _FieldBlock(
                            label: 'Username',
                            child: AppTextField(
                              controller: _usernameController,
                              hintText: 'username',
                              prefixText: '@',
                              validator: _validateUsername,
                              border: fieldBorder,
                            ),
                          ),
                          14.verticalSpace,
                          _FieldBlock(
                            label: 'Email',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppTextField(
                                  controller: _emailController,
                                  hintText: 'Email',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                  border: fieldBorder,
                                ),
                                _buildEmailVerificationFooter(),
                              ],
                            ),
                          ),
                          14.verticalSpace,
                          _FieldBlock(
                            label: 'Phone',
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    validator: _validatePhoneField,
                                    cursorColor: AppColors.black,
                                    style: AppTextStyles.regular(
                                      fontSize: 16,
                                      color: AppColors.black,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Phone',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: GestureDetector(
                                    onTap:
                                        (_phoneUnchangedFromInitial &&
                                                provider.phoneVerified) ||
                                            _phoneVerifiedForCurrent
                                        ? null
                                        : _onVerifyPhone,
                                    child: AppText(
                                      text:
                                          (_phoneUnchangedFromInitial &&
                                                  provider.phoneVerified) ||
                                              _phoneVerifiedForCurrent
                                          ? 'Verified'
                                          : 'Verify',
                                      style: AppTextStyles.semibold(
                                        fontSize: 15,
                                        color: AppColors.teal,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          16.verticalSpace,
                          AppText(
                            text: 'Social Accounts',
                            style: AppTextStyles.bold(
                              fontSize: 16,
                              color: AppColors.black,
                            ),
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
                    padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 12),
                    child: GestureDetector(
                      onTap: auth.isLogOutLoading ? null : _onSignOut,
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: settingsSignOut,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: auth.isLogOutLoading
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
                    ),
                  ),
                ],
              ),
            );
          },
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
                          backgroundColor: AppColors.buttonBackground,
                          foregroundColor: AppColors.onFill,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: AppText(
                          text: 'Save',
                          style: AppTextStyles.semibold(
                            fontSize: 16.sp,
                            color: AppColors.onFill,
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
        AppText(
          text: label,
          style: AppTextStyles.medium(
            fontSize: 14,
            color: AppColors.black,
          ),
        ),
        8.verticalSpace,
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: child,
        ),
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
    final trimmed = value.trim();
    final empty = trimmed.isEmpty;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              SizedBox(width: 44, child: Center(child: leading)),
              Container(width: 1, height: 22, color: const Color(0xFFE5E5EA)),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  text: empty ? 'Add link' : trimmed,
                  style: AppTextStyles.regular(
                    fontSize: 15,
                    color: empty
                        ? AppColors.muted
                        : AppColors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
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
    return AppDropdown(
      filled: false,
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}
