import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/widgets/loading_dialog.dart';
import 'package:redstreakapp/providers/profile/edit_profile_provider.dart';

/// OTP step after requesting email or phone change from Edit Profile.
class VerifyProfileContactScreen extends StatefulWidget {
  const VerifyProfileContactScreen({
    super.key,
    required this.kind,
    required this.destination,
    this.otpLength = 6,
  });

  /// `'email'` or `'phone'`
  final String kind;
  final String destination;
  final int otpLength;

  @override
  State<VerifyProfileContactScreen> createState() =>
      _VerifyProfileContactScreenState();
}

class _VerifyProfileContactScreenState extends State<VerifyProfileContactScreen> {
  static const int _resendCooldownSeconds = 60;

  final _otpCtr = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;
  int _resendSecondsLeft = 0;
  Timer? _resendCooldownTimer;

  @override
  void initState() {
    super.initState();
    _resendSecondsLeft = _resendCooldownSeconds;
    _startResendCooldownTicker();
  }

  void _startResendCooldownTicker() {
    _resendCooldownTimer?.cancel();
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_resendSecondsLeft <= 1) {
          _resendCooldownTimer?.cancel();
          _resendCooldownTimer = null;
          _resendSecondsLeft = 0;
        } else {
          _resendSecondsLeft--;
        }
      });
    });
  }

  void _armResendCooldown() {
    _resendCooldownTimer?.cancel();
    setState(() => _resendSecondsLeft = _resendCooldownSeconds);
    _startResendCooldownTicker();
  }

  bool get _resendLocked => _isResending || _resendSecondsLeft > 0;

  String get _resendButtonLabel {
    if (_isResending) return 'Sending…';
    if (_resendSecondsLeft > 0) return 'Re-send in ${_resendSecondsLeft}s';
    return 'Re-send';
  }

  @override
  void dispose() {
    _resendCooldownTimer?.cancel();
    _otpCtr.dispose();
    super.dispose();
  }

  bool get _isEmail => widget.kind == 'email';

  String get _subtitle {
    if (_isEmail) {
      return 'Enter the code sent to\n${widget.destination}';
    }
    return 'Enter the code sent to\n${widget.destination}';
  }

  Future<void> _verify() async {
    final code = _otpCtr.text.trim();
    if (code.length < widget.otpLength) {
      AppToast.error(context, 'Please enter the full verification code');
      return;
    }
    final edit = context.read<EditProfileProvider>();
    setState(() => _isVerifying = true);
    try {
      final result = _isEmail
          ? await edit.verifyEmailChange(
              email: widget.destination,
              otp: code,
            )
          : await edit.verifyPhoneChange(
              phone: widget.destination,
              otp: code,
            );
      if (!mounted) return;
      result.fold(
        (err) {
          AppToast.error(
            context,
            err.errorMsg.trim().isEmpty
                ? 'Verification failed. Please try again.'
                : err.errorMsg,
          );
        },
        (_) {
          AppToast.success(context, 'Verified successfully');
          context.pop(true);
        },
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    if (_isResending) return;
    final edit = context.read<EditProfileProvider>();
    setState(() => _isResending = true);
    try {
      showLoadingDialog(context);
      late final Either<ApiException, Map<String, dynamic>> result;
      try {
        result = _isEmail
            ? await edit.resendEmailOtp(widget.destination)
            : await edit.resendPhoneOtp(widget.destination);
      } finally {
        if (mounted) context.pop();
      }
      if (!mounted) return;
      result.fold(
        (err) {
          AppToast.error(
            context,
            err.errorMsg.trim().isEmpty
                ? 'Could not resend code. Please try again.'
                : err.errorMsg,
          );
        },
        (_) {
          _otpCtr.clear();
          AppToast.success(context, 'A new code has been sent');
          _armResendCooldown();
        },
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  PinTheme _pinTheme({
    TextStyle? textStyle,
    Color? borderColor,
    double borderWidth = 1,
    double borderRadius = 8,
  }) {
    return PinTheme(
      height: 52.h,
      width: 44.w,
      textStyle: textStyle,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Colors.grey,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: AppColors.black,
          ),
          onPressed: () => context.pop(false),
        ),
        centerTitle: true,
        title: Text(
          'Verify ${_isEmail ? 'email' : 'phone'}',
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              20.h.verticalSpace,
              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.textStyle16Semibold,
              ),
              28.h.verticalSpace,
              Pinput(
                controller: _otpCtr,
                length: widget.otpLength,
                separatorBuilder: (_) => 10.w.horizontalSpace,
                defaultPinTheme: _pinTheme(
                  borderColor: AppColors.black.withValues(alpha: 0.25),
                ),
                focusedPinTheme: _pinTheme(
                  textStyle: AppTextStyles.textStyle22Regular,
                  borderColor: AppColors.black.withValues(alpha: 0.45),
                  borderWidth: 2,
                ),
                submittedPinTheme: _pinTheme(
                  textStyle: AppTextStyles.textStyle22Medium,
                  borderColor: Colors.grey.shade400,
                ),
                keyboardType: TextInputType.number,
              ),
              const Spacer(),
              Text(
                'Didn’t receive a code?',
                textAlign: TextAlign.center,
                style: AppTextStyles.semibold(fontSize: 15.sp),
              ),
              AppOutlinedButton(
                text: _resendButtonLabel,
                onTap: _resendLocked ? null : _resend,
                foregroundColor: _resendLocked
                    ? AppColors.black.withValues(alpha: 0.35)
                    : null,
                borderColor: _resendLocked
                    ? AppColors.black.withValues(alpha: 0.2)
                    : null,
                margin: EdgeInsets.only(top: 10.h, bottom: 12.h),
              ),
              AppFilledButton(
                margin: EdgeInsets.only(bottom: 20.h),
                text: _isVerifying ? 'Verifying…' : 'Verify',
                onTap: _isVerifying ? () {} : _verify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
